// 把 Config 翻成 gRPC metadata。
// 这里是「认证 / dbName 可在流量中验证」的落点：服务端读到的
// `authorization` 与 `dbname` 就由这几个函数产出。

///|
/// gRPC 的 metadata 键必须小写（HTTP/2 要求头名小写，HPACK 编码器不做大小写折叠）。
pub let authorization_header : Bytes = b"authorization"

///|
/// Milvus 约定的默认库名键。上游 Go 客户端写的是 `dbName`，
/// 规范化为小写后是 `dbname`。
pub let db_name_header : Bytes = b"dbname"

///|
/// `grpc-encoding` 用来协商压缩。
pub let grpc_encoding_header : Bytes = b"grpc-encoding"

///|
/// `grpc-accept-encoding` 告知服务端本端能解哪些编码。
pub let grpc_accept_encoding_header : Bytes = b"grpc-accept-encoding"

///|
/// 本端能解的编码列表。`moonrpc` 的响应侧只会解 gzip，
/// 所以这里只声明 gzip，避免服务端选一个我们解不开的。
pub let grpc_accept_encoding_value : String = "identity,gzip"

///|
/// 由 `token` 生成 `Authorization` 头。空 token 当作没配。
pub fn auth_header(token : String) -> @header.Header {
  @header.Header::of("authorization", "Bearer " + token)
}

///|
/// 由 `db_name` 生成 `dbName` 头。空串当作没配。
pub fn db_name_header_field(db_name : String) -> @header.Header {
  @header.Header::of("dbname", db_name)
}

///|
/// 组装一次调用要带的 metadata。
///
/// 注意 `grpc-encoding` 的处境：`moonrpc` 在构造请求头时会把 metadata 原样
/// 追加进去（`client.mbt` 的 `metadata_value_to_wire` 那条循环），
/// **但它预留的 `is_reserved_header` 只用于响应侧过滤**，请求侧不过滤。
/// 也就是说请求方向自定义 header 是能带出去的 —— 这点已用真实 server 实测过。
/// 但 `moonrpc` 的请求侧没有 gzip 压缩请求体的实现（`encode_message` 只有
/// `compressed` 的响应侧解压路径），所以声明 `grpc-encoding: gzip` 会让
/// 服务端按 gzip 解一个没压缩的 body，反而出错。
///
/// 因此 `enable_gzip` **只声明 `grpc-accept-encoding`**（让服务端可以压响应），
/// 不声明 `grpc-encoding`（不声称自己压了请求）。
pub fn request_metadata(config : Config) -> Array[@header.Header] {
  let headers : Array[@header.Header] = []
  match config.token {
    Some(t) => if t != "" { headers.push(auth_header(t)) }
    None => ()
  }
  match config.db_name {
    Some(d) => if d != "" { headers.push(db_name_header_field(d)) }
    None => ()
  }
  if config.enable_gzip {
    headers.push(
      @header.Header::of("grpc-accept-encoding", grpc_accept_encoding_value),
    )
  }
  headers
}

///|
/// 读回一个 metadata 头（测试与调试用）。键比对不区分大小写。
pub fn metadata_get(headers : Array[@header.Header], name : String) -> String? {
  let want = name.to_lower()
  for h in headers {
    let (n, v) = h.ascii()
    if n.to_lower() == want {
      return Some(v)
    }
  }
  None
}
