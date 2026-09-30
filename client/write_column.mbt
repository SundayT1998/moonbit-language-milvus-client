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
// 移植自 milvus-io/milvus client/column/columns.go 的
// `Column.FieldData()` 一族与 client/milvusclient/write_options.go 的
// `processInsertColumns`（Apache-2.0）。
//
// 回读侧 `@column.from_field_data` 走的是 `FieldData` → `Column`；
// 这里走反方向 `Column` → `FieldData`。两边共用 `@column.ColumnValue`，
// 所以列类型只在 `column/` 定义一次 —— 写侧多出来的只有「行数对齐」
// 与「向量序列化」。

///|
/// 写入用的一列。名字加数据，等价于上游 `column.Column` 里写入侧用到的那部分。
///
/// 复用 `@column.ColumnValue` 而不是另造一套枚举，是为了让回读的
/// `Column` 能被原样改一改名字写回去（改列名重插入这种用法）。
pub(all) struct WriteColumn {
  name : String
  value : @column.ColumnValue
}

///|
pub fn WriteColumn::new(
  name : String,
  value : @column.ColumnValue,
) -> WriteColumn {
  { name, value, }
}

///|
/// 这一列的行数。
pub fn WriteColumn::len(self : WriteColumn) -> Int {
  match self.value {
    Bool(v) => v.length()
    Int8(v) | Int16(v) | Int32(v) => v.length()
    Int64(v) => v.length()
    Float(v) => v.length()
    Double(v) => v.length()
    String(v) | VarChar(v) | Text(v) => v.length()
    Timestamptz(v) => v.length()
    Json(v) => v.length()
    Geometry(v) => v.length()
    Array(v) => v.length()
    FloatVector(_, rows) | Float16Vector(_, rows) | BFloat16Vector(_, rows) =>
      rows.length()
    BinaryVector(_, rows) | Int8Vector(_, rows) => rows.length()
    SparseFloatVector(rows) => rows.length()
  }
}

///|
/// 这一列的 `@schema.DataType`。
pub fn WriteColumn::data_type(self : WriteColumn) -> @entity.DataType {
  match self.value {
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
/// 一列 → 一条 `FieldData`。
///
/// 动态字段（JSON）要带上 `is_dynamic`，否则服务端会把它当成 schema 里
/// 不存在的列拒绝。这里靠名字判断：`@column` 侧回读动态字段时也是用
/// `FieldData.is_dynamic` 标记的，写侧没有别的信号可用。
///
/// `nullable` 为真时写一条全 1 的 `valid_data`：调用方给的是实体数组，
/// 目前没有「某行是 null」的表示，写成全 1 与「全部有值」等价，
/// 但显式声明可空位图后服务端不会把空列当坏数据。
pub fn WriteColumn::to_field_data(
  self : WriteColumn,
  is_dynamic? : Bool = false,
) -> @schema.FieldData raise ClientError {
  let rows = self.len()
  let field = match self.value {
    Bool(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::BoolData(@schema.BoolArray::BoolArray(v)),
        ),
      )
    Int8(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::IntData(
            @schema.IntArray::IntArray(v.map(narrow_int)),
          ),
        ),
      )
    Int16(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::IntData(
            @schema.IntArray::IntArray(v.map(narrow_int)),
          ),
        ),
      )
    Int32(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(@schema.ScalarField_Data::IntData(@schema.IntArray::IntArray(v))),
      )
    Int64(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::LongData(@schema.LongArray::LongArray(v)),
        ),
      )
    Float(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::FloatData(@schema.FloatArray::FloatArray(v)),
        ),
      )
    Double(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::DoubleData(
            @schema.DoubleArray::DoubleArray(v),
          ),
        ),
      )
    String(v) | VarChar(v) | Text(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::StringData(
            @schema.StringArray::StringArray(v),
          ),
        ),
      )
    // JSON 在 wire 上是 `bytes`，每行一段 UTF-8 文本。
    Json(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::JsonData(@schema.JSONArray::JSONArray(v)),
        ),
      )
    Timestamptz(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::TimestamptzData(
            @schema.TimestamptzArray::TimestamptzArray(v),
          ),
        ),
      )
    Geometry(v) =>
      @schema.FieldData_Field::Scalars(
        scalar(
          @schema.ScalarField_Data::GeometryWktData(
            @schema.GeometryWktArray::GeometryWktArray(v),
          ),
        ),
      )
    Array(_) =>
      raise ClientError::Encode(
        "column \{self.name}: Array fields need an element type, which WriteColumn cannot infer",
      )
    FloatVector(dim, rows) =>
      vector_row_payload(self.name, dim, rows.length(), () => {
        @schema.VectorField_Data::FloatVector(
          @schema.FloatArray::FloatArray(flatten(rows)),
        )
      })
    Float16Vector(dim, rows) =>
      vector_row_payload(self.name, dim, rows.length(), () => {
        @schema.VectorField_Data::Float16Vector(
          bytes_of_rows(rows, @entity.float16_vector_bytes),
        )
      })
    BFloat16Vector(dim, rows) =>
      vector_row_payload(self.name, dim, rows.length(), () => {
        @schema.VectorField_Data::Bfloat16Vector(
          bytes_of_rows(rows, @entity.bfloat16_vector_bytes),
        )
      })
    BinaryVector(dim, rows) =>
      vector_row_payload(self.name, dim, rows.length(), () => {
        @schema.VectorField_Data::BinaryVector(join_bytes(rows))
      })
    Int8Vector(dim, rows) =>
      vector_row_payload(self.name, dim, rows.length(), () => {
        @schema.VectorField_Data::Int8Vector(join_bytes(rows))
      })
    SparseFloatVector(rows) =>
      @schema.FieldData_Field::Vectors(@schema.VectorField::{
        dim: 0L,
        valid_data: [],
        data: @schema.VectorField_Data::SparseFloatVector(@schema.SparseFloatArray::{
          contents: rows.map(row => {
            row.to_bytes() catch {
              err => raise ClientError::Schema(entity_schema_message(err))
            }
          }),
          dim: max_sparse_dim(rows).to_int64(),
        }),
      })
  }
  @schema.FieldData::{
    type_: data_type_to_proto(self.data_type()),
    field_name: self.name,
    field_id: 0L,
    is_dynamic,
    valid_data: [],
    field,
  }
  |> ignore_row_count(rows)
}

///|
/// 行数为 0 的列没有可写的内容，但也不该静默通过：
/// 服务端拿到空 `FieldData` 会把整批算成 0 行，调用方多半是搞错了。
fn ignore_row_count(
  field : @schema.FieldData,
  rows : Int,
) -> @schema.FieldData raise ClientError {
  if rows == 0 {
    raise ClientError::Encode(
      "column \{field.field_name} has no rows; every column in a write must carry at least one",
    )
  }
  field
}

///|
/// 标量 payload：只填 data，`valid_data` 留空表示「全部有值」。
fn scalar(data : @schema.ScalarField_Data) -> @schema.ScalarField {
  @schema.ScalarField::{ valid_data: [], data, }
}

///|
/// 向量 payload 的公共外壳，顺带校一下 dim 与行数。
fn vector_row_payload(
  name : String,
  dim : Int,
  rows : Int,
  build : () -> @schema.VectorField_Data raise ClientError,
) -> @schema.FieldData_Field raise ClientError {
  if dim <= 0 {
    raise ClientError::Encode(
      "column \{name}: vector dim must be positive, got \{dim}",
    )
  }
  if rows == 0 {
    raise ClientError::Encode("column \{name}: vector column has no rows")
  }
  @schema.FieldData_Field::Vectors(@schema.VectorField::{
    dim: dim.to_int64(),
    valid_data: [],
    data: build(),
  })
}

///|
/// 逐行编码后拼成一整块字节。fp16 / bf16 在 wire 上是「所有行首尾相接」，
/// 不是每行一个 bytes，所以这里必须拼平。
fn bytes_of_rows(
  rows : Array[Array[Float]],
  encode : (Array[Float]) -> Bytes,
) -> Bytes {
  join_bytes(rows.map(encode))
}

///|
fn join_bytes(parts : Array[Bytes]) -> Bytes {
  let buf = Buffer()
  for part in parts {
    buf.write_bytes(part)
  }
  buf.to_bytes()
}

///|
fn flatten(rows : Array[Array[Float]]) -> Array[Float] {
  let values : Array[Float] = []
  for row in rows {
    values.append(row)
  }
  values
}

///|
/// 稀疏向量那一列的 `dim` 是「本批次里最大的下标 + 1」，
/// 与上游 `SparseFloatArray.dim` 的语义一致（注释写明是最大维度）。
fn max_sparse_dim(rows : Array[@entity.SparseFloatVector]) -> UInt {
  let mut max : UInt = 0
  for row in rows {
    for index in row.indices {
      if index >= max {
        max = index + 1U
      }
    }
  }
  max
}

///|
/// `Int` → `Int32` 的窄化。越界的值直接报错，
/// 不静默按低位截断 —— 写进去一个错的值比写失败更难查。
fn narrow_int(value : Int) -> Int raise ClientError {
  if value < -2147483648 || value > 2147483647 {
    raise ClientError::Encode(
      "value \{value} does not fit in a 32-bit integer field",
    )
  }
  value
}
