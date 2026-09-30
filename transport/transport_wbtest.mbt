// transport 层的行为测试。这些用例不连真实服务，
// 验证的是「配置怎么翻成 metadata」「status 怎么被上层判别」这两件事。

///|
test "token 与 db_name 都注入成功" {
  let cfg = Config::new("127.0.0.1:19530")
    .with_token("root:Milvus")
    .with_db_name("my_db")
  let md = request_metadata(cfg)
  assert_eq(metadata_get(md, "authorization"), Some("Bearer root:Milvus"))
  assert_eq(metadata_get(md, "dbname"), Some("my_db"))
}

///|
test "没配 token / db_name 就不发对应的头" {
  let md = request_metadata(Config::new("127.0.0.1:19530"))
  assert_eq(md.length(), 0)
  assert_eq(metadata_get(md, "authorization"), None)
  assert_eq(metadata_get(md, "dbname"), None)
}

///|
test "空串不当作有效配置" {
  let cfg = Config::new("127.0.0.1:19530").with_token("").with_db_name("")
  assert_eq(request_metadata(cfg).length(), 0)
}

///|
test "metadata 键是小写的" {
  let cfg = Config::new("h:1").with_token("t").with_db_name("d")
  let md = request_metadata(cfg)
  for h in md {
    let (n, _) = h.ascii()
    assert_eq(n, n.to_lower())
  }
}

///|
/// `grpc-encoding` 不能由调用方声明：moonrpc 请求侧不压 body，
/// 声明了反而让服务端解一个没压的 body。这条锁住这个判断。
test "gzip 只声明 accept-encoding，不声明 grpc-encoding" {
  let md = request_metadata(Config::new("h:1").with_gzip())
  assert_eq(
    metadata_get(md, "grpc-accept-encoding"),
    Some(grpc_accept_encoding_value),
  )
  assert_eq(metadata_get(md, "grpc-encoding"), None)
}

///|
test "默认超时是有界的" {
  assert_eq(Config::new("h:1").timeout_millis, default_timeout_millis)
  assert_eq(Config::new("h:1").with_timeout_millis(500).timeout_millis, 500)
}

///|
test "DeadlineExceeded 能被上层识别为超时" {
  let err = RpcError::new(4, "deadline exceeded")
  assert_true(err.is_deadline_exceeded())
  assert_eq(err.code(), DeadlineExceeded)
  assert_false(err.is_retryable())
}

///|
test "Unavailable 可重试但不算超时" {
  let err = RpcError::new(14, "no backend available")
  assert_false(err.is_deadline_exceeded())
  assert_true(err.is_retryable())
}

///|
test "未知数值不丢原值" {
  let err = RpcError::new(99, "who knows")
  assert_eq(err.code(), Unknown)
  assert_eq(err.raw_code(), 99)
}

///|
test "status 码与规范数值对得上" {
  assert_eq(Ok.to_int(), 0)
  assert_eq(DeadlineExceeded.to_int(), 4)
  assert_eq(Unavailable.to_int(), 14)
  assert_eq(Unauthenticated.to_int(), 16)
  assert_eq(Code::from_int(4), DeadlineExceeded)
}

///|
test "错误消息可读" {
  assert_eq(
    RpcError::new(4, "deadline exceeded").to_string(),
    "DEADLINE_EXCEEDED: deadline exceeded",
  )
  assert_eq(RpcError::new(4, "").to_string(), "DEADLINE_EXCEEDED")
}

///|
/// 让 `Code` 的 `Debug` / `RpcError` 的 `Eq` 真正被用到：
/// 报错信息（日志、断言的 diff）要的是可读的码名，而不是数字。
test "status 的调试输出是人能看懂的" {
  // 断言失败时的 diff 走 Debug，所以它得是可读的名字而不是数字
  assert_eq(Code::DeadlineExceeded, Code::from_int(4))
  assert_eq(
    RpcError::new(4, "deadline exceeded") ==
    RpcError::new(4, "deadline exceeded"),
    true,
  )
  assert_eq(RpcError::new(4, "a") == RpcError::new(14, "a"), false)
  assert_eq(RpcError::new(4, "a") == RpcError::new(4, "b"), false)
}
