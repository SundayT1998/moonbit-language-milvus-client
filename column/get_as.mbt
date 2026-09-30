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
/// 该列对应的 Milvus 数据类型。`ColumnValue` 的成员是逐类型展开的，
/// 所以这是一张直接表。
pub fn Column::data_type(self : Column) -> @entity.DataType {
  match self.column {
    Bool(_) => @entity.DataType::Bool
    Int8(_) => @entity.DataType::Int8
    Int16(_) => @entity.DataType::Int16
    Int32(_) => @entity.DataType::Int32
    Int64(_) => @entity.DataType::Int64
    Float(_) => @entity.DataType::Float
    Double(_) => @entity.DataType::Double
    String(_) => @entity.DataType::String
    VarChar(_) => @entity.DataType::VarChar
    Text(_) => @entity.DataType::Text
    Timestamptz(_) => @entity.DataType::Timestamptz
    Json(_) => @entity.DataType::Json
    Geometry(_) => @entity.DataType::Geometry
    Array(_) => @entity.DataType::Array
    FloatVector(_, _) => @entity.DataType::FloatVector
    Float16Vector(_, _) => @entity.DataType::Float16Vector
    BFloat16Vector(_, _) => @entity.DataType::BFloat16Vector
    BinaryVector(_, _) => @entity.DataType::BinaryVector
    Int8Vector(_, _) => @entity.DataType::Int8Vector
    SparseFloatVector(_) => @entity.DataType::SparseFloatVector
  }
}

///|
/// 第 `idx` 行读成整数。
///
/// 与上游一致，`Int8 / Int16 / Int32 / Int64` 与 `Timestamptz` 都可读，
/// 不做跨大类转换：读 `Float` 列要整数是调用方的错，直接报出来。
pub fn Column::get_as_int64(
  self : Column,
  idx : Int,
) -> Int64 raise ColumnError {
  match self.get(idx) {
    Int8(v) => v.to_int64()
    Int16(v) => v.to_int64()
    Int32(v) => v.to_int64()
    Int64(v) => v
    Timestamptz(v) => v
    other => raise type_error(self, "Int64", other)
  }
}

///|
/// 第 `idx` 行读成字符串。`String / VarChar / Text / Geometry` 可读；
/// JSON 列要的是原始字节，用 `get_as_bytes`。
pub fn Column::get_as_string(
  self : Column,
  idx : Int,
) -> String raise ColumnError {
  match self.get(idx) {
    String(v) => v
    VarChar(v) => v
    Text(v) => v
    Geometry(v) => v
    other => raise type_error(self, "String", other)
  }
}

///|
/// 第 `idx` 行读成双精度浮点。`Float / Double` 可读，`Int*` 不隐式转浮点。
pub fn Column::get_as_double(
  self : Column,
  idx : Int,
) -> Double raise ColumnError {
  match self.get(idx) {
    Float(v) => v.to_double()
    Double(v) => v
    other => raise type_error(self, "Double", other)
  }
}

///|
/// 第 `idx` 行读成布尔。
pub fn Column::get_as_bool(self : Column, idx : Int) -> Bool raise ColumnError {
  match self.get(idx) {
    Bool(v) => v
    other => raise type_error(self, "Bool", other)
  }
}

///|
/// 第 `idx` 行读成原始字节。JSON 列（动态字段）与 `Bytes` 语义的列走这里。
pub fn Column::get_as_bytes(
  self : Column,
  idx : Int,
) -> Bytes raise ColumnError {
  match self.get(idx) {
    Json(v) => v
    BinaryVector(v) => v
    Int8Vector(v) => v
    other => raise type_error(self, "Bytes", other)
  }
}

///|
/// 第 `idx` 行动态字段（JSON）的文本。上游把动态字段按 `tidwall/gjson`
/// 取路径后再返回；本 Issue 明确不提供路径查询，所以这里只把服务端给的
/// JSON 原样解成字符串——它就是原 payload 的 UTF-8 文本，不做重新序列化，
/// 免得改变键序或数字格式。
///
/// 非 UTF-8 的 payload 会被替换字符顶掉（`Bytes::to_unchecked_string`
/// 不校验，`String::from_utf8?` 会校验）。这里校验并报错，因为「取回一段
/// 读不了的文本」比报错更难查。
pub fn Column::get_as_json_string(
  self : Column,
  idx : Int,
) -> String raise ColumnError {
  let bytes = self.get_as_bytes(idx)
  @utf8.decode(bytes) catch {
    @utf8.Malformed(_) =>
      raise MalformedPayload(
        "row \{idx} of field of type \{self.data_type().name()} is not valid UTF-8",
      )
  }
}
