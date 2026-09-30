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
// 移植自 milvus-io/milvus client/milvusclient/{read.go,read_options.go}
// 的 `Search` / `AnnRequest.searchRequest` 那一路（Apache-2.0）。
//
// 上游把 `SearchResults.results`（`schema.SearchResultData`）按 `topks`
// 切成每个 query 一个 `ResultSet`，每个 `ResultSet` 里再按输出字段摊成
// 列。本移植保留「按 query 切」这一层，但不把自己伪装成带 schema 的
// `ResultSet` —— 输出字段的列直接从响应里按名字取。

///|
/// `search_params` 里服务端认的键。字面量与上游逐条对齐。
pub let search_param_anns_field : String = "anns_field"

///|
pub let search_param_topk : String = "topk"

///|
pub let search_param_offset : String = "offset"

///|
pub let search_param_metric_type : String = "metric_type"

///|
pub let search_param_round_decimal : String = "round_decimal"

///|
pub let search_param_ignore_growing : String = "ignore_growing"

///|
pub let search_param_params : String = "params"

///|
/// 一条命中。`id` 是主键的文本形式：整数主键与字符串主键都收敛到
/// `String`，因为 `Hit` 的消费方几乎总是拿它去查行，而不是做算术。
///
/// `string_id` 只对字符串主键为真，用来区分「主键就是 `"12"`」和
/// 「整数主键 12」。
pub(all) struct SearchHit {
  id : String
  string_id : Bool
  score : Float
  fields : Map[String, @column.ColumnValue]
} derive(Debug)

///|
/// 一次 query 的全部命中，按分数降序（服务端保证的距离序）。
pub(all) struct SearchResult {
  hits : Array[SearchHit]
} derive(Debug)

///|
/// 检索的入参。对应上游 `searchOption` + `AnnRequest` 里本移植覆盖的那部分。
pub(all) struct SearchOption {
  collection_name : String
  partition_names : Array[String]
  anns_field : String
  limit : Int
  vectors : Array[@column.ColumnValue]
  expr : String
  output_fields : Array[String]
  metric_type : @index.MetricType?
  search_params : Array[(String, String)]
  offset : Int
  ignore_growing : Bool
  round_decimal : Int
  consistency_level : ConsistencyLevel?
}

///|
/// 记一个查询向量。每个元素是「一行」，也就是说：
/// `FloatVector(dim, [v1, v2])` 表示 nq = 2、每行 dim 维。
pub fn new_search_option(
  collection_name : String,
  limit : Int,
  vectors : Array[@column.ColumnValue],
) -> SearchOption {
  {
    collection_name,
    partition_names: [],
    anns_field: "",
    limit,
    vectors,
    expr: "",
    output_fields: [],
    metric_type: None,
    search_params: [],
    offset: 0,
    ignore_growing: false,
    round_decimal: -1,
    consistency_level: None,
  }
}

///|
pub fn SearchOption::with_anns_field(
  self : SearchOption,
  anns_field : String,
) -> SearchOption {
  { ..self, anns_field, }
}

///|
pub fn SearchOption::with_filter(
  self : SearchOption,
  expr : String,
) -> SearchOption {
  { ..self, expr, }
}

///|
pub fn SearchOption::with_output_fields(
  self : SearchOption,
  output_fields : Array[String],
) -> SearchOption {
  { ..self, output_fields, }
}

///|
pub fn SearchOption::with_partitions(
  self : SearchOption,
  partition_names : Array[String],
) -> SearchOption {
  { ..self, partition_names, }
}

///|
pub fn SearchOption::with_metric_type(
  self : SearchOption,
  metric_type : @index.MetricType,
) -> SearchOption {
  { ..self, metric_type: Some(metric_type), }
}

///|
pub fn SearchOption::with_search_param(
  self : SearchOption,
  key : String,
  value : String,
) -> SearchOption {
  let search_params : Array[(String, String)] = []
  let mut replaced = false
  for pair in self.search_params {
    if pair.0 == key {
      search_params.push((key, value))
      replaced = true
    } else {
      search_params.push(pair)
    }
  }
  if !replaced {
    search_params.push((key, value))
  }
  { ..self, search_params, }
}

///|
pub fn SearchOption::with_offset(
  self : SearchOption,
  offset : Int,
) -> SearchOption {
  { ..self, offset, }
}

///|
pub fn SearchOption::with_ignore_growing(
  self : SearchOption,
  ignore_growing? : Bool = true,
) -> SearchOption {
  { ..self, ignore_growing, }
}

///|
pub fn SearchOption::with_round_decimal(
  self : SearchOption,
  round_decimal : Int,
) -> SearchOption {
  { ..self, round_decimal, }
}

///|
pub fn SearchOption::with_consistency_level(
  self : SearchOption,
  level : ConsistencyLevel,
) -> SearchOption {
  { ..self, consistency_level: Some(level), }
}

///|
/// 占位符对应的 `common.PlaceholderType`。
///
/// 只有第一行决定类型 —— 与上游 `vector2Placeholder` 一致，
/// 混合类型的一批向量会被服务端按第一批的类型解析，早点在本地报错更好。
fn placeholder_type(
  vectors : Array[@column.ColumnValue],
) -> @common.PlaceholderType raise ClientError {
  if vectors.length() == 0 {
    raise ClientError::Encode("search requires at least one query vector")
  }
  match vectors[0] {
    FloatVector(_, _) => @common.PlaceholderType::FloatVector
    Float16Vector(_, _) => @common.PlaceholderType::Float16Vector
    BFloat16Vector(_, _) => @common.PlaceholderType::BFloat16Vector
    BinaryVector(_, _) => @common.PlaceholderType::BinaryVector
    Int8Vector(_, _) => @common.PlaceholderType::Int8Vector
    SparseFloatVector(_) => @common.PlaceholderType::SparseFloatVector
    VarChar(_) | String(_) | Text(_) => @common.PlaceholderType::VarChar
    _ =>
      raise ClientError::Encode(
        "\{column_value_type_name(vectors[0])} is not a searchable vector type",
      )
  }
}

///|
/// 一行的序列化形态。定长向量（float / fp16 / bf16 / binary / int8）在
/// wire 上是「每行一块字节」，所以这里逐行编码；稀疏向量本来就是
/// 行内不定长，`to_bytes` 已经是行编码。
fn serialize_row(
  column : @column.ColumnValue,
  index : Int,
) -> Bytes raise ClientError {
  match column {
    FloatVector(dim, rows) =>
      floats_row("FloatVector", dim, rows, index, row_to_le_bytes)
    Float16Vector(dim, rows) =>
      floats_row(
        "Float16Vector", dim, rows, index, @entity.float16_vector_bytes,
      )
    BFloat16Vector(dim, rows) =>
      floats_row(
        "BFloat16Vector", dim, rows, index, @entity.bfloat16_vector_bytes,
      )
    BinaryVector(dim, rows) => bytes_row("BinaryVector", dim / 8, rows, index)
    Int8Vector(dim, rows) => bytes_row("Int8Vector", dim, rows, index)
    SparseFloatVector(rows) => {
      if index >= rows.length() {
        raise ClientError::Encode(
          "SparseFloatVector: row \{index} is out of range (have \{rows.length()})",
        )
      }
      rows[index].to_bytes() catch {
        err => raise ClientError::Schema(entity_schema_message(err))
      }
    }
    _ =>
      raise ClientError::Encode(
        "\{column_value_type_name(column)} cannot be used as a query vector",
      )
  }
}

///|
fn floats_row(
  name : String,
  dim : Int,
  rows : Array[Array[Float]],
  index : Int,
  encode : (Array[Float]) -> Bytes,
) -> Bytes raise ClientError {
  if index >= rows.length() {
    raise ClientError::Encode(
      "\{name}: vector row \{index} is out of range (have \{rows.length()})",
    )
  }
  let row = rows[index]
  if row.length() != dim {
    raise ClientError::Encode(
      "\{name}: row \{index} has \{row.length()} values, expected \{dim}",
    )
  }
  encode(row)
}

///|
/// 定长字节行：逐行取一段。
fn bytes_row(
  name : String,
  row_bytes : Int,
  rows : Array[Bytes],
  index : Int,
) -> Bytes raise ClientError {
  if index >= rows.length() {
    raise ClientError::Encode(
      "\{name}: vector row \{index} is out of range (have \{rows.length()})",
    )
  }
  let row = rows[index]
  if row.length() != row_bytes {
    raise ClientError::Encode(
      "\{name}: row \{index} has \{row.length()} bytes, expected \{row_bytes}",
    )
  }
  row
}

///|
/// `Array[Float]` 的小端 float32 编码。
fn row_to_le_bytes(row : Array[Float]) -> Bytes {
  let buf = Buffer()
  for value in row {
    let bits = value.reinterpret_as_uint()
    buf.write_byte((bits & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((bits >> 8) & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((bits >> 16) & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((bits >> 24) & 0xFFU).reinterpret_as_int().to_byte())
  }
  buf.to_bytes()
}

///|
/// 编码成 `PlaceholderGroup` 的字节，塞进 `SearchRequest.placeholder_group`。
fn placeholder_group_bytes(
  vectors : Array[@column.ColumnValue],
) -> Bytes raise ClientError {
  let type_ = placeholder_type(vectors)
  let values : Array[Bytes] = []
  for i = 0; i < vectors.length(); i = i + 1 {
    values.push(serialize_row(vectors[i], i))
  }
  let group = @common.PlaceholderGroup::{
    placeholders: [@common.PlaceholderValue::{ tag: "$0", type_, values, }],
  }
  encode_request(group)
}

///|
/// `search_params`。上游总是把 `anns_field` / `topk` / `offset` /
/// `metric_type` / `round_decimal` / `ignore_growing` / `params` 这七个键
/// 写全（`metric_type` 为空时写空串），调用方的 `WithSearchParam`
/// 最后覆盖。这里保持同样的顺序与键集合，方便与服务端的行为对照。
fn search_params_of(option : SearchOption) -> Array[(String, String)] {
  let params : Array[(String, String)] = []
  let seen : Array[String] = []
  let push = (key : String, value : String) => {
    params.push((key, value))
    seen.push(key)
  }
  push(search_param_anns_field, option.anns_field)
  push(search_param_topk, option.limit.to_string())
  push(search_param_offset, option.offset.to_string())
  push(
    search_param_metric_type,
    match option.metric_type {
      Some(m) => m.to_string()
      None => ""
    },
  )
  push(search_param_round_decimal, option.round_decimal.to_string())
  push(search_param_ignore_growing, option.ignore_growing.to_string())
  push(search_param_params, "{}")
  for pair in option.search_params {
    if !seen.contains(pair.0) {
      params.push(pair)
    }
  }
  params
}

///|
/// 检索。
pub async fn Client::search(
  self : Client,
  option : SearchOption,
) -> SearchResult raise ClientError {
  decode_search_results(self.search_call(option).results.unwrap())
}

///|
/// 编排一次 `Search`：校验、编占位符、拼 `search_params`、发出去、查 status。
///
/// 返回值留着整个 `SearchResults`，因为 `results` 上有迭代器要的续页凭据。
/// 搜索本身与迭代器共用这一份，免得两处对「七个键的顺序」「use_default_consistency
/// 什么时候为真」各说各话。
async fn Client::search_call(
  self : Client,
  option : SearchOption,
) -> @milvus.SearchResults raise ClientError {
  if option.vectors.length() == 0 {
    raise ClientError::Encode("search requires at least one query vector")
  }
  // `nq` 是 `vectors` 的长度，服务端不接受「nq = 0」。迭代器收尾要发的
  // 那个空检索走下面的 `cancel_search` —— 它另开一个入口，因为它的
  // `search_input` 不是占位符。
  let placeholder = placeholder_group_bytes(option.vectors)
  let search_params = search_params_of(option).map(pair => {
    @common.KeyValuePair::KeyValuePair(pair.0, pair.1)
  })
  let consistency = match option.consistency_level {
    Some(level) => level.to_proto()
    None => @common.ConsistencyLevel::Bounded
  }
  let request = @milvus.SearchRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_names: option.partition_names,
    dsl: option.expr,
    search_input: @milvus.SearchRequest_SearchInput::PlaceholderGroup(
      placeholder,
    ),
    dsl_type: @common.DslType::BoolExprV1,
    output_fields: option.output_fields,
    search_params,
    travel_timestamp: 0UL,
    guarantee_timestamp: 0UL,
    nq: option.vectors.length().to_int64(),
    not_return_all_meta: false,
    consistency_level: consistency,
    use_default_consistency: option.consistency_level is None,
    namespace_: None,
  }
  let response : @milvus.SearchResults = self.call_service(search_path, request)
  match check_status(response.status) {
    Some(err) => raise err
    None => response
  }
}

///|
/// 迭代器收尾用的空检索：`nq = 0`，`search_input` 显式留空（`NotSet`）。
///
/// 服务端据 `search_iter_id` 找到那个游标会话，`nq = 0` 就表示「这批不要
/// 结果，把会话收掉」。走不了 `Client::search`：那条路要求至少一个查询向量，
/// 会用占位符填 `search_input`。
///
/// `search_params` 由调用方拼好传进来 —— 迭代器比这一层更清楚要带哪些凭据。
///
/// 包内可见：`SearchIterator` 的收尾用它，不属于门面 API。
async fn Client::cancel_search(
  self : Client,
  option : SearchOption,
) -> Unit raise ClientError {
  let search_params = option.search_params.map(pair => {
    @common.KeyValuePair::KeyValuePair(pair.0, pair.1)
  })
  let consistency = match option.consistency_level {
    Some(level) => level.to_proto()
    None => @common.ConsistencyLevel::Bounded
  }
  let request = @milvus.SearchRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_names: option.partition_names,
    dsl: option.expr,
    search_input: @milvus.SearchRequest_SearchInput::NotSet,
    dsl_type: @common.DslType::BoolExprV1,
    output_fields: [],
    search_params,
    travel_timestamp: 0UL,
    guarantee_timestamp: 0UL,
    nq: 0L,
    not_return_all_meta: false,
    consistency_level: consistency,
    use_default_consistency: option.consistency_level is None,
    namespace_: None,
  }
  let response : @milvus.SearchResults = self.call_service(search_path, request)
  match check_status(response.status) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 一次检索的原始响应 + 解好的命中。
///
/// 迭代器两条都要：命中给调用方，`SearchResultData` 上的
/// `search_iterator_v2_results` 是翻下一页的凭据，`SearchResult` 装不下它。
///
/// 包内可见，不对外 —— 外面拿到的是 `SearchResult`，需要续页凭据的是
/// 迭代器，而它在同一个包里。
struct RawSearchResult {
  data : @schema.SearchResultData
  result : SearchResult
} derive(Debug)

///|
/// 与 `Client::search` 同一条路径，只是把原始 `SearchResultData` 一并带回来。
/// 编排逻辑只有一份，见 `search_call`。包内可见，调用方是 `SearchIterator`。
async fn Client::search_raw(
  self : Client,
  option : SearchOption,
) -> RawSearchResult raise ClientError {
  let response = self.search_call(option)
  let data = response.results.unwrap()
  { data, result: decode_search_results(data), }
}

///|
/// `SearchResultData` → `SearchResult`。
///
/// 上游按 `topks` 把扁平的命中切成 nq 段；本移植把 nq 段再摊平回一条
/// `hits`，因为 `SearchByIDsOption` 之类「一次多查」的用例在本地几乎总是
/// 逐条处理。切段信息（`topks`）保留在响应里，需要时再切。
fn decode_search_results(
  data : @schema.SearchResultData,
) -> SearchResult raise ClientError {
  let total = match data.topks {
    [] => 0
    topks => {
      let mut sum = 0
      for k in topks {
        if k < 0L {
          raise ClientError::Decode("server returned a negative topk \{k}")
        }
        sum += k.to_int()
      }
      sum
    }
  }
  if data.scores.length() < total {
    raise ClientError::Decode(
      "server returned \{data.scores.length()} scores for \{total} hits",
    )
  }
  let ids = id_strings(data.ids, total)
  let score_fields : Map[String, @column.ColumnValue] = Map([])
  for field in data.fields_data {
    let column = @column.from_field_data(field) catch {
      err => raise ClientError::Decode(column_error_message(err))
    }
    score_fields[field.field_name] = column.column
  }
  let hits : Array[SearchHit] = []
  for i = 0; i < total; i = i + 1 {
    let (id, string_id) = ids[i]
    let fields : Map[String, @column.ColumnValue] = Map([])
    for pair in score_fields {
      fields[pair.0] = pair.1
    }
    hits.push({ id, string_id, score: data.scores[i], fields, })
  }
  { hits, }
}

///|
/// `schema.IDs` → 每行的 `(文本, 是否字符串主键)`。
///
/// 字符串主键的 `string_id` 为真，好让调用方区分 `"12"` 与 `12`。
fn id_strings(
  ids : @schema.IDs?,
  total : Int,
) -> Array[(String, Bool)] raise ClientError {
  let out : Array[(String, Bool)] = []
  match ids {
    None => ()
    Some(ids) =>
      match ids.id_field {
        @schema.IDs_IdField::IntId(a) =>
          for i = 0; i < total; i = i + 1 {
            if i >= a.data.length() {
              raise ClientError::Decode(
                "server returned \{a.data.length()} int ids for \{total} hits",
              )
            }
            out.push((a.data[i].to_string(), false))
          }
        @schema.IDs_IdField::StrId(a) =>
          for i = 0; i < total; i = i + 1 {
            if i >= a.data.length() {
              raise ClientError::Decode(
                "server returned \{a.data.length()} string ids for \{total} hits",
              )
            }
            out.push((a.data[i], true))
          }
        @schema.IDs_IdField::UuidId(a) =>
          for i = 0; i < total; i = i + 1 {
            if i >= a.data.length() {
              raise ClientError::Decode(
                "server returned \{a.data.length()} uuid ids for \{total} hits",
              )
            }
            out.push((bytes_to_hex(a.data[i]), true))
          }
        @schema.IDs_IdField::NotSet => ()
      }
  }
  if out.length() < total {
    raise ClientError::Decode(
      "server returned \{out.length()} ids for \{total} hits",
    )
  }
  out
}

///|
/// 16 字节 UUID 的十六进制写法。`@column` 回读时按字节保留，
/// 这里也保持同样的形态，不做 8-4-4-4-12 的加连字符美化 ——
/// 两种写法服务端都收，但一致比好看重要。
fn bytes_to_hex(bytes : Bytes) -> String {
  let digits = "0123456789abcdef"
  let parts : Array[String] = []
  for byte in bytes {
    let v = byte.to_uint()
    let high = (v >> 4).reinterpret_as_int()
    let low = (v & 0xFU).reinterpret_as_int()
    parts.push(digits[high:high + 1].to_owned())
    parts.push(digits[low:low + 1].to_owned())
  }
  parts.join("")
}
