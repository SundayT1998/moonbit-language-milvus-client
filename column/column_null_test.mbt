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
/// 接受标准二之一：空列。零个逻辑行，读任何下标都越界，不是静默返回零值。
test "empty column has zero rows" {
  let col = @column.from_field_data(
    scalar_field(
      @schema.DataType::Int64,
      @schema.ScalarField_Data::LongData({ data: [], }),
    ),
  )
  assert_eq(col.len(), 0)
  assert_eq(col.valid_count(), 0)
  try col.get(0) catch {
    @column.ColumnError::IndexOutOfRange(_) => ()
    _ => fail("an empty column should report the index as out of range")
  } noraise {
    _ => fail("an empty column should not hand back a value")
  }
}

///|
/// 接受标准二之二：null 行。`valid_data` 逐行给出有无值，null 行读出来
/// 是 `Cell::Null`，`is_null` 认它。
test "null rows are marked and read as null" {
  let col = @column.from_field_data(
    scalar_field(
      @schema.DataType::VarChar,
      @schema.ScalarField_Data::StringData({ data: ["a", "c"], }),
      valid=[true, false, true],
    ),
  )
  assert_eq(col.len(), 3)
  assert_eq(col.valid_count(), 2)
  assert_eq(col.is_null(0), false)
  assert_eq(col.is_null(1), true)
  assert_eq(col.is_null(2), false)
  assert_eq(col.get_as_string(0), "a")
  assert_eq(col.get(1), @column.Cell::Null)
  // 紧凑布局：第 2 行是数据里的第 1 个，不是第 2 个。
  assert_eq(col.get_as_string(2), "c")
  try col.get_as_string(1) catch {
    @column.ColumnError::NullValue(_) => ()
    _ => fail("reading a null row as a string should report it as null")
  } noraise {
    _ => fail("a null row should not produce a string")
  }
}

///|
/// 行满布局：`valid_data` 与数据等长，数据在 null 位上是占位的零值。
/// 这时逻辑下标就是物理下标，第 2 行读出来仍是数据里的第 2 个。
test "row-dense valid_data keeps logical indices aligned with data" {
  let col = @column.from_field_data(
    scalar_field(
      @schema.DataType::Int64,
      @schema.ScalarField_Data::LongData({ data: [7L, 0L, 9L], }),
      valid=[true, false, true],
    ),
  )
  assert_eq(col.len(), 3)
  assert_eq(col.get_as_int64(0), 7L)
  assert_eq(col.is_null(1), true)
  assert_eq(col.get_as_int64(2), 9L)
}

///|
/// `end` 为负表示到末尾；正的 `end` 是开区间。上游 `-1` 的约定照搬，
/// 因为查询/检索回读按批次切片时会用到。
test "row range begin/end slices logically" {
  let field = scalar_field(
    @schema.DataType::Int64,
    @schema.ScalarField_Data::LongData({ data: [1L, 2L, 3L, 4L, 5L], }),
  )
  let head = @column.from_field_data(field, begin=1, end=3)
  assert_eq(head.len(), 2)
  assert_eq(head.get_as_int64(0), 2L)
  assert_eq(head.get_as_int64(1), 3L)

  let tail = @column.from_field_data(field, begin=3, end=-1)
  assert_eq(tail.len(), 2)
  assert_eq(tail.get_as_int64(0), 4L)
  assert_eq(tail.get_as_int64(1), 5L)

  try @column.from_field_data(field, begin=0, end=99) catch {
    @column.ColumnError::IndexOutOfRange(_) => ()
    _ => fail("an end past the last row should be out of range")
  } noraise {
    _ => fail("an end past the last row should not be clamped silently")
  }
}

///|
/// 两处有效性位图都有且不一致就是坏负载，报错而不是挑一边。
/// 上游 `validateAndNormalizeFieldDataValidData` 同样拒。
test "conflicting legacy and field-specific valid_data is rejected" {
  let field : @schema.FieldData = {
    type_: @schema.DataType::Int64,
    field_name: "f",
    field_id: 0L,
    is_dynamic: false,
    valid_data: [true, false],
    field: @schema.FieldData_Field::Scalars({
      valid_data: [false, true],
      data: @schema.ScalarField_Data::LongData({ data: [1L, 2L], }),
    }),
  }
  try @column.from_field_data(field) catch {
    @column.ColumnError::MalformedPayload(_) => ()
    _ => fail("conflicting valid_data should be rejected")
  } noraise {
    _ => fail("conflicting valid_data should not be silently accepted")
  }
}
