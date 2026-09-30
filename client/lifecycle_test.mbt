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
// 分区 / 加载 / flush 的跨 target 测试（#17）。
// 复用 `client_test.mbt` 里的假传输：断言请求编成了服务端认的字节，
// 响应解回了对的类型，轮询在拿到终止态后停下。

///|
async test "create_partition / drop_partition 编出正确的请求" {
  let client = test_client([
    (@client.create_partition_path, encode(ok_status())),
    (@client.drop_partition_path, encode(ok_status())),
  ])
  let (client, recorded) = client
  let _ = client.create_partition(
    @client.new_create_partition_option("demo", "p1"),
  ) catch {
    _ => ()
  }
  let _ = client.drop_partition(@client.new_drop_partition_option("demo", "p1")) catch {
    _ => ()
  }
  let create_request : @milvus.CreatePartitionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(create_request.collection_name, "demo")
  assert_eq(create_request.partition_name, "p1")
  let drop_request : @milvus.DropPartitionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[1].body),
    ),
  )
  assert_eq(drop_request.partition_name, "p1")
}

///|
async test "has_partition 读 BoolResponse 的 value" {
  // 假传输按路径回放，同一个路径只能有一条响应；两次调用各起一个客户端。
  let yes = @milvus.BoolResponse::{ status: Some(ok_status()), value: true, }
  let no = @milvus.BoolResponse::{ status: Some(ok_status()), value: false, }
  let (client_yes, _) = test_client([(@client.has_partition_path, encode(yes))])
  let (client_no, _) = test_client([(@client.has_partition_path, encode(no))])
  assert_true(
    client_yes.has_partition(@client.new_has_partition_option("demo", "p1")) catch {
      _ => false
    },
  )
  assert_false(
    client_no.has_partition(@client.new_has_partition_option("demo", "p2")) catch {
      _ => true
    },
  )
}

///|
async test "list_partitions 走 ShowPartitions 并带 Type=All" {
  let response = @milvus.ShowPartitionsResponse::{
    status: Some(ok_status()),
    partition_names: ["_default", "p1"],
    partition_ids: [1L, 2L],
    created_timestamps: [],
    created_utc_timestamps: [],
    in_memory_percentages: [],
  }
  let client = test_client([(@client.show_partitions_path, encode(response))])
  let (client, recorded) = client
  let names = client.list_partitions(@client.new_list_partitions_option("demo")) catch {
    _ => []
  }
  assert_eq(names, ["_default", "p1"])
  let request : @milvus.ShowPartitionsRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(request.collection_name, "demo")
  assert_eq(request.type_, @milvus.ShowType::All)
}

///|
async test "load_collection 后轮询 GetLoadingProgress 到 100" {
  let progress = @milvus.GetLoadingProgressResponse::{
    status: Some(ok_status()),
    progress: 100L,
    refresh_progress: 0L,
  }
  let client = test_client([
    (@client.load_collection_path, encode(ok_status())),
    (@client.get_loading_progress_path, encode(progress)),
  ])
  let (client, recorded) = client
  let task = client.load_collection(
    @client.new_load_collection_option("demo").with_replica(2),
  ) catch {
    _ => fail("load_collection should succeed")
  }
  assert_eq(task.collection_name(), "demo")
  assert_eq(task.progress(), 100L) catch {
    _ => fail("progress should read")
  }
  task.wait() catch {
    _ => fail("wait should return")
  }
  // 一次 LoadCollection + 显式 progress 一次 + wait 里的一次 = 3 次 GetLoadingProgress
  assert_eq(recorded.val.length(), 3)
  let load_request : @milvus.LoadCollectionRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(load_request.collection_name, "demo")
  assert_eq(load_request.replica_number, 2)
  assert_false(load_request.refresh)
}

///|
async test "load_partitions 的请求带上分区名" {
  let progress = @milvus.GetLoadingProgressResponse::{
    status: Some(ok_status()),
    progress: 100L,
    refresh_progress: 0L,
  }
  let client = test_client([
    (@client.load_partitions_path, encode(ok_status())),
    (@client.get_loading_progress_path, encode(progress)),
  ])
  let (client, recorded) = client
  let task = client.load_partitions(
    @client.new_load_partitions_option("demo", ["p1", "p2"]),
  ) catch {
    _ => fail("load_partitions should succeed")
  }
  assert_eq(task.partition_names(), ["p1", "p2"])
  task.wait() catch {
    _ => fail("wait should return")
  }
  let request : @milvus.LoadPartitionsRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(request.partition_names, ["p1", "p2"])
}

///|
async test "refresh 模式等的是 refresh_progress" {
  let progress = @milvus.GetLoadingProgressResponse::{
    status: Some(ok_status()),
    progress: 40L,
    refresh_progress: 100L,
  }
  let client = test_client([
    (@client.load_collection_path, encode(ok_status())),
    (@client.get_loading_progress_path, encode(progress)),
  ])
  let (client, _) = client
  let task = client.load_collection(
    @client.new_load_collection_option("demo").with_refresh(),
  ) catch {
    _ => fail("load_collection should succeed")
  }
  // refresh 为真时看 refresh_progress，100 即完成；progress 只有 40 也不影响
  task.wait() catch {
    _ => fail("wait should return")
  }
}

///|
async test "release_collection / release_partitions 编出正确的请求" {
  let client = test_client([
    (@client.release_collection_path, encode(ok_status())),
    (@client.release_partitions_path, encode(ok_status())),
  ])
  let (client, recorded) = client
  let _ = client.release_collection(
    @client.new_release_collection_option("demo"),
  ) catch {
    _ => ()
  }
  let _ = client.release_partitions(
    @client.new_release_partitions_option("demo", ["p1"]),
  ) catch {
    _ => ()
  }
  let release_request : @milvus.ReleasePartitionsRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[1].body),
    ),
  )
  assert_eq(release_request.partition_names, ["p1"])
}

///|
async test "get_load_state 在 Loading 时补查进度" {
  let state = @milvus.GetLoadStateResponse::{
    status: Some(ok_status()),
    state: @common.LoadState::LoadStateLoading,
  }
  let progress = @milvus.GetLoadingProgressResponse::{
    status: Some(ok_status()),
    progress: 66L,
    refresh_progress: 0L,
  }
  let client = test_client([
    (@client.get_load_state_path, encode(state)),
    (@client.get_loading_progress_path, encode(progress)),
  ])
  let (client, _) = client
  let load_state = client.get_load_state(
    @client.new_get_load_state_option("demo"),
  ) catch {
    _ => fail("get_load_state should succeed")
  }
  assert_eq(load_state.state, @client.CollectionLoadState::Loading)
  assert_eq(load_state.progress, 66L)
}

///|
async test "get_load_state 非 Loading 时不补查进度" {
  let state = @milvus.GetLoadStateResponse::{
    status: Some(ok_status()),
    state: @common.LoadState::LoadStateLoaded,
  }
  let client = test_client([(@client.get_load_state_path, encode(state))])
  let (client, recorded) = client
  let load_state = client.get_load_state(
    @client.new_get_load_state_option("demo"),
  ) catch {
    _ => fail("get_load_state should succeed")
  }
  assert_eq(load_state.state, @client.CollectionLoadState::Loaded)
  assert_eq(load_state.progress, 0L)
  // 只发了一次请求，没有多余的 GetLoadingProgress
  assert_eq(recorded.val.length(), 1)
}

///|
async test "flush 拿响应里的 segment 与时间戳，GetFlushState 轮询到完成" {
  let seg_ids : Map[String, @schema.LongArray] = Map([
    ("demo", @schema.LongArray::LongArray([11L, 12L])),
  ])
  let flush_ts : Map[String, UInt64] = Map([("demo", 900UL)])
  let flush_response = @milvus.FlushResponse::{
    status: Some(ok_status()),
    db_name: "default",
    coll_seg_ids: seg_ids,
    flush_coll_seg_ids: seg_ids,
    coll_seal_times: Map([]),
    coll_flush_ts: flush_ts,
    channel_cps: Map([]),
  }
  let flush_state = @milvus.GetFlushStateResponse::{
    status: Some(ok_status()),
    flushed: true,
  }
  let client = test_client([
    (@client.flush_path, encode(flush_response)),
    (@client.get_flush_state_path, encode(flush_state)),
  ])
  let (client, recorded) = client
  let task = client.flush(@client.new_flush_option("demo")) catch {
    _ => fail("flush should succeed")
  }
  assert_eq(task.segment_ids(), [11L, 12L])
  assert_eq(task.flush_timestamp(), 900UL)
  assert_true(task.is_flushed() catch { _ => false })
  task.wait() catch {
    _ => fail("wait should return")
  }
  let flush_request : @milvus.FlushRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[0].body),
    ),
  )
  assert_eq(flush_request.collection_names, ["demo"])
  let state_request : @milvus.GetFlushStateRequest = @lib.Read::read_with_limit(
    @lib.LimitedReader::LimitedReader(
      @lib.BytesReader::from_bytes(recorded.val[1].body),
    ),
  )
  assert_eq(state_request.collection_name, "demo")
  assert_eq(state_request.segment_ids, [11L, 12L])
  assert_eq(state_request.flush_ts, 900UL)
}

///|
async test "get_flush_state 未完成时返回 false" {
  let flush_state = @milvus.GetFlushStateResponse::{
    status: Some(ok_status()),
    flushed: false,
  }
  let client = test_client([(@client.get_flush_state_path, encode(flush_state))])
  let (client, _) = client
  assert_false(
    client.get_flush_state(
      @client.new_get_flush_state_option("demo", [1L, 2L], 5UL),
    ) catch {
      _ => true
    },
  )
}

///|
async test "分区 RPC 遇服务端拒绝抛 Server 错误" {
  let failure = @common.Status::{
    error_code: @common.ErrorCode::UnexpectedError,
    reason: "boom",
    code: 1,
    retriable: false,
    detail: "detail",
    extra_info: {},
  }
  let client = test_client([(@client.create_partition_path, encode(failure))])
  let (client, _) = client
  let mut raised = false
  ignore(
    client.create_partition(@client.new_create_partition_option("demo", "p1")),
  ) catch {
    err => if err is @client.Server(_) { raised = true }
  }
  assert_true(raised)
}

///|
/// 按调用次数变响应的假传输：同一个路径第一次回 `false`，第二次回 `true`。
/// 用来证明轮询确实会重试，而不是只查一次就返回。
fn sequence_transport(
  seq : Ref[Int],
  responses : Array[Bytes],
) -> @client.Unary {
  (path, body) => {
    ignore((path, body))
    let i = seq.val
    seq.val = i + 1
    if i < responses.length() {
      responses[i]
    } else {
      responses[responses.length() - 1]
    }
  }
}

///|
async test "flush 轮询：未完成时继续查，完成后停下" {
  let flush_response = @milvus.FlushResponse::{
    status: Some(ok_status()),
    db_name: "default",
    coll_seg_ids: Map([("demo", @schema.LongArray::LongArray([7L]))]),
    flush_coll_seg_ids: Map([]),
    coll_seal_times: Map([]),
    coll_flush_ts: Map([("demo", 42UL)]),
    channel_cps: Map([]),
  }
  let not_yet = @milvus.GetFlushStateResponse::{
    status: Some(ok_status()),
    flushed: false,
  }
  let done = @milvus.GetFlushStateResponse::{
    status: Some(ok_status()),
    flushed: true,
  }
  // 响应序列按「调用顺序」发：Flush → 未完成 → 完成
  let seq : Ref[Int] = Ref(0)
  let config = @transport.Config::new("127.0.0.1:19530")
  let client = @client.Client::new(
    config,
    sequence_transport(seq, [
      encode(flush_response),
      encode(not_yet),
      encode(done),
    ]),
  )
  let task = client.flush(
    @client.new_flush_option("demo").with_check_interval_millis(1),
  ) catch {
    _ => fail("flush should succeed")
  }
  task.wait() catch {
    _ => fail("wait should return")
  }
  // Flush 一次 + 轮询两次（未完成 → 完成）
  assert_eq(seq.val, 3)
}
