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
// 移植自 milvus-io/milvus client/milvusclient/{maintenance.go,
// maintenance_options.go} 的 load / release 部分与 client/entity/load_state.go
// （Apache-2.0）。
//
// 上游 `LoadCollection` / `LoadPartitions` 返回一个 `LoadTask`，`Await` 里
// 每 200ms 轮询 `GetLoadingProgress` 直到 `progress == 100`。本移植照搬，
// 只是把等待交给 `@async.sleep`，并把轮询间隔做成可配的（默认 200ms 与上游一致）。
//
// 上游还区分「refresh 模式」：`refresh = true` 时等的是 `refresh_progress`
// 而不是 `progress`。本移植保留这个开关，语义一致。

///|
/// 集合 / 分区的加载状态。对应上游 `entity.LoadState`。
pub(all) struct LoadState {
  /// 加载档位。
  state : CollectionLoadState
  /// 已加载百分比（0–100）。只在 `Loading` 时有意义。
  progress : Int64
} derive(Eq, Debug)

///|
/// 加载档位。序号与 `common.LoadState` 对齐，`to_int` / `from_int`
/// 是 wire 上的枚举值，不是客户端概念。
pub(all) enum CollectionLoadState {
  /// 集合/分区不存在。
  NotExist
  /// 存在但没加载。
  NotLoad
  /// 正在加载。
  Loading
  /// 已加载。
  Loaded
  /// 上游新增而本客户端尚未认识的值。保留原始序号，不猜测语义。
  Unknown(Int)
} derive(Eq, Debug)

///|
pub fn CollectionLoadState::to_int(self : CollectionLoadState) -> Int {
  match self {
    NotExist => 0
    NotLoad => 1
    Loading => 2
    Loaded => 3
    Unknown(n) => n
  }
}

///|
pub fn CollectionLoadState::from_int(n : Int) -> CollectionLoadState {
  match n {
    0 => NotExist
    1 => NotLoad
    2 => Loading
    3 => Loaded
    _ => Unknown(n)
  }
}

///|
/// 从生成的 proto 枚举翻过来。
pub fn CollectionLoadState::from_proto(
  state : @common.LoadState,
) -> CollectionLoadState {
  match state {
    @common.LoadState::LoadStateNotExist => NotExist
    @common.LoadState::LoadStateNotLoad => NotLoad
    @common.LoadState::LoadStateLoading => Loading
    @common.LoadState::LoadStateLoaded => Loaded
    // 生成物是 open enum，多出来的分支按原始序号收，不假装认识。
    @common.LoadState::Unknown(code) => Unknown(code.0.reinterpret_as_int())
  }
}

///|
/// 加载完成的判据：`Loaded` 即成功，其余都还没到。
pub fn CollectionLoadState::is_loaded(self : CollectionLoadState) -> Bool {
  match self {
    Loaded => true
    _ => false
  }
}

///|
/// 上游 `NewLoadCollectionOption` 的默认轮询间隔。
pub let default_load_check_interval_millis : Int = 200

///|
/// 加载集合的入参。对应上游 `loadCollectionOption`。
pub(all) struct LoadCollectionOption {
  collection_name : String
  /// 副本数。0 表示走服务端默认（上游注释也是这个意思，默认值在服务端）。
  replica_number : Int
  resource_groups : Array[String]
  /// 字段级部分加载：只加载这些字段。空数组表示全字段。
  load_fields : Array[String]
  /// 字段级部分加载时跳过动态字段。
  skip_load_dynamic_field : Bool
  /// 透传给服务端的额外加载参数。上游也是这个出口。
  load_params : Array[(String, String)]
  /// refresh 模式：等 `refresh_progress` 而不是 `progress`。
  refresh : Bool
  /// `wait` 的轮询间隔。
  check_interval_millis : Int
}

///|
pub fn new_load_collection_option(
  collection_name : String,
) -> LoadCollectionOption {
  {
    collection_name,
    replica_number: 0,
    resource_groups: [],
    load_fields: [],
    skip_load_dynamic_field: false,
    load_params: [],
    refresh: false,
    check_interval_millis: default_load_check_interval_millis,
  }
}

///|
pub fn LoadCollectionOption::with_replica(
  self : LoadCollectionOption,
  replica_number : Int,
) -> LoadCollectionOption {
  { ..self, replica_number, }
}

///|
/// `with_replica` 的别名。上游 Go 侧叫 `WithReplica`，
/// 早先的集成自检按 `with_replica_number` 写，两个都留着少一次改名。
pub fn LoadCollectionOption::with_replica_number(
  self : LoadCollectionOption,
  replica_number : Int,
) -> LoadCollectionOption {
  { ..self, replica_number, }
}

///|
/// 追加一条加载参数。同名键覆盖已有的。
pub fn LoadCollectionOption::with_load_param(
  self : LoadCollectionOption,
  key : String,
  value : String,
) -> LoadCollectionOption {
  { ..self, load_params: upsert_pair(self.load_params, key, value), }
}

///|
/// 键值对数组的 upsert：同名键替换，其余保持原序。
fn upsert_pair(
  pairs : Array[(String, String)],
  key : String,
  value : String,
) -> Array[(String, String)] {
  let out : Array[(String, String)] = []
  let mut replaced = false
  for pair in pairs {
    if pair.0 == key {
      out.push((key, value))
      replaced = true
    } else {
      out.push(pair)
    }
  }
  if !replaced {
    out.push((key, value))
  }
  out
}

///|
pub fn LoadCollectionOption::with_resource_groups(
  self : LoadCollectionOption,
  resource_groups : Array[String],
) -> LoadCollectionOption {
  { ..self, resource_groups, }
}

///|
pub fn LoadCollectionOption::with_load_fields(
  self : LoadCollectionOption,
  load_fields : Array[String],
) -> LoadCollectionOption {
  { ..self, load_fields, }
}

///|
pub fn LoadCollectionOption::with_skip_load_dynamic_field(
  self : LoadCollectionOption,
  skip? : Bool = true,
) -> LoadCollectionOption {
  { ..self, skip_load_dynamic_field: skip, }
}

///|
pub fn LoadCollectionOption::with_refresh(
  self : LoadCollectionOption,
  refresh? : Bool = true,
) -> LoadCollectionOption {
  { ..self, refresh, }
}

///|
pub fn LoadCollectionOption::with_check_interval_millis(
  self : LoadCollectionOption,
  millis : Int,
) -> LoadCollectionOption {
  { ..self, check_interval_millis: millis, }
}

///|
/// 加载任务。上游 `LoadTask`：拿着集合名与轮询间隔，`Await` 到加载完成。
pub struct LoadTask {
  client : Client
  collection_name : String
  /// 空数组表示「整个集合」。非空表示「只等这些分区」。
  partition_names : Array[String]
  interval_millis : Int
  refresh : Bool
}

///|
pub fn LoadTask::collection_name(self : LoadTask) -> String {
  self.collection_name
}

///|
pub fn LoadTask::partition_names(self : LoadTask) -> Array[String] {
  self.partition_names
}

///|
/// 查一次加载进度（0–100）。不等待。
pub async fn LoadTask::progress(self : LoadTask) -> Int64 raise ClientError {
  let request = @milvus.GetLoadingProgressRequest::{
    base: None,
    collection_name: self.collection_name,
    partition_names: self.partition_names,
    db_name: "",
  }
  let response : @milvus.GetLoadingProgressResponse = self.client.call_service(
    get_loading_progress_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None =>
      if self.refresh {
        response.refresh_progress
      } else {
        response.progress
      }
  }
}

///|
/// 这块数据现在能不能查。`refresh` 模式下看的是 `refresh_progress`。
pub async fn LoadTask::is_loaded(self : LoadTask) -> Bool raise ClientError {
  self.progress() == 100L
}

///|
/// 轮询到加载完成。间隔取 `check_interval_millis`，与上游 `LoadTask.Await`
/// 一致：先等一个间隔再查第一次。
///
/// 上游靠 `ctx.Done()` 退出；本移植里取消是 `@async.sleep` 抛出的，
/// 按 `Code::Cancelled` 归到 `Transport` 一类，调用方仍可用
/// `@async.with_timeout` 之类的外层机制收口。
pub async fn LoadTask::wait(self : LoadTask) -> Unit raise ClientError {
  while !self.is_loaded() {
    sleep_or_cancel(self.interval_millis)
  }
}

///|
/// `@async.sleep` 失败只有取消一种可能，翻成 `Code::Cancelled` 的传输错误，
/// 好让 `ClientError::is_transport` 能把它认出来。
async fn sleep_or_cancel(millis : Int) -> Unit raise ClientError {
  @async.sleep(millis) catch {
    err =>
      raise ClientError::Transport(
        @transport.RpcError::new(
          @transport.Code::Cancelled.to_int(),
          "等待被取消: " + err.to_string(),
        ),
      )
  }
}

///|
/// 加载集合。返回的 `LoadTask` 可以用 `wait` 等到加载完成，
/// 也可以拿 `progress` 自己轮询。
pub async fn Client::load_collection(
  self : Client,
  option : LoadCollectionOption,
) -> LoadTask raise ClientError {
  let request = @milvus.LoadCollectionRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    replica_number: option.replica_number,
    resource_groups: option.resource_groups,
    refresh: option.refresh,
    load_fields: option.load_fields,
    skip_load_dynamic_field: option.skip_load_dynamic_field,
    load_params: Map::from_array(option.load_params),
  }
  let response : @common.Status = self.call_service(
    load_collection_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None =>
      {
        client: self,
        collection_name: option.collection_name,
        partition_names: [],
        interval_millis: option.check_interval_millis,
        refresh: option.refresh,
      }
  }
}

///|
/// 卸载集合的入参。
pub(all) struct ReleaseCollectionOption {
  collection_name : String
}

///|
pub fn new_release_collection_option(
  collection_name : String,
) -> ReleaseCollectionOption {
  { collection_name, }
}

///|
/// 把集合从查询节点卸载。卸载后检索会报错，这是判据。
pub async fn Client::release_collection(
  self : Client,
  option : ReleaseCollectionOption,
) -> Unit raise ClientError {
  let request = @milvus.ReleaseCollectionRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
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
/// 加载分区的入参。字段与 `LoadCollectionOption` 一一对应，只是多了分区名。
pub(all) struct LoadPartitionsOption {
  collection_name : String
  partition_names : Array[String]
  replica_number : Int
  resource_groups : Array[String]
  load_fields : Array[String]
  skip_load_dynamic_field : Bool
  load_params : Array[(String, String)]
  refresh : Bool
  check_interval_millis : Int
}

///|
pub fn new_load_partitions_option(
  collection_name : String,
  partition_names : Array[String],
) -> LoadPartitionsOption {
  {
    collection_name,
    partition_names,
    replica_number: 0,
    resource_groups: [],
    load_fields: [],
    skip_load_dynamic_field: false,
    load_params: [],
    refresh: false,
    check_interval_millis: default_load_check_interval_millis,
  }
}

///|
pub fn LoadPartitionsOption::with_replica(
  self : LoadPartitionsOption,
  replica_number : Int,
) -> LoadPartitionsOption {
  { ..self, replica_number, }
}

///|
pub fn LoadPartitionsOption::with_resource_groups(
  self : LoadPartitionsOption,
  resource_groups : Array[String],
) -> LoadPartitionsOption {
  { ..self, resource_groups, }
}

///|
pub fn LoadPartitionsOption::with_load_fields(
  self : LoadPartitionsOption,
  load_fields : Array[String],
) -> LoadPartitionsOption {
  { ..self, load_fields, }
}

///|
pub fn LoadPartitionsOption::with_skip_load_dynamic_field(
  self : LoadPartitionsOption,
  skip? : Bool = true,
) -> LoadPartitionsOption {
  { ..self, skip_load_dynamic_field: skip, }
}

///|
/// `with_replica` 的别名，理由同 `LoadCollectionOption::with_replica_number`。
pub fn LoadPartitionsOption::with_replica_number(
  self : LoadPartitionsOption,
  replica_number : Int,
) -> LoadPartitionsOption {
  { ..self, replica_number, }
}

///|
/// 追加一条加载参数。同名键覆盖已有的。
pub fn LoadPartitionsOption::with_load_param(
  self : LoadPartitionsOption,
  key : String,
  value : String,
) -> LoadPartitionsOption {
  { ..self, load_params: upsert_pair(self.load_params, key, value), }
}

///|
pub fn LoadPartitionsOption::with_refresh(
  self : LoadPartitionsOption,
  refresh? : Bool = true,
) -> LoadPartitionsOption {
  { ..self, refresh, }
}

///|
pub fn LoadPartitionsOption::with_check_interval_millis(
  self : LoadPartitionsOption,
  millis : Int,
) -> LoadPartitionsOption {
  { ..self, check_interval_millis: millis, }
}

///|
/// 加载分区。返回的 `LoadTask` 只等这些分区。
pub async fn Client::load_partitions(
  self : Client,
  option : LoadPartitionsOption,
) -> LoadTask raise ClientError {
  let request = @milvus.LoadPartitionsRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_names: option.partition_names,
    replica_number: option.replica_number,
    resource_groups: option.resource_groups,
    refresh: option.refresh,
    load_fields: option.load_fields,
    skip_load_dynamic_field: option.skip_load_dynamic_field,
    load_params: Map::from_array(option.load_params),
  }
  let response : @common.Status = self.call_service(
    load_partitions_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None =>
      {
        client: self,
        collection_name: option.collection_name,
        partition_names: option.partition_names,
        interval_millis: option.check_interval_millis,
        refresh: option.refresh,
      }
  }
}

///|
/// 卸载分区的入参。
pub(all) struct ReleasePartitionsOption {
  collection_name : String
  partition_names : Array[String]
}

///|
pub fn new_release_partitions_option(
  collection_name : String,
  partition_names : Array[String],
) -> ReleasePartitionsOption {
  { collection_name, partition_names, }
}

///|
/// 卸载分区。
pub async fn Client::release_partitions(
  self : Client,
  option : ReleasePartitionsOption,
) -> Unit raise ClientError {
  let request = @milvus.ReleasePartitionsRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_names: option.partition_names,
  }
  let response : @common.Status = self.call_service(
    release_partitions_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 查加载状态的入参。
pub(all) struct GetLoadStateOption {
  collection_name : String
  partition_names : Array[String]
}

///|
pub fn new_get_load_state_option(
  collection_name : String,
  partition_names? : Array[String] = [],
) -> GetLoadStateOption {
  { collection_name, partition_names, }
}

///|
/// 查集合 / 分区的加载状态。
///
/// 与上游一致：状态是 `Loading` 时顺带查一次进度，这样调用方拿到的
/// `progress` 在加载中才有意义；其余状态进度留 0。
pub async fn Client::get_load_state(
  self : Client,
  option : GetLoadStateOption,
) -> LoadState raise ClientError {
  let request = @milvus.GetLoadStateRequest::{
    base: None,
    collection_name: option.collection_name,
    partition_names: option.partition_names,
    db_name: "",
  }
  let response : @milvus.GetLoadStateResponse = self.call_service(
    get_load_state_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => {
      let state = CollectionLoadState::from_proto(response.state)
      let progress = if state is Loading {
        let progress_request = @milvus.GetLoadingProgressRequest::{
          base: None,
          collection_name: option.collection_name,
          partition_names: option.partition_names,
          db_name: "",
        }
        let progress_response : @milvus.GetLoadingProgressResponse = self.call_service(
          get_loading_progress_path, progress_request,
        )
        match check_status(progress_response.status) {
          Some(err) => raise err
          None => progress_response.progress
        }
      } else {
        0L
      }
      { state, progress, }
    }
  }
}
