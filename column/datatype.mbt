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
// 生成的 `@schema.DataType` 只带序号，没有名字；`@entity.DataType` 有名字
// （`name()`），且它的数值与 proto 逐条对齐。这里做一次显式对应，让上方
// 报错文案用的是 `@entity` 的名字，两边不会各写一份字符串。

///|
/// 生成的枚举值转 `@entity.DataType`；`Unknown` 表示服务端发了一个本
/// 客户端还不认识的类型，返回 `None` 而不是猜一个名字。
fn entity_data_type_opt(t : @schema.DataType) -> @entity.DataType? {
  let d = match t {
    @schema.DataType::None => @entity.DataType::None
    @schema.DataType::Bool => @entity.DataType::Bool
    @schema.DataType::Int8 => @entity.DataType::Int8
    @schema.DataType::Int16 => @entity.DataType::Int16
    @schema.DataType::Int32 => @entity.DataType::Int32
    @schema.DataType::Int64 => @entity.DataType::Int64
    @schema.DataType::Float => @entity.DataType::Float
    @schema.DataType::Double => @entity.DataType::Double
    @schema.DataType::String => @entity.DataType::String
    @schema.DataType::VarChar => @entity.DataType::VarChar
    @schema.DataType::Array => @entity.DataType::Array
    @schema.DataType::JSON => @entity.DataType::Json
    @schema.DataType::Geometry => @entity.DataType::Geometry
    @schema.DataType::Text => @entity.DataType::Text
    @schema.DataType::Timestamptz => @entity.DataType::Timestamptz
    @schema.DataType::Mol => @entity.DataType::Mol
    @schema.DataType::Date => @entity.DataType::Date
    @schema.DataType::Time => @entity.DataType::Time
    @schema.DataType::Decimal => @entity.DataType::Decimal
    @schema.DataType::UUID => @entity.DataType::Uuid
    @schema.DataType::BinaryVector => @entity.DataType::BinaryVector
    @schema.DataType::FloatVector => @entity.DataType::FloatVector
    @schema.DataType::Float16Vector => @entity.DataType::Float16Vector
    @schema.DataType::BFloat16Vector => @entity.DataType::BFloat16Vector
    @schema.DataType::SparseFloatVector => @entity.DataType::SparseFloatVector
    @schema.DataType::Int8Vector => @entity.DataType::Int8Vector
    @schema.DataType::ArrayOfVector => @entity.DataType::ArrayOfVector
    @schema.DataType::ArrayOfStruct => @entity.DataType::ArrayOfStruct
    @schema.DataType::Struct => @entity.DataType::Struct
    @schema.DataType::Unknown(_) => return None
  }
  Some(d)
}

///|
/// 类型名，报错文案用。
fn data_type_name(t : @schema.DataType) -> String {
  match entity_data_type_opt(t) {
    Some(d) => d.name()
    None => "unknown"
  }
}

///|
/// 把服务端放在 `int32` 数组里的 `Int8` 收窄回有符号字节。
/// 上游用 Go 的 `int8(i32)`，就是二进制补码截断加符号扩展；这里显式写出来。
fn narrow_int8(v : Int) -> Int {
  let byte = v & 0xFF
  if byte >= 0x80 {
    byte - 0x100
  } else {
    byte
  }
}

///|
/// `Int16` 同理。
fn narrow_int16(v : Int) -> Int {
  let half = v & 0xFFFF
  if half >= 0x8000 {
    half - 0x10000
  } else {
    half
  }
}
