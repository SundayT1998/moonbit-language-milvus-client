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
/// 键名与字面量是线上协议的一部分，逐条钉死，防重构时手滑。
test "protocol keys" {
  assert_eq(@index.index_type_key, "index_type")
  assert_eq(@index.metric_type_key, "metric_type")
}

///|
/// MetricType 字面量必须与上游 entity.MetricType 一致（大小写敏感）。
test "metric type literals match upstream" {
  assert_eq(@index.MetricType::L2.to_string(), "L2")
  assert_eq(@index.MetricType::IP.to_string(), "IP")
  assert_eq(@index.MetricType::COSINE.to_string(), "COSINE")
  assert_eq(@index.MetricType::HAMMING.to_string(), "HAMMING")
  assert_eq(@index.MetricType::JACCARD.to_string(), "JACCARD")
  assert_eq(@index.MetricType::TANIMOTO.to_string(), "TANIMOTO")
  assert_eq(@index.MetricType::Substructure.to_string(), "SUBSTRUCTURE")
  assert_eq(@index.MetricType::Superstructure.to_string(), "SUPERSTRUCTURE")
  assert_eq(@index.MetricType::BM25.to_string(), "BM25")
  assert_eq(@index.MetricType::MhJaccard.to_string(), "MHJACCARD")
  assert_eq(@index.MetricType::MaxSim.to_string(), "MAX_SIM")
  assert_eq(@index.MetricType::MaxSimCosine.to_string(), "MAX_SIM_COSINE")
  assert_eq(@index.MetricType::MaxSimL2.to_string(), "MAX_SIM_L2")
  assert_eq(@index.MetricType::MaxSimIP.to_string(), "MAX_SIM_IP")
  assert_eq(@index.MetricType::MaxSimHamming.to_string(), "MAX_SIM_HAMMING")
  assert_eq(@index.MetricType::MaxSimJaccard.to_string(), "MAX_SIM_JACCARD")
}

///|
/// 字面量往返闭合。
test "metric type round-trips through its literal" {
  let all : Array[@index.MetricType] = [
    @index.MetricType::L2,
    @index.MetricType::IP,
    @index.MetricType::COSINE,
    @index.MetricType::HAMMING,
    @index.MetricType::JACCARD,
    @index.MetricType::TANIMOTO,
    @index.MetricType::Substructure,
    @index.MetricType::Superstructure,
    @index.MetricType::BM25,
    @index.MetricType::MhJaccard,
    @index.MetricType::MaxSim,
    @index.MetricType::MaxSimCosine,
    @index.MetricType::MaxSimL2,
    @index.MetricType::MaxSimIP,
    @index.MetricType::MaxSimHamming,
    @index.MetricType::MaxSimJaccard,
  ]
  for m in all {
    assert_eq(@index.MetricType::from_string(m.to_string()), Some(m))
  }
}

///|
/// 未知串返回 None，不猜。
test "unknown metric type literal is rejected" {
  assert_eq(@index.MetricType::from_string("EUCLIDEAN"), None)
  assert_eq(@index.MetricType::from_string("l2"), None)
  assert_eq(@index.MetricType::from_string(""), None)
}

///|
/// IndexType 字面量必须与上游 index.IndexType 一致。
test "index type literals match upstream" {
  assert_eq(@index.IndexType::Flat.to_string(), "FLAT")
  assert_eq(@index.IndexType::BinFlat.to_string(), "BIN_FLAT")
  assert_eq(@index.IndexType::IvfFlat.to_string(), "IVF_FLAT")
  assert_eq(@index.IndexType::BinIvfFlat.to_string(), "BIN_IVF_FLAT")
  assert_eq(@index.IndexType::IvfPQ.to_string(), "IVF_PQ")
  assert_eq(@index.IndexType::IvfSQ8.to_string(), "IVF_SQ8")
  assert_eq(@index.IndexType::IvfRabitQ.to_string(), "IVF_RABITQ")
  assert_eq(@index.IndexType::HNSW.to_string(), "HNSW")
  assert_eq(@index.IndexType::HNSWSQ.to_string(), "HNSW_SQ")
  assert_eq(@index.IndexType::HNSWPQ.to_string(), "HNSW_PQ")
  assert_eq(@index.IndexType::HNSWPRQ.to_string(), "HNSW_PRQ")
  assert_eq(@index.IndexType::IvfHNSW.to_string(), "IVF_HNSW")
  assert_eq(@index.IndexType::AutoIndex.to_string(), "AUTOINDEX")
  assert_eq(@index.IndexType::DiskANN.to_string(), "DISKANN")
  assert_eq(@index.IndexType::AISAQ.to_string(), "AISAQ")
  assert_eq(@index.IndexType::SCANN.to_string(), "SCANN")
  assert_eq(@index.IndexType::MinHashLSH.to_string(), "MINHASH_LSH")
  assert_eq(
    @index.IndexType::SparseInverted.to_string(),
    "SPARSE_INVERTED_INDEX",
  )
  assert_eq(@index.IndexType::SparseWAND.to_string(), "SPARSE_WAND")
  assert_eq(@index.IndexType::GpuIvfFlat.to_string(), "GPU_IVF_FLAT")
  assert_eq(@index.IndexType::GpuIvfPQ.to_string(), "GPU_IVF_PQ")
  assert_eq(@index.IndexType::GpuCagra.to_string(), "GPU_CAGRA")
  assert_eq(@index.IndexType::GpuBruteForce.to_string(), "GPU_BRUTE_FORCE")
  assert_eq(@index.IndexType::Trie.to_string(), "Trie")
  assert_eq(@index.IndexType::Sorted.to_string(), "STL_SORT")
  assert_eq(@index.IndexType::Inverted.to_string(), "INVERTED")
  assert_eq(@index.IndexType::Bitmap.to_string(), "BITMAP")
  assert_eq(@index.IndexType::Ngram.to_string(), "NGRAM")
  assert_eq(@index.IndexType::FmIndex.to_string(), "FMINDEX")
  assert_eq(@index.IndexType::RTree.to_string(), "RTREE")
}

///|
/// 索引类型字面量往返闭合。
test "index type round-trips through its literal" {
  let all : Array[@index.IndexType] = [
    @index.IndexType::Flat,
    @index.IndexType::BinFlat,
    @index.IndexType::IvfFlat,
    @index.IndexType::BinIvfFlat,
    @index.IndexType::IvfPQ,
    @index.IndexType::IvfSQ8,
    @index.IndexType::IvfRabitQ,
    @index.IndexType::HNSW,
    @index.IndexType::HNSWSQ,
    @index.IndexType::HNSWPQ,
    @index.IndexType::HNSWPRQ,
    @index.IndexType::IvfHNSW,
    @index.IndexType::AutoIndex,
    @index.IndexType::DiskANN,
    @index.IndexType::AISAQ,
    @index.IndexType::SCANN,
    @index.IndexType::MinHashLSH,
    @index.IndexType::SparseInverted,
    @index.IndexType::SparseWAND,
    @index.IndexType::GpuIvfFlat,
    @index.IndexType::GpuIvfPQ,
    @index.IndexType::GpuCagra,
    @index.IndexType::GpuBruteForce,
    @index.IndexType::Trie,
    @index.IndexType::Sorted,
    @index.IndexType::Inverted,
    @index.IndexType::Bitmap,
    @index.IndexType::Ngram,
    @index.IndexType::FmIndex,
    @index.IndexType::RTree,
  ]
  for t in all {
    assert_eq(@index.IndexType::from_string(t.to_string()), Some(t))
  }
}
