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
/// Errors raised while decoding a `FieldData` into a column, or while reading
/// a row out of one. The text is the observable behaviour of this module, so
/// it is phrased after the upstream `client/column` wording where the two
/// reject the same input.
pub(all) suberror ColumnError {
  /// The wire payload does not carry the data the declared `DataType` needs,
  /// e.g. a `FloatVector` field whose `VectorField.data` is a binary vector.
  /// Mirrors upstream `errFieldDataTypeNotMatch`.
  DataTypeNotMatch(String)
  /// The field type has no column representation in this client, e.g. a
  /// `Struct` payload. Mirrors upstream's `unsupported data type %s`.
  UnsupportedType(String)
  /// A row/index argument is outside the column.
  IndexOutOfRange(String)
  /// The payload's shape disagrees with the rows it claims, e.g. a vector
  /// payload whose byte count is not a multiple of the row width, or a
  /// `valid_data` length that matches neither the logical rows nor the valid
  /// count.
  MalformedPayload(String)
  /// The row is null, so there is no value to read.
  NullValue(String)
} derive(Debug)

// `derive(Debug)` promotes the trait methods to plain methods, which MoonBit
// deprecates. Pinning the promotions here keeps the module warning-free
// without dropping the derive, the same as the other packages do.

///|
#deprecated
pub extend ColumnError with @debug.Debug::{to_repr}

///|
/// 把「读错类型」和「读到 null」分开报。null 行单列一个错误，因为它是
/// 数据本身的状态，而类型不符是调用方写错了代码。
fn type_error(column : Column, want : String, got : Cell) -> ColumnError {
  match got {
    Null =>
      NullValue("row is null in field of type \{column.data_type().name()}")
    _ =>
      DataTypeNotMatch(
        "cannot read \{column.data_type().name()} column as \{want}",
      )
  }
}
