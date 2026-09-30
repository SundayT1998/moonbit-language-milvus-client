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
// 移植自 milvus-io/milvus client/milvusclient/index_options.go 与
// client/index/index.go（Apache-2.0）。
//
// 这一层只做**参数装配**：把 `Index` 与调用方给的名字/字段拼成 RPC 的入参。
// wire 编解码由 `proto/` 生成物负责，两者以这里的数据类型交接。
// 刻意不 import 生成物，这样本 Issue 的验收项（builder 行为、非法组合报错）
// 不依赖生成链条就能测。

///|
/// 索引 RPC 的服务路径，取自 `milvus.proto` 的 `MilvusService`。
/// gRPC 方法名是 `/` + 全限定服务名 + `/` + 方法名。
pub let create_index_path : String = "/milvus.proto.milvus.MilvusService/CreateIndex"

///|
/// 见 `create_index_path`。
pub let describe_index_path : String = "/milvus.proto.milvus.MilvusService/DescribeIndex"

///|
/// 见 `create_index_path`。
pub let drop_index_path : String = "/milvus.proto.milvus.MilvusService/DropIndex"

///|
/// 服务端索引构建状态，取自 `common.IndexState`。
/// 序号必须与上游对齐：这是 wire 上的枚举值，不是客户端概念。
pub(all) enum IndexState {
  None
  Unissued
  InProgress
  Finished
  Failed
  Retry
  /// 上游新增而本客户端尚未认识的值。保留原始序号，不猜测语义。
  Unknown(Int)
} derive(Eq, Debug)

///|
/// 上游枚举序号。
pub fn IndexState::to_int(self : IndexState) -> Int {
  match self {
    None => 0
    Unissued => 1
    InProgress => 2
    Finished => 3
    Failed => 4
    Retry => 5
    Unknown(n) => n
  }
}

///|
/// 反解上游枚举序号。
pub fn IndexState::from_int(n : Int) -> IndexState {
  match n {
    0 => None
    1 => Unissued
    2 => InProgress
    3 => Finished
    4 => Failed
    5 => Retry
    _ => Unknown(n)
  }
}

///|
/// 该状态是否表示构建已结束——成功或失败都算结束，再等下去没有意义。
/// 上游 `CreateIndexTask::Await` 正是在这两个分支上停下的。
pub fn IndexState::is_terminal(self : IndexState) -> Bool {
  match self {
    Finished | Failed => true
    _ => false
  }
}

///|
/// `CreateIndex` 的入参。
pub(all) struct CreateIndexRequest {
  db_name : String
  collection_name : String
  field_name : String
  /// 索引名。空串走服务端默认命名。
  index_name : String
  /// 已装配好的参数键值对，含 `index_type` / `metric_type`。
  extra_params : Array[(String, String)]
} derive(Eq, Debug)

///|
/// 由索引定义拼出 `CreateIndex` 入参。
///
/// `db_name` 留空表示走连接的默认库：Milvus 的 `db_name` 为空时由服务端
/// 落到默认 database，与传 `"default"` 等价但少一次显式依赖。
pub fn CreateIndexRequest::from_index(
  collection_name : String,
  field_name : String,
  index : Index,
  db_name? : String = "",
) -> CreateIndexRequest raise IndexParamError {
  if collection_name == "" {
    raise InvalidArgument(reason="collection_name must not be empty")
  }
  if field_name == "" {
    raise InvalidArgument(reason="field_name must not be empty")
  }
  {
    db_name,
    collection_name,
    field_name,
    index_name: index.name,
    extra_params: index.params.to_pairs(),
  }
}

///|
/// `DescribeIndex` 的入参。`field_name` 与 `index_name` 都留空表示「列全部」。
pub(all) struct DescribeIndexRequest {
  db_name : String
  collection_name : String
  field_name : String
  index_name : String
} derive(Eq, Debug)

///|
/// 列出某集合的全部索引。
pub fn DescribeIndexRequest::list_all(
  collection_name : String,
  db_name? : String = "",
) -> DescribeIndexRequest raise IndexParamError {
  if collection_name == "" {
    raise InvalidArgument(reason="collection_name must not be empty")
  }
  { db_name, collection_name, field_name: "", index_name: "", }
}

///|
/// 按索引名查一个索引。
pub fn DescribeIndexRequest::by_name(
  collection_name : String,
  index_name : String,
  db_name? : String = "",
) -> DescribeIndexRequest raise IndexParamError {
  if collection_name == "" {
    raise InvalidArgument(reason="collection_name must not be empty")
  }
  if index_name == "" {
    raise InvalidArgument(
      reason="index_name must not be empty; use list_all for every index",
    )
  }
  { db_name, collection_name, field_name: "", index_name, }
}

///|
/// 按字段名查该字段上的索引。
pub fn DescribeIndexRequest::by_field(
  collection_name : String,
  field_name : String,
  db_name? : String = "",
) -> DescribeIndexRequest raise IndexParamError {
  if collection_name == "" {
    raise InvalidArgument(reason="collection_name must not be empty")
  }
  if field_name == "" {
    raise InvalidArgument(reason="field_name must not be empty")
  }
  { db_name, collection_name, field_name, index_name: "", }
}

///|
/// `DropIndex` 的入参。
pub(all) struct DropIndexRequest {
  db_name : String
  collection_name : String
  /// 索引名。Milvus 要求给出名字，空串会被服务端拒绝。
  index_name : String
} derive(Eq, Debug)

///|
/// 拼出 `DropIndex` 入参。索引名必填：Milvus 不支持「删该集合的全部索引」，
/// 想全删只能先 `DescribeIndex` 再逐个 drop，所以这里不提供空名入口。
pub fn DropIndexRequest::new(
  collection_name : String,
  index_name : String,
  db_name? : String = "",
) -> DropIndexRequest raise IndexParamError {
  if collection_name == "" {
    raise InvalidArgument(reason="collection_name must not be empty")
  }
  if index_name == "" {
    raise InvalidArgument(reason="index_name must not be empty")
  }
  { db_name, collection_name, index_name, }
}

///|
/// `DescribeIndex` 返回的一条索引描述。
pub(all) struct IndexDescription {
  index_name : String
  index_id : Int64
  /// 就是 `CreateIndex` 时给的键值对，原样回读。
  params : Array[(String, String)]
  field_name : String
  indexed_rows : Int64
  total_rows : Int64
  pending_index_rows : Int64
  state : IndexState
  /// 构建失败时的原因，仅 `state == Failed` 时有意义。
  fail_reason : String
} derive(Eq, Debug)

///|
/// 把回读的参数还原成 `IndexParams`，键名原样。
pub fn IndexDescription::index_params(self : IndexDescription) -> IndexParams {
  IndexParams::from_pairs(self.params)
}

///|
/// 回读的索引类型。上游把 `index_type` 放在 params 里，不是独立字段；
/// 返回 `None` 表示服务端没给这个键（老版本可能不返回）。
pub fn IndexDescription::index_type(self : IndexDescription) -> IndexType? {
  match self.index_params().get(index_type_key) {
    Some(s) => IndexType::from_string(s)
    None => None
  }
}

///|
/// 回读的度量类型。
pub fn IndexDescription::metric_type(self : IndexDescription) -> MetricType? {
  match self.index_params().get(metric_type_key) {
    Some(s) => MetricType::from_string(s)
    None => None
  }
}

///|
/// 构建进度：已完成行数 / 总行数。总行数为 0 时返回 `None`——
/// 集合还空着，除法没有意义，也不该假装进度是 0%。
pub fn IndexDescription::progress(self : IndexDescription) -> Double? {
  if self.total_rows == 0L {
    return None
  }
  Some(self.indexed_rows.to_double() / self.total_rows.to_double())
}

///|
/// 在响应里按索引名挑一条。
///
/// 上游 `DescribeIndex` 用 `for` 循环找名字相等的一条，找不到就报 `IndexNotFound`；
/// 这里同样不取「第一条」充数——多索引集合下那是错的。
pub fn find_by_name(
  descriptions : Array[IndexDescription],
  index_name : String,
) -> IndexDescription? {
  for d in descriptions {
    if d.index_name == index_name {
      return Some(d)
    }
  }
  None
}

///|
/// 在响应里按字段名挑该字段上的全部索引。
pub fn find_by_field(
  descriptions : Array[IndexDescription],
  field_name : String,
) -> Array[IndexDescription] {
  let out : Array[IndexDescription] = []
  for d in descriptions {
    if d.field_name == field_name {
      out.push(d)
    }
  }
  out
}
