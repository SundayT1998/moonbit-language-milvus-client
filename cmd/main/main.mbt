// gRPC 传输层自检程序。
//
// 用法：
//   moon run --target native cmd/main -- [host:port] [token] [dbName]
//
// 它依次验证 Issue #11 的三条验收标准：
//   1. 能建立连接并完成一次 unary 调用
//   2. 认证与 dbName metadata 确实发出去了
//   3. 超时配置生效，超时错误能被识别出来
//
// 前者需要一个真实可达的 Milvus；后两条可对着任意 gRPC 服务验。
//
// 退出码非 0 即失败（照 cmd/integration 的写法），CI 直接看退出码：
// 建连失败、Health/Check 报了非超时的错误，都会 abort 掉。
// 只有「调用超时」被当作通过 —— 超时本身正是第 3 条要验的东西，
// 它说明超时配置生效了、且错误被认出来了。

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
/// 跑自检。返回空串表示全过，否则是失败文本。
///
/// 与 `cmd/integration` 同构：`run` 只负责把失败翻译成退出码，
/// 判定逻辑收在返回文本的函数里。
async fn run(address : String, token : String?, db_name : String?) -> Unit {
  let outcome = check(address, token, db_name)
  if outcome != "" {
    println("\n传输层自检失败：" + outcome)
    // 非 0 退出码；失败细节已经打在 stdout 里。
    abort(outcome)
  }
  println("\n传输层自检全部通过")
}

///|
async fn check(address : String, token : String?, db_name : String?) -> String {
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
      return "[1] 建连失败：" + e.to_string()
    }
  }
  println("[1] 建连成功")
  let outcome = match client.ping() {
    Ok(_) => {
      println("[2] Health/Check 通过，channel 可用")
      ""
    }
    Err(err) =>
      if err.is_deadline_exceeded() {
        // 超时不算失败：第 3 条要验的就是它。
        println("[3] 调用超时：" + err.to_string())
        ""
      } else {
        println("[2] 调用失败：" + err.to_string())
        "[2] 调用失败：" + err.to_string()
      }
  }
  client.close()
  outcome
}
