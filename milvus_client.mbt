// Milvus 客户端的公开入口。
//
// 这层刻意只放跨 target 的东西 —— 模块 `preferred_target = "wasm"`，
// 根包在 wasm / js / native 下都得编得过。
// 真正发请求的实现是 native 专属的，见 `client/native`：
// 它依赖的 `moonrpc/net` 自己声明了 `supported_targets = "native"`。
//
// 根包只做转发，不定义自己的类型，也不暴露 `client/` 的内部结构。
// 用户看到的名字（`Config` / `Client` / `SearchOption`…）都是 `pub type`，
// 换实现时换的是别名，不是用户的代码。

// ---- 连接配置与失败 ----

///|
/// Milvus 连接配置。`address` 形如 `host:port`，不带端口时用默认端口。
pub type Config = @transport.Config

///|
/// 调用失败。上层用 `is_deadline_exceeded(err)` 判断超时，
/// 不用去比对魔法数字。
pub type RpcError = @transport.RpcError

///|
/// gRPC 状态码。
pub type Code = @transport.Code

///|
/// Milvus 默认端口。
pub let default_port : Int = @transport.default_port

///|
/// 默认调用超时。
pub let default_timeout_millis : Int = @transport.default_timeout_millis

///|
/// 最小可用配置。
pub fn with_address(address : String) -> Config {
  @transport.Config::new(address)
}

///|
/// 带上认证 token（Milvus 的 `user:password` 形式）。
pub fn with_token(config : Config, token : String) -> Config {
  config.with_token(token)
}

///|
/// 带上默认库名。
pub fn with_db_name(config : Config, db_name : String) -> Config {
  config.with_db_name(db_name)
}

///|
/// 设定默认调用超时（毫秒）。
pub fn with_timeout_millis(config : Config, timeout_millis : Int) -> Config {
  config.with_timeout_millis(timeout_millis)
}

///|
/// 开/关 gzip。开启后客户端会声明 `grpc-accept-encoding: gzip`，
/// 允许服务端压响应。
pub fn with_gzip(config : Config, enable? : Bool = true) -> Config {
  config.with_gzip(enable~)
}

///|
/// 这次失败是不是超时。
pub fn is_deadline_exceeded(err : RpcError) -> Bool {
  err.is_deadline_exceeded()
}

///|
/// 这次失败能不能重试。
pub fn is_retryable(err : RpcError) -> Bool {
  err.is_retryable()
}

// ---- 客户端 ----

///|
/// 一次 unary 调用的形状。把它留给调用方实现，是为了让 `Client` 能
/// 在 wasm / js 下也编得过（真连 socket 的实现是 native 专属的）。
pub type Unary = @client.Unary

///|
/// 客户端。用 `client/config` 建，或（native 下）用
/// `client/native/connect` 直接建一条真连接。
pub type Client = @client.Client

///|
/// 一次调用失败。`is_transport_failure` / `is_retryable` 用来分流。
pub type ClientError = @client.ClientError

///|
/// 挂上一条已有的连接。
pub fn new_client(config : Config, call : Unary) -> Client {
  @client.Client::new(config, call)
}

///|
/// 客户端持有的配置。
pub fn client_config(client : Client) -> Config {
  client.config()
}

///|
/// 失败是不是出在传输层（可以原样重试的那一类）。
pub fn is_transport_failure(err : ClientError) -> Bool {
  err.is_transport()
}

///|
/// 服务端是否把这次失败标成可重试。
pub fn is_client_error_retryable(err : ClientError) -> Bool {
  err.is_retryable()
}

///|
/// 这次失败是不是超时。
pub fn is_client_error_deadline_exceeded(err : ClientError) -> Bool {
  err.is_deadline_exceeded()
}

///|
/// 服务端错误码；不是服务端拒绝就返回 `@errors.unexpected_code`。
pub fn client_error_code(err : ClientError) -> Int {
  err.code()
}

// ---- 一致性等级 ----

///|
/// Milvus 的一致性等级。
pub type ConsistencyLevel = @client.ConsistencyLevel

///|
/// 上游默认档：`Bounded`。
pub let default_consistency_level : ConsistencyLevel = @client.default_consistency_level

// ---- 集合生命周期 ----

///|
/// 建集合的入参。
pub type CreateCollectionOption = @client.CreateCollectionOption

///|
/// 描述集合的入参。
pub type DescribeCollectionOption = @client.DescribeCollectionOption

///|
/// 删集合的入参。
pub type DropCollectionOption = @client.DropCollectionOption

///|
/// 列集合的入参。
pub type ListCollectionsOption = @client.ListCollectionsOption

///|
/// 集合元信息。
pub type CollectionDescription = @client.CollectionDescription

// ---- 数据面 ----

///|
/// 写入用的一列。
pub type WriteColumn = @client.WriteColumn

///|
/// 写入入参（insert / upsert 共用）。
pub type WriteOption = @client.WriteOption

///|
/// 删除入参。
pub type DeleteOption = @client.DeleteOption

///|
/// 一次写入的结果。
pub type MutationResult = @client.MutationResult

// ---- 检索面 ----

///|
/// 检索入参。
pub type SearchOption = @client.SearchOption

///|
/// 一条命中。
pub type SearchHit = @client.SearchHit

///|
/// 一次检索的结果。
pub type SearchResult = @client.SearchResult

///|
/// 查询入参。
pub type QueryOption = @client.QueryOption

///|
/// 一次查询的结果。
pub type QueryResult = @client.QueryResult
