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
// 的 `Query` / `queryOption`（Apache-2.0）。

///|
/// `query_params` 里服务端认的键。字面量与上游逐条对齐。
pub let query_param_limit : String = "limit"

///|
pub let query_param_offset : String = "offset"

///|
pub let query_param_order_by_fields : String = "order_by_fields"

///|
/// 一次查询的结果：按输出字段摊成的列，外加列名。
///
/// 上游返回带 schema 的 `ResultSet`，字段的 `DataType` 也留在列上；
/// 这里保留 `@column.ColumnValue` 的 `FieldData.type_` 信息，
/// 由 `QueryResult::column` 按名取。
pub(all) struct QueryResult {
  columns : Array[@column.Column]
  names : Array[String]
} derive(Debug)

///|
/// 结果行数。没有列时是 0。
pub fn QueryResult::len(self : QueryResult) -> Int {
  if self.columns.length() == 0 {
    0
  } else {
    self.columns[0].len()
  }
}

///|
/// `true` 表示结果里没有这一列 —— 与「列存在但全是 null」不同，
/// 后者也返回 `Some`。
pub fn QueryResult::has_column(self : QueryResult, name : String) -> Bool {
  self.names.contains(name)
}

///|
/// 按字段名取一列。
pub fn QueryResult::column(
  self : QueryResult,
  name : String,
) -> @column.Column? {
  for i = 0; i < self.names.length(); i = i + 1 {
    if self.names[i] == name {
      return Some(self.columns[i])
    }
  }
  None
}

///|
/// 查询的入参。对应上游 `queryOption`。
pub(all) struct QueryOption {
  collection_name : String
  partition_names : Array[String]
  expr : String
  output_fields : Array[String]
  query_params : Array[(String, String)]
  consistency_level : ConsistencyLevel?
}

///|
/// 上游 `NewQueryOption`：默认一致性 `Bounded`，其余空。
///
/// `limit` **不预置**，与上游一致：不传就是服务端自己的默认上限。
/// 调用方想要确定的行数就显式 `with_limit`。
pub fn new_query_option(collection_name : String) -> QueryOption {
  {
    collection_name,
    partition_names: [],
    expr: "",
    output_fields: [],
    query_params: [],
    consistency_level: None,
  }
}

///|
pub fn QueryOption::with_filter(
  self : QueryOption,
  expr : String,
) -> QueryOption {
  { ..self, expr, }
}

///|
pub fn QueryOption::with_output_fields(
  self : QueryOption,
  output_fields : Array[String],
) -> QueryOption {
  { ..self, output_fields, }
}

///|
pub fn QueryOption::with_partitions(
  self : QueryOption,
  partition_names : Array[String],
) -> QueryOption {
  { ..self, partition_names, }
}

///|
pub fn QueryOption::with_consistency_level(
  self : QueryOption,
  level : ConsistencyLevel,
) -> QueryOption {
  { ..self, consistency_level: Some(level), }
}

///|
pub fn QueryOption::with_limit(self : QueryOption, limit : Int) -> QueryOption {
  set_query_param(self, query_param_limit, limit.to_string())
}

///|
pub fn QueryOption::with_offset(
  self : QueryOption,
  offset : Int,
) -> QueryOption {
  set_query_param(self, query_param_offset, offset.to_string())
}

///|
/// 排序字段。每项写作 `name` 或 `name:asc` / `name:desc`，
/// 缺省升序；服务端要求带排序字段时必须显式给 limit。
pub fn QueryOption::with_order_by_fields(
  self : QueryOption,
  fields : Array[String],
) -> QueryOption {
  set_query_param(self, query_param_order_by_fields, fields.join(","))
}

///|
fn set_query_param(
  option : QueryOption,
  key : String,
  value : String,
) -> QueryOption {
  let query_params : Array[(String, String)] = []
  let mut replaced = false
  for pair in option.query_params {
    if pair.0 == key {
      query_params.push((key, value))
      replaced = true
    } else {
      query_params.push(pair)
    }
  }
  if !replaced {
    query_params.push((key, value))
  }
  { ..option, query_params, }
}

///|
/// 按主键查。与上游 `WithIDs` 一致，主键被拼进表达式而不是单独传 —
/// 服务端没有「按主键批量取」的字段，只有 `expr`。
pub fn QueryOption::with_int64_ids(
  self : QueryOption,
  field_name : String,
  ids : Array[Int64],
) -> QueryOption {
  let parts : Array[String] = ids.map(id => id.to_string())
  { ..self, expr: field_name + " in [" + parts.join(",") + "]", }
}

///|
pub fn QueryOption::with_string_ids(
  self : QueryOption,
  field_name : String,
  ids : Array[String],
) -> QueryOption {
  let parts : Array[String] = ids.map(id => "\"" + id + "\"")
  { ..self, expr: field_name + " in [" + parts.join(",") + "]", }
}

///|
/// 查询。
///
/// 与上游一致：响应里带了 `output_fields` 就优先用响应的那份
/// （服务端可能因为 `*` 通配或动态字段补出更多列），否则回落到请求里的。
pub async fn Client::query(
  self : Client,
  option : QueryOption,
) -> QueryResult raise ClientError {
  let query_params = option.query_params.map(pair => {
    @common.KeyValuePair::KeyValuePair(pair.0, pair.1)
  })
  let consistency = match option.consistency_level {
    Some(level) => level.to_proto()
    None => @common.ConsistencyLevel::Bounded
  }
  let request = @milvus.QueryRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    expr: option.expr,
    output_fields: option.output_fields,
    partition_names: option.partition_names,
    travel_timestamp: 0UL,
    guarantee_timestamp: 0UL,
    query_params,
    not_return_all_meta: false,
    consistency_level: consistency,
    use_default_consistency: option.consistency_level is None,
    namespace_: None,
  }
  let response : @milvus.QueryResults = self.call_service(query_path, request)
  match check_status(response.status) {
    Some(err) => raise err
    None => decode_query_results(response)
  }
}

///|
fn decode_query_results(
  response : @milvus.QueryResults,
) -> QueryResult raise ClientError {
  let columns : Array[@column.Column] = []
  let names : Array[String] = []
  for field in response.fields_data {
    let column = @column.from_field_data(field) catch {
      err => raise ClientError::Decode(column_error_message(err))
    }
    names.push(field.field_name)
    columns.push(column)
  }
  { columns, names, }
}
