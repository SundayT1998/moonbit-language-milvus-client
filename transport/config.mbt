// Milvus 连接配置：认证 / 默认 DB / 超时 / 压缩。
// 纯逻辑，不碰 socket，所有 target 都能用；
// 真正的借道由 `client_native.mbt` 落到 `moonrpc/net` 上。

///|
/// Milvus 连接参数。对应上游 `client.Config` 里与本 Issue 相关的那几个字段。
///
/// - `address` 形如 `host:port`
/// - `token` 走 `Authorization: Bearer <token>`
/// - `db_name` 走 `dbName` metadata
/// - `timeout_millis` 既是默认调用超时，也用于建连
pub(all) struct Config {
  address : String
  token : String?
  db_name : String?
  timeout_millis : Int
  enable_gzip : Bool
}

///|
/// Milvus 默认端口。上游 `client` 用的也是它。
pub let default_port : Int = 19530

///|
/// 默认调用超时：Milvus 上游 Go 客户端默认不限，这里取 30s 作为有界默认。
pub let default_timeout_millis : Int = 30_000

///|
/// 只给地址的最小配置。
pub fn Config::new(address : String) -> Config {
  {
    address,
    token: None,
    db_name: None,
    timeout_millis: default_timeout_millis,
    enable_gzip: false,
  }
}

///|
pub fn Config::with_token(self : Config, token : String) -> Config {
  { ..self, token: Some(token), }
}

///|
pub fn Config::with_db_name(self : Config, db_name : String) -> Config {
  { ..self, db_name: Some(db_name), }
}

///|
pub fn Config::with_timeout_millis(
  self : Config,
  timeout_millis : Int,
) -> Config {
  { ..self, timeout_millis, }
}

///|
/// 打开 gzip。注意当前 `moonrpc` 会把调用方给的 `grpc-encoding`
/// 当成保留头吞掉（只在响应侧读它），所以这里为真时得换一条路：
/// 见 `request_metadata` 的注释。
pub fn Config::with_gzip(self : Config, enable? : Bool = true) -> Config {
  { ..self, enable_gzip: enable, }
}
