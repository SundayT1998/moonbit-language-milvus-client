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

///|
/// gRPC 路径是协议的一部分，拼错就是 404。
test "rpc paths match the MilvusService" {
  assert_eq(
    @index.create_index_path, "/milvus.proto.milvus.MilvusService/CreateIndex",
  )
  assert_eq(
    @index.describe_index_path, "/milvus.proto.milvus.MilvusService/DescribeIndex",
  )
  assert_eq(
    @index.drop_index_path, "/milvus.proto.milvus.MilvusService/DropIndex",
  )
}

///|
/// IndexState 序号必须与 common.IndexState 逐条对齐：这是 wire 值。
test "index state numbers match upstream" {
  assert_eq(@index.IndexState::None.to_int(), 0)
  assert_eq(@index.IndexState::Unissued.to_int(), 1)
  assert_eq(@index.IndexState::InProgress.to_int(), 2)
  assert_eq(@index.IndexState::Finished.to_int(), 3)
  assert_eq(@index.IndexState::Failed.to_int(), 4)
  assert_eq(@index.IndexState::Retry.to_int(), 5)
  assert_eq(@index.IndexState::from_int(3), @index.IndexState::Finished)
  assert_eq(@index.IndexState::from_int(4), @index.IndexState::Failed)
}

///|
/// 上游将来新增的枚举值不能被当成已认识的语义：保留序号，标成 Unknown。
test "unknown index state keeps its number" {
  assert_eq(@index.IndexState::from_int(99), @index.IndexState::Unknown(99))
  assert_eq(@index.IndexState::from_int(99).to_int(), 99)
}

///|
/// 只有 Finished / Failed 是终态，其余要接着轮询。
test "only finished and failed are terminal" {
  assert_true(@index.IndexState::Finished.is_terminal())
  assert_true(@index.IndexState::Failed.is_terminal())
  assert_false(@index.IndexState::InProgress.is_terminal())
  assert_false(@index.IndexState::Unissued.is_terminal())
  assert_false(@index.IndexState::Retry.is_terminal())
  assert_false(@index.IndexState::None.is_terminal())
  assert_false(@index.IndexState::Unknown(99).is_terminal())
}

///|
/// CreateIndex 入参从索引定义装配出来，参数键值对原样透传。
test "create index request from an index" {
  let idx = @index.new_hnsw_index(@index.MetricType::COSINE, m=32)
  let req = @index.CreateIndexRequest::from_index(
    "demo",
    "embedding",
    idx.with_name("embedding_idx"),
  )
  assert_eq(req.collection_name, "demo")
  assert_eq(req.field_name, "embedding")
  assert_eq(req.index_name, "embedding_idx")
  assert_eq(req.db_name, "")
  assert_eq(req.extra_params, [
    ("metric_type", "COSINE"),
    ("index_type", "HNSW"),
    ("M", "32"),
    ("efConstruction", "200"),
  ])
}

///|
/// 索引名留空走服务端默认命名，不是错误。
test "create index request allows a default index name" {
  let idx = @index.new_auto_index(@index.MetricType::L2)
  let req = @index.CreateIndexRequest::from_index("demo", "vec", idx)
  assert_eq(req.index_name, "")
}

///|
/// 集合名与字段名是必填项，空了就直接拒，省一次往返。
test "create index request rejects empty names" {
  let idx = @index.new_flat_index(@index.MetricType::L2)
  let a : Result[Unit, @index.IndexParamError] = try {
    let _ = @index.CreateIndexRequest::from_index("", "vec", idx)
    Ok(())
  } catch {
    e => Err(e)
  }
  match a {
    Err(@index.IndexParamError::InvalidArgument(reason~)) =>
      assert_true(reason.contains("collection_name"))
    _ => fail("expected InvalidArgument for empty collection")
  }

  let b : Result[Unit, @index.IndexParamError] = try {
    let _ = @index.CreateIndexRequest::from_index("demo", "", idx)
    Ok(())
  } catch {
    e => Err(e)
  }
  match b {
    Err(@index.IndexParamError::InvalidArgument(reason~)) =>
      assert_true(reason.contains("field_name"))
    _ => fail("expected InvalidArgument for empty field")
  }
}

///|
/// 三种 DescribeIndex 入参形态：全列、按名、按字段。
test "describe index request shapes" {
  let all = @index.DescribeIndexRequest::list_all("demo")
  assert_eq(all.field_name, "")
  assert_eq(all.index_name, "")

  let by_name = @index.DescribeIndexRequest::by_name("demo", "idx_a")
  assert_eq(by_name.index_name, "idx_a")
  assert_eq(by_name.field_name, "")

  let by_field = @index.DescribeIndexRequest::by_field("demo", "embedding")
  assert_eq(by_field.field_name, "embedding")
  assert_eq(by_field.index_name, "")
}

///|
/// 「按名查」但不给名字是调用方搞错了：全列有专门入口。
test "describe by name requires an index name" {
  let r : Result[Unit, @index.IndexParamError] = try {
    let _ = @index.DescribeIndexRequest::by_name("demo", "")
    Ok(())
  } catch {
    e => Err(e)
  }
  match r {
    Err(@index.IndexParamError::InvalidArgument(reason~)) =>
      assert_true(reason.contains("list_all"))
    _ => fail("expected InvalidArgument")
  }
}

///|
/// DropIndex 必填索引名：Milvus 没有「删全部索引」。
test "drop index request requires names" {
  let ok = @index.DropIndexRequest::new("demo", "idx_a")
  assert_eq(ok.collection_name, "demo")
  assert_eq(ok.index_name, "idx_a")

  let r : Result[Unit, @index.IndexParamError] = try {
    let _ = @index.DropIndexRequest::new("demo", "")
    Ok(())
  } catch {
    e => Err(e)
  }
  match r {
    Err(@index.IndexParamError::InvalidArgument(reason~)) =>
      assert_true(reason.contains("index_name"))
    _ => fail("expected InvalidArgument")
  }
}

///|
/// 回读一条索引描述：类型与度量从 params 里解出来。
test "index description reads back type and metric" {
  let d : @index.IndexDescription = {
    index_name: "embedding_idx",
    index_id: 456L,
    params: [("index_type", "HNSW"), ("metric_type", "COSINE"), ("M", "16")],
    field_name: "embedding",
    indexed_rows: 100L,
    total_rows: 100L,
    pending_index_rows: 0L,
    state: @index.IndexState::Finished,
    fail_reason: "",
  }
  assert_eq(d.index_type(), Some(@index.IndexType::HNSW))
  assert_eq(d.metric_type(), Some(@index.MetricType::COSINE))
  assert_eq(d.index_params().get("M"), Some("16"))
  assert_eq(d.progress(), Some(1.0))
}

///|
/// 服务端没回某个键时返回 None，不用默认值糊过去。
test "missing param keys yield none" {
  let d : @index.IndexDescription = {
    index_name: "x",
    index_id: 1L,
    params: [],
    field_name: "f",
    indexed_rows: 0L,
    total_rows: 0L,
    pending_index_rows: 0L,
    state: @index.IndexState::InProgress,
    fail_reason: "",
  }
  assert_eq(d.index_type(), None)
  assert_eq(d.metric_type(), None)
  // 空集合没有进度可言，不做除零
  assert_eq(d.progress(), None)
}

///|
/// 未知的 index_type 字面量返回 None，不 panic。
test "unknown index type literal yields none" {
  let d : @index.IndexDescription = {
    index_name: "x",
    index_id: 1L,
    params: [("index_type", "SOMETHING_NEW")],
    field_name: "f",
    indexed_rows: 0L,
    total_rows: 0L,
    pending_index_rows: 0L,
    state: @index.IndexState::InProgress,
    fail_reason: "",
  }
  assert_eq(d.index_type(), None)
}

///|
/// 多索引集合下按名挑，不能拿第一条充数。
test "find by name does not fall back to the first entry" {
  let a : @index.IndexDescription = {
    index_name: "idx_a",
    index_id: 1L,
    params: [],
    field_name: "fa",
    indexed_rows: 0L,
    total_rows: 0L,
    pending_index_rows: 0L,
    state: @index.IndexState::Finished,
    fail_reason: "",
  }
  let b : @index.IndexDescription = {
    index_name: "idx_b",
    index_id: 2L,
    params: [],
    field_name: "fb",
    indexed_rows: 0L,
    total_rows: 0L,
    pending_index_rows: 0L,
    state: @index.IndexState::Finished,
    fail_reason: "",
  }
  let all = [a, b]
  assert_eq(@index.find_by_name(all, "idx_b"), Some(b))
  assert_eq(@index.find_by_name(all, "idx_c"), None)
}

///|
/// 按字段筛出该字段上的全部索引。
test "find by field returns every index on it" {
  let mk = (name : String, field : String) => {
    let d : @index.IndexDescription = {
      index_name: name,
      index_id: 1L,
      params: [],
      field_name: field,
      indexed_rows: 0L,
      total_rows: 0L,
      pending_index_rows: 0L,
      state: @index.IndexState::Finished,
      fail_reason: "",
    }
    d
  }
  let all = [mk("i1", "vec"), mk("i2", "other"), mk("i3", "vec")]
  let hits = @index.find_by_field(all, "vec")
  assert_eq(hits.length(), 2)
  assert_eq(hits[0].index_name, "i1")
  assert_eq(hits[1].index_name, "i3")
  assert_eq(@index.find_by_field(all, "nope").length(), 0)
}
