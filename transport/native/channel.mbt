// native 传输：把 `Config` 变成一条真实的 h2c gRPC 连接。
//
// 这层只做三件事 —— 建连、把 metadata 挂上、把 reply 翻成上层认识的 `RpcError`。
// 之所以单独成包而不是塞进 `transport/`：`moonrpc/net` 声明了
// `supported_targets = "native"`，而模块 `preferred_target = "wasm"`，
// 混在一起会让 wasm / js 直接编不过（见 Issue #11 的 R4）。

///|
/// 一条到 Milvus 的 gRPC 连接。`moonrpc` 的 `Channel` 本身是长连接、
/// 多路复用的，这里只把 `Config` 的默认值记住，省得每次调用都传。
pub struct Client {
  channel : @net.Channel
  config : @transport.Config
}

///|
/// 拆 `host:port`。没写端口就用 Milvus 默认端口；
/// `[::1]:19530` 这种带方括号的 IPv6 也认。
///
/// 从右往左找最后一个 `:`，这样裸 IPv6（`::1`）不会被误当成 host:port ——
/// 它没有端口，只能落回默认端口。
pub fn parse_address(address : String) -> (String, Int) {
  if address == "" {
    return ("", @transport.default_port)
  }
  // IPv6 字面量：[...] 或 [...]:port
  if address[0] == '[' {
    match address.find("]") {
      Some(close) => {
        let host = address[1:close].to_owned()
        let rest = address[close + 1:].to_owned()
        if rest.length() > 0 && rest[0] == ':' {
          return (host, parse_port(rest[1:].to_owned()))
        }
        return (host, @transport.default_port)
      }
      None => return (address, @transport.default_port)
    }
  }
  match address.rev_find(":") {
    Some(i) => {
      let host = address[:i].to_owned()
      let port_str = address[i + 1:].to_owned()
      if host == "" || port_str == "" {
        return (address, @transport.default_port)
      }
      (host, parse_port(port_str))
    }
    None => (address, @transport.default_port)
  }
}

///|
/// 端口解析失败就退回默认端口：Milvus 的地址是用户手写的配置，
/// 报错不如按缺省处理来得省事，真正的连接失败会在 dial 时报出来。
fn parse_port(s : String) -> Int {
  let n = @string.parse_int(s[:]) catch { _ => -1 }
  if n > 0 && n <= 65535 {
    n
  } else {
    @transport.default_port
  }
}

///|
/// 按 `Config` 建连。
pub async fn Client::connect(config : @transport.Config) -> Client {
  let (host, port) = parse_address(config.address)
  let channel = @net.Channel::connect(host, port)
  { channel, config, }
}

///|
/// 建连并立刻验证通道可用：发一次 unary 调用，拿到的错误是
/// `Unimplemented` 也算「通了」（说明对端确实是 gRPC 服务）。
/// 这对 CI 里没有真实 Milvus 的场景有用。
pub fn Client::close(self : Client) -> Unit {
  self.channel.close()
}

///|
/// 发一次 unary 调用，返回 reply 的消息体。
///
/// `path` 是 `/pkg.Service/Method`；`request` 是已编码好的 protobuf body
/// （不含 gRPC 的 5 字节长度前缀 —— 那层由 `moonrpc` 负责）。
/// 失败按 gRPC 语义抛 `RpcError`，非 OK 一律抛，包括超时。
pub async fn Client::unary(
  self : Client,
  path : String,
  request : Bytes,
  timeout_millis? : Int,
) -> Bytes raise @transport.RpcError {
  let metadata = @transport.request_metadata(self.config)
  let timeout = match timeout_millis {
    Some(ms) => ms
    None => self.config.timeout_millis
  }
  // `moonrpc` 的 socket 层抛 `Error`（连接断了、帧坏了）。
  // 这些对上层来说都属于「传输不可用」，归到 UNAVAILABLE 比漏成
  // 一个没类型的 error 更好判别，也才符合 gRPC 的语义。
  let reply = self.channel.unary(
    path,
    request,
    metadata~,
    timeout_millis=timeout,
  ) catch {
    e =>
      raise @transport.RpcError::new(
        @transport.Code::Unavailable.to_int(),
        "transport failure: " + e.to_string(),
      )
  }
  if reply.grpc_status != 0 {
    raise @transport.RpcError::new(reply.grpc_status, reply.grpc_message)
  }
  match reply.messages {
    [msg, ..] => msg
    [] =>
      raise @transport.RpcError::new(
        @transport.Code::Internal.to_int(),
        "server returned OK but no message",
      )
  }
}

///|
/// 只走到「连接 + 一次调用」为止，判断链路是否可用。
/// 返回 `Ok(())` 表示握手与 framing 都对；`Err(e)` 时若 `e` 是
/// `Unimplemented`，仍说明服务端是活的 gRPC 服务。
pub async fn Client::ping(self : Client) -> Result[Unit, @transport.RpcError] {
  let metadata = @transport.request_metadata(self.config)
  let reply = self.channel.unary(
    "/grpc.health.v1.Health/Check",
    b"",
    metadata~,
    timeout_millis=self.config.timeout_millis,
  ) catch {
    e =>
      return Err(
        @transport.RpcError::new(
          @transport.Code::Unavailable.to_int(),
          "transport failure: " + e.to_string(),
        ),
      )
  }
  match reply.grpc_status {
    0 => Ok(())
    s =>
      if s == @transport.Code::Unimplemented.to_int() {
        Ok(())
      } else {
        Err(@transport.RpcError::new(s, reply.grpc_message))
      }
  }
}
