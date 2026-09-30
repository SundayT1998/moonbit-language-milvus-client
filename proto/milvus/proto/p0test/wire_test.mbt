///|
/// P0 探针：DescribeCollectionRequest 的 wire 编解码往返。
/// 不连真实服务，只验证生成物能编码成字节、再解码回等值对象。
fn sample_request() -> @milvus.DescribeCollectionRequest {
  let base = @common.MsgBase::MsgBase(
    @common.MsgType::DescribeCollection,
    100L,
    1234UL,
    1L,
    2L,
    {},
  )
  @milvus.DescribeCollectionRequest::DescribeCollectionRequest(
    base~,
    "default",
    "demo_collection",
    456L,
    0UL,
  )
}

///|
test "DescribeCollectionRequest wire round-trip" {
  let req = sample_request()
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(req, buf)
  let bytes : Bytes = buf.to_bytes()
  assert_true(bytes.length() > 0)
  let reader = @lib.BytesReader::from_bytes(bytes)
  let decoded : @milvus.DescribeCollectionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(reader),
  )
  assert_eq(decoded.db_name, "default")
  assert_eq(decoded.collection_name, "demo_collection")
  assert_eq(decoded.collection_id, 456L)
  assert_eq(decoded.time_stamp, 0UL)
  assert_eq(decoded.base.unwrap().msg_id, 100L)
}

///|
/// size_of 与编码长度应一致（生成器同时产出 Sized 与 Write）
test "size_of matches encoded length" {
  let req = sample_request()
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(req, buf)
  assert_eq(buf.length().reinterpret_as_uint(), @lib.size_of(req))
}

///|
/// gRPC 风格：长度前缀的 message（unary 调用的 payload 形态）
test "delimited (gRPC payload) round-trip" {
  let req = sample_request()
  let body = @buffer.Buffer::Buffer()
  @lib.Write::write(req, body)
  let buf = @buffer.Buffer::Buffer()
  @lib.write_varint(buf, body.length().to_uint64())
  buf.write_bytes(body.to_bytes())
  let bytes : Bytes = buf.to_bytes()
  let reader = @lib.BytesReader::from_bytes(bytes)
  let decoded : @milvus.DescribeCollectionRequest = @lib.read_message(
    @lib.LimitedReader::LimitedReader(reader),
  )
  assert_eq(decoded.collection_name, "demo_collection")
  assert_eq(decoded.collection_id, 456L)
}
