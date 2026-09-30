// 根包的公开行为测试。这层只是转发到 transport，
// 所以这里断言的是「转发没错、默认值对」。

///|
test "默认端口与超时" {
  assert_eq(@milvus-client.default_port, 19530)
  assert_eq(@milvus-client.default_timeout_millis, 30_000)
}

///|
test "最小配置" {
  let cfg = @milvus-client.with_address("127.0.0.1:19530")
  assert_eq(cfg.address, "127.0.0.1:19530")
  assert_eq(cfg.token, None)
  assert_eq(cfg.db_name, None)
  assert_eq(cfg.timeout_millis, @milvus-client.default_timeout_millis)
}

///|
test "链式配置" {
  let cfg = @milvus-client.with_address("milvus:19530")
    |> @milvus-client.with_token("root:Milvus")
    |> @milvus-client.with_db_name("demo")
    |> @milvus-client.with_timeout_millis(1000)
  assert_eq(cfg.token, Some("root:Milvus"))
  assert_eq(cfg.db_name, Some("demo"))
  assert_eq(cfg.timeout_millis, 1000)
}
