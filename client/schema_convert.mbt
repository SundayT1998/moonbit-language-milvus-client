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
// 移植自 milvus-io/milvus client/entity/schema.go（`ReadProto` /
// `ProtoMessage`）与 client/milvusclient/collection_options.go
// （Apache-2.0）。
//
// 协议无关的领域类型在 `@entity`，wire 类型在生成的 `@schema` 里，
// 这一层是两者的桥。数值常量与 `milvus.proto.schema.DataType` 逐条对齐，
// 改动等于改协议。

///|
/// `@entity.DataType` → `@schema.DataType`。
///
/// 生成的枚举把 `JSON` / `UUID` 拼成全大写，与上游 proto 一致；
/// `@entity` 侧用惯常的 `Json` / `Uuid`。两边新增类型时这里都要动。
pub fn data_type_to_proto(value : @entity.DataType) -> @schema.DataType {
  match value {
    None => @schema.DataType::None
    Bool => @schema.DataType::Bool
    Int8 => @schema.DataType::Int8
    Int16 => @schema.DataType::Int16
    Int32 => @schema.DataType::Int32
    Int64 => @schema.DataType::Int64
    Float => @schema.DataType::Float
    Double => @schema.DataType::Double
    String => @schema.DataType::String
    VarChar => @schema.DataType::VarChar
    Array => @schema.DataType::Array
    Json => @schema.DataType::JSON
    Geometry => @schema.DataType::Geometry
    Text => @schema.DataType::Text
    Timestamptz => @schema.DataType::Timestamptz
    Mol => @schema.DataType::Mol
    Date => @schema.DataType::Date
    Time => @schema.DataType::Time
    Decimal => @schema.DataType::Decimal
    Uuid => @schema.DataType::UUID
    BinaryVector => @schema.DataType::BinaryVector
    FloatVector => @schema.DataType::FloatVector
    Float16Vector => @schema.DataType::Float16Vector
    BFloat16Vector => @schema.DataType::BFloat16Vector
    SparseFloatVector => @schema.DataType::SparseFloatVector
    Int8Vector => @schema.DataType::Int8Vector
    ArrayOfVector => @schema.DataType::ArrayOfVector
    ArrayOfStruct => @schema.DataType::ArrayOfStruct
    Struct => @schema.DataType::Struct
  }
}

///|
/// `@schema.DataType` → `@entity.DataType?`。
///
/// 认不出的值（协议比本地新）返回 `None`，由调用方决定是跳过这个字段还是
/// 报错 —— 静默当成某个已知类型会把未知字段读歪。
pub fn data_type_from_proto(value : @schema.DataType) -> @entity.DataType? {
  match value {
    @schema.DataType::None => Some(@entity.DataType::None)
    @schema.DataType::Bool => Some(@entity.DataType::Bool)
    @schema.DataType::Int8 => Some(@entity.DataType::Int8)
    @schema.DataType::Int16 => Some(@entity.DataType::Int16)
    @schema.DataType::Int32 => Some(@entity.DataType::Int32)
    @schema.DataType::Int64 => Some(@entity.DataType::Int64)
    @schema.DataType::Float => Some(@entity.DataType::Float)
    @schema.DataType::Double => Some(@entity.DataType::Double)
    @schema.DataType::String => Some(@entity.DataType::String)
    @schema.DataType::VarChar => Some(@entity.DataType::VarChar)
    @schema.DataType::Array => Some(@entity.DataType::Array)
    @schema.DataType::JSON => Some(@entity.DataType::Json)
    @schema.DataType::Geometry => Some(@entity.DataType::Geometry)
    @schema.DataType::Text => Some(@entity.DataType::Text)
    @schema.DataType::Timestamptz => Some(@entity.DataType::Timestamptz)
    @schema.DataType::Mol => Some(@entity.DataType::Mol)
    @schema.DataType::Date => Some(@entity.DataType::Date)
    @schema.DataType::Time => Some(@entity.DataType::Time)
    @schema.DataType::Decimal => Some(@entity.DataType::Decimal)
    @schema.DataType::UUID => Some(@entity.DataType::Uuid)
    @schema.DataType::BinaryVector => Some(@entity.DataType::BinaryVector)
    @schema.DataType::FloatVector => Some(@entity.DataType::FloatVector)
    @schema.DataType::Float16Vector => Some(@entity.DataType::Float16Vector)
    @schema.DataType::BFloat16Vector => Some(@entity.DataType::BFloat16Vector)
    @schema.DataType::SparseFloatVector =>
      Some(@entity.DataType::SparseFloatVector)
    @schema.DataType::Int8Vector => Some(@entity.DataType::Int8Vector)
    @schema.DataType::ArrayOfVector => Some(@entity.DataType::ArrayOfVector)
    @schema.DataType::ArrayOfStruct => Some(@entity.DataType::ArrayOfStruct)
    @schema.DataType::Struct => Some(@entity.DataType::Struct)
    _ => None
  }
}

///|
/// 一个 `@entity.Field` → `@schema.FieldSchema`。
///
/// `dim` / `max_length` 不是 `FieldSchema` 的字段：服务端从 `type_params`
/// 里读，所以这里也把它俩合并进 `type_params`，顺序是 dim 在前。
pub fn field_to_proto(field : @entity.Field) -> @schema.FieldSchema {
  let params : Array[@common.KeyValuePair] = []
  match field.dim {
    Some(dim) =>
      params.push(
        @common.KeyValuePair::KeyValuePair(@entity.dim_key, dim.to_string()),
      )
    None => ()
  }
  match field.max_length {
    Some(len) =>
      params.push(
        @common.KeyValuePair::KeyValuePair(
          @entity.max_length_key,
          len.to_string(),
        ),
      )
    None => ()
  }
  for pair in field.type_params {
    params.push(@common.KeyValuePair::KeyValuePair(pair.0, pair.1))
  }
  let element_type = match field.element_type {
    Some(t) => data_type_to_proto(t)
    None => @schema.DataType::None
  }
  @schema.FieldSchema::{
    field_id: field.field_id,
    name: field.name,
    is_primary_key: field.is_primary_key,
    description: field.description,
    data_type: data_type_to_proto(field.data_type),
    type_params: params,
    index_params: [],
    auto_id: field.auto_id,
    state: @schema.FieldState::FieldCreated,
    element_type,
    default_value: None,
    is_dynamic: field.is_dynamic,
    is_partition_key: field.is_partition_key,
    is_clustering_key: field.is_clustering_key,
    nullable: field.nullable,
    is_function_output: false,
    external_field: "",
    type_schema: None,
    element_nullable: false,
  }
}

///|
/// `@entity.CollectionSchema` → `@schema.CollectionSchema`。
///
/// `name` 单独传：`@entity.CollectionSchema` 里没有集合名这一项，
/// 上游也是把名字留在 `CreateCollectionOption` 上再补进 proto。
pub fn schema_to_proto(
  name : String,
  schema : @entity.CollectionSchema,
) -> @schema.CollectionSchema {
  @schema.CollectionSchema::{
    name,
    description: schema.description,
    auto_id: false,
    fields: schema.fields.map(field_to_proto),
    enable_dynamic_field: schema.enable_dynamic_field,
    properties: [],
    functions: [],
    db_name: "",
    struct_array_fields: [],
    version: 0,
    external_source: "",
    external_spec: "",
    do_physical_backfill: false,
    file_resource_ids: [],
    enable_namespace: false,
  }
}

///|
/// 编码 `CreateCollectionRequest.schema` 那个 `bytes` 字段。
pub fn serialize_collection_schema(
  name : String,
  schema : @entity.CollectionSchema,
) -> Bytes raise ClientError {
  encode_request(schema_to_proto(name, schema))
}

///|
/// `type_params` 里某个键的整数值；缺键或非数字都算 0。
///
/// 上游 `entity.ReadProto` 用 `strconv.ParseInt` 并吞掉错误，
/// 这里同样不报错：`type_params` 是自由格式，服务端可能塞进任意键。
fn type_param_int(params : Array[@common.KeyValuePair], key : String) -> Int {
  for pair in params {
    if pair.key == key {
      return @string.parse_int(pair.value[:]) catch { _ => 0 }
    }
  }
  0
}

///|
/// `@schema.FieldSchema` → `@entity.Field`。
///
/// 生成物的 `element_type` 是必填枚举、缺省 `None`，所以这里用
/// `data_type_from_proto(...)` 之后再判断是否真的设了元素类型。
pub fn field_from_proto(
  proto : @schema.FieldSchema,
) -> @entity.Field raise ClientError {
  let data_type = match data_type_from_proto(proto.data_type) {
    Some(t) => t
    None =>
      raise ClientError::Decode(
        "field \{proto.name} has unknown data type \{proto.data_type.to_enum().0}",
      )
  }
  let mut element_type : @entity.DataType? = None
  if proto.element_type != @schema.DataType::None {
    match data_type_from_proto(proto.element_type) {
      Some(t) => element_type = Some(t)
      None =>
        raise ClientError::Decode(
          "field \{proto.name} has unknown element type \{proto.element_type.to_enum().0}",
        )
    }
  }
  let dim = type_param_int(proto.type_params, @entity.dim_key)
  let max_length = type_param_int(proto.type_params, @entity.max_length_key)
  let extra : Array[(String, String)] = []
  for pair in proto.type_params {
    if pair.key != @entity.dim_key && pair.key != @entity.max_length_key {
      extra.push((pair.key, pair.value))
    }
  }
  {
    name: proto.name,
    data_type,
    field_id: proto.field_id,
    is_primary_key: proto.is_primary_key,
    auto_id: proto.auto_id,
    description: proto.description,
    is_dynamic: proto.is_dynamic,
    is_partition_key: proto.is_partition_key,
    is_clustering_key: proto.is_clustering_key,
    nullable: proto.nullable,
    element_type,
    dim: if dim == 0 {
      None
    } else {
      Some(dim)
    },
    max_length: if max_length == 0 {
      None
    } else {
      Some(max_length)
    },
    type_params: extra,
  }
}

///|
/// `@entity.SchemaError` 的文本。它在 `@entity` 里只 derive 了 `Eq, Debug`，
/// 包外拿不到内部字符串，所以这里按 Debug 展开取出来。
/// 校验错误是给人看的，包一层 `Debug(...)` 也比只写「schema 不合法」强。
pub fn entity_schema_message(err : @entity.SchemaError) -> String {
  match err {
    SchemaError(msg) => msg
  }
}
