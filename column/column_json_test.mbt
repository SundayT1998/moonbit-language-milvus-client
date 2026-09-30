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
/// 接受标准三：动态字段（`JSON`）以 JSON 字符串形式取回。这个 Issue 不做
/// 路径查询（上游用 `tidwall/gjson` 做，本客户端不引这个依赖），所以取回
/// 的是服务端给的原始文本，不重新序列化——键序和数字格式都保持原样。
test "dynamic field comes back as a JSON string" {
  let payload = @utf8.encode("{\"city\":\"Shanghai\",\"n\":3}")
  let field : @schema.FieldData = {
    type_: @schema.DataType::JSON,
    field_name: "$meta",
    field_id: 0L,
    is_dynamic: true,
    valid_data: [],
    field: @schema.FieldData_Field::Scalars({
      valid_data: [],
      data: @schema.ScalarField_Data::JsonData({ data: [payload], }),
    }),
  }
  let col = @column.from_field_data(field)
  assert_eq(col.data_type(), @entity.DataType::Json)
  assert_eq(col.len(), 1)
  assert_eq(col.get_as_json_string(0), "{\"city\":\"Shanghai\",\"n\":3}")
  assert_eq(col.get_as_bytes(0), payload)
}

///|
/// 空字符串也是合法的 JSON 文本（服务端可能给空 payload），不当作错误；
/// 但非 UTF-8 的字节报错，因为「取回一段读不了的文本」比报错更难查。
test "json string requires UTF-8" {
  let empty = @column.from_field_data(
    scalar_field(
      @schema.DataType::JSON,
      @schema.ScalarField_Data::JsonData({ data: [Bytes::from_array([])], }),
    ),
  )
  assert_eq(empty.get_as_json_string(0), "")

  let bad = @column.from_field_data(
    scalar_field(
      @schema.DataType::JSON,
      @schema.ScalarField_Data::JsonData({
        data: [Bytes::from_array([b'\xFF', b'\xFE'])],
      }),
    ),
  )
  try bad.get_as_json_string(0) catch {
    @column.ColumnError::MalformedPayload(_) => ()
    _ => fail("invalid UTF-8 JSON should be rejected")
  } noraise {
    _ => fail("invalid UTF-8 JSON should not be handed back as a string")
  }
}

///|
/// `Array` 列：每行一个标量数组，元素类型由 `element_type` 给定。
/// `Int64`、`VarChar` 各测一条，空数组也要能取回。
test "array column decodes rows of scalars" {
  let field = scalar_field(
    @schema.DataType::Array,
    @schema.ScalarField_Data::ArrayData({
      element_type: @schema.DataType::Int64,
      data: [
        {
          valid_data: [],
          data: @schema.ScalarField_Data::LongData({ data: [1L, 2L], }),
        },
        {
          valid_data: [],
          data: @schema.ScalarField_Data::LongData({ data: [], }),
        },
        {
          valid_data: [],
          data: @schema.ScalarField_Data::LongData({ data: [3L], }),
        },
      ],
    }),
  )
  let col = @column.from_field_data(field)
  assert_eq(col.len(), 3)
  assert_eq(
    col.get(0),
    @column.Cell::Array(@column.ArrayValue::Int64([1L, 2L])),
  )
  assert_eq(col.get(1), @column.Cell::Array(@column.ArrayValue::Int64([])))
  assert_eq(col.get(2), @column.Cell::Array(@column.ArrayValue::Int64([3L])))

  let strings = @column.from_field_data(
    scalar_field(
      @schema.DataType::Array,
      @schema.ScalarField_Data::ArrayData({
        element_type: @schema.DataType::VarChar,
        data: [
          {
            valid_data: [],
            data: @schema.ScalarField_Data::StringData({ data: ["a", "b"], }),
          },
        ],
      }),
    ),
  )
  assert_eq(
    strings.get(0),
    @column.Cell::Array(@column.ArrayValue::String(["a", "b"])),
  )
}

///|
/// 类型不符的读取要报出来，不做隐式转换：拿 Int64 列读字符串、读浮点、
/// 读布尔都是调用方的错。
test "reading a column as the wrong type is rejected" {
  let col = @column.from_field_data(
    scalar_field(
      @schema.DataType::Int64,
      @schema.ScalarField_Data::LongData({ data: [1L], }),
    ),
  )
  try col.get_as_string(0).length() catch {
    @column.ColumnError::DataTypeNotMatch(_) => ()
    _ => fail("reading an Int64 column as a string should be rejected")
  } noraise {
    _ => fail("reading an Int64 column as a string should not succeed")
  }
  try col.get_as_double(0).to_int() catch {
    @column.ColumnError::DataTypeNotMatch(_) => ()
    _ => fail("reading an Int64 column as a double should be rejected")
  } noraise {
    _ => fail("reading an Int64 column as a double should not succeed")
  }
  try col.get_as_bool(0) catch {
    @column.ColumnError::DataTypeNotMatch(_) => ()
    _ => fail("reading an Int64 column as a bool should be rejected")
  } noraise {
    _ => fail("reading an Int64 column as a bool should not succeed")
  }
  assert_eq(col.get_as_int64(0), 1L)
}

///|
/// 客户端不认识的字段类型报「不支持」，而不是硬套一个。
test "unsupported field type is reported" {
  let field = scalar_field(
    @schema.DataType::Struct,
    @schema.ScalarField_Data::LongData({ data: [1L], }),
  )
  try @column.from_field_data(field) catch {
    @column.ColumnError::UnsupportedType(_) => ()
    _ => fail("a Struct field should be reported as unsupported")
  } noraise {
    _ => fail("a Struct field should not decode")
  }
}
