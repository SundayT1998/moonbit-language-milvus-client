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
// 从生成的 `FieldData` 里把数据段取出来。上游这些工作散在 `columns.go`
// 的 switch 分支里（`fd.GetScalars().GetBoolData().GetData()` 之类），
// 这里收成几个小函数，decode.mbt 只负责把类型和这里的取数对上。

///|
/// 标量 payload 里的 `oneof`，取不到就按类型不符报错。所有标量取值都要
/// 过这一关，省得每个分支各写一遍空判断。
fn scalar_payload(
  field : @schema.FieldData,
  want : String,
) -> @schema.ScalarField raise ColumnError {
  match field.field {
    @schema.FieldData_Field::Scalars(s) => s
    _ =>
      raise DataTypeNotMatch(
        "field \{field.field_name} declared \{data_type_name(field.type_)} but carries no scalar payload, wanted \{want}",
      )
  }
}

///|
/// 向量 payload。同上。
fn vector_payload(
  field : @schema.FieldData,
  want : String,
) -> @schema.VectorField raise ColumnError {
  match field.field {
    @schema.FieldData_Field::Vectors(v) => v
    _ =>
      raise DataTypeNotMatch(
        "field \{field.field_name} declared \{data_type_name(field.type_)} but carries no vector payload, wanted \{want}",
      )
  }
}

///|
/// 标量 oneof 里没有对应数据时报错。
fn missing_scalar(field : @schema.FieldData, want : String) -> ColumnError {
  DataTypeNotMatch(
    "field \{field.field_name} declares \{data_type_name(field.type_)} but its scalar payload is \{want}",
  )
}

///|
/// 向量 oneof 里没有对应数据时报错。
fn missing_vector(field : @schema.FieldData, want : String) -> ColumnError {
  DataTypeNotMatch(
    "field \{field.field_name} declares \{data_type_name(field.type_)} but its vector payload is \{want}",
  )
}

///|
/// Bool 列的数据段。
fn scalar_bool(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[Bool] raise ColumnError {
  let s = scalar_payload(field, "bool_data")
  match s.data {
    @schema.ScalarField_Data::BoolData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    _ => raise missing_scalar(field, "not bool_data")
  }
}

///|
/// `int_data` 是 `Int8 / Int16 / Int32` 三者共用的 `int32` 数组。
/// 上游在 `int32ToType` 里做收窄，这里保留 `Int` 由 `decode.mbt` 收窄，
/// 因为 MoonBit 的 `Int` 就是 32 位以上，收窄只是显示问题。
fn scalar_int(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[Int] raise ColumnError {
  let s = scalar_payload(field, "int_data")
  match s.data {
    @schema.ScalarField_Data::IntData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    _ => raise missing_scalar(field, "not int_data")
  }
}

///|
/// `long_data`：`Int64` 与 `Timestamptz` 共用。
fn scalar_long(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[Int64] raise ColumnError {
  let s = scalar_payload(field, "long_data")
  match s.data {
    @schema.ScalarField_Data::LongData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    _ => raise missing_scalar(field, "not long_data")
  }
}

///|
/// `float_data`。
fn scalar_float(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[Float] raise ColumnError {
  let s = scalar_payload(field, "float_data")
  match s.data {
    @schema.ScalarField_Data::FloatData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    _ => raise missing_scalar(field, "not float_data")
  }
}

///|
/// `double_data`。
fn scalar_double(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[Double] raise ColumnError {
  let s = scalar_payload(field, "double_data")
  match s.data {
    @schema.ScalarField_Data::DoubleData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    _ => raise missing_scalar(field, "not double_data")
  }
}

///|
/// `string_data`：`String / VarChar / Text / Geometry` 共用。
fn scalar_string(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[String] raise ColumnError {
  let s = scalar_payload(field, "string_data")
  match s.data {
    @schema.ScalarField_Data::StringData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    @schema.ScalarField_Data::GeometryWktData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    _ => raise missing_scalar(field, "not string_data")
  }
}

///|
/// 二进制标量：`JSON` 落的 `json_data`。动态字段就在这一支。
fn scalar_bytes(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[Bytes] raise ColumnError {
  let s = scalar_payload(field, "json_data")
  match s.data {
    @schema.ScalarField_Data::JsonData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    @schema.ScalarField_Data::BytesData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    @schema.ScalarField_Data::GeometryData(a) =>
      slice_scalar_data(field.field_name, a.data, valid, begin, end)
    _ => raise missing_scalar(field, "not json_data")
  }
}
