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
// `Array` 列的取数。上游 `parseArrayData` 走的是 `ArrayArray`：
// 外层 `data` 是每行一个 `ScalarField`，元素类型在 `element_type`。
// 数组元素只能是标量，所以这里只需要认识标量那几条。

///|
/// `Array` 列的每一行。
fn array_rows(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[ArrayValue] raise ColumnError {
  let s = scalar_payload(field, "array_data")
  match s.data {
    @schema.ScalarField_Data::ArrayData(a) => {
      let logical = logical_len(a.data.length(), valid)
      check_range(field.field_name, begin, end, logical)
      let e = normalize_end(end, logical)
      let b = clamp_begin(begin, logical)
      let rows : Array[ArrayValue] = []
      for i = b; i < e; i = i + 1 {
        rows.push(array_cell(field.field_name, a.element_type, a.data[i]))
      }
      rows
    }
    _ => raise missing_scalar(field, "not array_data")
  }
}

///|
/// 一行数组值。`ArrayArray.element_type` 说这行的元素是什么标量类型，
/// 不认识就报错，不落到「当字符串读」这种猜测上。
fn array_cell(
  field_name : String,
  element_type : @schema.DataType,
  row : @schema.ScalarField,
) -> ArrayValue raise ColumnError {
  match element_type {
    @schema.DataType::Bool =>
      match row.data {
        @schema.ScalarField_Data::BoolData(a) => ArrayValue::Bool(a.data)
        _ => raise array_element_mismatch(field_name, "bool")
      }
    @schema.DataType::Int8 =>
      match row.data {
        @schema.ScalarField_Data::IntData(a) =>
          ArrayValue::Int8(a.data.map(narrow_int8))
        _ => raise array_element_mismatch(field_name, "int8")
      }
    @schema.DataType::Int16 =>
      match row.data {
        @schema.ScalarField_Data::IntData(a) =>
          ArrayValue::Int16(a.data.map(narrow_int16))
        _ => raise array_element_mismatch(field_name, "int16")
      }
    @schema.DataType::Int32 =>
      match row.data {
        @schema.ScalarField_Data::IntData(a) => ArrayValue::Int32(a.data)
        _ => raise array_element_mismatch(field_name, "int32")
      }
    @schema.DataType::Int64 =>
      match row.data {
        @schema.ScalarField_Data::LongData(a) => ArrayValue::Int64(a.data)
        _ => raise array_element_mismatch(field_name, "int64")
      }
    @schema.DataType::Float =>
      match row.data {
        @schema.ScalarField_Data::FloatData(a) => ArrayValue::Float(a.data)
        _ => raise array_element_mismatch(field_name, "float")
      }
    @schema.DataType::Double =>
      match row.data {
        @schema.ScalarField_Data::DoubleData(a) => ArrayValue::Double(a.data)
        _ => raise array_element_mismatch(field_name, "double")
      }
    @schema.DataType::String
    | @schema.DataType::VarChar
    | @schema.DataType::Text =>
      match row.data {
        @schema.ScalarField_Data::StringData(a) => ArrayValue::String(a.data)
        _ => raise array_element_mismatch(field_name, "string")
      }
    other =>
      raise UnsupportedType(
        "array field \{field_name} has unsupported element type \{data_type_name(other)}",
      )
  }
}

///|
fn array_element_mismatch(field_name : String, want : String) -> ColumnError {
  MalformedPayload(
    "array field \{field_name} declares element type \{want} but the row carries other data",
  )
}
