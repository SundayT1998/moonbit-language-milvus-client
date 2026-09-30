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
// 移植自 milvus-io/milvus client/entity/consistency_level.go（Apache-2.0）。

///|
/// Milvus 的一致性等级。与 `common.ConsistencyLevel` 逐条对齐。
pub(all) enum ConsistencyLevel {
  Strong
  Session
  Bounded
  Eventually
  Customized
} derive(Eq, Debug)

///|
/// 上游 `entity.DefaultConsistencyLevel`：`Bounded`。
pub let default_consistency_level : ConsistencyLevel = ConsistencyLevel::Bounded

///|
/// 上游字面量 / proto 枚举值。
pub fn ConsistencyLevel::to_int(self : ConsistencyLevel) -> Int {
  match self {
    Strong => 0
    Session => 1
    Bounded => 2
    Eventually => 3
    Customized => 4
  }
}

///|
/// 反解 proto 枚举值。越界一律退回 `Bounded`（下游的默认值），
/// 因为协议未来加档时旧客户端只能按默认档处理。
pub fn ConsistencyLevel::from_int(value : Int) -> ConsistencyLevel {
  match value {
    0 => Strong
    1 => Session
    2 => Bounded
    3 => Eventually
    4 => Customized
    _ => default_consistency_level
  }
}

///|
pub fn ConsistencyLevel::to_proto(
  self : ConsistencyLevel,
) -> @common.ConsistencyLevel {
  @common.ConsistencyLevel::from_enum(
    @lib.Enum(self.to_int().reinterpret_as_uint()),
  )
}

///|
pub fn ConsistencyLevel::from_proto(
  value : @common.ConsistencyLevel,
) -> ConsistencyLevel {
  ConsistencyLevel::from_int(value.to_enum().0.reinterpret_as_int())
}
