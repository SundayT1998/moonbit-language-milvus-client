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
// 移植自 milvus-io/milvus client/index/{hnsw,ivf,flat,auto}.go（Apache-2.0）。

///|
/// `index_type` 的字面量。与上游 `index.IndexType` 逐条对齐。
pub(all) enum IndexType {
  Flat
  BinFlat
  IvfFlat
  BinIvfFlat
  IvfPQ
  IvfSQ8
  IvfRabitQ
  HNSW
  HNSWSQ
  HNSWPQ
  HNSWPRQ
  IvfHNSW
  AutoIndex
  DiskANN
  AISAQ
  SCANN
  MinHashLSH
  SparseInverted
  SparseWAND
  GpuIvfFlat
  GpuIvfPQ
  GpuCagra
  GpuBruteForce
  Trie
  Sorted
  Inverted
  Bitmap
  Ngram
  FmIndex
  RTree
} derive(Eq, Debug)

///|
/// 上游字面量。
pub fn IndexType::to_string(self : IndexType) -> String {
  match self {
    Flat => "FLAT"
    BinFlat => "BIN_FLAT"
    IvfFlat => "IVF_FLAT"
    BinIvfFlat => "BIN_IVF_FLAT"
    IvfPQ => "IVF_PQ"
    IvfSQ8 => "IVF_SQ8"
    IvfRabitQ => "IVF_RABITQ"
    HNSW => "HNSW"
    HNSWSQ => "HNSW_SQ"
    HNSWPQ => "HNSW_PQ"
    HNSWPRQ => "HNSW_PRQ"
    IvfHNSW => "IVF_HNSW"
    AutoIndex => "AUTOINDEX"
    DiskANN => "DISKANN"
    AISAQ => "AISAQ"
    SCANN => "SCANN"
    MinHashLSH => "MINHASH_LSH"
    SparseInverted => "SPARSE_INVERTED_INDEX"
    SparseWAND => "SPARSE_WAND"
    GpuIvfFlat => "GPU_IVF_FLAT"
    GpuIvfPQ => "GPU_IVF_PQ"
    GpuCagra => "GPU_CAGRA"
    GpuBruteForce => "GPU_BRUTE_FORCE"
    Trie => "Trie"
    Sorted => "STL_SORT"
    Inverted => "INVERTED"
    Bitmap => "BITMAP"
    Ngram => "NGRAM"
    FmIndex => "FMINDEX"
    RTree => "RTREE"
  }
}

///|
/// 反解上游字面量。
pub fn IndexType::from_string(s : String) -> IndexType? {
  match s {
    "FLAT" => Some(Flat)
    "BIN_FLAT" => Some(BinFlat)
    "IVF_FLAT" => Some(IvfFlat)
    "BIN_IVF_FLAT" => Some(BinIvfFlat)
    "IVF_PQ" => Some(IvfPQ)
    "IVF_SQ8" => Some(IvfSQ8)
    "IVF_RABITQ" => Some(IvfRabitQ)
    "HNSW" => Some(HNSW)
    "HNSW_SQ" => Some(HNSWSQ)
    "HNSW_PQ" => Some(HNSWPQ)
    "HNSW_PRQ" => Some(HNSWPRQ)
    "IVF_HNSW" => Some(IvfHNSW)
    "AUTOINDEX" => Some(AutoIndex)
    "DISKANN" => Some(DiskANN)
    "AISAQ" => Some(AISAQ)
    "SCANN" => Some(SCANN)
    "MINHASH_LSH" => Some(MinHashLSH)
    "SPARSE_INVERTED_INDEX" => Some(SparseInverted)
    "SPARSE_WAND" => Some(SparseWAND)
    "GPU_IVF_FLAT" => Some(GpuIvfFlat)
    "GPU_IVF_PQ" => Some(GpuIvfPQ)
    "GPU_CAGRA" => Some(GpuCagra)
    "GPU_BRUTE_FORCE" => Some(GpuBruteForce)
    "Trie" => Some(Trie)
    "STL_SORT" => Some(Sorted)
    "INVERTED" => Some(Inverted)
    "BITMAP" => Some(Bitmap)
    "NGRAM" => Some(Ngram)
    "FMINDEX" => Some(FmIndex)
    "RTREE" => Some(RTree)
    _ => None
  }
}

///|
/// 一个索引定义：可选名字、类型，以及构建参数。
pub(all) struct Index {
  /// 索引名。空串表示让服务端用默认名（上游把 index_name 留空即为默认）。
  name : String
  metric_type : MetricType
  index_type : IndexType
  params : IndexParams
}

///|
/// 组装出完整参数：`metric_type` / `index_type` 固定在最前，其余按插入序。
/// 上游每个具体构建器都把这两个键写进 `Params()`，位置在 Go 的 map 里无序；
/// 这里定死顺序，便于测试快照稳定。
fn finish(
  name : String,
  metric_type : MetricType,
  index_type : IndexType,
  params : IndexParams,
) -> Index {
  let full = IndexParams::new()
  full.set(metric_type_key, metric_type.to_string())
  full.set(index_type_key, index_type.to_string())
  for entry in params.to_pairs() {
    // 这两个键由构建器掌管，调用方经 WithExtraIndexParams 传入时必须被忽略，
    // 否则 Params() 的 index_type 会与 Index::index_type 打架。
    if entry.0 == index_type_key || entry.0 == metric_type_key {
      continue
    }
    full.set(entry.0, entry.1)
  }
  { name, metric_type, index_type, params: full, }
}

///|
/// 索引的构建参数（含 `index_type` / `metric_type`）。
pub fn Index::params(self : Index) -> IndexParams {
  self.params
}

///|
/// 索引名。
pub fn Index::name(self : Index) -> String {
  self.name
}

///|
/// 索引类型。
pub fn Index::index_type(self : Index) -> IndexType {
  self.index_type
}

///|
/// 度量类型。
pub fn Index::metric_type(self : Index) -> MetricType {
  self.metric_type
}

///|
/// 合并额外构建参数，键名不做白名单，原样透传（服务端校验）。
/// `index_type` / `metric_type` 是保留键，静默忽略。
pub fn Index::with_extra_params(self : Index, extra : IndexParams) -> Index {
  let merged = IndexParams::from_pairs(self.params.to_pairs())
  for entry in extra.to_pairs() {
    merged.set(entry.0, entry.1)
  }
  finish(self.name, self.metric_type, self.index_type, merged)
}

///|
/// 设置索引名。
pub fn Index::with_name(self : Index, name : String) -> Index {
  { ..self, name, }
}

///|
/// 通用索引：调用方自己给全参数，`index_type` 从入参里取。
/// 上游 `NewGenericIndex` 同名同义，留作「构建器还没覆盖的参数」的出口。
pub fn new_generic_index(
  name : String,
  params : IndexParams,
) -> Index raise IndexParamError {
  let raw = match params.get(index_type_key) {
    Some(s) => s
    None => raise InvalidArgument(reason="generic index requires index_type")
  }
  let index_type = match IndexType::from_string(raw) {
    Some(t) => t
    None => raise InvalidArgument(reason="unknown index_type: \{raw}")
  }
  let metric_type = match params.get(metric_type_key) {
    Some(s) =>
      match MetricType::from_string(s) {
        Some(m) => m
        None => raise InvalidArgument(reason="unknown metric_type: \{s}")
      }
    None => raise InvalidArgument(reason="generic index requires metric_type")
  }
  finish(name, metric_type, index_type, params)
}

///|
/// HNSW：图索引，`M` 是每层邻居数，`efConstruction` 是建图时的候选队列长度。
///
/// 上游默认值 `M=16`、`efConstruction=200`（Milvus 文档与 Go SDK 示例一致）；
/// 越界检查与 knowhere 的 `CheckAndAdjust` 对齐：`M ≥ 2`，`efConstruction ≥ 1`。
pub fn new_hnsw_index(
  metric_type : MetricType,
  m? : Int = 16,
  ef_construction? : Int = 200,
) -> Index raise IndexParamError {
  if m < 2 {
    raise OutOfRange(key="M", value=m, expected=">= 2")
  }
  if ef_construction < 1 {
    raise OutOfRange(
      key="efConstruction",
      value=ef_construction,
      expected=">= 1",
    )
  }
  let params = IndexParams::new()
  params.set_int("M", m)
  params.set_int("efConstruction", ef_construction)
  finish("", metric_type, HNSW, params)
}

///|
/// IVF_FLAT：倒排 + 原始向量，`nlist` 是聚类中心数。
/// 上游 `NewIvfFlatIndex` 不校验，服务端要求 `nlist ∈ [1, 65536]`。
pub fn new_ivf_flat_index(
  metric_type : MetricType,
  nlist? : Int = 128,
) -> Index raise IndexParamError {
  if nlist < 1 || nlist > 65536 {
    raise OutOfRange(key="nlist", value=nlist, expected="[1, 65536]")
  }
  let params = IndexParams::new()
  params.set_int("nlist", nlist)
  finish("", metric_type, IvfFlat, params)
}

///|
/// AUTOINDEX：把参数完全交给服务端调优。
/// 上游 `NewAutoIndex` 只写 `index_type` 与 `metric_type`。
pub fn new_auto_index(metric_type : MetricType) -> Index {
  finish("", metric_type, AutoIndex, IndexParams::new())
}

///|
/// FLAT：暴力检索，只有 `metric_type` 与 `index_type`。
pub fn new_flat_index(metric_type : MetricType) -> Index {
  finish("", metric_type, Flat, IndexParams::new())
}

///|
/// 给浮点向量的索引补一道度量校验。
///
/// Milvus 用 `HAMMING` 配 `FloatVector` 只会在服务端被拒（`IllegalMetricType`），
/// 客户端提前判可以省一次往返。**不改变服务端语义**：这里放过的组合，服务端仍可能拒绝。
pub fn check_float_vector_metric(index : Index) -> Unit raise IndexParamError {
  if !index.metric_type.valid_for_float_vector() {
    raise InvalidCombination(
      index_type=index.index_type.to_string(),
      reason="metric_type \{index.metric_type.to_string()} is not valid for float vectors",
    )
  }
}
