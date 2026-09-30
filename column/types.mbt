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
// 移植自 milvus-io/milvus client/column/（Apache-2.0），基线 commit 见
// proto/PROVENANCE。上游用「每个类型一个 Go 结构体 + Column 接口」表达，
// MoonBit 侧用带载荷的枚举表达同构的东西：枚举成员就是列的具体类型，
// 公共方法按成员分派。响应回读依赖的全部列类型都在这里。

///|
/// 一列的值。每个成员对应上游一个 `ColumnXxx`。
///
/// 定长标量按原宽度保存（`Int8` 存 `Int`，不是 `Byte`），因为 Milvus 的
/// `IntArray` 在线上就是 `int32`，缩短再还原只会引入一类没必要的截断。
/// `Json` 与 `Bytes` 保留原始字节而不是解析后的树：Issue 要求动态字段
/// 以 JSON 字符串形式取回，路径查询留给调用方。
pub(all) enum ColumnValue {
  Bool(Array[Bool])
  Int8(Array[Int])
  Int16(Array[Int])
  Int32(Array[Int])
  Int64(Array[Int64])
  Float(Array[Float])
  Double(Array[Double])
  String(Array[String])
  VarChar(Array[String])
  Text(Array[String])
  Timestamptz(Array[Int64])
  Json(Array[Bytes])
  Geometry(Array[String])
  Array(Array[ArrayValue])
  FloatVector(Int, Array[Array[Float]])
  Float16Vector(Int, Array[Array[Float]])
  BFloat16Vector(Int, Array[Array[Float]])
  BinaryVector(Int, Array[Bytes])
  Int8Vector(Int, Array[Bytes])
  SparseFloatVector(Array[@entity.SparseFloatVector])
} derive(Eq, Debug)

///|
/// `Array` 列的一行：元素类型固定的一种标量数组。数组元素只能是标量，
/// 所以比 `ColumnValue` 窄。
pub(all) enum ArrayValue {
  Bool(Array[Bool])
  Int8(Array[Int])
  Int16(Array[Int])
  Int32(Array[Int])
  Int64(Array[Int64])
  Float(Array[Float])
  Double(Array[Double])
  String(Array[String])
} derive(Eq, Debug)

///|
/// 一列：列的值加上可空信息。`nullable` 为 `false` 时 `valid` 为空，
/// 每一行都有值；为 `true` 时 `valid` 逐行给出该行是否有值（`false`
/// 即 null），长度等于逻辑行数。
///
/// 上游把 `nullable` 和 `validData` 放在共享的 `genericColumnBase` 里，
/// 具体列类型各自内嵌它；这里把两者提到 `Column` 这一层，因为 MoonBit
/// 的枚举没法共享字段。
pub(all) struct Column {
  column : ColumnValue
  nullable : Bool
  valid : Array[Bool]
} derive(Debug)

///|
/// 由值和一个可选的 `valid_data` 组出列。`valid` 为空表示非空列。
fn build(column : ColumnValue, valid : Array[Bool]) -> Column {
  if valid.is_empty() {
    { column, nullable: false, valid: [], }
  } else {
    { column, nullable: true, valid, }
  }
}
