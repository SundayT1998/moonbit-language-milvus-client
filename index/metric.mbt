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
// 移植自 milvus-io/milvus client/entity/common.go（Apache-2.0），
// 基线 commit 见 proto/upstream/PROVENANCE.md。
// 字面量必须与上游逐条对齐：Milvus 服务端按字符串匹配，大小写敏感。

///|
/// 距离度量类型。Milvus 服务端按字符串比对，故用 `String` 而非枚举序号承载。
/// 上游同名常量在 `entity.MetricType`，`index.MetricType` 是它的别名。
pub(all) enum MetricType {
  /// 欧氏距离，越小越相近。浮点向量默认。
  L2
  /// 内积，越大越相近。
  IP
  /// 余弦相似度，越大越相近。
  COSINE
  /// 汉明距离，二进制向量。
  HAMMING
  /// Jaccard 距离，二进制向量。
  JACCARD
  /// Tanimoto 距离，二进制向量。
  TANIMOTO
  /// 超结构/子结构，分子数据。
  Substructure
  Superstructure
  /// 稀疏向量全文检索。
  BM25
  /// MinHash 的 Jaccard，稀疏向量。
  MhJaccard
  /// 多向量（ArrayOfVector）系列，语义与同名非 MaxSim 版本一致。
  MaxSim
  MaxSimCosine
  MaxSimL2
  MaxSimIP
  MaxSimHamming
  MaxSimJaccard
} derive(Eq, Debug)

///|
/// 上游使用的字面量。改动这里就是改动线上协议，测试逐条锁住。
pub fn MetricType::to_string(self : MetricType) -> String {
  match self {
    L2 => "L2"
    IP => "IP"
    COSINE => "COSINE"
    HAMMING => "HAMMING"
    JACCARD => "JACCARD"
    TANIMOTO => "TANIMOTO"
    Substructure => "SUBSTRUCTURE"
    Superstructure => "SUPERSTRUCTURE"
    BM25 => "BM25"
    MhJaccard => "MHJACCARD"
    MaxSim => "MAX_SIM"
    MaxSimCosine => "MAX_SIM_COSINE"
    MaxSimL2 => "MAX_SIM_L2"
    MaxSimIP => "MAX_SIM_IP"
    MaxSimHamming => "MAX_SIM_HAMMING"
    MaxSimJaccard => "MAX_SIM_JACCARD"
  }
}

///|
/// 反解上游字面量；未知串返回 `None`，不猜测。
pub fn MetricType::from_string(s : String) -> MetricType? {
  match s {
    "L2" => Some(L2)
    "IP" => Some(IP)
    "COSINE" => Some(COSINE)
    "HAMMING" => Some(HAMMING)
    "JACCARD" => Some(JACCARD)
    "TANIMOTO" => Some(TANIMOTO)
    "SUBSTRUCTURE" => Some(Substructure)
    "SUPERSTRUCTURE" => Some(Superstructure)
    "BM25" => Some(BM25)
    "MHJACCARD" => Some(MhJaccard)
    "MAX_SIM" => Some(MaxSim)
    "MAX_SIM_COSINE" => Some(MaxSimCosine)
    "MAX_SIM_L2" => Some(MaxSimL2)
    "MAX_SIM_IP" => Some(MaxSimIP)
    "MAX_SIM_HAMMING" => Some(MaxSimHamming)
    "MAX_SIM_JACCARD" => Some(MaxSimJaccard)
    _ => None
  }
}

///|
/// 该度量是否可用于浮点向量（`FloatVector` / `Float16Vector` / `BFloat16Vector`）。
/// 上游不显式校验这一步，服务端在 `CreateIndex` 时才拒绝；
/// 客户端提前判能给出更清晰的错误，故单列但**不放松**服务端语义。
pub fn MetricType::valid_for_float_vector(self : MetricType) -> Bool {
  match self {
    L2 | IP | COSINE | MaxSimL2 | MaxSimIP | MaxSimCosine => true
    _ => false
  }
}
