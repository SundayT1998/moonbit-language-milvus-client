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
// 迭代器的假传输测试（#18）。
//
// 这里用的是同一套 `Recorded` / `fake_transport`（见 client_test.mbt），
// 只是响应是**队列**：迭代器天然要连发好几次同类请求，按路径回放一份
// 固定的响应不够用。
//
// 验收标准逐条对到这里：
// - 「超过单次返回上限的查询能完整遍历」→ query_iterator 连翻三批
// - 「空结果 / 最后一页边界正确」→ 空页 / 恰好一批 / 上限截断
// - 「中途 Close 不泄漏服务端资源」→ search_iterator 的收尾请求

///|
/// 按调用顺序出队的假传输。队列空了就报 `Unimplemented` —— 那说明
/// 迭代器多发了一发。
fn queued_transport(
  responses : Ref[Array[(String, Bytes)]],
  recorded : Ref[Array[Recorded]],
) -> @client.Unary {
  (path, body) => {
    let log = recorded.val
    log.push({ path, body, })
    recorded.val = log
    let queue = responses.val
    if queue.length() == 0 {
      raise @transport.RpcError::new(
        @transport.Code::Unimplemented.to_int(),
        "fake transport queue is empty, but " + path + " was called",
      )
    }
    let (expected, payload) = queue[0]
    responses.val = queue[1:].to_owned()
    if expected != path {
      raise @transport.RpcError::new(
        @transport.Code::Unimplemented.to_int(),
        "expected " + expected + ", got " + path,
      )
    }
    payload
  }
}

///|
/// 收齐所有响应后建一个客户端。
fn iter_client(
  responses : Array[(String, Bytes)],
) -> (@client.Client, Ref[Array[(String, Bytes)]], Ref[Array[Recorded]]) {
  let queue : Ref[Array[(String, Bytes)]] = Ref(responses)
  let recorded : Ref[Array[Recorded]] = Ref([])
  let config = @transport.Config::new("127.0.0.1:19530")
  (
    @client.Client::new(config, queued_transport(queue, recorded)),
    queue,
    recorded,
  )
}

///|
/// 集合 schema 响应：一个 Int64 主键 + 一个 float 向量字段。
fn describe_response(pk_type : @schema.DataType) -> Bytes raise {
  let pk_field = @schema.FieldSchema::{
    field_id: 100L,
    name: "id",
    is_primary_key: true,
    description: "",
    data_type: pk_type,
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
  }
  let vector_field = @schema.FieldSchema::{
    field_id: 101L,
    name: "vector",
    is_primary_key: false,
    description: "",
    data_type: @schema.DataType::FloatVector,
    type_params: [@common.KeyValuePair::KeyValuePair("dim", "2")],
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
  }
  let schema = @schema.CollectionSchema::{
    name: "demo",
    description: "",
    auto_id: false,
    fields: [pk_field, vector_field],
    enable_dynamic_field: false,
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
    schema: Some(schema),
    collection_id: 77L,
    virtual_channel_names: [],
    physical_channel_names: [],
    created_timestamp: 0UL,
    created_utc_timestamp: 0UL,
    shards_num: 1,
    aliases: [],
    start_positions: [],
    consistency_level: @common.ConsistencyLevel::Bounded,
    collection_name: "demo",
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
  encode(response)
}

///|
/// 一页查询结果：`id` 是 Int64 列，`name` 是字符串列。
fn query_results(ids : Array[Int64], names : Array[String]) -> Bytes raise {
  let id_field = @schema.FieldData::{
    type_: @schema.DataType::Int64,
    field_name: "id",
    field_id: 100L,
    is_dynamic: false,
    valid_data: [],
    field: @schema.FieldData_Field::Scalars(@schema.ScalarField::{
      valid_data: [],
      data: @schema.ScalarField_Data::LongData(
        @schema.LongArray::LongArray(ids),
      ),
    }),
  }
  let name_field = @schema.FieldData::{
    type_: @schema.DataType::VarChar,
    field_name: "name",
    field_id: 102L,
    is_dynamic: false,
    valid_data: [],
    field: @schema.FieldData_Field::Scalars(@schema.ScalarField::{
      valid_data: [],
      data: @schema.ScalarField_Data::StringData(
        @schema.StringArray::StringArray(names),
      ),
    }),
  }
  let response = @milvus.QueryResults::{
    status: Some(ok_status()),
    fields_data: [id_field, name_field],
    collection_name: "demo",
    output_fields: ["id", "name"],
    session_ts: 0UL,
    primary_field_name: "id",
  }
  encode(response)
}

///|
/// 空的一页：没有列。
fn empty_query_results() -> Bytes raise {
  let response = @milvus.QueryResults::{
    status: Some(ok_status()),
    fields_data: [],
    collection_name: "demo",
    output_fields: [],
    session_ts: 0UL,
    primary_field_name: "id",
  }
  encode(response)
}

///|
/// 一页检索结果：`ids` 条命中、`scores` 条分数，外加续页凭据。
fn search_results(
  ids : Array[Int64],
  scores : Array[Float],
  token : String,
  last_bound : Float,
) -> Bytes raise {
  let data = @schema.SearchResultData::{
    num_queries: 1L,
    top_k: ids.length().to_int64(),
    fields_data: [],
    scores,
    ids: Some(@schema.IDs::{
      id_field: @schema.IDs_IdField::IntId(@schema.LongArray::LongArray(ids)),
    }),
    topks: [ids.length().to_int64()],
    output_fields: [],
    group_by_field_value: None,
    all_search_count: 0L,
    distances: [],
    search_iterator_v2_results: Some(
      @schema.SearchIteratorV2Results::SearchIteratorV2Results(
        token, last_bound,
      ),
    ),
    recalls: [],
    primary_field_name: "id",
    element_indices: None,
    group_by_field_values: [],
  }
  let response = @milvus.SearchResults::{
    status: Some(ok_status()),
    results: Some(data),
    collection_name: "demo",
    session_ts: 9UL,
  }
  encode(response)
}

///|
/// 请求里的 `query_params` / `search_params`，摊成 Map 方便断言。

///|
/// 一页只有 `name` 列、没有主键的响应 —— 用来验证「服务端没回主键」这条。
fn only_name_payload() -> Bytes raise {
  let name_field = @schema.FieldData::{
    type_: @schema.DataType::VarChar,
    field_name: "name",
    field_id: 102L,
    is_dynamic: false,
    valid_data: [],
    field: @schema.FieldData_Field::Scalars(@schema.ScalarField::{
      valid_data: [],
      data: @schema.ScalarField_Data::StringData(
        @schema.StringArray::StringArray(["a"]),
      ),
    }),
  }
  encode(@milvus.QueryResults::{
    status: Some(ok_status()),
    fields_data: [name_field],
    collection_name: "demo",
    output_fields: ["name"],
    session_ts: 0UL,
    primary_field_name: "id",
  })
}

///|
fn param_map(pairs : Array[@common.KeyValuePair]) -> Map[String, String] {
  let map : Map[String, String] = Map([])
  for pair in pairs {
    map[pair.key] = pair.value
  }
  map
}

///|
/// 第 `n` 次调用的请求体，解码成 `QueryRequest`。
fn query_request_at(
  recorded : Ref[Array[Recorded]],
  n : Int,
) -> @milvus.QueryRequest raise {
  @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[n].body),
    ),
  )
}

///|
/// 第 `n` 次调用的请求体，解码成 `SearchRequest`。
fn search_request_at(
  recorded : Ref[Array[Recorded]],
  n : Int,
) -> @milvus.SearchRequest raise {
  @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[n].body),
    ),
  )
}

///|
fn id_column(page : @client.QueryResult) -> @column.Column raise {
  match page.column("id") {
    Some(column) => column
    None => fail("id column expected")
  }
}

///|
fn ids_of(page : @client.QueryResult) -> Array[Int64] raise {
  let column = id_column(page)
  let out : Array[Int64] = []
  for i = 0; i < column.len(); i = i + 1 {
    out.push(column.get_as_int64(i) catch { _ => fail("int64 expected") })
  }
  out
}

///|
async test "query_iterator 连翻三批，第三批空即收尾" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.query_path, query_results([1L, 2L], ["a", "b"])),
    (@client.query_path, query_results([3L], ["c"])),
    (@client.query_path, empty_query_results()),
  ])
  let iterator = client.query_iterator(
    @client.new_query_iterator_option("demo")
    .with_output_fields(["name"])
    .with_batch_size(2),
  ) catch {
    _ => fail("query_iterator should succeed")
  }
  // 第一批
  let first = iterator.next() catch { _ => fail("first batch expected") }
  assert_eq(ids_of(first), [1L, 2L])
  assert_eq(first.len(), 2)
  // 第一批的请求：没有游标，只有 limit=batch_size
  let first_request = query_request_at(recorded, 1)
  assert_eq(first_request.expr, "")
  let params = param_map(first_request.query_params)
  assert_eq(params[@client.iterator_key], "true")
  assert_eq(params[@client.query_param_limit], "2")
  // 主键被补进 output_fields（调用方只给了 name）
  assert_eq(first_request.output_fields, ["name", "id"])
  // 第二批：表达式里带上游标
  let second = iterator.next() catch { _ => fail("second batch expected") }
  assert_eq(ids_of(second), [3L])
  assert_eq(query_request_at(recorded, 2).expr, "id > 2")
  // 第三批：服务端回空
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected EndOfIterator")
    Err(err) => assert_true(err.is_end_of_iterator())
  }
  // 取空之后迭代器自己收尾了：内部状态一致，也对调用方报 EndOfIterator
  assert_true(iterator.is_closed())
  // 收尾之后再问一次还是 EndOfIterator，而不是又发一发
  let again : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match again {
    Ok(_) => fail("expected EndOfIterator")
    Err(err) => assert_true(err.is_end_of_iterator())
  }
  assert_eq(recorded.val.length(), 4)
}

///|
async test "query_iterator 把 filter 与主键游标用 and 拼起来" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.query_path, query_results([7L], ["x"])),
    (@client.query_path, empty_query_results()),
  ])
  let iterator = client.query_iterator(
    @client.new_query_iterator_option("demo")
    .with_filter("  name != \"skip\"  ")
    .with_batch_size(1),
  ) catch {
    _ => fail("query_iterator should succeed")
  }
  let _ = iterator.next() catch { _ => fail("first batch expected") }
  ignore(iterator.next()) catch {
    _ => ()
  }
  // 第一批发的是原样的用户表达式（上游不 trim）
  assert_eq(query_request_at(recorded, 1).expr, "  name != \"skip\"  ")
  // 第二批发的是 (用户表达式去空白) and id > 7 —— 上游是 `strings.TrimSpace`
  assert_eq(query_request_at(recorded, 2).expr, "(name != \"skip\") and id > 7")
}

///|
async test "query_iterator 字符串主键的游标带双引号" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::VarChar),
    ),
    (@client.query_path, query_results([], [])),
  ])
  let iterator = client.query_iterator(
    @client.new_query_iterator_option("demo").with_batch_size(1),
  ) catch {
    _ => fail("query_iterator should succeed")
  }
  ignore(iterator.next()) catch {
    _ => ()
  }
  assert_eq(recorded.val.length(), 2)
}

///|
async test "query_iterator 上限到了就不再发请求" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.query_path, query_results([1L, 2L], ["a", "b"])),
  ])
  let iterator = client.query_iterator(
    @client.new_query_iterator_option("demo").with_batch_size(2).with_limit(2L),
  ) catch {
    _ => fail("query_iterator should succeed")
  }
  let batch = iterator.next() catch { _ => fail("first batch expected") }
  assert_eq(batch.len(), 2)
  // 上限正好用完：下一批直接 EndOfIterator，不再问服务端
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected EndOfIterator")
    Err(err) => assert_true(err.is_end_of_iterator())
  }
  // 上限正好用完：只发了 DescribeCollection + 一批，没有第二发
  assert_eq(recorded.val.length(), 2)
}

///|
async test "query_iterator 上限不跨批截断" {
  let (client, _, _) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.query_path, query_results([1L, 2L, 3L], ["a", "b", "c"])),
  ])
  let iterator = client.query_iterator(
    @client.new_query_iterator_option("demo").with_batch_size(3).with_limit(2L),
  ) catch {
    _ => fail("query_iterator should succeed")
  }
  // 上限 2、批大小 3：服务端给了 3 行，原样返回 3 行。
  // 这是与上游不同的地方，见 iterator.mbt 文件头第 2 条。
  let batch = iterator.next() catch { _ => fail("first batch expected") }
  assert_eq(batch.len(), 3)
}

///|
async test "query_iterator 批大小非正数时报 Setup" {
  let (client, _, recorded) = iter_client([])
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(
      client.query_iterator(
        @client.new_query_iterator_option("demo").with_batch_size(0),
      ),
    )
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a setup error")
    Err(err) =>
      assert_false(err.is_end_of_iterator()) catch {
        _ => fail("is_end_of_iterator should not raise")
      }
  }
  // 校验不过就不该发请求
  assert_eq(recorded.val.length(), 0)
}

///|
async test "query_iterator 主键不可排序时报 Setup" {
  let (client, _, _) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Bool),
    ),
  ])
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(client.query_iterator(@client.new_query_iterator_option("demo")))
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a setup error")
    Err(Setup(msg)) => assert_true(msg.contains("Int64 or VarChar"))
    Err(_) => fail("expected Setup")
  }
}

///|
async test "query_iterator 服务端没回主键列时报 Setup" {
  let (client, _, _) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.query_path, only_name_payload()),
  ])
  let iterator = client.query_iterator(
    @client.new_query_iterator_option("demo").with_batch_size(1),
  ) catch {
    _ => fail("query_iterator should succeed")
  }
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a setup error")
    Err(Setup(msg)) => assert_true(msg.contains("primary key column"))
    Err(_) => fail("expected Setup")
  }
}

///|
async test "query_iterator Close 之后报 Closed" {
  let (client, _, _) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
  ])
  let iterator = client.query_iterator(
    @client.new_query_iterator_option("demo"),
  ) catch {
    _ => fail("query_iterator should succeed")
  }
  iterator.close()
  assert_true(iterator.is_closed())
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected Closed")
    Err(err) => assert_true(err.is_closed())
  }
}

///|
async test "query_iterator 传输失败原样抬成 Rpc" {
  let config = @transport.Config::new("127.0.0.1:19530")
  // 第一次 DescribeCollection 就断线
  let call : @client.Unary = (_, _) => {
    raise @transport.RpcError::new(
      @transport.Code::Unavailable.to_int(),
      "connection refused",
    )
  }
  let client = @client.Client::new(config, call)
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(client.query_iterator(@client.new_query_iterator_option("demo")))
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a transport error")
    Err(err) => {
      assert_true(err.is_transport_failure())
      assert_true(err.is_retryable())
    }
  }
}

///|
async test "search_iterator 连翻两批并把 token 带回去" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.search_path, search_results([7L, 8L], [0.9, 0.8], "tok-1", 0.8)),
    (@client.search_path, search_results([9L], [0.7], "tok-2", 0.7)),
    (@client.search_path, search_results([], [], "tok-3", 0.0)),
    // 翻到空后迭代器自己补的收尾一发
    (@client.search_path, search_results([], [], "tok-3", 0.0)),
  ])
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 2, [
      @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
    ])
    .with_anns_field("vector")
    .with_batch_size(2),
  ) catch {
    _ => fail("search_iterator should succeed")
  }
  // 第一批：没有游标，但有批大小与集合 ID
  let first = iterator.next() catch { _ => fail("first batch expected") }
  assert_eq(first.hits.length(), 2)
  assert_eq(first.hits[0].id, "7")
  let first_request = search_request_at(recorded, 1)
  let first_params = param_map(first_request.search_params)
  assert_eq(first_params[@client.iterator_key], "true")
  assert_eq(first_params[@client.iterator_search_v2_key], "true")
  assert_eq(first_params[@client.iterator_batch_size_key], "2")
  assert_eq(first_params[@client.iterator_collection_id_key], "77")
  assert_eq(first_params[@client.search_param_topk], "2")
  assert_false(first_params.contains(@client.iterator_search_id_key))
  // 第二批：带上一批的 token 与 last_bound
  let second = iterator.next() catch { _ => fail("second batch expected") }
  assert_eq(second.hits.length(), 1)
  let second_params = param_map(search_request_at(recorded, 2).search_params)
  assert_eq(second_params[@client.iterator_search_id_key], "tok-1")
  // `last_bound` 声明为 float32，读回来就是 0.800000011920929 —— 服务端
  // 只要求「原样带回去」，不要求它好看。
  assert_true(
    second_params[@client.iterator_search_last_bound_key].has_prefix("0.8"),
  )
  // 第三批空 -> 收尾，再发的那一发把服务端会话关掉（不带 token）
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected EndOfIterator")
    Err(err) => assert_true(err.is_end_of_iterator())
  }
  // 第三批（空）之后迭代器自己补了一发收尾请求：nq = 0、不带占位符
  let close_request = search_request_at(recorded, 4)
  assert_eq(close_request.nq, 0L)
  match close_request.search_input {
    NotSet => ()
    _ => fail("close request should carry no search input")
  }
  assert_eq(recorded.val.length(), 5)
}

///|
async test "search_iterator nq 大于 1 时报 Setup" {
  let (client, _, recorded) = iter_client([])
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(
      client.search_iterator(
        @client.new_search_iterator_option("demo", 10, [
          @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
          @column.ColumnValue::FloatVector(2, [[0.3, 0.4]]),
        ]),
      ),
    )
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a setup error")
    Err(Setup(msg)) => assert_true(msg.contains("nq = 1"))
    Err(other) => fail("unexpected: " + other.to_string())
  }
  assert_eq(recorded.val.length(), 0)
}

///|
async test "search_iterator 批大小非正数时报 Setup" {
  let (client, _, _) = iter_client([])
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(
      client.search_iterator(
        @client.new_search_iterator_option("demo", 10, [
          @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
        ]).with_batch_size(-1),
      ),
    )
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a setup error")
    Err(err) => assert_true(err.to_string().contains("batch size"))
  }
}

///|
async test "search_iterator 服务端不支持 v2 时报 Setup" {
  let without_token = @milvus.SearchResults::{
    status: Some(ok_status()),
    results: Some(@schema.SearchResultData::{
      num_queries: 1L,
      top_k: 1L,
      fields_data: [],
      scores: [0.5],
      ids: Some(@schema.IDs::{
        id_field: @schema.IDs_IdField::IntId(@schema.LongArray::LongArray([1L])),
      }),
      topks: [1L],
      output_fields: [],
      group_by_field_value: None,
      all_search_count: 0L,
      distances: [],
      search_iterator_v2_results: None,
      recalls: [],
      primary_field_name: "id",
      element_indices: None,
      group_by_field_values: [],
    }),
    collection_name: "demo",
    session_ts: 0UL,
  }
  let (client, _, _) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.search_path, encode(without_token)),
  ])
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 10, [
      @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
    ]),
  ) catch {
    _ => fail("search_iterator should succeed")
  }
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected a setup error")
    Err(Setup(msg)) => assert_true(msg.contains("search iterator v2"))
    Err(_) => fail("expected Setup")
  }
}

///|
async test "search_iterator Close 会发出收尾请求" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.search_path, search_results([7L], [0.9], "tok-1", 0.9)),
    (@client.search_path, search_results([], [], "tok-1", 0.9)),
  ])
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 10, [
      @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
    ]).with_batch_size(1),
  ) catch {
    _ => fail("search_iterator should succeed")
  }
  let _ = iterator.next() catch { _ => fail("first batch expected") }
  let closed_cleanly = iterator.close() catch {
    _ => fail("close should not raise")
  }
  assert_true(closed_cleanly)
  assert_true(iterator.is_closed())
  // 收尾请求把 token 带上（服务端据此找到那个会话），批大小写 0 ——
  // 它不是一次翻页，值是多少无所谓，写 0 是为了别让人误以为还要一批
  let close_request = search_request_at(recorded, 2)
  let params = param_map(close_request.search_params)
  assert_eq(params[@client.iterator_search_id_key], "tok-1")
  // 关掉之后再问报 Closed，不再发请求
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected Closed")
    Err(err) => assert_true(err.is_closed())
  }
  assert_eq(recorded.val.length(), 3)
}

///|
async test "search_iterator 没取过一批时 Close 不发请求" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
  ])
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 10, [
      @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
    ]),
  ) catch {
    _ => fail("search_iterator should succeed")
  }
  let closed_cleanly = iterator.close() catch {
    _ => fail("close should not raise")
  }
  assert_true(closed_cleanly)
  assert_eq(recorded.val.length(), 1)
}

///|
async test "search_iterator 收尾请求失败时 Close 返回 false" {
  let (client, _, _) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.search_path, search_results([7L], [0.9], "tok-1", 0.9)),
  ])
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 10, [
      @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
    ]).with_batch_size(1),
  ) catch {
    _ => fail("search_iterator should succeed")
  }
  let _ = iterator.next() catch { _ => fail("first batch expected") }
  // 队列已空，收尾那一发会报 Unimplemented
  let closed_cleanly = iterator.close() catch {
    _ => fail("close should not raise")
  }
  assert_false(closed_cleanly)
  assert_true(iterator.is_closed())
}

///|
async test "search_iterator 上限到了就不再发请求" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.search_path, search_results([7L, 8L], [0.9, 0.8], "tok-1", 0.8)),
  ])
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 10, [
      @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
    ])
    .with_batch_size(2)
    .with_limit(2L),
  ) catch {
    _ => fail("search_iterator should succeed")
  }
  let batch = iterator.next() catch { _ => fail("first batch expected") }
  assert_eq(batch.hits.length(), 2)
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected EndOfIterator")
    Err(err) => assert_true(err.is_end_of_iterator())
  }
  // 第一批 + 收尾请求
  assert_eq(recorded.val.length(), 3)
}

///|
async test "search_iterator 空结果第一批发完就收尾" {
  let (client, _, recorded) = iter_client([
    (
      @client.describe_collection_path,
      describe_response(@schema.DataType::Int64),
    ),
    (@client.search_path, search_results([], [], "tok-0", 0.0)),
    // 翻到空之后迭代器自己补的那一发收尾
    (@client.search_path, search_results([], [], "tok-0", 0.0)),
  ])
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 10, [
      @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
    ]),
  ) catch {
    _ => fail("search_iterator should succeed")
  }
  let outcome : Result[Unit, @client.IteratorError] = try {
    ignore(iterator.next())
    Ok(())
  } catch {
    err => Err(err)
  }
  match outcome {
    Ok(_) => fail("expected EndOfIterator")
    Err(err) => assert_true(err.is_end_of_iterator())
  }
  // 第一发（空）+ 收尾一发
  assert_eq(recorded.val.length(), 3)
  let close_request = search_request_at(recorded, 2)
  assert_eq(close_request.nq, 0L)
}
