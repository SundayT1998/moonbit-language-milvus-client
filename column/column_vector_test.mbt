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
/// `FloatVector` 的扁平 float32 数组按 `dim` 切成行。
test "float vector rows split by dim" {
  let field = vector_field(
    @schema.DataType::FloatVector,
    @schema.VectorField_Data::FloatVector({ data: [1.0F, 2.0F, 3.0F, 4.0F], }),
    2L,
  )
  let col = @column.from_field_data(field)
  assert_eq(col.data_type(), @entity.DataType::FloatVector)
  assert_eq(col.len(), 2)
  assert_eq(col.get(0), @column.Cell::FloatVector([1.0F, 2.0F]))
  assert_eq(col.get(1), @column.Cell::FloatVector([3.0F, 4.0F]))
}

///|
/// `BinaryVector`：`dim` 位打包，行宽 `dim / 8` 字节。`dim` 不是 8 的倍数
/// 是坏负载。
test "binary vector rows are dim/8 bytes and dim must divide by 8" {
  let field = vector_field(
    @schema.DataType::BinaryVector,
    @schema.VectorField_Data::BinaryVector(
      Bytes::from_array([b'\xFF', b'\x00', b'\x0F', b'\xF0']),
    ),
    16L,
  )
  let col = @column.from_field_data(field)
  assert_eq(col.len(), 2)
  assert_eq(
    col.get(0),
    @column.Cell::BinaryVector(Bytes::from_array([b'\xFF', b'\x00'])),
  )
  assert_eq(
    col.get(1),
    @column.Cell::BinaryVector(Bytes::from_array([b'\x0F', b'\xF0'])),
  )

  let bad = vector_field(
    @schema.DataType::BinaryVector,
    @schema.VectorField_Data::BinaryVector(Bytes::from_array([b'\xFF'])),
    12L,
  )
  try @column.from_field_data(bad) catch {
    @column.ColumnError::MalformedPayload(_) => ()
    _ => fail("a binary vector dim not a multiple of 8 should be rejected")
  } noraise {
    _ => fail("a binary vector dim not a multiple of 8 should not be accepted")
  }
}

///|
/// `Float16Vector`：线上每维 2 字节小端。0x3C00 是 1.0，0x4000 是 2.0。
/// 奇数字节数是坏负载。
test "float16 vector decodes little-endian binary16" {
  let field = vector_field(
    @schema.DataType::Float16Vector,
    @schema.VectorField_Data::Float16Vector(
      // 1.0 与 2.0 的 binary16 位模式，小端两字节一组。
      Bytes::from_array([b'\x00', b'\x3C', b'\x00', b'\x40']),
    ),
    1L,
  )
  let col = @column.from_field_data(field)
  assert_eq(col.get(0), @column.Cell::Float16Vector([1.0F]))
  assert_eq(col.get(1), @column.Cell::Float16Vector([2.0F]))

  let odd = vector_field(
    @schema.DataType::Float16Vector,
    @schema.VectorField_Data::Float16Vector(Bytes::from_array([b'\x00'])),
    1L,
  )
  try @column.from_field_data(odd) catch {
    @column.ColumnError::MalformedPayload(_) => ()
    _ => fail("an odd float16 payload should be rejected")
  } noraise {
    _ => fail("an odd float16 payload should not be accepted")
  }
}

///|
/// `BFloat16Vector`：`@entity.bfloat16_from_float` 的编码要能原样解回。
/// 这条是回读侧的往返验证，写侧的位级比对在 `entity/bfloat16_test.mbt`。
test "bfloat16 vector round-trips through entity encoding" {
  let encoded = @entity.bfloat16_vector_bytes([1.5F, -2.0F])
  let field = vector_field(
    @schema.DataType::BFloat16Vector,
    @schema.VectorField_Data::Bfloat16Vector(encoded),
    1L,
  )
  let col = @column.from_field_data(field)
  assert_eq(col.get(0), @column.Cell::BFloat16Vector([1.5F]))
  assert_eq(col.get(1), @column.Cell::BFloat16Vector([-2.0F]))
}

///|
/// `SparseFloatVector`：每行一段 `(uint32, float32)` 小端对，解回
/// `@entity.SparseFloatVector`。空行是合法的——稀疏行没有维度。
test "sparse float vector rows decode from wire bytes" {
  let row = @entity.SparseFloatVector::new([1U, 5U], [0.5F, 1.5F])
  let empty = @entity.SparseFloatVector::new([], [])
  let field = vector_field(
    @schema.DataType::SparseFloatVector,
    @schema.VectorField_Data::SparseFloatVector({
      contents: [row.to_bytes(), empty.to_bytes()],
      dim: 6L,
    }),
    0L,
  )
  let col = @column.from_field_data(field)
  assert_eq(col.len(), 2)
  assert_eq(col.get(0), @column.Cell::SparseFloatVector(row))
  assert_eq(col.get(1), @column.Cell::SparseFloatVector(empty))
}

///|
/// `Int8Vector`：有符号字节，行宽就是 `dim`。
test "int8 vector rows are dim bytes" {
  let field = vector_field(
    @schema.DataType::Int8Vector,
    @schema.VectorField_Data::Int8Vector(
      Bytes::from_array([b'\x01', b'\x02', b'\x03', b'\x04']),
    ),
    2L,
  )
  let col = @column.from_field_data(field)
  assert_eq(col.len(), 2)
  assert_eq(
    col.get(0),
    @column.Cell::Int8Vector(Bytes::from_array([b'\x01', b'\x02'])),
  )
  assert_eq(
    col.get(1),
    @column.Cell::Int8Vector(Bytes::from_array([b'\x03', b'\x04'])),
  )
}

///|
/// 可空向量按紧凑布局解：`valid_data` 一行一个，payload 只放有效行。
test "nullable float vector reads compact payload" {
  let field = vector_field(
    @schema.DataType::FloatVector,
    @schema.VectorField_Data::FloatVector({ data: [7.0F, 8.0F], }),
    1L,
    valid=[false, true, true],
  )
  let col = @column.from_field_data(field)
  assert_eq(col.len(), 3)
  assert_eq(col.is_null(0), true)
  assert_eq(col.get(1), @column.Cell::FloatVector([7.0F]))
  assert_eq(col.get(2), @column.Cell::FloatVector([8.0F]))
}

///|
/// 声明是浮点向量却带了别的向量 payload，就是类型不符，不是去猜一个。
test "vector payload mismatching the declared type is rejected" {
  let field = vector_field(
    @schema.DataType::FloatVector,
    @schema.VectorField_Data::BinaryVector(Bytes::from_array([b'\x00'])),
    8L,
  )
  try @column.from_field_data(field) catch {
    @column.ColumnError::DataTypeNotMatch(_) => ()
    _ => fail("a float vector field with a binary payload should be rejected")
  } noraise {
    _ => fail("a mismatched vector payload should not be accepted")
  }
}
