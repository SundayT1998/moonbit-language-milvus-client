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
// 移植自 milvus-io/milvus client/milvusclient/{collection.go,
// collection_options.go}（Apache-2.0）。
//
// 上游的 `CreateCollection` 在成功之后还会顺带建索引、必要时 load 集合
// （`IsFast()`），本移植只保留 SDK 层面的「发一次 CreateCollection」，
// 建索引/load 属于后续 Issue，不在这里假装做完。

///|
/// 建集合的入参。对应上游 `createCollectionOption`。
///
/// `schema` 为 `None` 时就是「快速建表」：按 `dim` 合成一张
/// 主键 + 向量字段的默认表，字段名与上游
/// `SimpleCreateCollectionOptions` 一致（`id` / `vector`）。
pub(all) struct CreateCollectionOption {
  name : String
  shard_num : Int
  schema : @entity.CollectionSchema?
  dim : Int
  auto_id : Bool
  enable_dynamic_schema : Bool
  pk_field_name : String
  vector_field_name : String
  varchar_pk : Bool
  varchar_pk_max_length : Int
  consistency_level : ConsistencyLevel
  properties : Array[(String, String)]
  num_partitions : Int64
}

///|
/// 上游 `NewCreateCollectionOption`：拿一张自定义 schema 建表。
/// 默认分片数 1、一致性 `Bounded`。
pub fn new_create_collection_option(
  name : String,
  schema : @entity.CollectionSchema,
) -> CreateCollectionOption {
  {
    name,
    shard_num: 1,
    schema: Some(schema),
    dim: 0,
    auto_id: false,
    enable_dynamic_schema: false,
    pk_field_name: "id",
    vector_field_name: "vector",
    varchar_pk: false,
    varchar_pk_max_length: 0,
    consistency_level: default_consistency_level,
    properties: [],
    num_partitions: 0L,
  }
}

///|
/// 上游 `SimpleCreateCollectionOptions`：只给名字和维度，其余按默认。
pub fn simple_create_collection_option(
  name : String,
  dim : Int,
) -> CreateCollectionOption {
  {
    name,
    shard_num: 1,
    schema: None,
    dim,
    auto_id: true,
    enable_dynamic_schema: true,
    pk_field_name: "id",
    vector_field_name: "vector",
    varchar_pk: false,
    varchar_pk_max_length: 0,
    consistency_level: default_consistency_level,
    properties: [],
    num_partitions: 0L,
  }
}

///|
pub fn CreateCollectionOption::with_auto_id(
  self : CreateCollectionOption,
  auto_id : Bool,
) -> CreateCollectionOption {
  { ..self, auto_id, }
}

///|
pub fn CreateCollectionOption::with_shard_num(
  self : CreateCollectionOption,
  shard_num : Int,
) -> CreateCollectionOption {
  { ..self, shard_num, }
}

///|
pub fn CreateCollectionOption::with_dynamic_schema(
  self : CreateCollectionOption,
  enable? : Bool = true,
) -> CreateCollectionOption {
  { ..self, enable_dynamic_schema: enable, }
}

///|
pub fn CreateCollectionOption::with_varchar_pk(
  self : CreateCollectionOption,
  varchar_pk : Bool,
  max_length : Int,
) -> CreateCollectionOption {
  { ..self, varchar_pk, varchar_pk_max_length: max_length, }
}

///|
pub fn CreateCollectionOption::with_pk_field_name(
  self : CreateCollectionOption,
  name : String,
) -> CreateCollectionOption {
  { ..self, pk_field_name: name, }
}

///|
pub fn CreateCollectionOption::with_vector_field_name(
  self : CreateCollectionOption,
  name : String,
) -> CreateCollectionOption {
  { ..self, vector_field_name: name, }
}

///|
pub fn CreateCollectionOption::with_consistency_level(
  self : CreateCollectionOption,
  level : ConsistencyLevel,
) -> CreateCollectionOption {
  { ..self, consistency_level: level, }
}

///|
pub fn CreateCollectionOption::with_num_partitions(
  self : CreateCollectionOption,
  num_partitions : Int64,
) -> CreateCollectionOption {
  { ..self, num_partitions, }
}

///|
/// 追加一条集合属性。同名键覆盖已有的。
pub fn CreateCollectionOption::with_property(
  self : CreateCollectionOption,
  key : String,
  value : String,
) -> CreateCollectionOption {
  let properties : Array[(String, String)] = []
  let mut replaced = false
  for pair in self.properties {
    if pair.0 == key {
      properties.push((key, value))
      replaced = true
    } else {
      properties.push(pair)
    }
  }
  if !replaced {
    properties.push((key, value))
  }
  { ..self, properties, }
}

///|
/// 快速建表时合成的那张 schema，与上游 `Request()` 里 `isFast` 分支一致。
fn fast_schema(
  option : CreateCollectionOption,
) -> @entity.CollectionSchema raise ClientError {
  let pk = if option.varchar_pk {
    @entity.Field::new(option.pk_field_name, @entity.DataType::VarChar).with_max_length(
      option.varchar_pk_max_length,
    ) catch {
      err => raise ClientError::Schema(entity_schema_message(err))
    }
  } else {
    @entity.Field::new(option.pk_field_name, @entity.DataType::Int64)
  }
  let mut pk = pk.as_primary_key()
  if option.auto_id {
    pk = pk.as_auto_id()
  }
  let mut vector = @entity.Field::new(
    option.vector_field_name,
    @entity.DataType::FloatVector,
  )
  vector = vector.with_dim(option.dim) catch {
    err => raise ClientError::Schema(entity_schema_message(err))
  }
  @entity.CollectionSchema::new([pk, vector]).with_dynamic_field(
    option.enable_dynamic_schema,
  )
}

///|
/// 组装 `CreateCollectionRequest`。
fn create_collection_request(
  option : CreateCollectionOption,
) -> @milvus.CreateCollectionRequest raise ClientError {
  let schema_proto = match option.schema {
    Some(schema) => serialize_collection_schema(option.name, schema)
    None => serialize_collection_schema(option.name, fast_schema(option))
  }
  let properties = option.properties.map(pair => {
    @common.KeyValuePair::KeyValuePair(pair.0, pair.1)
  })
  @milvus.CreateCollectionRequest::{
    base: None,
    db_name: "",
    collection_name: option.name,
    schema: schema_proto,
    shards_num: option.shard_num,
    consistency_level: option.consistency_level.to_proto(),
    properties,
    num_partitions: option.num_partitions,
  }
}

///|
/// 建集合。schema 不合法会在发出请求之前就报 `ClientError::Schema`。
///
/// 上游还在这里断言 `Validate() error`（客户端预检）。本移植把这一步
/// 显式化：schema 走一遍 `@entity.CollectionSchema::validate`，
/// 快速建表也走，因为合成出来的表同样可能不合法（比如 dim 为 0）。
pub async fn Client::create_collection(
  self : Client,
  option : CreateCollectionOption,
) -> Unit raise ClientError {
  let schema = match option.schema {
    Some(schema) => schema
    None => fast_schema(option)
  }
  schema.validate() catch {
    err => raise ClientError::Schema(entity_schema_message(err))
  }
  let request = create_collection_request(option)
  let response : @common.Status = self.call_service(
    create_collection_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 描述集合的入参。
pub(all) struct DescribeCollectionOption {
  name : String
}

///|
pub fn new_describe_collection_option(
  name : String,
) -> DescribeCollectionOption {
  { name, }
}

///|
/// 集合的元信息。对应上游 `entity.Collection` 里 SDK 层面的那几项。
pub(all) struct CollectionDescription {
  name : String
  id : Int64
  schema : @entity.CollectionSchema
  physical_channels : Array[String]
  virtual_channels : Array[String]
  consistency_level : ConsistencyLevel
  shard_num : Int
  properties : Array[(String, String)]
  update_timestamp : UInt64
} derive(Debug)

///|
/// 把响应翻成 `CollectionDescription`。
///
/// 集合名以 `schema.name` 为准（上游也是 `collection.Name =
/// collection.Schema.CollectionName`），响应顶层的 `collection_name` 只作兜底。
fn collection_description_from_proto(
  response : @milvus.DescribeCollectionResponse,
) -> CollectionDescription raise ClientError {
  let schema_proto = response.schema.unwrap()
  let fields : Array[@entity.Field] = []
  for field in schema_proto.fields {
    fields.push(field_from_proto(field))
  }
  let schema = @entity.CollectionSchema::new(fields)
    .with_description(schema_proto.description)
    .with_dynamic_field(schema_proto.enable_dynamic_field)
  let properties : Array[(String, String)] = response.properties.map(pair => {
    (pair.key, pair.value)
  })
  {
    name: if schema_proto.name != "" {
      schema_proto.name
    } else {
      response.collection_name
    },
    id: response.collection_id,
    schema,
    physical_channels: response.physical_channel_names,
    virtual_channels: response.virtual_channel_names,
    consistency_level: ConsistencyLevel::from_proto(response.consistency_level),
    shard_num: response.shards_num,
    properties,
    update_timestamp: response.update_timestamp,
  }
}

///|
/// 查集合元信息。
pub async fn Client::describe_collection(
  self : Client,
  option : DescribeCollectionOption,
) -> CollectionDescription raise ClientError {
  let request = @milvus.DescribeCollectionRequest::{
    base: None,
    db_name: "",
    collection_name: option.name,
    collection_id: 0L,
    time_stamp: 0UL,
  }
  let response : @milvus.DescribeCollectionResponse = self.call_service(
    describe_collection_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => collection_description_from_proto(response)
  }
}

///|
/// 集合是否存在。
///
/// 上游用 `DescribeCollection` 实现，把 `ErrCollectionNotFound` 当成
/// 「不存在」而不是失败 —— 别指望用 `HasCollection` RPC，
/// 上游的 `HasCollection` 也是这么走的。
pub async fn Client::has_collection(
  self : Client,
  option : DescribeCollectionOption,
) -> Bool raise ClientError {
  let request = @milvus.DescribeCollectionRequest::{
    base: None,
    db_name: "",
    collection_name: option.name,
    collection_id: 0L,
    time_stamp: 0UL,
  }
  let response : @milvus.DescribeCollectionResponse = self.call_service(
    describe_collection_path, request,
  )
  match check_status(response.status) {
    Some(Server(err)) =>
      if @errors.error_code(Some(err)) ==
        @errors.error_code(Some(@errors.err_collection_not_found())) {
        false
      } else {
        raise ClientError::Server(err)
      }
    Some(other) => raise other
    None => true
  }
}

///|
/// 删集合的入参。
pub(all) struct DropCollectionOption {
  name : String
}

///|
pub fn new_drop_collection_option(name : String) -> DropCollectionOption {
  { name, }
}

///|
/// 删集合，连带它的数据一起删。
pub async fn Client::drop_collection(
  self : Client,
  option : DropCollectionOption,
) -> Unit raise ClientError {
  let request = @milvus.DropCollectionRequest::{
    base: None,
    db_name: "",
    collection_name: option.name,
  }
  let response : @common.Status = self.call_service(
    drop_collection_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 加载集合的入参。对应上游 `loadCollectionOption`。
///
/// 服务端只返回一个 `common.Status`，没有 `GetLoadingProgress` 那套进度
/// 查询。上游 SDK 拿到状态后自己轮询 `GetLoadingProgress` 等到 100%，
/// 本移植暂时不做 —— 调用方如果需要等待，用 `get_load_state` 自己轮询。
pub(all) struct LoadCollectionOption {
  name : String
  replica_number : Int
  resource_groups : Array[String]
  load_fields : Array[String]
  skip_load_dynamic_field : Bool
  load_params : Array[(String, String)]
}

///|
pub fn new_load_collection_option(name : String) -> LoadCollectionOption {
  {
    name,
    replica_number: 0,
    resource_groups: [],
    load_fields: [],
    skip_load_dynamic_field: false,
    load_params: [],
  }
}

///|
pub fn LoadCollectionOption::with_replica_number(
  self : LoadCollectionOption,
  replica_number : Int,
) -> LoadCollectionOption {
  { ..self, replica_number, }
}

///|
/// 把集合加载进内存，之后才能对它做检索。
///
/// 这是 `Search` / `Query` 的前置条件：Milvus 不会在建表后自动加载，
/// 对未加载的集合发检索会得到 `collection not loaded`（错误码
/// `CollectionNotLoaded`）。
pub async fn Client::load_collection(
  self : Client,
  option : LoadCollectionOption,
) -> Unit raise ClientError {
  let request = @milvus.LoadCollectionRequest::{
    base: None,
    db_name: "",
    collection_name: option.name,
    replica_number: option.replica_number,
    resource_groups: option.resource_groups,
    refresh: false,
    load_fields: option.load_fields,
    skip_load_dynamic_field: option.skip_load_dynamic_field,
    load_params: Map::from_array(
      option.load_params.map(pair => (pair.0, pair.1)),
    ),
  }
  let response : @common.Status = self.call_service(
    load_collection_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 从内存里卸载集合，释放查询节点的资源。
///
/// 与 `load_collection` 成对；对应的上游调用点是 `ReleaseCollection`。
pub async fn Client::release_collection(
  self : Client,
  option : DropCollectionOption,
) -> Unit raise ClientError {
  let request = @milvus.ReleaseCollectionRequest::{
    base: None,
    db_name: "",
    collection_name: option.name,
  }
  let response : @common.Status = self.call_service(
    release_collection_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 集合的加载状态。对应上游 `entity.LoadState`。
///
/// 只暴露本移植用得到的四项；生成物里的 `LoadState::Unknown` 是
/// 未知枚举值的岔路，这里归到 `NotExist` 之外单列，避免被当成
/// 「什么都没发生」而静默等下去。
pub(all) enum CollectionLoadState {
  NotExist
  NotLoad
  Loading
  Loaded
  Unknown(Int)
} derive(Eq, Debug)

///|
fn load_state_from_proto(state : @common.LoadState) -> CollectionLoadState {
  match state {
    LoadStateNotExist => CollectionLoadState::NotExist
    LoadStateNotLoad => CollectionLoadState::NotLoad
    LoadStateLoading => CollectionLoadState::Loading
    LoadStateLoaded => CollectionLoadState::Loaded
    Unknown(code) => CollectionLoadState::Unknown(code.0.reinterpret_as_int())
  }
}

///|
/// 查集合当前的加载状态。
///
/// 给调用方一个可轮询的判据：`load_collection` 返回不代表数据面已经
/// 就绪，`Loaded` 才是。
pub async fn Client::get_load_state(
  self : Client,
  option : DescribeCollectionOption,
) -> CollectionLoadState raise ClientError {
  let request = @milvus.GetLoadStateRequest::{
    base: None,
    collection_name: option.name,
    partition_names: [],
    db_name: "",
  }
  let response : @milvus.GetLoadStateResponse = self.call_service(
    get_load_state_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => load_state_from_proto(response.state)
  }
}

///|
/// 列集合的入参。上游就一个空请求，这里保留一个类型，
/// 以便将来加 `type` / `db_name` 时不动调用点。
pub(all) struct ListCollectionsOption {
  show_loaded : Bool
}

///|
pub fn new_list_collections_option() -> ListCollectionsOption {
  { show_loaded: false, }
}

///|
/// 列出库里的集合名。
pub async fn Client::list_collections(
  self : Client,
  option : ListCollectionsOption,
) -> Array[String] raise ClientError {
  let request = @milvus.ShowCollectionsRequest::{
    base: None,
    db_name: "",
    time_stamp: 0UL,
    type_: if option.show_loaded {
      @milvus.ShowType::InMemory
    } else {
      @milvus.ShowType::All
    },
    collection_names: [],
  }
  let response : @milvus.ShowCollectionsResponse = self.call_service(
    show_collections_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => response.collection_names
  }
}
