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
// 行的读接口。上游 `Column` 接口有 `Get / GetAsInt64 / GetAsString /
// GetAsDouble / GetAsBool / IsNull / Len`；这里保留 `Len`、`IsNull` 和
// 一个按列类型返回的 `Get`（`Cell`），外加 `GetAs*` 会拒绝跨类型读取
// 的那几个——不做隐式转换，读错类型就是 bug，早点报出来。

///|
/// 一行的值。与 `ColumnValue` 一一对应，只是每项至多一个元素。
///
/// `Null` 单独一个成员，而不是让 `Get` 返回 `Cell?`：一整列全空时
/// 仍要能区分「第 3 行是 null」和「列就这么长」，`Cell` 自己承载这个区别。
pub(all) enum Cell {
  Bool(Bool)
  Int8(Int)
  Int16(Int)
  Int32(Int)
  Int64(Int64)
  Float(Float)
  Double(Double)
  String(String)
  VarChar(String)
  Text(String)
  Timestamptz(Int64)
  Json(Bytes)
  Geometry(String)
  Array(ArrayValue)
  FloatVector(Array[Float])
  Float16Vector(Array[Float])
  BFloat16Vector(Array[Float])
  BinaryVector(Bytes)
  Int8Vector(Bytes)
  SparseFloatVector(@entity.SparseFloatVector)
  Null
} derive(Eq, Debug)

///|
/// 逻辑行数。可空列以 `valid` 的长度为准——数据行可能比它短，那是紧凑
/// 布局；非空列就是数据的长度。
pub fn Column::len(self : Column) -> Int {
  if self.nullable {
    self.valid.length()
  } else {
    match self.column {
      Bool(v) => v.length()
      Int8(v) | Int16(v) | Int32(v) => v.length()
      Int64(v) | Timestamptz(v) => v.length()
      Float(v) => v.length()
      Double(v) => v.length()
      String(v) | VarChar(v) | Text(v) | Geometry(v) => v.length()
      Json(v) => v.length()
      Array(v) => v.length()
      FloatVector(_, v) | Float16Vector(_, v) | BFloat16Vector(_, v) =>
        v.length()
      BinaryVector(_, v) | Int8Vector(_, v) => v.length()
      SparseFloatVector(v) => v.length()
    }
  }
}

///|
/// 第 `idx` 行是否为 null。越界报错；非空列恒为 `false`。
pub fn Column::is_null(self : Column, idx : Int) -> Bool raise ColumnError {
  if idx < 0 || idx >= self.len() {
    raise IndexOutOfRange("row index \{idx} out of range [0, \{self.len()})")
  }
  if self.nullable {
    !self.valid[idx]
  } else {
    false
  }
}

///|
/// 有效行数：`valid` 里 `true` 的个数，非空列等于 `len()`。
/// 上游 `ValidCount`。
pub fn Column::valid_count(self : Column) -> Int {
  if !self.nullable {
    return self.len()
  }
  let mut count = 0
  for v in self.valid {
    if v {
      count = count + 1
    }
  }
  count
}

///|
/// 第 `idx` 行的值。null 行返回 `Cell::Null`。
///
/// 可空列的数据按上游约定分两种布局：`valid` 长度等于数据长度时（行满）
/// 数据行与逻辑行一一对应；否则数据是紧凑的，null 行不占位，需要把逻辑
/// 下标映射到物理下标。`value_index` 负责这件事，下面所有取值都走它。
pub fn Column::get(self : Column, idx : Int) -> Cell raise ColumnError {
  if idx < 0 || idx >= self.len() {
    raise IndexOutOfRange("row index \{idx} out of range [0, \{self.len()})")
  }
  if self.nullable && !self.valid[idx] {
    return Null
  }
  let j = self.value_index(idx)
  match self.column {
    Bool(v) => Bool(v[j])
    Int8(v) => Int8(v[j])
    Int16(v) => Int16(v[j])
    Int32(v) => Int32(v[j])
    Int64(v) => Int64(v[j])
    Float(v) => Float(v[j])
    Double(v) => Double(v[j])
    String(v) => String(v[j])
    VarChar(v) => VarChar(v[j])
    Text(v) => Text(v[j])
    Timestamptz(v) => Timestamptz(v[j])
    Json(v) => Json(v[j])
    Geometry(v) => Geometry(v[j])
    Array(v) => Array(v[j])
    FloatVector(_, v) => FloatVector(v[j])
    Float16Vector(_, v) => Float16Vector(v[j])
    BFloat16Vector(_, v) => BFloat16Vector(v[j])
    BinaryVector(_, v) => BinaryVector(v[j])
    Int8Vector(_, v) => Int8Vector(v[j])
    SparseFloatVector(v) => SparseFloatVector(v[j])
  }
}

///|
/// 第 `idx` 行在数据数组里的物理下标。
///
/// 只有「可空且紧凑」才需要映射：数据长度小于逻辑行数。行满布局里
/// 物理下标就是逻辑下标，上游 `genericColumnBase.valueIndex` 同理。
fn Column::value_index(self : Column, idx : Int) -> Int {
  if !self.nullable || self.data_len() == self.valid.length() {
    return idx
  }
  let mut seen = 0
  for i = 0; i < idx; i = i + 1 {
    if self.valid[i] {
      seen = seen + 1
    }
  }
  seen
}

///|
/// 数据数组的长度。用于判断紧凑布局，不参与任何取值。
fn Column::data_len(self : Column) -> Int {
  match self.column {
    Bool(v) => v.length()
    Int8(v) | Int16(v) | Int32(v) => v.length()
    Int64(v) | Timestamptz(v) => v.length()
    Float(v) => v.length()
    Double(v) => v.length()
    String(v) | VarChar(v) | Text(v) | Geometry(v) => v.length()
    Json(v) => v.length()
    Array(v) => v.length()
    FloatVector(_, v) | Float16Vector(_, v) | BFloat16Vector(_, v) => v.length()
    BinaryVector(_, v) | Int8Vector(_, v) => v.length()
    SparseFloatVector(v) => v.length()
  }
}
