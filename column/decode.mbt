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
// 移植自 milvus-io/milvus client/column/columns.go 的 `FieldDataColumn`
// 与 `parseScalarData`（Apache-2.0）。上游用 Go 泛型把「取数据 → 圈范围 →
// 处理 valid_data → 造列」摊成一层模板，这里按列类型写开——MoonBit 的
// 枚举没有和 Go 类型参数等价的东西，硬凑反而难读。

///|
/// 把一条 `FieldData` 解成一列。
///
/// `begin` / `end` 是行区间，`end` 为负表示到末尾（上游用 `-1` 表达这一点，
/// 这里照搬，因为查询/检索回读确实会按批次切片）。区间按**逻辑行**算：
/// 可空列先圈 `valid_data`，再据此找到数据里的对应段。
///
/// 这是本 Issue 的核心入口：`Query` / `Search` 返回的每一种列类型都从这里过。
pub fn from_field_data(
  field : @schema.FieldData,
  begin? : Int = 0,
  end? : Int = -1,
) -> Column raise ColumnError {
  let type_ = field.type_
  if valid_data_conflicts(field) {
    raise MalformedPayload(
      "field \{field.field_name} carries conflicting legacy and field-specific valid_data",
    )
  }
  let valid = field_valid_data(field)
  match type_ {
    @schema.DataType::Bool =>
      build(
        ColumnValue::Bool(scalar_bool(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Int8 =>
      build(
        ColumnValue::Int8(scalar_int(field, begin, end, valid).map(narrow_int8)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Int16 =>
      build(
        ColumnValue::Int16(
          scalar_int(field, begin, end, valid).map(narrow_int16),
        ),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Int32 =>
      build(
        ColumnValue::Int32(scalar_int(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Int64 =>
      build(
        ColumnValue::Int64(scalar_long(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Float =>
      build(
        ColumnValue::Float(scalar_float(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Double =>
      build(
        ColumnValue::Double(scalar_double(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::String =>
      build(
        ColumnValue::String(scalar_string(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::VarChar =>
      build(
        ColumnValue::VarChar(scalar_string(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Text =>
      build(
        ColumnValue::Text(scalar_string(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Timestamptz =>
      build(
        ColumnValue::Timestamptz(scalar_long(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::JSON =>
      build(
        ColumnValue::Json(scalar_bytes(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Geometry =>
      build(
        ColumnValue::Geometry(scalar_string(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::Array =>
      build(
        ColumnValue::Array(array_rows(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    @schema.DataType::FloatVector => {
      let (dim, rows) = vector_float_rows(field, begin, end, valid)
      build(ColumnValue::FloatVector(dim, rows), valid_slice(valid, begin, end))
    }
    @schema.DataType::Float16Vector => {
      let (dim, rows) = vector_float16_rows(field, begin, end, valid)
      build(
        ColumnValue::Float16Vector(dim, rows),
        valid_slice(valid, begin, end),
      )
    }
    @schema.DataType::BFloat16Vector => {
      let (dim, rows) = vector_bfloat16_rows(field, begin, end, valid)
      build(
        ColumnValue::BFloat16Vector(dim, rows),
        valid_slice(valid, begin, end),
      )
    }
    @schema.DataType::BinaryVector => {
      let (dim, rows) = vector_binary_rows(field, begin, end, valid)
      build(
        ColumnValue::BinaryVector(dim, rows),
        valid_slice(valid, begin, end),
      )
    }
    @schema.DataType::Int8Vector => {
      let (dim, rows) = vector_int8_rows(field, begin, end, valid)
      build(ColumnValue::Int8Vector(dim, rows), valid_slice(valid, begin, end))
    }
    @schema.DataType::SparseFloatVector =>
      build(
        ColumnValue::SparseFloatVector(sparse_rows(field, begin, end, valid)),
        valid_slice(valid, begin, end),
      )
    other =>
      raise UnsupportedType(
        "unsupported field data type \{data_type_name(other)}",
      )
  }
}
