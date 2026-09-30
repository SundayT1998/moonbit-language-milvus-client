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
// maintenance_options.go} 的 `Flush` / `FlushTask`（Apache-2.0）。
//
// 上游 `Flush` 返回 `*FlushTask`，`Await` 每 200ms 轮询 `GetFlushState`
// 直到 `flushed == true`。请求侧不按 segment 粒度，响应侧给的是
// 「集合名 → segment id 列表 / flush 时间戳」的映射，本移植照搬这个形状。

///|
/// 上游 `NewFlushOption` 的默认轮询间隔。
pub let default_flush_check_interval_millis : Int = 200

///|
/// flush 的入参。对应上游 `flushOption`：一次只 flush 一个集合
/// （`FlushRequest.collection_names` 是 repeated，但上游只塞一个）。
pub(all) struct FlushOption {
  collection_name : String
  /// `Await` 的轮询间隔。
  check_interval_millis : Int
}

///|
pub fn new_flush_option(collection_name : String) -> FlushOption {
  {
    collection_name,
    check_interval_millis: default_flush_check_interval_millis,
  }
}

///|
pub fn FlushOption::with_check_interval_millis(
  self : FlushOption,
  millis : Int,
) -> FlushOption {
  { ..self, check_interval_millis: millis, }
}

///|
/// flush 任务。拿着 `Flush` 响应里那段属于本集合的信息，
/// `Await` 到落盘完成。
pub struct FlushTask {
  client : Client
  collection_name : String
  /// 本次 flush 涉及的全部 segment（含正在 seal 的）。
  segment_ids : Array[Int64]
  /// 已进入 flush 流程的 segment id。
  flushed_segment_ids : Array[Int64]
  /// 本次 flush 的混合时间戳，`GetFlushState` 用它对账。
  flush_timestamp : UInt64
  interval_millis : Int
}

///|
pub fn FlushTask::collection_name(self : FlushTask) -> String {
  self.collection_name
}

///|
pub fn FlushTask::segment_ids(self : FlushTask) -> Array[Int64] {
  self.segment_ids
}

///|
pub fn FlushTask::flushed_segment_ids(self : FlushTask) -> Array[Int64] {
  self.flushed_segment_ids
}

///|
pub fn FlushTask::flush_timestamp(self : FlushTask) -> UInt64 {
  self.flush_timestamp
}

///|
/// 查一次落盘状态。不等待。
pub async fn FlushTask::is_flushed(self : FlushTask) -> Bool raise ClientError {
  let request = @milvus.GetFlushStateRequest::{
    segment_ids: self.segment_ids,
    flush_ts: self.flush_timestamp,
    db_name: "",
    collection_name: self.collection_name,
  }
  let response : @milvus.GetFlushStateResponse = self.client.call_service(
    get_flush_state_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => response.flushed
  }
}

///|
/// 轮询到落盘完成，与上游 `FlushTask.Await` 一致：先等一个间隔再查第一次。
pub async fn FlushTask::wait(self : FlushTask) -> Unit raise ClientError {
  while !self.is_flushed() {
    @async.sleep(self.interval_millis) catch {
      err =>
        raise ClientError::Transport(
          @transport.RpcError::new(
            @transport.Code::Cancelled.to_int(),
            "等待被取消: " + err.to_string(),
          ),
        )
    }
  }
}

///|
/// 把集合的已插入数据刷成持久化 segment。
///
/// `Flush` 只触发；真正落盘要等 `FlushTask::wait`。返回的任务里带上
/// 服务端给的 segment id 与 flush 时间戳，`wait` 拿它们去 `GetFlushState`。
pub async fn Client::flush(
  self : Client,
  option : FlushOption,
) -> FlushTask raise ClientError {
  let request = @milvus.FlushRequest::{
    base: None,
    db_name: "",
    collection_names: [option.collection_name],
  }
  let response : @milvus.FlushResponse = self.call_service(flush_path, request)
  match check_status(response.status) {
    Some(err) => raise err
    None => {
      let segment_ids = long_array_data(
        response.coll_seg_ids,
        option.collection_name,
      )
      let flushed_segment_ids = long_array_data(
        response.flush_coll_seg_ids,
        option.collection_name,
      )
      let flush_timestamp = match
        response.coll_flush_ts.get(option.collection_name) {
        Some(ts) => ts
        None => 0UL
      }
      {
        client: self,
        collection_name: option.collection_name,
        segment_ids,
        flushed_segment_ids,
        flush_timestamp,
        interval_millis: option.check_interval_millis,
      }
    }
  }
}

///|
/// 从 `FlushResponse` 的 map 里取某集合的 segment id 列表。
/// 序列里没这个集合时返回空数组——服务端不保证每个集合都在 map 里。
fn long_array_data(
  map : Map[String, @schema.LongArray],
  collection_name : String,
) -> Array[Int64] {
  match map.get(collection_name) {
    Some(array) => array.data
    None => []
  }
}

///|
/// `GetFlushState` 的入参。上层拿 `FlushTask` 里的字段直接查时用这个。
pub(all) struct GetFlushStateOption {
  collection_name : String
  segment_ids : Array[Int64]
  flush_timestamp : UInt64
}

///|
pub fn new_get_flush_state_option(
  collection_name : String,
  segment_ids : Array[Int64],
  flush_timestamp : UInt64,
) -> GetFlushStateOption {
  { collection_name, segment_ids, flush_timestamp, }
}

///|
/// 查这些 segment 是否已落盘。`FlushTask::is_flushed` 是它的糖。
pub async fn Client::get_flush_state(
  self : Client,
  option : GetFlushStateOption,
) -> Bool raise ClientError {
  let request = @milvus.GetFlushStateRequest::{
    segment_ids: option.segment_ids,
    flush_ts: option.flush_timestamp,
    db_name: "",
    collection_name: option.collection_name,
  }
  let response : @milvus.GetFlushStateResponse = self.call_service(
    get_flush_state_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => response.flushed
  }
}
