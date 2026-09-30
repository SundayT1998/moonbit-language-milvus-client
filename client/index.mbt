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
// 移植自 milvus-io/milvus client/milvusclient/index_options.go 的
// `CreateIndex` / `DescribeIndex` / `DropIndex` 调用点（Apache-2.0）。
//
// `@index` 那层只负责把参数装配好（`Index` → 键值对），wire 编解码在
// 生成物里。这里是两者之间的桥：装配好的 `extra_params` 塞进请求、响应
// 翻成 `@index.IndexDescription`。
//
// 顺序不能反：Milvus 要求**先建索引再 LoadCollection**，否则加载会报
// `index not found`（错误码 `IndexNotExist`）。集成测试踩过这个坑。

///|
/// 建索引的入参。
pub(all) struct CreateIndexOption {
  collection_name : String
  field_name : String
  index : @index.Index
}

///|
pub fn new_create_index_option(
  collection_name : String,
  field_name : String,
  index : @index.Index,
) -> CreateIndexOption {
  { collection_name, field_name, index, }
}

///|
/// 给字段建索引。
///
/// `@index` 里装配好的 `index_type` / `metric_type` 与其余构建参数一并
/// 作为 `extra_params` 发出去，与上游 `CreateIndex` 的组包方式一致。
pub async fn Client::create_index(
  self : Client,
  option : CreateIndexOption,
) -> Unit raise ClientError {
  let request = @milvus.CreateIndexRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    field_name: option.field_name,
    extra_params: option.index
    .params()
    .to_pairs()
    .map(pair => @common.KeyValuePair::KeyValuePair(pair.0, pair.1)),
    index_name: option.index.name(),
  }
  let response : @common.Status = self.call_service(create_index_path, request)
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 描述索引的入参。`field_name` / `index_name` 都留空表示列全部。
pub(all) struct DescribeIndexOption {
  collection_name : String
  field_name : String
  index_name : String
}

///|
pub fn new_describe_index_option(
  collection_name : String,
) -> DescribeIndexOption {
  { collection_name, field_name: "", index_name: "", }
}

///|
pub fn DescribeIndexOption::with_field_name(
  self : DescribeIndexOption,
  field_name : String,
) -> DescribeIndexOption {
  { ..self, field_name, }
}

///|
pub fn DescribeIndexOption::with_index_name(
  self : DescribeIndexOption,
  index_name : String,
) -> DescribeIndexOption {
  { ..self, index_name, }
}

///|
/// 把生成物的 `IndexDescription` 翻成 `@index.IndexDescription`。
fn index_description_from_proto(
  proto : @milvus.IndexDescription,
) -> @index.IndexDescription {
  {
    index_name: proto.index_name,
    index_id: proto.index_id,
    params: proto.params.map(pair => (pair.key, pair.value)),
    field_name: proto.field_name,
    indexed_rows: proto.indexed_rows,
    total_rows: proto.total_rows,
    pending_index_rows: proto.pending_index_rows,
    state: index_state_from_proto(proto.state),
    fail_reason: proto.index_state_fail_reason,
  }
}

///|
fn index_state_from_proto(state : @common.IndexState) -> @index.IndexState {
  @index.IndexState::from_int(index_state_to_int(state))
}

///|
fn index_state_to_int(state : @common.IndexState) -> Int {
  match state {
    IndexStateNone => 0
    Unissued => 1
    InProgress => 2
    Finished => 3
    Failed => 4
    Retry => 5
    Unknown(code) => code.0.reinterpret_as_int()
  }
}

///|
/// 查集合上的索引。返回的每条都带服务端回读的参数与构建状态。
pub async fn Client::describe_index(
  self : Client,
  option : DescribeIndexOption,
) -> Array[@index.IndexDescription] raise ClientError {
  let request = @milvus.DescribeIndexRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    field_name: option.field_name,
    index_name: option.index_name,
    timestamp: 0UL,
  }
  let response : @milvus.DescribeIndexResponse = self.call_service(
    describe_index_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => response.index_descriptions.map(index_description_from_proto)
  }
}

///|
/// 删索引的入参。Milvus 要求给出索引名，空串会被服务端拒绝。
pub(all) struct DropIndexOption {
  collection_name : String
  index_name : String
}

///|
pub fn new_drop_index_option(
  collection_name : String,
  index_name : String,
) -> DropIndexOption {
  { collection_name, index_name, }
}

///|
/// 删掉一个索引。
pub async fn Client::drop_index(
  self : Client,
  option : DropIndexOption,
) -> Unit raise ClientError {
  let request = @milvus.DropIndexRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    field_name: "",
    index_name: option.index_name,
  }
  let response : @common.Status = self.call_service(drop_index_path, request)
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}
