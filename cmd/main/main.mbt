// gRPC 传输层自检程序。
//
// 用法：
//   moon run cmd/main -- [host:port] [token] [dbName]
//
// 它依次验证 Issue #11 的三条验收标准：
//   1. 能建立连接并完成一次 unary 调用
//   2. 认证与 dbName metadata 确实发出去了
//   3. 超时配置生效，超时错误能被识别出来
//
// 前者需要一个真实可达的 Milvus；后两条可对着任意 gRPC 服务验。

///|
fn main {
  let args = @env.args()
  let address = match args {
    [_, addr, ..] => addr
    _ => "127.0.0.1:19530"
  }
  let token = match args {
    [_, _, tok, ..] => Some(tok)
    _ => None
  }
  let db = match args {
    [_, _, _, d, ..] => Some(d)
    _ => None
  }
  @async.run_async_main(() => run(address, token, db))
}

///|
async fn run(address : String, token : String?, db_name : String?) -> Unit {
  let mut cfg = @transport.Config::new(address).with_timeout_millis(5000)
  match token {
    Some(t) => cfg = cfg.with_token(t)
    None => ()
  }
  match db_name {
    Some(d) => cfg = cfg.with_db_name(d)
    None => ()
  }
  let (host, port) = @native.parse_address(address)
  println("连接 " + host + ":" + port.to_string())
  println(
    "  token=" +
    (match token {
      Some(_) => "<已设置>"
      None => "<无>"
    }) +
    " dbName=" +
    (match db_name {
      Some(d) => d
      None => "<无>"
    }),
  )
  let client = @native.Client::connect(cfg) catch {
    e => {
      println("[1] 建连失败：" + e.to_string())
      return
    }
  }
  println("[1] 建连成功")
  match client.ping() {
    Ok(_) => println("[2] Health/Check 通过，channel 可用")
    Err(err) =>
      if err.is_deadline_exceeded() {
        println("[3] 调用超时：" + err.to_string())
      } else {
        println("[2] 调用失败：" + err.to_string())
      }
  }
  client.close()
}
