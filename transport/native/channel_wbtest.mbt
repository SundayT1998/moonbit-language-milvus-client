// native 传输的端到端测试：真的起一条 h2c 连接，
// 用 `moonrpc` 的服务端引擎在本地收包、断言它收到了什么。
//
// 这么做而不是去连真实 Milvus：CI 里没有 Milvus，
// 而本 Issue 要验的是「metadata 有没有真的发出去」，
// 一个受控的对端就够，且能断言到字节。

///|
/// 一次调用在服务端留下的痕迹。
struct Seen {
  auth : String
  db : String
  deadline : Int?
  body : String
}

///|
/// 起一个本地 h2c 服务端，把 `/probe.S/Echo` 收到的东西记进 `seen`。
/// 服务端在 `TaskGroup` 里跑，调用方负责在结束时取消它。
fn capture_server(seen : Array[Seen]) -> @net.GrpcServer {
  let server = @net.GrpcServer::new()
  server.register_unary("/probe.S/Echo", (ctx, req) => {
    let read = (name : Bytes) => {
      match ctx.metadata_get(name) {
        Some(v) => @utf8.decode_lossy(v[:])
        None => "<none>"
      }
    }
    seen.push({
      auth: read(b"authorization"),
      db: read(b"dbname"),
      deadline: ctx.deadline_millis,
      body: @utf8.decode_lossy(req[:]),
    })
    req
  })
  server
}

///|
/// 一个偏高的端口，避开常用服务；测试串行跑，够用。
fn test_port() -> Int {
  19173
}

///|
/// 端到端：连上、发一次带认证与 dbName 的调用，
/// 服务端收到的 metadata 与 `Config` 一致。
async test "端到端：认证与 dbName 真的上了线" {
  let seen : Array[Seen] = []
  let server = capture_server(seen)
  let port = test_port()
  let cfg = @transport.Config::new("127.0.0.1:" + port.to_string())
    .with_token("root:Milvus")
    .with_db_name("my_db")
    .with_timeout_millis(5000)
  @async.with_task_group(g => {
    let task = g.spawn(() => server.serve(host="127.0.0.1", port~))
    @async.sleep(200)
    let client = @channel.Client::connect(cfg)
    let reply = client.unary("/probe.S/Echo", b"ping")
    assert_eq(reply, b"ping")
    client.close()
    task.cancel()
    assert_eq(seen.length(), 1)
    assert_eq(seen[0].auth, "Bearer root:Milvus")
    assert_eq(seen[0].db, "my_db")
    assert_eq(seen[0].deadline, Some(5000))
    assert_eq(seen[0].body, "ping")
  })
}

///|
/// 没配 token / dbName 时，服务端看到的应是「没有这个头」，
/// 而不是空串 —— gRPC 的 metadata 里空值没有意义。
async test "端到端：没配就不发" {
  let seen : Array[Seen] = []
  let server = capture_server(seen)
  let port = test_port() + 1
  let cfg = @transport.Config::new("127.0.0.1:" + port.to_string())
  @async.with_task_group(g => {
    let task = g.spawn(() => server.serve(host="127.0.0.1", port~))
    @async.sleep(200)
    let client = @channel.Client::connect(cfg)
    ignore(client.unary("/probe.S/Echo", b"x"))
    client.close()
    task.cancel()
    assert_eq(seen.length(), 1)
    assert_eq(seen[0].auth, "<none>")
    assert_eq(seen[0].db, "<none>")
  })
}

///|
/// 连不上时立刻失败，而不是挂在那里等默认超时。
/// `Client::connect` 走的是 socket 层，失败抛的是底层 `Error`；
/// 一旦连上了、调用中途断链，才归到 `RpcError(UNAVAILABLE)`。
async test "端到端：连不上时立刻失败" {
  let cfg = @transport.Config::new("127.0.0.1:19199").with_timeout_millis(300)
  let failed = try {
    let client = @channel.Client::connect(cfg)
    client.close()
    false
  } catch {
    _ => true
  }
  assert_true(failed)
}

///|
/// 地址解析：带端口、不带端口、IPv6 字面量。
test "地址解析" {
  assert_eq(parse_address("127.0.0.1:19530"), ("127.0.0.1", 19530))
  assert_eq(parse_address("127.0.0.1"), ("127.0.0.1", @transport.default_port))
  assert_eq(
    parse_address("milvus.local"),
    ("milvus.local", @transport.default_port),
  )
  assert_eq(parse_address("[::1]:19530"), ("::1", 19530))
  assert_eq(
    parse_address("localhost:0"),
    ("localhost", @transport.default_port),
  )
  assert_eq(
    parse_address("localhost:70000"),
    ("localhost", @transport.default_port),
  )
}
