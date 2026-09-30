// Licensed to the LF AI & Data foundation under one
// or more contributor license agreements. See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership. The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// 用假传输跑的跨 target 测试。
//
// 这里断言两件事：请求确实编成了服务端认的字节，响应确实解回了对的类型。
// 真实 Milvus 跑通「建表 → 插入 → 检索」是验收标准里的另一条，
// 由 CI 之外的手工验证覆盖（见 Issue #15 的说明）。

///|
/// 一条被记下来的调用。
struct Recorded {
  path : String
  body : Bytes
} derive(Debug)

///|
/// 假传输：按路径回放预置的响应，同时把请求记下来。
///
/// 用 `Ref` 而不是返回 `(@client.Unary, Array[@client.Recorded])`：`@client.Client::new` 收的
/// 是函数值，捕获的数组要能在调用之后被测试读到。
fn fake_transport(
  responses : Array[(String, Bytes)],
  recorded : Ref[Array[Recorded]],
) -> @client.Unary {
  (path, body) => {
    let log = recorded.val
    log.push({ path, body, })
    recorded.val = log
    for pair in responses {
      if pair.0 == path {
        return pair.1
      }
    }
    raise @transport.RpcError::new(
      @transport.Code::Unimplemented.to_int(),
      "fake transport has no response for " + path,
    )
  }
}

///|
fn[T : @lib.Write] encode(message : T) -> Bytes raise {
  let buf = @buffer.Buffer::Buffer()
  @lib.Write::write(message, buf)
  buf.to_bytes()
}

///|
fn ok_status() -> @common.Status {
  @common.Status::{
    error_code: @common.ErrorCode::Success,
    reason: "",
    code: 0,
    retriable: false,
    detail: "",
    extra_info: {},
  }
}

///|
fn test_client(
  responses : Array[(String, Bytes)],
) -> (@client.Client, Ref[Array[Recorded]]) {
  let recorded : Ref[Array[Recorded]] = Ref([])
  let config = @transport.Config::new("127.0.0.1:19530")
  (@client.Client::new(config, fake_transport(responses, recorded)), recorded)
}

///|
async test "create_collection 编出可解析的请求" {
  let client = test_client([
    (@client.create_collection_path, encode(ok_status())),
  ])
  let (client, recorded) = client
  let schema = @entity.CollectionSchema::new([
    @entity.Field::new("id", @entity.DataType::Int64).as_primary_key(),
    @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(4),
  ])
  let option = @client.new_create_collection_option("demo", schema)
  let _ = client.create_collection(option) catch { _ => () }
  let calls = recorded.val
  assert_eq(calls.length(), 1)
  assert_eq(calls[0].path, @client.create_collection_path)
  let request : @milvus.CreateCollectionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(calls[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
  assert_eq(request.shards_num, 1)
  assert_eq(request.consistency_level, @common.ConsistencyLevel::Bounded)
  // schema 是嵌套的 bytes：解出来看看字段名与 dim
  let schema_proto : @schema.CollectionSchema = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(request.schema),
    ),
  )
  assert_eq(schema_proto.name, "demo")
  assert_eq(schema_proto.fields.length(), 2)
  assert_eq(schema_proto.fields[0].name, "id")
  assert_true(schema_proto.fields[0].is_primary_key)
  assert_eq(schema_proto.fields[1].type_params[0].key, "dim")
  assert_eq(schema_proto.fields[1].type_params[0].value, "4")
}

///|
async test "create_collection 快速建表合成默认 schema" {
  let client = test_client([
    (@client.create_collection_path, encode(ok_status())),
  ])
  let (client, recorded) = client
  let _ = client.create_collection(
    @client.simple_create_collection_option("quick", 8),
  ) catch {
    _ => ()
  }
  let request : @milvus.CreateCollectionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  let schema_proto : @schema.CollectionSchema = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(request.schema),
    ),
  )
  // 与上游 SimpleCreateCollectionOptions 一致：id / vector，autoID，动态字段开
  assert_eq(schema_proto.fields[0].name, "id")
  assert_true(schema_proto.fields[0].auto_id)
  assert_eq(schema_proto.fields[1].name, "vector")
  assert_true(schema_proto.enable_dynamic_field)
}

///|
async test "create_collection 的 schema 不合法时不发请求" {
  let client = test_client([
    (@client.create_collection_path, encode(ok_status())),
  ])
  let (client, recorded) = client
  // 没有主键字段 -> validate 会拒
  let schema = @entity.CollectionSchema::new([
    @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(4),
  ])
  let mut raised = false
  ignore(
    client.create_collection(
      @client.new_create_collection_option("bad", schema),
    ),
  ) catch {
    _ => raised = true
  }
  assert_true(raised)
  assert_eq(recorded.val.length(), 0)
}

///|
async test "drop_collection 与 list_collections" {
  let show = @milvus.ShowCollectionsResponse::{
    status: Some(ok_status()),
    collection_names: ["a", "b"],
    collection_ids: [1L, 2L],
    created_timestamps: [],
    created_utc_timestamps: [],
    in_memory_percentages: [],
    query_service_available: [],
    shards_num: [],
  }
  let client = test_client([
    (@client.drop_collection_path, encode(ok_status())),
    (@client.show_collections_path, encode(show)),
  ])
  let (client, recorded) = client
  let mut raised = false
  ignore(client.drop_collection(@client.new_drop_collection_option("a"))) catch {
    _ => raised = true
  }
  assert_false(raised)
  let names = client.list_collections(@client.new_list_collections_option()) catch {
    _ => []
  }
  assert_eq(names, ["a", "b"])
  let list_request : @milvus.ShowCollectionsRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[1].body),
    ),
  )
  assert_eq(list_request.type_, @milvus.ShowType::All)
}

///|
async test "describe_collection 解出元信息" {
  let schema_proto = @schema.CollectionSchema::{
    name: "demo",
    description: "a demo",
    auto_id: false,
    fields: [
      @schema.FieldSchema::{
        field_id: 100L,
        name: "id",
        is_primary_key: true,
        description: "",
        data_type: @schema.DataType::Int64,
        type_params: [],
        index_params: [],
        auto_id: false,
        state: @schema.FieldState::FieldCreated,
        element_type: @schema.DataType::None,
        default_value: None,
        is_dynamic: false,
        is_partition_key: false,
        is_clustering_key: false,
        nullable: false,
        is_function_output: false,
        external_field: "",
        type_schema: None,
        element_nullable: false,
      },
      @schema.FieldSchema::{
        field_id: 101L,
        name: "vector",
        is_primary_key: false,
        description: "",
        data_type: @schema.DataType::FloatVector,
        type_params: [@common.KeyValuePair::KeyValuePair("dim", "4")],
        index_params: [],
        auto_id: false,
        state: @schema.FieldState::FieldCreated,
        element_type: @schema.DataType::None,
        default_value: None,
        is_dynamic: false,
        is_partition_key: false,
        is_clustering_key: false,
        nullable: false,
        is_function_output: false,
        external_field: "",
        type_schema: None,
        element_nullable: false,
      },
    ],
    enable_dynamic_field: true,
    properties: [],
    functions: [],
    db_name: "",
    struct_array_fields: [],
    version: 0,
    external_source: "",
    external_spec: "",
    do_physical_backfill: false,
    file_resource_ids: [],
    enable_namespace: false,
  }
  let response = @milvus.DescribeCollectionResponse::{
    status: Some(ok_status()),
    schema: Some(schema_proto),
    collection_id: 77L,
    virtual_channel_names: ["v1"],
    physical_channel_names: ["p1"],
    created_timestamp: 0UL,
    created_utc_timestamp: 0UL,
    shards_num: 2,
    aliases: [],
    start_positions: [],
    consistency_level: @common.ConsistencyLevel::Strong,
    collection_name: "demo",
    properties: [@common.KeyValuePair::KeyValuePair("k", "v")],
    db_name: "",
    num_partitions: 0L,
    db_id: 0L,
    request_time: 0UL,
    update_timestamp: 12345UL,
    update_timestamp_str: "",
    shard_infos: [],
    shard_by: "",
    routing_modulus: 0UL,
  }
  let client = test_client([
    (@client.describe_collection_path, encode(response)),
  ])
  let (client, _) = client
  let described = client.describe_collection(
    @client.new_describe_collection_option("demo"),
  ) catch {
    _ => fail("describe_collection should succeed")
  }
  assert_eq(described.name, "demo")
  assert_eq(described.id, 77L)
  assert_eq(described.shard_num, 2)
  assert_eq(described.update_timestamp, 12345UL)
  assert_eq(described.consistency_level, @client.ConsistencyLevel::Strong)
  assert_eq(described.schema.fields.length(), 2)
  assert_eq(described.schema.fields[1].dim, Some(4))
  assert_eq(described.schema.fields[1].data_type, @entity.DataType::FloatVector)
  assert_eq(described.properties, [("k", "v")])
  assert_eq(described.virtual_channels, ["v1"])
}

///|
async test "has_collection 把 collection-not-found 当 false" {
  // 服务端的错误码 100 = 现代码里的集合不存在（见 @errors 的映射表）。
  let missing = @milvus.DescribeCollectionResponse::{
    status: Some(@common.Status::{
      error_code: @common.ErrorCode::CollectionNotExists,
      reason: "collection not found",
      code: @errors.error_code(Some(@errors.err_collection_not_found())),
      retriable: false,
      detail: "",
      extra_info: {},
    }),
    schema: None,
    collection_id: 0L,
    virtual_channel_names: [],
    physical_channel_names: [],
    created_timestamp: 0UL,
    created_utc_timestamp: 0UL,
    shards_num: 0,
    aliases: [],
    start_positions: [],
    consistency_level: @common.ConsistencyLevel::Strong,
    collection_name: "",
    properties: [],
    db_name: "",
    num_partitions: 0L,
    db_id: 0L,
    request_time: 0UL,
    update_timestamp: 0UL,
    update_timestamp_str: "",
    shard_infos: [],
    shard_by: "",
    routing_modulus: 0UL,
  }
  let client = test_client([(@client.describe_collection_path, encode(missing))])
  let (client, _) = client
  let found = client.has_collection(
    @client.new_describe_collection_option("nope"),
  ) catch {
    _ => true
  }
  assert_false(found)
}

///|
async test "insert 编出 FieldData 并把主键解回来" {
  let response = @milvus.MutationResult::{
    status: Some(ok_status()),
    ids: Some(@schema.IDs::{
      id_field: @schema.IDs_IdField::IntId(
        @schema.LongArray::LongArray([10L, 11L]),
      ),
    }),
    succ_index: [],
    err_index: [],
    acknowledged: true,
    insert_cnt: 2L,
    delete_cnt: 0L,
    upsert_cnt: 0L,
    timestamp: 42UL,
  }
  let client = test_client([(@client.insert_path, encode(response))])
  let (client, recorded) = client
  let result = client.insert(
    @client.new_write_option("demo", [
      @client.WriteColumn::new("id", @column.ColumnValue::Int64([1L, 2L])),
      @client.WriteColumn::new(
        "vector",
        @column.ColumnValue::FloatVector(2, [[0.1, 0.2], [0.3, 0.4]]),
      ),
    ]),
  ) catch {
    _ => fail("insert should succeed")
  }
  assert_eq(result.insert_count, 2L)
  assert_eq(result.timestamp, 42UL)
  assert_eq(result.ids, Some(@column.ColumnValue::Int64([10L, 11L])))
  let request : @milvus.InsertRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
  assert_eq(request.num_rows, 2U)
  assert_eq(request.fields_data.length(), 2)
  assert_eq(request.fields_data[0].field_name, "id")
  match request.fields_data[0].field {
    Scalars(s) =>
      match s.data {
        LongData(a) => assert_eq(a.data, [1L, 2L])
        _ => fail("expected LongData")
      }
    _ => fail("expected Scalars")
  }
  match request.fields_data[1].field {
    Vectors(v) => {
      assert_eq(v.dim, 2L)
      match v.data {
        FloatVector(a) => assert_eq(a.data, [0.1, 0.2, 0.3, 0.4])
        _ => fail("expected FloatVector")
      }
    }
    _ => fail("expected Vectors")
  }
}

///|
async test "insert 的列行数不一致时报错" {
  let client = test_client([(@client.insert_path, encode(ok_status()))])
  let (client, recorded) = client
  let mut raised = false
  ignore(
    client.insert(
      @client.new_write_option("demo", [
        @client.WriteColumn::new("id", @column.ColumnValue::Int64([1L, 2L])),
        @client.WriteColumn::new(
          "vector",
          @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
        ),
      ]),
    ),
  ) catch {
    _ => raised = true
  }
  assert_true(raised)
  assert_eq(recorded.val.length(), 0)
}

///|
async test "upsert 把 partial_update 带上去" {
  let response = @milvus.MutationResult::{
    status: Some(ok_status()),
    ids: None,
    succ_index: [],
    err_index: [],
    acknowledged: true,
    insert_cnt: 0L,
    delete_cnt: 0L,
    upsert_cnt: 1L,
    timestamp: 7UL,
  }
  let client = test_client([(@client.upsert_path, encode(response))])
  let (client, recorded) = client
  let _ = client.upsert(
    @client.new_write_option("demo", [
      @client.WriteColumn::new("id", @column.ColumnValue::Int64([1L])),
    ]).with_partial_update(),
  ) catch {
    _ => fail("upsert should succeed")
  }
  let request : @milvus.UpsertRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_true(request.partial_update)
  assert_eq(request.num_rows, 1U)
}

///|
async test "delete 按主键拼表达式" {
  let response = @milvus.MutationResult::{
    status: Some(ok_status()),
    ids: None,
    succ_index: [],
    err_index: [],
    acknowledged: true,
    insert_cnt: 0L,
    delete_cnt: 3L,
    upsert_cnt: 0L,
    timestamp: 5UL,
  }
  let client = test_client([(@client.delete_path, encode(response))])
  let (client, recorded) = client
  let result = client.delete(
    @client.delete_by_int64_ids("demo", "id", [1L, 2L, 3L]),
  ) catch {
    _ => fail("delete should succeed")
  }
  assert_eq(result.delete_count, 3L)
  let request : @milvus.DeleteRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(request.expr, "id in [1,2,3]")
  assert_eq(request.consistency_level, @common.ConsistencyLevel::Strong)
}

///|
async test "search 编出占位符与 search_params" {
  let ids = @schema.IDs::{
    id_field: @schema.IDs_IdField::IntId(@schema.LongArray::LongArray([7L])),
  }
  let data = @schema.SearchResultData::{
    num_queries: 1L,
    top_k: 2L,
    fields_data: [],
    scores: [0.9],
    ids: Some(ids),
    topks: [1L],
    output_fields: ["id"],
    group_by_field_value: None,
    all_search_count: 0L,
    distances: [],
    recalls: [],
    primary_field_name: "id",
    element_indices: None,
    group_by_field_values: [],
  }
  let response = @milvus.SearchResults::{
    status: Some(ok_status()),
    results: Some(data),
    collection_name: "demo",
    session_ts: 0UL,
  }
  let client = test_client([(@client.search_path, encode(response))])
  let (client, recorded) = client
  let result = client.search(
    @client.new_search_option("demo", 2, [
      @column.ColumnValue::FloatVector(4, [[0.1, 0.2, 0.3, 0.4]]),
    ])
    .with_anns_field("vector")
    .with_metric_type(@index.MetricType::L2)
    .with_output_fields(["id"]),
  ) catch {
    _ => fail("search should succeed")
  }
  assert_eq(result.hits.length(), 1)
  assert_eq(result.hits[0].id, "7")
  assert_false(result.hits[0].string_id)
  assert_eq(result.hits[0].score, 0.9)
  let request : @milvus.SearchRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
  assert_eq(request.nq, 1L)
  assert_eq(request.dsl_type, @common.DslType::BoolExprV1)
  // 没有显式设一致性 -> 用默认档，并把 use_default_consistency 置真
  assert_true(request.use_default_consistency)
  assert_eq(request.consistency_level, @common.ConsistencyLevel::Bounded)
  // search_params 是「固定七个键 + 调用方覆盖」的集合
  let params : Map[String, String] = Map([])
  for pair in request.search_params {
    params[pair.key] = pair.value
  }
  assert_eq(params[@client.search_param_anns_field], "vector")
  assert_eq(params[@client.search_param_topk], "2")
  assert_eq(params[@client.search_param_offset], "0")
  assert_eq(params[@client.search_param_metric_type], "L2")
  assert_eq(params[@client.search_param_round_decimal], "-1")
  assert_eq(params[@client.search_param_ignore_growing], "false")
  assert_eq(params[@client.search_param_params], "{}")
  // 占位符解出来是 float32 的四行一组的形态
  match request.search_input {
    PlaceholderGroup(bytes) => {
      let group : @common.PlaceholderGroup = @lib.Read::read_with_limit(
        @lib.LimitedReader::LimitedReader(@lib.BytesReader::from_bytes(bytes)),
      )
      assert_eq(group.placeholders.length(), 1)
      assert_eq(group.placeholders[0].tag, "$0")
      assert_eq(
        group.placeholders[0].type_,
        @common.PlaceholderType::FloatVector,
      )
      assert_eq(group.placeholders[0].values.length(), 1)
      // float32 小端 [0.1, 0.2, 0.3, 0.4] 的第一个字节可以对照
      assert_eq(group.placeholders[0].values[0].length(), 16)
    }
    _ => fail("expected PlaceholderGroup")
  }
}

///|
async test "search 没有查询向量时不发请求" {
  let client = test_client([(@client.search_path, encode(ok_status()))])
  let (client, recorded) = client
  let mut raised = false
  ignore(client.search(@client.new_search_option("demo", 2, []))) catch {
    _ => raised = true
  }
  assert_true(raised)
  assert_eq(recorded.val.length(), 0)
}

///|
async test "search 的字符串主键带 string_id 标记" {
  let data = @schema.SearchResultData::{
    num_queries: 1L,
    top_k: 1L,
    fields_data: [],
    scores: [0.5],
    ids: Some(@schema.IDs::{
      id_field: @schema.IDs_IdField::StrId(
        @schema.StringArray::StringArray(["alpha"]),
      ),
    }),
    topks: [1L],
    output_fields: [],
    group_by_field_value: None,
    all_search_count: 0L,
    distances: [],
    recalls: [],
    primary_field_name: "name",
    element_indices: None,
    group_by_field_values: [],
  }
  let response = @milvus.SearchResults::{
    status: Some(ok_status()),
    results: Some(data),
    collection_name: "demo",
    session_ts: 0UL,
  }
  let (client, _) = test_client([(@client.search_path, encode(response))])
  let result = client.search(
    @client.new_search_option("demo", 1, [
      @column.ColumnValue::FloatVector(2, [[0.0, 0.0]]),
    ]),
  ) catch {
    _ => fail("search should succeed")
  }
  assert_eq(result.hits[0].id, "alpha")
  assert_true(result.hits[0].string_id)
}

///|
async test "query 解出列" {
  let id_field = @schema.FieldData::{
    type_: @schema.DataType::Int64,
    field_name: "id",
    field_id: 100L,
    is_dynamic: false,
    valid_data: [],
    field: @schema.FieldData_Field::Scalars(@schema.ScalarField::{
      valid_data: [],
      data: @schema.ScalarField_Data::LongData(
        @schema.LongArray::LongArray([1L, 2L]),
      ),
    }),
  }
  let response = @milvus.QueryResults::{
    status: Some(ok_status()),
    fields_data: [id_field],
    collection_name: "demo",
    output_fields: ["id"],
    session_ts: 0UL,
    primary_field_name: "id",
  }
  let client = test_client([(@client.query_path, encode(response))])
  let (client, recorded) = client
  let result = client.query(
    @client.new_query_option("demo").with_filter("id > 0").with_limit(10),
  ) catch {
    _ => fail("query should succeed")
  }
  assert_eq(result.len(), 2)
  assert_true(result.has_column("id"))
  let column = match result.column("id") {
    Some(column) => column
    None => fail("id column expected")
  }
  let values = column.get(1) catch { _ => fail("row 1 expected") }
  assert_eq(values, @column.Cell::Int64(2L))
  let request : @milvus.QueryRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(request.expr, "id > 0")
  let params : Map[String, String] = Map([])
  for pair in request.query_params {
    params[pair.key] = pair.value
  }
  assert_eq(params[@client.query_param_limit], "10")
}

///|
async test "query 不带 limit 时也发默认 limit" {
  // Milvus 对没带 limit 的 Query 会全量返回，而不是「默认 16384」。
  // 上游每次都把 limit 显式写进 query_params，这里必须照做。
  let response = @milvus.QueryResults::{
    status: Some(ok_status()),
    fields_data: [],
    collection_name: "demo",
    output_fields: [],
    session_ts: 0UL,
    primary_field_name: "id",
  }
  let (client, recorded) = test_client([(@client.query_path, encode(response))])
  let _ = client.query(@client.new_query_option("demo").with_filter("id > 0")) catch {
    _ => fail("query should succeed")
  }
  let request : @milvus.QueryRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  let params : Map[String, String] = Map([])
  for pair in request.query_params {
    params[pair.key] = pair.value
  }
  assert_eq(
    params[@client.query_param_limit],
    @client.default_query_limit.to_string(),
  )
}

///|
async test "with_limit 覆盖默认值而不是追加一条" {
  let response = @milvus.QueryResults::{
    status: Some(ok_status()),
    fields_data: [],
    collection_name: "demo",
    output_fields: [],
    session_ts: 0UL,
    primary_field_name: "id",
  }
  let (client, recorded) = test_client([(@client.query_path, encode(response))])
  let _ = client.query(@client.new_query_option("demo").with_limit(7)) catch {
    _ => fail("query should succeed")
  }
  let request : @milvus.QueryRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  let limits : Array[String] = []
  for pair in request.query_params {
    if pair.key == @client.query_param_limit {
      limits.push(pair.value)
    }
  }
  assert_eq(limits, ["7"])
}

///|
async test "load_collection 编出请求并认 OK" {
  let (client, recorded) = test_client([
    (@client.load_collection_path, encode(ok_status())),
  ])
  let mut raised = false
  ignore(client.load_collection(@client.new_load_collection_option("demo"))) catch {
    _ => raised = true
  }
  assert_false(raised)
  let calls = recorded.val
  assert_eq(calls.length(), 1)
  assert_eq(calls[0].path, @client.load_collection_path)
  let request : @milvus.LoadCollectionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(calls[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
  // 不显式设副本数时留 0，由服务端取默认值
  assert_eq(request.replica_number, 0)
  assert_false(request.refresh)
  assert_false(request.skip_load_dynamic_field)
  assert_eq(request.resource_groups.length(), 0)
  assert_eq(request.load_fields.length(), 0)
  assert_eq(request.load_params.length(), 0)
}

///|
async test "load_collection 把 load_params 与部分加载字段带上去" {
  let (client, recorded) = test_client([
    (@client.load_collection_path, encode(ok_status())),
  ])
  let option = @client.new_load_collection_option("demo").with_replica_number(2)
  let option = { ..option, resource_groups: ["rg1"], load_fields: ["vector"], }
  let option = {
    ..option,
    skip_load_dynamic_field: true,
    load_params: [("mmap.enabled", "true")],
  }
  let _ = client.load_collection(option) catch { _ => () }
  let calls = recorded.val
  let request : @milvus.LoadCollectionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(calls[0].body),
    ),
  )
  assert_eq(request.replica_number, 2)
  assert_eq(request.resource_groups, ["rg1"])
  assert_eq(request.load_fields, ["vector"])
  assert_true(request.skip_load_dynamic_field)
  assert_eq(request.load_params.get("mmap.enabled"), Some("true"))
}

///|
async test "release_collection 打的是 ReleaseCollection 路径" {
  let (client, recorded) = test_client([
    (@client.release_collection_path, encode(ok_status())),
  ])
  let _ = client.release_collection(@client.new_drop_collection_option("demo")) catch {
    _ => ()
  }
  let calls = recorded.val
  assert_eq(calls.length(), 1)
  assert_eq(calls[0].path, @client.release_collection_path)
  let request : @milvus.ReleaseCollectionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(calls[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
}

///|
async test "load_collection 被服务端拒绝时抛 Server" {
  let failure = @common.Status::{
    error_code: @common.ErrorCode::UnexpectedError,
    reason: "collection not found",
    code: 100,
    retriable: false,
    detail: "",
    extra_info: {},
  }
  let (client, _) = test_client([
    (@client.load_collection_path, encode(failure)),
  ])
  let outcome : Result[Unit, @client.ClientError] = try {
    ignore(client.load_collection(@client.new_load_collection_option("x")))
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a server error")
    Err(Server(err)) => assert_eq(@errors.error_code(Some(err)), 100)
    Err(_) => fail("expected Server")
  }
}

///|
async test "get_load_state 解出四种状态" {
  let cases : Array[(@common.LoadState, @client.CollectionLoadState)] = [
    (
      @common.LoadState::LoadStateNotExist,
      @client.CollectionLoadState::NotExist,
    ),
    (@common.LoadState::LoadStateNotLoad, @client.CollectionLoadState::NotLoad),
    (@common.LoadState::LoadStateLoading, @client.CollectionLoadState::Loading),
    (@common.LoadState::LoadStateLoaded, @client.CollectionLoadState::Loaded),
  ]
  for pair in cases {
    let response = @milvus.GetLoadStateResponse::{
      status: Some(ok_status()),
      state: pair.0,
    }
    let (client, recorded) = test_client([
      (@client.get_load_state_path, encode(response)),
    ])
    let state = client.get_load_state(
      @client.new_describe_collection_option("demo"),
    ) catch {
      _ => fail("expected a load state")
    }
    assert_eq(state, pair.1)
    let request : @milvus.GetLoadStateRequest = @lib.Read::read_with_limit(
      @lib.LimitedReader::LimitedReader(
        @lib.BytesReader::from_bytes(recorded.val[0].body),
      ),
    )
    assert_eq(request.collection_name, "demo")
  }
}

///|
async test "get_load_state 的未知枚举值单列出来" {
  // 99 不在 LoadState 的定义里，生成物会落到 Unknown 岔路。
  // 上层靠它区分「没见过的状态」和「那就是没加载」。
  let response = @milvus.GetLoadStateResponse::{
    status: Some(ok_status()),
    state: @common.LoadState::Unknown(@lib.Enum(99)),
  }
  let (client, _) = test_client([
    (@client.get_load_state_path, encode(response)),
  ])
  let state = client.get_load_state(
    @client.new_describe_collection_option("demo"),
  ) catch {
    _ => fail("expected a load state")
  }
  assert_eq(state, @client.CollectionLoadState::Unknown(99))
}

///|
async test "create_index 把 Index 装配成 extra_params" {
  let (client, recorded) = test_client([
    (@client.create_index_path, encode(ok_status())),
  ])
  let index = @index.new_hnsw_index(@index.MetricType::COSINE)
    .with_name("vec_idx")
    .with_extra_params(@index.IndexParams::from_pairs([("M", "16")]))
  let mut raised = false
  ignore(
    client.create_index(
      @client.new_create_index_option("demo", "vector", index),
    ),
  ) catch {
    _ => raised = true
  }
  assert_false(raised)
  let calls = recorded.val
  assert_eq(calls[0].path, @client.create_index_path)
  let request : @milvus.CreateIndexRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(calls[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
  assert_eq(request.field_name, "vector")
  assert_eq(request.index_name, "vec_idx")
  // index_type / metric_type 由 Index 装配，M 由调用方经 extra params 带进来
  let params = Map::from_array(request.extra_params.map(p => (p.key, p.value)))
  assert_eq(params.get("metric_type"), Some("COSINE"))
  assert_eq(params.get("index_type"), Some("HNSW"))
  assert_eq(params.get("M"), Some("16"))
}

///|
async test "describe_index 解出索引描述与状态" {
  let response = @milvus.DescribeIndexResponse::{
    status: Some(ok_status()),
    index_descriptions: [
      @milvus.IndexDescription::{
        index_name: "vec_idx",
        index_id: 7L,
        params: [
          @common.KeyValuePair::KeyValuePair("index_type", "HNSW"),
          @common.KeyValuePair::KeyValuePair("metric_type", "L2"),
        ],
        field_name: "vector",
        indexed_rows: 10L,
        total_rows: 10L,
        state: @common.IndexState::Finished,
        index_state_fail_reason: "",
        pending_index_rows: 0L,
        min_index_version: 0,
        max_index_version: 0,
      },
    ],
  }
  let (client, recorded) = test_client([
    (@client.describe_index_path, encode(response)),
  ])
  let descriptions = client.describe_index(
    @client.new_describe_index_option("demo"),
  ) catch {
    _ => fail("expected index descriptions")
  }
  assert_eq(descriptions.length(), 1)
  let d = descriptions[0]
  assert_eq(d.index_name, "vec_idx")
  assert_eq(d.index_id, 7L)
  assert_eq(d.field_name, "vector")
  assert_eq(d.state, @index.IndexState::Finished)
  assert_true(d.state.is_terminal())
  assert_eq(d.index_type(), Some(@index.IndexType::HNSW))
  assert_eq(d.metric_type(), Some(@index.MetricType::L2))
  let request : @milvus.DescribeIndexRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
  // 默认不按字段/名字过滤，即「列全部」
  assert_eq(request.field_name, "")
  assert_eq(request.index_name, "")
}

///|
async test "describe_index 把未知的构建状态单列出来" {
  let response = @milvus.DescribeIndexResponse::{
    status: Some(ok_status()),
    index_descriptions: [
      @milvus.IndexDescription::{
        index_name: "i",
        index_id: 1L,
        params: [],
        field_name: "vector",
        indexed_rows: 0L,
        total_rows: 0L,
        state: @common.IndexState::Unknown(@lib.Enum(42)),
        index_state_fail_reason: "",
        pending_index_rows: 0L,
        min_index_version: 0,
        max_index_version: 0,
      },
    ],
  }
  let (client, _) = test_client([
    (@client.describe_index_path, encode(response)),
  ])
  let descriptions = client.describe_index(
    @client.new_describe_index_option("demo"),
  ) catch {
    _ => fail("expected index descriptions")
  }
  assert_eq(descriptions[0].state, @index.IndexState::Unknown(42))
  assert_false(descriptions[0].state.is_terminal())
}

///|
async test "drop_index 打的是 DropIndex 路径并带上索引名" {
  let (client, recorded) = test_client([
    (@client.drop_index_path, encode(ok_status())),
  ])
  let _ = client.drop_index(@client.new_drop_index_option("demo", "vec_idx")) catch {
    _ => ()
  }
  let calls = recorded.val
  assert_eq(calls[0].path, @client.drop_index_path)
  let request : @milvus.DropIndexRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(calls[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
  assert_eq(request.index_name, "vec_idx")
}

///|
async test "服务端拒绝变成 Server 错误" {
  let failure = @common.Status::{
    error_code: @common.ErrorCode::UnexpectedError,
    reason: "boom",
    code: 1,
    retriable: true,
    detail: "line 1\nline 2",
    extra_info: {},
  }
  let (client, _) = test_client([
    (@client.drop_collection_path, encode(failure)),
  ])
  let outcome : Result[Unit, @client.ClientError] = try {
    ignore(client.drop_collection(@client.new_drop_collection_option("x")))
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a server error")
    Err(Server(err)) => {
      assert_true(@errors.is_retryable_err(Some(err)))
      assert_true(@errors.is_retryable_err(Some(err)))
    }
    Err(_) => fail("expected Server")
  }
}

///|
async test "传输失败原样透传" {
  let config = @transport.Config::new("127.0.0.1:19530")
  let call : @client.Unary = (_, _) => {
    raise @transport.RpcError::new(
      @transport.Code::Unavailable.to_int(),
      "connection refused",
    )
  }
  let client = @client.Client::new(config, call)
  let outcome : Result[Unit, @client.ClientError] = try {
    ignore(client.drop_collection(@client.new_drop_collection_option("x")))
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a transport error")
    Err(err) => {
      assert_true(err.is_transport())
      // UNAVAILABLE 是传输层里可重试的一类，与 @transport 的判定一致
      assert_true(err.is_retryable())
    }
  }
}

///|
async test "响应字节坏掉时报 Decode" {
  // 字段号 2（reason）、wire type 2（长度前缀），声明的长度是 10 但一个字节都没有
  let (client, _) = test_client([(@client.drop_collection_path, b"\x12\x0a")])
  let outcome : Result[Unit, @client.ClientError] = try {
    ignore(client.drop_collection(@client.new_drop_collection_option("x")))
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a decode error")
    Err(Decode(_)) => ()
    Err(_) => fail("expected Decode")
  }
}
