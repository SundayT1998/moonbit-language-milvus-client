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
// 移植自 milvus-io/milvus client/milvusclient/{write.go,write_options.go}
// （Apache-2.0）。
//
// 上游 `InsertRequest` 要拿一张 `*entity.Collection`（带 schema 与
// `UpdateTimestamp`）才构造得出来，因为它会按 schema 做列校验、并把
// schema 版本号带上做 schema-mismatch 重试。本移植不缓存 schema，
// 只保留 `NewColumnBasedInsertOption` 那一路：调用方给列，客户端编码，
// `schema_timestamp` 留 0 表示「不校验版本」。这是 Issue 边界里写明的
// 上限（row-based API 不移植），也是 R6 里「Schema 缓存与重试」的
// 已知取舍。

///|
/// 一次写入的结果。与上游 `InsertResult` / `UpsertResult` / `DeleteResult`
/// 合并成一条：三个 RPC 返回的都是同一个 `MutationResult`。
pub(all) struct MutationResult {
  ids : @column.ColumnValue?
  insert_count : Int64
  delete_count : Int64
  upsert_count : Int64
  timestamp : UInt64
} derive(Debug)

///|
/// 结果里没有主键（比如 delete）时是 `None`。
pub fn MutationResult::has_ids(self : MutationResult) -> Bool {
  match self.ids {
    Some(_) => true
    None => false
  }
}

///|
/// 把 `schema.IDs` 翻成列。
///
/// `IntId` / `StrId` 之外还有 `UuidId`（16 字节定长），
/// 这里按 `@column.ColumnValue::String` 收——UUID 在 `@entity` 侧没有独立
/// 的列类型，回读侧也是按字节处理的。
fn ids_column(ids : @schema.IDs?) -> @column.ColumnValue? {
  match ids {
    None => None
    Some(ids) =>
      match ids.id_field {
        @schema.IDs_IdField::IntId(a) =>
          Some(@column.ColumnValue::Int64(a.data))
        @schema.IDs_IdField::StrId(a) =>
          Some(@column.ColumnValue::VarChar(a.data))
        @schema.IDs_IdField::UuidId(a) =>
          Some(@column.ColumnValue::Json(a.data))
        @schema.IDs_IdField::NotSet => None
      }
  }
}

///|
fn mutation_result_from_proto(
  response : @milvus.MutationResult,
) -> MutationResult {
  {
    ids: ids_column(response.ids),
    insert_count: response.insert_cnt,
    delete_count: response.delete_cnt,
    upsert_count: response.upsert_cnt,
    timestamp: response.timestamp,
  }
}

///|
/// 写一批列的共同入参：集合名 + 可选分区。
///
/// `upsert` 多一个 `partial_update`：上游 `WithPartialUpdate` 打开后，
/// 服务端只覆盖请求里出现的字段，其余保持原值。
pub(all) struct WriteOption {
  collection_name : String
  partition_name : String
  columns : Array[WriteColumn]
  partial_update : Bool
}

///|
/// 上游 `NewColumnBasedInsertOption`：给集合名和列，不指定分区
/// （空分区名落到默认分区 `_default`）。
pub fn new_write_option(
  collection_name : String,
  columns : Array[WriteColumn],
) -> WriteOption {
  { collection_name, partition_name: "", columns, partial_update: false, }
}

///|
pub fn WriteOption::with_partition(
  self : WriteOption,
  partition_name : String,
) -> WriteOption {
  { ..self, partition_name, }
}

///|
/// 只在 upsert 上有意义；insert 上设了不会报错，只是被忽略。
pub fn WriteOption::with_partial_update(
  self : WriteOption,
  partial_update? : Bool = true,
) -> WriteOption {
  { ..self, partial_update, }
}

///|
/// 所有列的行数必须一致，否则服务端只会按第一列的长度算 `num_rows`，
/// 多出来的数据被静默丢掉。上游 `processInsertColumns` 也做这一步校验。
fn check_row_counts(columns : Array[WriteColumn]) -> Int raise ClientError {
  if columns.length() == 0 {
    raise ClientError::Encode("write requires at least one column")
  }
  let rows = columns[0].len()
  for column in columns {
    if column.len() != rows {
      raise ClientError::Encode(
        "column \{column.name} has \{column.len()} rows, but column \{columns[0].name} has \{rows}",
      )
    }
  }
  rows
}

///|
/// 列数组 → `FieldData` 数组，并返回行数。
fn build_fields_data(
  columns : Array[WriteColumn],
) -> (Array[@schema.FieldData], Int) raise ClientError {
  let rows = check_row_counts(columns)
  let fields : Array[@schema.FieldData] = []
  for column in columns {
    fields.push(column.to_field_data())
  }
  (fields, rows)
}

///|
/// 插入。返回服务端生成的主键（`auto_id` 打开时才有）与写入计数。
pub async fn Client::insert(
  self : Client,
  option : WriteOption,
) -> MutationResult raise ClientError {
  let (fields_data, rows) = build_fields_data(option.columns)
  let request = @milvus.InsertRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_name: option.partition_name,
    fields_data,
    hash_keys: [],
    num_rows: rows.reinterpret_as_uint(),
    schema_timestamp: 0UL,
    namespace_: None,
  }
  let response : @milvus.MutationResult = self.call_service(
    insert_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => mutation_result_from_proto(response)
  }
}

///|
/// 插入或更新。
///
/// 与上游一致：upsert 的主键必须由调用方给出（哪怕 schema 是 `auto_id`），
/// 因为主键就是查找键。
pub async fn Client::upsert(
  self : Client,
  option : WriteOption,
) -> MutationResult raise ClientError {
  let (fields_data, rows) = build_fields_data(option.columns)
  let request = @milvus.UpsertRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_name: option.partition_name,
    fields_data,
    hash_keys: [],
    num_rows: rows.reinterpret_as_uint(),
    schema_timestamp: 0UL,
    partial_update: option.partial_update,
    namespace_: None,
  }
  let response : @milvus.MutationResult = self.call_service(
    upsert_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => mutation_result_from_proto(response)
  }
}

///|
/// 删除的入参。
///
/// 上游用一个统一的 `deleteOption`，表达式和一致性等级二选一地填。
/// 这里把「用主键删」和「用表达式删」分开成两个构造函数，
/// 因为主键那一支要拼表达式（见 `pks_expr`），跟手写表达式不是一回事。
pub(all) struct DeleteOption {
  collection_name : String
  partition_name : String
  expr : String
  consistency_level : ConsistencyLevel?
}

///|
/// 按表达式删，比如 `age > 30`。
pub fn new_delete_option(
  collection_name : String,
  expr : String,
) -> DeleteOption {
  { collection_name, partition_name: "", expr, consistency_level: None, }
}

///|
/// 按主键删。与上游 `WithInt64IDs` 一致，拼成 `pk in [...]`。
pub fn delete_by_int64_ids(
  collection_name : String,
  field_name : String,
  ids : Array[Int64],
) -> DeleteOption {
  let parts : Array[String] = ids.map(id => id.to_string())
  {
    collection_name,
    partition_name: "",
    expr: field_name + " in [" + parts.join(",") + "]",
    consistency_level: None,
  }
}

///|
/// 按字符串主键删。与上游 `WithStringIDs` 一致，每个值加双引号。
pub fn delete_by_string_ids(
  collection_name : String,
  field_name : String,
  ids : Array[String],
) -> DeleteOption {
  let parts : Array[String] = ids.map(id => "\"" + id + "\"")
  {
    collection_name,
    partition_name: "",
    expr: field_name + " in [" + parts.join(",") + "]",
    consistency_level: None,
  }
}

///|
pub fn DeleteOption::with_partition(
  self : DeleteOption,
  partition_name : String,
) -> DeleteOption {
  { ..self, partition_name, }
}

///|
pub fn DeleteOption::with_consistency_level(
  self : DeleteOption,
  level : ConsistencyLevel,
) -> DeleteOption {
  { ..self, consistency_level: Some(level), }
}

///|
/// 删。`MutationResult.delete_count` 是服务端实际删掉的条数。
pub async fn Client::delete(
  self : Client,
  option : DeleteOption,
) -> MutationResult raise ClientError {
  if option.expr == "" {
    raise ClientError::Encode("delete requires a non-empty expression")
  }
  let consistency = match option.consistency_level {
    Some(level) => level.to_proto()
    None => @common.ConsistencyLevel::Strong
  }
  let request = @milvus.DeleteRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_name: option.partition_name,
    expr: option.expr,
    hash_keys: [],
    consistency_level: consistency,
    namespace_: None,
  }
  let response : @milvus.MutationResult = self.call_service(
    delete_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => mutation_result_from_proto(response)
  }
}
