// Milvus 客户端的公开入口。
//
// 这层刻意只放跨 target 的东西 —— 模块 `preferred_target = "wasm"`，
// 根包在 wasm / js / native 下都得编得过。
// 真正发请求的实现是 native 专属的，见 `transport/native`：
// 它依赖的 `moonrpc/net` 自己声明了 `supported_targets = "native"`。

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
