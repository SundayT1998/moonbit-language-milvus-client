///|
/// #15 探针：Client 门面用到的核心 RPC 请求/响应的 wire 往返。
/// 不连真实服务，只验证生成物能编码成字节、再解码回等值对象。
///
/// 这些断言是「生成器 + 裁剪 proto」这一层的正确性下限：
/// 字段号写错、oneof 分支选错、repeated 打包规则错了，都能在这里抓住。

///|
fn[T : @lib.Write + @lib.Sized, M : @lib.Read + Default] round_trip(
  value : T,
) -> M raise {
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(value, buf)
  assert_eq(buf.length().reinterpret_as_uint(), @lib.size_of(value))
  let reader = @lib.BytesReader::from_bytes(buf.to_bytes())
  @lib.Read::read_with_limit(@lib.LimitedReader::LimitedReader(reader))
}

///|
test "CreateCollectionRequest wire round-trip" {
  let req = @milvus.CreateCollectionRequest::{
    base: None,
    db_name: "default",
    collection_name: "demo",
    schema: b"\x01\x02",
    shards_num: 1,
    consistency_level: @common.ConsistencyLevel::Bounded,
    properties: [@common.KeyValuePair::KeyValuePair("k", "v")],
    num_partitions: 0L,
  }
  let decoded : @milvus.CreateCollectionRequest = round_trip(req)
  assert_eq(decoded.collection_name, "demo")
  assert_eq(decoded.db_name, "default")
  assert_eq(decoded.schema, b"\x01\x02")
  assert_eq(decoded.shards_num, 1)
  assert_eq(decoded.consistency_level, @common.ConsistencyLevel::Bounded)
  assert_eq(decoded.properties[0].value, "v")
}

///|
test "InsertRequest + MutationResult wire round-trip" {
  let field = @schema.FieldData::{
    type_: @schema.DataType::Int64,
    field_name: "id",
    field_id: 100L,
    is_dynamic: false,
    valid_data: [],
    field: @schema.FieldData_Field::Scalars(@schema.ScalarField::{
      valid_data: [],
      data: @schema.ScalarField_Data::LongData(
        @schema.LongArray::LongArray([1L, 2L, 3L]),
      ),
    }),
  }
  let req = @milvus.InsertRequest::{
    base: None,
    db_name: "",
    collection_name: "demo",
    partition_name: "_default",
    fields_data: [field],
    hash_keys: [],
    num_rows: 3U,
    schema_timestamp: 42UL,
    namespace_: None,
  }
  let decoded : @milvus.InsertRequest = round_trip(req)
  assert_eq(decoded.collection_name, "demo")
  assert_eq(decoded.partition_name, "_default")
  assert_eq(decoded.num_rows, 3U)
  assert_eq(decoded.schema_timestamp, 42UL)
  match decoded.fields_data[0].field {
    Scalars(s) =>
      match s.data {
        LongData(a) => assert_eq(a.data, [1L, 2L, 3L])
        _ => fail("expected LongData")
      }
    _ => fail("expected Scalars")
  }
  let resp = @milvus.MutationResult::{
    status: None,
    ids: Some(@schema.IDs::{
      id_field: @schema.IDs_IdField::IntId(
        @schema.LongArray::LongArray([7L, 8L]),
      ),
    }),
    succ_index: [],
    err_index: [],
    acknowledged: true,
    insert_cnt: 2L,
    delete_cnt: 0L,
    upsert_cnt: 0L,
    timestamp: 99UL,
  }
  let back : @milvus.MutationResult = round_trip(resp)
  assert_eq(back.insert_cnt, 2L)
  assert_eq(back.timestamp, 99UL)
  assert_true(back.acknowledged)
  match back.ids.unwrap().id_field {
    IntId(a) => assert_eq(a.data, [7L, 8L])
    _ => fail("expected IntId")
  }
}

///|
test "DeleteRequest wire round-trip" {
  let req = @milvus.DeleteRequest::{
    base: None,
    db_name: "",
    collection_name: "demo",
    partition_name: "",
    expr: "id in [1, 2]",
    hash_keys: [],
    consistency_level: @common.ConsistencyLevel::Strong,
    namespace_: None,
  }
  let decoded : @milvus.DeleteRequest = round_trip(req)
  assert_eq(decoded.expr, "id in [1, 2]")
  assert_eq(decoded.consistency_level, @common.ConsistencyLevel::Strong)
}

///|
test "SearchRequest placeholder wire round-trip" {
  let ph = @common.PlaceholderGroup::{
    placeholders: [
      @common.PlaceholderValue::{
        tag: "$0",
        type_: @common.PlaceholderType::FloatVector,
        values: [b"\x00\x00\x80\x3f", b"\x00\x00\x00\x40"],
      },
    ],
  }
  let ph_buf = @buffer.Buffer::Buffer()
  @lib.Write::write(ph, ph_buf)
  let req = @milvus.SearchRequest::{
    base: None,
    db_name: "",
    collection_name: "demo",
    partition_names: [],
    dsl: "",
    search_input: @milvus.SearchRequest_SearchInput::PlaceholderGroup(
      ph_buf.to_bytes(),
    ),
    dsl_type: @common.DslType::BoolExprV1,
    output_fields: ["id"],
    search_params: [
      @common.KeyValuePair::KeyValuePair("topk", "3"),
      @common.KeyValuePair::KeyValuePair("anns_field", "vector"),
    ],
    travel_timestamp: 0UL,
    guarantee_timestamp: 0UL,
    nq: 2L,
    not_return_all_meta: false,
    consistency_level: @common.ConsistencyLevel::Bounded,
    use_default_consistency: false,
    namespace_: None,
  }
  let decoded : @milvus.SearchRequest = round_trip(req)
  assert_eq(decoded.nq, 2L)
  assert_eq(decoded.dsl_type, @common.DslType::BoolExprV1)
  match decoded.search_input {
    PlaceholderGroup(bytes) => {
      let reader = @lib.BytesReader::from_bytes(bytes)
      let back : @common.PlaceholderGroup = @lib.Read::read_with_limit(
        @lib.LimitedReader::LimitedReader(reader),
      )
      assert_eq(back.placeholders[0].tag, "$0")
      assert_eq(
        back.placeholders[0].type_,
        @common.PlaceholderType::FloatVector,
      )
      assert_eq(back.placeholders[0].values.length(), 2)
    }
    _ => fail("expected PlaceholderGroup")
  }
}

///|
test "SearchResults wire round-trip" {
  let data = @schema.SearchResultData::{
    num_queries: 1L,
    top_k: 2L,
    fields_data: [],
    scores: [0.9, 0.8],
    ids: Some(@schema.IDs::{
      id_field: @schema.IDs_IdField::StrId(
        @schema.StringArray::StringArray(["a", "b"]),
      ),
    }),
    topks: [2L],
    output_fields: ["id"],
    group_by_field_value: None,
    all_search_count: 0L,
    distances: [],
    search_iterator_v2_results: None,
    recalls: [],
    primary_field_name: "id",
    element_indices: None,
    group_by_field_values: [],
  }
  let resp = @milvus.SearchResults::{
    status: None,
    results: Some(data),
    collection_name: "demo",
    session_ts: 0UL,
  }
  let decoded : @milvus.SearchResults = round_trip(resp)
  assert_eq(decoded.collection_name, "demo")
  let r = decoded.results.unwrap()
  assert_eq(r.num_queries, 1L)
  assert_eq(r.topks, [2L])
  assert_eq(r.scores, [0.9, 0.8])
  match r.ids.unwrap().id_field {
    StrId(a) => assert_eq(a.data, ["a", "b"])
    _ => fail("expected StrId")
  }
}

///|
test "QueryRequest / QueryResults wire round-trip" {
  let req = @milvus.QueryRequest::{
    base: None,
    db_name: "",
    collection_name: "demo",
    expr: "id > 0",
    output_fields: ["id", "vector"],
    partition_names: [],
    travel_timestamp: 0UL,
    guarantee_timestamp: 0UL,
    query_params: [@common.KeyValuePair::KeyValuePair("limit", "10")],
    not_return_all_meta: false,
    consistency_level: @common.ConsistencyLevel::Bounded,
    use_default_consistency: true,
    namespace_: None,
  }
  let decoded : @milvus.QueryRequest = round_trip(req)
  assert_eq(decoded.expr, "id > 0")
  assert_eq(decoded.output_fields, ["id", "vector"])
  assert_eq(decoded.query_params[0].key, "limit")
  let resp = @milvus.QueryResults::{
    status: None,
    fields_data: [],
    collection_name: "demo",
    output_fields: ["id"],
    session_ts: 0UL,
    primary_field_name: "id",
  }
  let back : @milvus.QueryResults = round_trip(resp)
  assert_eq(back.collection_name, "demo")
  assert_eq(back.output_fields, ["id"])
}

///|
test "ShowCollectionsResponse wire round-trip" {
  let resp = @milvus.ShowCollectionsResponse::{
    status: None,
    collection_names: ["a", "b"],
    collection_ids: [1L, 2L],
    created_timestamps: [0UL, 0UL],
    created_utc_timestamps: [0UL, 0UL],
    in_memory_percentages: [],
    query_service_available: [true, false],
    shards_num: [1, 2],
  }
  let decoded : @milvus.ShowCollectionsResponse = round_trip(resp)
  assert_eq(decoded.collection_names, ["a", "b"])
  assert_eq(decoded.collection_ids, [1L, 2L])
  assert_eq(decoded.query_service_available, [true, false])
  assert_eq(decoded.shards_num, [1, 2])
}
