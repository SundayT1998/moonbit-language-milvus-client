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
// 移植自 milvus-io/milvus client/column/generic_base.go 的
// `getFieldDataValidData` / `validateAndNormalizeFieldDataValidData` 与
// `countValidBounds`（Apache-2.0）。
//
// 有效性位图在两个地方放过：`FieldData.valid_data`（旧）和
// `ScalarField.valid_data` / `VectorField.valid_data`（新）。读的一侧先看
// 旧字段，读不到再回落到字段级，与上游 `getFieldDataValidData` 的读取顺序
// 一致；两处都有且不一致就是坏负载，上报而不猜哪一边对。上游
// `validateAndNormalizeFieldDataValidData` 同理。

///|
/// 取这条 `FieldData` 的有效性位图。旧字段（`FieldData.valid_data`）优先，
/// 读不到再回落到字段级——与上游 `getFieldDataValidData` 的读取顺序一致。
/// 返回空数组表示非空字段。
fn field_valid_data(field : @schema.FieldData) -> Array[Bool] {
  if !field.valid_data.is_empty() {
    return field.valid_data
  }
  match field.field {
    @schema.FieldData_Field::Scalars(s) => s.valid_data
    @schema.FieldData_Field::Vectors(v) => v.valid_data
    @schema.FieldData_Field::NotSet => []
  }
}

///|
/// 两处有效性位图都在且不一致时返回 `true`。上游
/// `fieldDataValidDataConsistent` 的判定。
fn valid_data_conflicts(field : @schema.FieldData) -> Bool {
  let legacy = field.valid_data
  let current = match field.field {
    @schema.FieldData_Field::Scalars(s) => s.valid_data
    @schema.FieldData_Field::Vectors(v) => v.valid_data
    @schema.FieldData_Field::NotSet => []
  }
  !legacy.is_empty() && !current.is_empty() && legacy != current
}

///|
/// 圈出 `valid` 的 `[begin, end)` 段。`end` 为负表示到末尾。
/// 区间按逻辑行算，所以这里只处理 `valid`；数据段的位置另算。
fn valid_slice(valid : Array[Bool], begin : Int, end : Int) -> Array[Bool] {
  if valid.is_empty() {
    return []
  }
  let n = valid.length()
  let b = clamp_begin(begin, n)
  let e = normalize_end(end, n)
  if b >= e {
    return []
  }
  valid[b:e].to_owned()
}

///|
/// 把 `begin` 夹到 `[0, n]`。上游对越界的 `begin` 直接报错，这里做成
/// 夹取是因为调用方通常传的是「我已经知道要哪几行」；越界即空，不静默
/// 取错行。真正的区间校验在 `rows_in_range` 里，只有明确要整列时才用。
fn clamp_begin(begin : Int, n : Int) -> Int {
  if begin < 0 {
    0
  } else if begin > n {
    n
  } else {
    begin
  }
}

///|
/// `end` 归一：负数表示到末尾，超过 `n` 夹到 `n`。
fn normalize_end(end : Int, n : Int) -> Int {
  if end < 0 {
    n
  } else if end > n {
    n
  } else {
    end
  }
}

///|
/// 校验行区间：`begin ∈ [0, n]`，`end` 为负或 `∈ [begin, n]`。
/// 上游 `normalizeFieldDataRange` 在这里报错而不是夹取，因为它要区分
/// 「调用方要了不存在的行」和「数据就这么长」。本模块沿用同一条线。
fn check_range(
  field_name : String,
  begin : Int,
  end : Int,
  n : Int,
) -> Unit raise ColumnError {
  if begin < 0 || begin > n {
    raise IndexOutOfRange(
      "field \{field_name} row range start \{begin} is outside [0, \{n})",
    )
  }
  let e = if end < 0 { n } else { end }
  if e < begin || e > n {
    raise IndexOutOfRange(
      "field \{field_name} row range [\{begin}, \{e}) is invalid for \{n} rows",
    )
  }
}

///|
/// 逻辑行数：有 `valid_data` 就是它的长度，否则是数据数组的长度。
/// 上游 `parseScalarData` 里 `logicalLen` 的取法。
fn logical_len(data_len : Int, valid : Array[Bool]) -> Int {
  if valid.is_empty() {
    data_len
  } else {
    valid.length()
  }
}

///|
/// 紧凑布局的行区间：`valid` 里 `[begin, end)` 段的有效值，在数据数组里
/// 占哪一段，以及有多少个。
///
/// 上游 `countValidBounds`。返回 `(value_begin, value_end, count)`。
/// 「行满」布局（数据长度等于逻辑行数）下数据段就是 `[begin, end)`，
/// 由调用方先行判断，不走这里。
fn count_valid_bounds(
  valid : Array[Bool],
  begin : Int,
  end : Int,
) -> (Int, Int, Int) {
  let mut value_begin = 0
  let mut value_end = 0
  let mut count = 0
  for idx, is_valid in valid {
    if !is_valid {
      continue
    }
    count = count + 1
    if idx < begin {
      value_begin = value_begin + 1
    }
    if idx < end {
      value_end = value_end + 1
    }
  }
  (value_begin, value_end, count)
}

///|
/// 把一段标量数据按 `[begin, end)` 圈出来。
///
/// 可空字段的数据分两种布局：
/// - **行满**（数据长度等于逻辑行数）：数据与逻辑行一一对应，直接切。
/// - **紧凑**（数据长度等于有效数）：null 行不占位，先按 `valid` 算出
///   数据段，再切。
/// 数据长度与两者都对不上就是坏负载。
fn[T] slice_scalar_data(
  field_name : String,
  data : Array[T],
  valid : Array[Bool],
  begin : Int,
  end : Int,
) -> Array[T] raise ColumnError {
  let n = logical_len(data.length(), valid)
  check_range(field_name, begin, end, n)
  if valid.is_empty() {
    let e = normalize_end(end, n)
    return data[clamp_begin(begin, n):e].to_owned()
  }
  if n == valid.length() && data.length() == n {
    // 行满：数据段与逻辑段重合。
    return data[begin:normalize_end(end, n)].to_owned()
  }
  let (value_begin, value_end, count) = count_valid_bounds(
    valid,
    begin,
    normalize_end(end, n),
  )
  if data.length() != count {
    raise MalformedPayload(
      "field \{field_name} compact payload has \{data.length()} values but \{count} valid rows",
    )
  }
  data[value_begin:value_end].to_owned()
}
