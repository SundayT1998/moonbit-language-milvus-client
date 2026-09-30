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
/// 一条标量 `FieldData`：只填类型、名字和 oneof 里的数据。带上
/// `valid_data` 就是可空列。
fn scalar_field(
  type_ : @schema.DataType,
  data : @schema.ScalarField_Data,
  valid? : Array[Bool] = [],
) -> @schema.FieldData {
  {
    type_,
    field_name: "f",
    field_id: 0L,
    is_dynamic: false,
    valid_data: [],
    field: @schema.FieldData_Field::Scalars({ valid_data: valid, data, }),
  }
}

///|
/// 一条向量 `FieldData`。
fn vector_field(
  type_ : @schema.DataType,
  data : @schema.VectorField_Data,
  dim : Int64,
  valid? : Array[Bool] = [],
) -> @schema.FieldData {
  {
    type_,
    field_name: "v",
    field_id: 0L,
    is_dynamic: false,
    valid_data: [],
    field: @schema.FieldData_Field::Vectors({ dim, valid_data: valid, data, }),
  }
}

///|
/// 接受标准一：每一种标量列类型都能从 `FieldData` 解出来，值原样可读。
test "scalar columns decode from FieldData" {
  let bools = @column.from_field_data(
    scalar_field(
      @schema.DataType::Bool,
      @schema.ScalarField_Data::BoolData({ data: [true, false], }),
    ),
  )
  assert_eq(bools.data_type(), @entity.DataType::Bool)
  assert_eq(bools.len(), 2)
  assert_eq(bools.get_as_bool(0), true)
  assert_eq(bools.get_as_bool(1), false)

  let ints = @column.from_field_data(
    scalar_field(
      @schema.DataType::Int32,
      @schema.ScalarField_Data::IntData({ data: [1, 2, 3], }),
    ),
  )
  assert_eq(ints.data_type(), @entity.DataType::Int32)
  assert_eq(ints.get_as_int64(2), 3L)

  let longs = @column.from_field_data(
    scalar_field(
      @schema.DataType::Int64,
      @schema.ScalarField_Data::LongData({ data: [10L, -20L], }),
    ),
  )
  assert_eq(longs.get_as_int64(1), -20L)

  let floats = @column.from_field_data(
    scalar_field(
      @schema.DataType::Float,
      @schema.ScalarField_Data::FloatData({ data: [1.5F], }),
    ),
  )
  assert_eq(floats.get_as_double(0), 1.5)

  let doubles = @column.from_field_data(
    scalar_field(
      @schema.DataType::Double,
      @schema.ScalarField_Data::DoubleData({ data: [2.5], }),
    ),
  )
  assert_eq(doubles.get_as_double(0), 2.5)

  let strings = @column.from_field_data(
    scalar_field(
      @schema.DataType::VarChar,
      @schema.ScalarField_Data::StringData({ data: ["a", "b"], }),
    ),
  )
  assert_eq(strings.get_as_string(1), "b")
}

///|
/// 窄整数在读取时按位宽截断：服务端把 `Int8` 放在 `int32` 数组里，
/// 一个 0xFF 是 -1 而不是 255。
test "int8 and int16 narrow on read" {
  let int8 = @column.from_field_data(
    scalar_field(
      @schema.DataType::Int8,
      @schema.ScalarField_Data::IntData({ data: [-1, 127, -128], }),
    ),
  )
  assert_eq(int8.data_type(), @entity.DataType::Int8)
  assert_eq(int8.get_as_int64(0), -1L)
  assert_eq(int8.get_as_int64(1), 127L)
  assert_eq(int8.get_as_int64(2), -128L)
}
