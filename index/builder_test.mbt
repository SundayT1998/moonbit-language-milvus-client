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
/// 上游默认值：`NewHNSWIndex` 的典型调用是 `(L2, 16, 200)`，
/// 与 Milvus 文档给出的默认 `M=16` / `efConstruction=200` 一致。
test "hnsw defaults match upstream" {
  let idx = @index.new_hnsw_index(@index.MetricType::COSINE)
  assert_eq(idx.index_type(), @index.IndexType::HNSW)
  assert_eq(idx.metric_type(), @index.MetricType::COSINE)
  let p = idx.params()
  assert_eq(p.get("index_type"), Some("HNSW"))
  assert_eq(p.get("metric_type"), Some("COSINE"))
  assert_eq(p.get("M"), Some("16"))
  assert_eq(p.get("efConstruction"), Some("200"))
}

///|
/// 显式传参不得被默认值覆盖，且数值走十进制字符串。
test "hnsw explicit params" {
  let idx = @index.new_hnsw_index(
    @index.MetricType::L2,
    m=64,
    ef_construction=128,
  )
  let p = idx.params()
  assert_eq(p.get("M"), Some("64"))
  assert_eq(p.get("efConstruction"), Some("128"))
  assert_eq(p.get("metric_type"), Some("L2"))
}

///|
/// `M` 的下界是 2（knowhere 拒绝 1 及以下）。
test "hnsw rejects M below 2" {
  let result : Result[Unit, @index.IndexParamError] = try {
    let _ = @index.new_hnsw_index(@index.MetricType::L2, m=1)
    Ok(())
  } catch {
    e => Err(e)
  }
  match result {
    Err(@index.IndexParamError::OutOfRange(key~, value~, expected~)) => {
      assert_eq(key, "M")
      assert_eq(value, 1)
      assert_eq(expected, ">= 2")
    }
    _ => fail("expected OutOfRange for M")
  }
}

///|
/// `efConstruction` 下界是 1。
test "hnsw rejects efConstruction below 1" {
  let result : Result[Unit, @index.IndexParamError] = try {
    let _ = @index.new_hnsw_index(@index.MetricType::L2, ef_construction=0)
    Ok(())
  } catch {
    e => Err(e)
  }
  match result {
    Err(@index.IndexParamError::OutOfRange(key~, ..)) =>
      assert_eq(key, "efConstruction")
    _ => fail("expected OutOfRange for efConstruction")
  }
}

///|
/// IVF_FLAT 默认 `nlist=128`。
test "ivf flat defaults" {
  let idx = @index.new_ivf_flat_index(@index.MetricType::IP)
  let p = idx.params()
  assert_eq(p.get("index_type"), Some("IVF_FLAT"))
  assert_eq(p.get("metric_type"), Some("IP"))
  assert_eq(p.get("nlist"), Some("128"))
  assert_eq(p.size(), 3)
}

///|
/// `nlist` 上界 65536，越界在构造期报错。
test "ivf flat rejects out-of-range nlist" {
  for bad in [0, -1, 65537] {
    let result : Result[Unit, @index.IndexParamError] = try {
      let _ = @index.new_ivf_flat_index(@index.MetricType::L2, nlist=bad)
      Ok(())
    } catch {
      e => Err(e)
    }
    match result {
      Err(@index.IndexParamError::OutOfRange(key~, value~, expected~)) => {
        assert_eq(key, "nlist")
        assert_eq(value, bad)
        assert_eq(expected, "[1, 65536]")
      }
      _ => fail("expected OutOfRange for nlist")
    }
  }
}

///|
/// AUTOINDEX 与 FLAT 只有两个参数，不带任何额外键。
test "auto index and flat index carry only the two keys" {
  let auto = @index.new_auto_index(@index.MetricType::COSINE)
  assert_eq(auto.params().size(), 2)
  assert_eq(auto.params().get("index_type"), Some("AUTOINDEX"))
  assert_eq(auto.params().get("metric_type"), Some("COSINE"))

  let flat = @index.new_flat_index(@index.MetricType::L2)
  assert_eq(flat.params().size(), 2)
  assert_eq(flat.params().get("index_type"), Some("FLAT"))
  assert_eq(flat.params().get("metric_type"), Some("L2"))
}

///|
/// `WithExtraIndexParams` 可补构建器未建模的参数。
test "extra params reach the wire" {
  let extra = @index.IndexParams::new()
  extra.set("refine", "true")
  extra.set("refine_type", "fp32")
  let idx = @index.new_hnsw_index(@index.MetricType::L2).with_extra_params(
    extra,
  )
  let p = idx.params()
  assert_eq(p.get("refine"), Some("true"))
  assert_eq(p.get("refine_type"), Some("fp32"))
  assert_eq(p.get("M"), Some("16"))
}

///|
/// 额外参数在键冲突时覆盖构建器的值——除了两个保留键。
test "extra params override, except the reserved keys" {
  let extra = @index.IndexParams::new()
  extra.set("M", "32")
  extra.set(@index.index_type_key, "IVF_FLAT")
  extra.set(@index.metric_type_key, "IP")
  let idx = @index.new_hnsw_index(@index.MetricType::L2).with_extra_params(
    extra,
  )
  let p = idx.params()
  assert_eq(p.get("M"), Some("32"))
  // 保留键被忽略，否则 params 里的 index_type 会与 index_type() 打架
  assert_eq(p.get("index_type"), Some("HNSW"))
  assert_eq(p.get("metric_type"), Some("L2"))
  assert_eq(idx.index_type(), @index.IndexType::HNSW)
  assert_eq(idx.metric_type(), @index.MetricType::L2)
}

///|
/// 通用索引是兜底出口：调用方自己给 index_type。
test "generic index accepts a raw index_type" {
  let params = @index.IndexParams::new()
  params.set("index_type", "FMINDEX")
  params.set("metric_type", "BM25")
  params.set("custom_key", "custom_value")
  let idx = @index.new_generic_index("fm_index", params)
  assert_eq(idx.name(), "fm_index")
  assert_eq(idx.index_type(), @index.IndexType::FmIndex)
  assert_eq(idx.params().get("custom_key"), Some("custom_value"))
}

///|
/// 通用索引缺 index_type 时报错，不猜默认。
test "generic index requires index_type" {
  let params = @index.IndexParams::new()
  params.set("metric_type", "L2")
  let result : Result[Unit, @index.IndexParamError] = try {
    let _ = @index.new_generic_index("x", params)
    Ok(())
  } catch {
    e => Err(e)
  }
  match result {
    Err(@index.IndexParamError::InvalidArgument(reason~)) =>
      assert_true(reason.contains("index_type"))
    _ => fail("expected InvalidArgument")
  }
}

///|
/// 未知 index_type 字面量被拒。
test "generic index rejects unknown index_type" {
  let params = @index.IndexParams::new()
  params.set("index_type", "NOT_A_REAL_INDEX")
  params.set("metric_type", "L2")
  let result : Result[Unit, @index.IndexParamError] = try {
    let _ = @index.new_generic_index("x", params)
    Ok(())
  } catch {
    e => Err(e)
  }
  match result {
    Err(@index.IndexParamError::InvalidArgument(reason~)) =>
      assert_true(reason.contains("NOT_A_REAL_INDEX"))
    _ => fail("expected InvalidArgument")
  }
}

///|
/// 浮点向量不接受的度量提前拦下：HAMMING 配 FloatVector 服务端必拒。
test "float vector metric check" {
  assert_true(@index.MetricType::L2.valid_for_float_vector())
  assert_true(@index.MetricType::IP.valid_for_float_vector())
  assert_true(@index.MetricType::COSINE.valid_for_float_vector())
  assert_true(@index.MetricType::MaxSimCosine.valid_for_float_vector())
  assert_false(@index.MetricType::HAMMING.valid_for_float_vector())
  assert_false(@index.MetricType::JACCARD.valid_for_float_vector())
  assert_false(@index.MetricType::BM25.valid_for_float_vector())

  let ok = @index.new_hnsw_index(@index.MetricType::COSINE)
  @index.check_float_vector_metric(ok)

  let bad = @index.new_hnsw_index(@index.MetricType::HAMMING)
  let result : Result[Unit, @index.IndexParamError] = try {
    @index.check_float_vector_metric(bad)
    Ok(())
  } catch {
    e => Err(e)
  }
  match result {
    Err(@index.IndexParamError::InvalidCombination(index_type~, reason~)) => {
      assert_eq(index_type, "HNSW")
      assert_true(reason.contains("HAMMING"))
    }
    _ => fail("expected InvalidCombination")
  }
}
