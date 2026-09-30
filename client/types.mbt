// Licensed to the LF AI & Data foundation under one
// or more contributor license agreements. See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership. The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// 移植自 milvus-io/milvus client/milvusclient/{client.go,collection.go,
// write.go,read.go}（Apache-2.0）。
//
// 上游的 `Client` 是一层薄客户端：Option → protobuf 请求 → 发 RPC →
// 响应反序列化，本地不做任何向量计算。这里保持同样的形状。

///|
/// 一次 unary 调用的形状：给路径和已编码的 protobuf body，拿回已解码前的
/// 响应字节。
///
/// 把它抽成函数值而不是直接依赖 `@transport/native`，是因为模块
/// `preferred_target = "wasm"`：`client` 这层必须在 wasm / js 下编得过，
/// 而真连 socket 的实现是 native 专属的（见 `client/native`）。
pub type Unary = async (String, Bytes) -> Bytes raise @transport.RpcError

///|
/// 连到 Milvus 的客户端。
///
/// `config` 只用来取 dbName、超时、metadata 之类的默认值；真正把字
/// 节发出去的是 `call`。
pub struct Client {
  config : @transport.Config
  call : Unary
}

///|
/// 一次调用失败。四种来源分开，是因为上层的处置不一样：
/// 传输问题可以重试，服务端拒绝要看错误码，schema 不合说明本地模型过时，
/// 编解码失败说明客户端有 bug。
pub suberror ClientError {
  Transport(@transport.RpcError)
  Server(@errors.MerError)
  Schema(String)
  Encode(String)
  Decode(String)
}

///|
/// 传输层是否还能用。`Client` 的方法里，只有这一类才值得原样重试。
pub fn ClientError::is_transport(self : ClientError) -> Bool {
  match self {
    Transport(_) => true
    _ => false
  }
}

///|
/// 服务端是否把这次失败标成可重试。
/// 与 `@errors.is_retryable_err` 一致：只看服务端下发的 `retriable`，
/// 不做本地猜测。
pub fn ClientError::is_retryable(self : ClientError) -> Bool {
  match self {
    Transport(err) => err.is_retryable()
    Server(err) => @errors.is_retryable_err(Some(err))
    _ => false
  }
}

///|
/// 这次失败是不是超时。
pub fn ClientError::is_deadline_exceeded(self : ClientError) -> Bool {
  match self {
    Transport(err) => err.is_deadline_exceeded()
    _ => false
  }
}

///|
/// 拿服务端错误码；不是服务端拒绝就返回 `@errors.unexpected_code`。
pub fn ClientError::code(self : ClientError) -> Int {
  match self {
    Server(err) => @errors.error_code(Some(err))
    _ => @errors.unexpected_code
  }
}

///|
/// 底层错误对象，便于上层用 `@errors.same_code` 之类的判等。
pub fn ClientError::server_error(self : ClientError) -> @errors.MerError? {
  match self {
    Server(err) => Some(err)
    _ => None
  }
}

///|
pub impl Show for ClientError with fn to_string(self) {
  match self {
    Transport(err) => "transport: " + err.to_string()
    Server(err) => "server: " + err.to_string()
    Schema(msg) => "schema: " + msg
    Encode(msg) => "encode: " + msg
    Decode(msg) => "decode: " + msg
  }
}

///|
/// 挂上一条已有的连接。`call` 通常是 `@native.Client::unary` 的部分应用。
pub fn Client::new(config : @transport.Config, call : Unary) -> Client {
  { config, call, }
}

///|
/// 客户端持有的配置。
pub fn Client::config(self : Client) -> @transport.Config {
  self.config
}

///|
/// 把服务端 `common.Status` 翻成 `ClientError`。
///
/// Milvus 的老式 RPC 把错误放在响应体的 `status` 里而不是 gRPC 状态里，
/// 所以每个响应都要过一道这个检查。OK 返回 `None`。
fn check_status(status : @common.Status?) -> ClientError? {
  if @errors.is_ok(status) {
    return None
  }
  match @errors.from_status(status.unwrap()) {
    Some(err) => Some(Server(err))
    None => Some(Server(@errors.err_unexpected()))
  }
}

///|
/// 发一次调用并解码响应。
///
/// 这里的泛型约束是生成物给的：请求要能 `Write` + `Sized`（编码），
/// 响应要能 `Read` + `Default`（解码）。
async fn[Req : @lib.Write, Resp : @lib.Read + Default] Client::call_service(
  self : Client,
  path : String,
  request : Req,
) -> Resp raise ClientError {
  let body = encode_request(request)
  let response = (self.call)(path, body) catch {
    err => raise ClientError::Transport(err)
  }
  decode_response(response)
}

///|
fn[Req : @lib.Write] encode_request(request : Req) -> Bytes raise ClientError {
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(request, buf) catch {
    err => raise ClientError::Encode(err.to_string())
  }
  buf.to_bytes()
}

///|
fn[M : @lib.Read + Default] decode_response(
  bytes : Bytes,
) -> M raise ClientError {
  if bytes.length() == 0 {
    // 空 body 也是合法的「默认消息」，gRPC 允许；生成物的 Default 正好接住。
    return Default::default()
  }
  let reader = @lib.BytesReader::from_bytes(bytes)
  @lib.Read::read_with_limit(@lib.LimitedReader::LimitedReader(reader)) catch {
    err => raise ClientError::Decode(err.to_string())
  }
}

///|
/// `@column.ColumnError` 的文本。它在 `@column` 里只 derive 了 `Debug`，
/// 包外拿不到内部字符串，所以这里按构造器解出来。
pub fn column_error_message(err : @column.ColumnError) -> String {
  match err {
    DataTypeNotMatch(msg) => msg
    UnsupportedType(msg) => msg
    IndexOutOfRange(msg) => msg
    MalformedPayload(msg) => msg
    NullValue(msg) => msg
  }
}

///|
/// `@column.ColumnValue` 的类型名。`@column` 没有把它暴露出来，
/// 而包外的报错文本需要一个能定位的说法。
pub fn column_value_type_name(value : @column.ColumnValue) -> String {
  match value {
    Bool(_) => "Bool"
    Int8(_) => "Int8"
    Int16(_) => "Int16"
    Int32(_) => "Int32"
    Int64(_) => "Int64"
    Float(_) => "Float"
    Double(_) => "Double"
    String(_) => "String"
    VarChar(_) => "VarChar"
    Text(_) => "Text"
    Timestamptz(_) => "Timestamptz"
    Json(_) => "Json"
    Geometry(_) => "Geometry"
    Array(_) => "Array"
    FloatVector(_, _) => "FloatVector"
    Float16Vector(_, _) => "Float16Vector"
    BFloat16Vector(_, _) => "BFloat16Vector"
    BinaryVector(_, _) => "BinaryVector"
    Int8Vector(_, _) => "Int8Vector"
    SparseFloatVector(_) => "SparseFloatVector"
  }
}
