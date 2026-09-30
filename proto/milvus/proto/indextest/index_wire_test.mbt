///|
/// 索引 RPC 的 wire 往返验证：请求构造 → 编码 → 解码 → 等值。
/// 不连真实服务；服务端行为另由集成测试覆盖。
///
/// 参数键名与字面量手写在 `index` 包里有对应断言（`index/builder_test.mbt`），
/// 这里只验证同一组键值对能原样过一遍 wire。

///|
fn kv(key : String, value : String) -> @common.KeyValuePair {
  @common.KeyValuePair::KeyValuePair(key, value)
}

///|
fn hnsw_request() -> @milvus.CreateIndexRequest {
  @milvus.CreateIndexRequest::CreateIndexRequest(
    "default",
    "demo_collection",
    "embedding",
    [
      kv("metric_type", "COSINE"),
      kv("index_type", "HNSW"),
      kv("M", "16"),
      kv("efConstruction", "200"),
    ],
    "embedding_idx",
  )
}

///|
test "CreateIndexRequest wire round-trip" {
  let req = hnsw_request()
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(req, buf)
  let bytes : Bytes = buf.to_bytes()
  assert_true(bytes.length() > 0)
  let reader = @lib.BytesReader::from_bytes(bytes)
  let decoded : @milvus.CreateIndexRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(reader),
  )
  assert_eq(decoded.collection_name, "demo_collection")
  assert_eq(decoded.field_name, "embedding")
  assert_eq(decoded.index_name, "embedding_idx")
  assert_eq(decoded.db_name, "default")
  assert_eq(decoded.extra_params.length(), 4)
  assert_eq(decoded.extra_params[0].key, "metric_type")
  assert_eq(decoded.extra_params[0].value, "COSINE")
  assert_eq(decoded.extra_params[2].key, "M")
  assert_eq(decoded.extra_params[2].value, "16")
}

///|
test "CreateIndexRequest size_of matches encoded length" {
  let req = hnsw_request()
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(req, buf)
  assert_eq(buf.length().reinterpret_as_uint(), @lib.size_of(req))
}

///|
test "DropIndexRequest wire round-trip" {
  let req = @milvus.DropIndexRequest::DropIndexRequest(
    "", "demo_collection", "", "embedding_idx",
  )
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(req, buf)
  let reader = @lib.BytesReader::from_bytes(buf.to_bytes())
  let decoded : @milvus.DropIndexRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(reader),
  )
  assert_eq(decoded.collection_name, "demo_collection")
  assert_eq(decoded.index_name, "embedding_idx")
}

///|
test "DescribeIndexResponse wire round-trip" {
  let desc : @milvus.IndexDescription = @milvus.IndexDescription::IndexDescription(
    "embedding_idx",
    456L,
    [kv("index_type", "HNSW"), kv("metric_type", "COSINE")],
    "embedding",
    100L,
    100L,
    @common.IndexState::Finished,
    "",
    0L,
    0,
    0,
  )
  let resp = @milvus.DescribeIndexResponse::DescribeIndexResponse([desc])
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(resp, buf)
  let reader = @lib.BytesReader::from_bytes(buf.to_bytes())
  let decoded : @milvus.DescribeIndexResponse = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(reader),
  )
  assert_eq(decoded.index_descriptions.length(), 1)
  let d = decoded.index_descriptions[0]
  assert_eq(d.index_name, "embedding_idx")
  assert_eq(d.index_id, 456L)
  assert_eq(d.field_name, "embedding")
  assert_eq(d.indexed_rows, 100L)
  assert_eq(d.total_rows, 100L)
  assert_eq(d.state, @common.IndexState::Finished)
  assert_eq(d.params.length(), 2)
  assert_eq(d.params[0].key, "index_type")
}
