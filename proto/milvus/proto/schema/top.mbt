///|
pub(all) enum DataType {
  None
  Bool
  Int8
  Int16
  Int32
  Int64
  Float
  Double
  String
  VarChar
  Array
  JSON
  Geometry
  Text
  Timestamptz
  Mol
  Date
  Time
  Decimal
  UUID
  BinaryVector
  FloatVector
  Float16Vector
  BFloat16Vector
  SparseFloatVector
  Int8Vector
  ArrayOfVector
  ArrayOfStruct
  Struct
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn DataType::to_enum(self : DataType) -> @lib.Enum {
  match self {
    DataType::None => 0
    DataType::Bool => 1
    DataType::Int8 => 2
    DataType::Int16 => 3
    DataType::Int32 => 4
    DataType::Int64 => 5
    DataType::Float => 10
    DataType::Double => 11
    DataType::String => 20
    DataType::VarChar => 21
    DataType::Array => 22
    DataType::JSON => 23
    DataType::Geometry => 24
    DataType::Text => 25
    DataType::Timestamptz => 26
    DataType::Mol => 27
    DataType::Date => 28
    DataType::Time => 29
    DataType::Decimal => 30
    DataType::UUID => 31
    DataType::BinaryVector => 100
    DataType::FloatVector => 101
    DataType::Float16Vector => 102
    DataType::BFloat16Vector => 103
    DataType::SparseFloatVector => 104
    DataType::Int8Vector => 105
    DataType::ArrayOfVector => 106
    DataType::ArrayOfStruct => 200
    DataType::Struct => 201
    DataType::Unknown(value) => value
  }
}

///|
pub fn DataType::from_enum(i : @lib.Enum) -> DataType {
  match i.0 {
    0 => DataType::None
    1 => DataType::Bool
    2 => DataType::Int8
    3 => DataType::Int16
    4 => DataType::Int32
    5 => DataType::Int64
    10 => DataType::Float
    11 => DataType::Double
    20 => DataType::String
    21 => DataType::VarChar
    22 => DataType::Array
    23 => DataType::JSON
    24 => DataType::Geometry
    25 => DataType::Text
    26 => DataType::Timestamptz
    27 => DataType::Mol
    28 => DataType::Date
    29 => DataType::Time
    30 => DataType::Decimal
    31 => DataType::UUID
    100 => DataType::BinaryVector
    101 => DataType::FloatVector
    102 => DataType::Float16Vector
    103 => DataType::BFloat16Vector
    104 => DataType::SparseFloatVector
    105 => DataType::Int8Vector
    106 => DataType::ArrayOfVector
    200 => DataType::ArrayOfStruct
    201 => DataType::Struct
    _ => DataType::Unknown(i)
  }
}

///|
pub impl Default for DataType with fn default() -> DataType {
  DataType::None
}

///|
pub impl @lib.Sized for DataType with fn size_of(self : DataType) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for DataType with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DataType raise {
  match json {
    String("None") => DataType::None
    String("Bool") => DataType::Bool
    String("Int8") => DataType::Int8
    String("Int16") => DataType::Int16
    String("Int32") => DataType::Int32
    String("Int64") => DataType::Int64
    String("Float") => DataType::Float
    String("Double") => DataType::Double
    String("String") => DataType::String
    String("VarChar") => DataType::VarChar
    String("Array") => DataType::Array
    String("JSON") => DataType::JSON
    String("Geometry") => DataType::Geometry
    String("Text") => DataType::Text
    String("Timestamptz") => DataType::Timestamptz
    String("Mol") => DataType::Mol
    String("Date") => DataType::Date
    String("Time") => DataType::Time
    String("Decimal") => DataType::Decimal
    String("UUID") => DataType::UUID
    String("BinaryVector") => DataType::BinaryVector
    String("FloatVector") => DataType::FloatVector
    String("Float16Vector") => DataType::Float16Vector
    String("BFloat16Vector") => DataType::BFloat16Vector
    String("SparseFloatVector") => DataType::SparseFloatVector
    String("Int8Vector") => DataType::Int8Vector
    String("ArrayOfVector") => DataType::ArrayOfVector
    String("ArrayOfStruct") => DataType::ArrayOfStruct
    String("Struct") => DataType::Struct
    Number(0, ..) => DataType::None
    Number(1, ..) => DataType::Bool
    Number(2, ..) => DataType::Int8
    Number(3, ..) => DataType::Int16
    Number(4, ..) => DataType::Int32
    Number(5, ..) => DataType::Int64
    Number(10, ..) => DataType::Float
    Number(11, ..) => DataType::Double
    Number(20, ..) => DataType::String
    Number(21, ..) => DataType::VarChar
    Number(22, ..) => DataType::Array
    Number(23, ..) => DataType::JSON
    Number(24, ..) => DataType::Geometry
    Number(25, ..) => DataType::Text
    Number(26, ..) => DataType::Timestamptz
    Number(27, ..) => DataType::Mol
    Number(28, ..) => DataType::Date
    Number(29, ..) => DataType::Time
    Number(30, ..) => DataType::Decimal
    Number(31, ..) => DataType::UUID
    Number(100, ..) => DataType::BinaryVector
    Number(101, ..) => DataType::FloatVector
    Number(102, ..) => DataType::Float16Vector
    Number(103, ..) => DataType::BFloat16Vector
    Number(104, ..) => DataType::SparseFloatVector
    Number(105, ..) => DataType::Int8Vector
    Number(106, ..) => DataType::ArrayOfVector
    Number(200, ..) => DataType::ArrayOfStruct
    Number(201, ..) => DataType::Struct
    Number(value, ..) =>
      if value.trunc() == value {
        DataType::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for DataType with fn to_json(self : DataType) -> Json {
  match self {
    DataType::None => "None"
    DataType::Bool => "Bool"
    DataType::Int8 => "Int8"
    DataType::Int16 => "Int16"
    DataType::Int32 => "Int32"
    DataType::Int64 => "Int64"
    DataType::Float => "Float"
    DataType::Double => "Double"
    DataType::String => "String"
    DataType::VarChar => "VarChar"
    DataType::Array => "Array"
    DataType::JSON => "JSON"
    DataType::Geometry => "Geometry"
    DataType::Text => "Text"
    DataType::Timestamptz => "Timestamptz"
    DataType::Mol => "Mol"
    DataType::Date => "Date"
    DataType::Time => "Time"
    DataType::Decimal => "Decimal"
    DataType::UUID => "UUID"
    DataType::BinaryVector => "BinaryVector"
    DataType::FloatVector => "FloatVector"
    DataType::Float16Vector => "Float16Vector"
    DataType::BFloat16Vector => "BFloat16Vector"
    DataType::SparseFloatVector => "SparseFloatVector"
    DataType::Int8Vector => "Int8Vector"
    DataType::ArrayOfVector => "ArrayOfVector"
    DataType::ArrayOfStruct => "ArrayOfStruct"
    DataType::Struct => "Struct"
    DataType::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum FieldState {
  FieldCreated
  FieldCreating
  FieldDropping
  FieldDropped
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn FieldState::to_enum(self : FieldState) -> @lib.Enum {
  match self {
    FieldState::FieldCreated => 0
    FieldState::FieldCreating => 1
    FieldState::FieldDropping => 2
    FieldState::FieldDropped => 3
    FieldState::Unknown(value) => value
  }
}

///|
pub fn FieldState::from_enum(i : @lib.Enum) -> FieldState {
  match i.0 {
    0 => FieldState::FieldCreated
    1 => FieldState::FieldCreating
    2 => FieldState::FieldDropping
    3 => FieldState::FieldDropped
    _ => FieldState::Unknown(i)
  }
}

///|
pub impl Default for FieldState with fn default() -> FieldState {
  FieldState::FieldCreated
}

///|
pub impl @lib.Sized for FieldState with fn size_of(self : FieldState) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FieldState with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FieldState raise {
  match json {
    String("FieldCreated") => FieldState::FieldCreated
    String("FieldCreating") => FieldState::FieldCreating
    String("FieldDropping") => FieldState::FieldDropping
    String("FieldDropped") => FieldState::FieldDropped
    Number(0, ..) => FieldState::FieldCreated
    Number(1, ..) => FieldState::FieldCreating
    Number(2, ..) => FieldState::FieldDropping
    Number(3, ..) => FieldState::FieldDropped
    Number(value, ..) =>
      if value.trunc() == value {
        FieldState::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FieldState with fn to_json(self : FieldState) -> Json {
  match self {
    FieldState::FieldCreated => "FieldCreated"
    FieldState::FieldCreating => "FieldCreating"
    FieldState::FieldDropping => "FieldDropping"
    FieldState::FieldDropped => "FieldDropped"
    FieldState::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum FunctionType {
  Unknown
  BM25
  TextEmbedding
  Rerank
  MinHash
  MolFingerprint
  Unknown1(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn FunctionType::to_enum(self : FunctionType) -> @lib.Enum {
  match self {
    FunctionType::Unknown => 0
    FunctionType::BM25 => 1
    FunctionType::TextEmbedding => 2
    FunctionType::Rerank => 3
    FunctionType::MinHash => 4
    FunctionType::MolFingerprint => 5
    FunctionType::Unknown1(value) => value
  }
}

///|
pub fn FunctionType::from_enum(i : @lib.Enum) -> FunctionType {
  match i.0 {
    0 => FunctionType::Unknown
    1 => FunctionType::BM25
    2 => FunctionType::TextEmbedding
    3 => FunctionType::Rerank
    4 => FunctionType::MinHash
    5 => FunctionType::MolFingerprint
    _ => FunctionType::Unknown1(i)
  }
}

///|
pub impl Default for FunctionType with fn default() -> FunctionType {
  FunctionType::Unknown
}

///|
pub impl @lib.Sized for FunctionType with fn size_of(self : FunctionType) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FunctionType with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FunctionType raise {
  match json {
    String("Unknown") => FunctionType::Unknown
    String("BM25") => FunctionType::BM25
    String("TextEmbedding") => FunctionType::TextEmbedding
    String("Rerank") => FunctionType::Rerank
    String("MinHash") => FunctionType::MinHash
    String("MolFingerprint") => FunctionType::MolFingerprint
    Number(0, ..) => FunctionType::Unknown
    Number(1, ..) => FunctionType::BM25
    Number(2, ..) => FunctionType::TextEmbedding
    Number(3, ..) => FunctionType::Rerank
    Number(4, ..) => FunctionType::MinHash
    Number(5, ..) => FunctionType::MolFingerprint
    Number(value, ..) =>
      if value.trunc() == value {
        FunctionType::Unknown1(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FunctionType with fn to_json(self : FunctionType) -> Json {
  match self {
    FunctionType::Unknown => "Unknown"
    FunctionType::BM25 => "BM25"
    FunctionType::TextEmbedding => "TextEmbedding"
    FunctionType::Rerank => "Rerank"
    FunctionType::MinHash => "MinHash"
    FunctionType::MolFingerprint => "MolFingerprint"
    FunctionType::Unknown1(value) => value.0.to_json()
  }
}

///|
pub(all) enum ShardState {
  ShardNormal
  ShardCreating
  ShardSplitting
  ShardDropped
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn ShardState::to_enum(self : ShardState) -> @lib.Enum {
  match self {
    ShardState::ShardNormal => 0
    ShardState::ShardCreating => 1
    ShardState::ShardSplitting => 2
    ShardState::ShardDropped => 3
    ShardState::Unknown(value) => value
  }
}

///|
pub fn ShardState::from_enum(i : @lib.Enum) -> ShardState {
  match i.0 {
    0 => ShardState::ShardNormal
    1 => ShardState::ShardCreating
    2 => ShardState::ShardSplitting
    3 => ShardState::ShardDropped
    _ => ShardState::Unknown(i)
  }
}

///|
pub impl Default for ShardState with fn default() -> ShardState {
  ShardState::ShardNormal
}

///|
pub impl @lib.Sized for ShardState with fn size_of(self : ShardState) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for ShardState with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ShardState raise {
  match json {
    String("ShardNormal") => ShardState::ShardNormal
    String("ShardCreating") => ShardState::ShardCreating
    String("ShardSplitting") => ShardState::ShardSplitting
    String("ShardDropped") => ShardState::ShardDropped
    Number(0, ..) => ShardState::ShardNormal
    Number(1, ..) => ShardState::ShardCreating
    Number(2, ..) => ShardState::ShardSplitting
    Number(3, ..) => ShardState::ShardDropped
    Number(value, ..) =>
      if value.trunc() == value {
        ShardState::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for ShardState with fn to_json(self : ShardState) -> Json {
  match self {
    ShardState::ShardNormal => "ShardNormal"
    ShardState::ShardCreating => "ShardCreating"
    ShardState::ShardSplitting => "ShardSplitting"
    ShardState::ShardDropped => "ShardDropped"
    ShardState::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) struct CollectionSchema {
  mut name : String
  mut description : String
  mut auto_id : Bool
  mut fields : Array[FieldSchema]
  mut enable_dynamic_field : Bool
  mut properties : Array[@common.KeyValuePair]
  mut functions : Array[FunctionSchema]
  mut db_name : String
  mut struct_array_fields : Array[StructArrayFieldSchema]
  mut version : Int
  mut external_source : String
  mut external_spec : String
  mut do_physical_backfill : Bool
  mut file_resource_ids : Array[Int64]
  mut enable_namespace : Bool
} derive(Eq, Debug)

///|
pub impl @lib.Sized for CollectionSchema with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  if self.description != Default::default() {
    size += @lib.size_of_length_delimited_field(
      2U,
      @lib.size_of(self.description),
    )
  }
  if self.auto_id != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.auto_id))
  }
  for s in self.fields {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  if self.enable_dynamic_field != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.enable_dynamic_field))
  }
  for s in self.properties {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  for s in self.functions {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(s))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(8U, @lib.size_of(self.db_name))
  }
  for s in self.struct_array_fields {
    size += @lib.size_of_length_delimited_field(9U, @lib.size_of(s))
  }
  if self.version != Default::default() {
    size += @lib.size_of_field(10U, @lib.size_of(self.version))
  }
  if self.external_source != Default::default() {
    size += @lib.size_of_length_delimited_field(
      11U,
      @lib.size_of(self.external_source),
    )
  }
  if self.external_spec != Default::default() {
    size += @lib.size_of_length_delimited_field(
      12U,
      @lib.size_of(self.external_spec),
    )
  }
  if self.do_physical_backfill != Default::default() {
    size += @lib.size_of_field(13U, @lib.size_of(self.do_physical_backfill))
  }
  if !self.file_resource_ids.is_empty() {
    size += @lib.size_of_length_delimited_field(
      14U,
      self.file_resource_ids.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if self.enable_namespace != Default::default() {
    size += @lib.size_of_field(15U, @lib.size_of(self.enable_namespace))
  }
  size
}

///|
pub impl Default for CollectionSchema with fn default() -> CollectionSchema {
  CollectionSchema::{
    name: Default::default(),
    description: Default::default(),
    auto_id: Default::default(),
    fields: [],
    enable_dynamic_field: Default::default(),
    properties: [],
    functions: [],
    db_name: Default::default(),
    struct_array_fields: [],
    version: Default::default(),
    external_source: Default::default(),
    external_spec: Default::default(),
    do_physical_backfill: Default::default(),
    file_resource_ids: [],
    enable_namespace: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn CollectionSchema::CollectionSchema(
  name : String,
  description : String,
  auto_id : Bool,
  fields : Array[FieldSchema],
  enable_dynamic_field : Bool,
  properties : Array[@common.KeyValuePair],
  functions : Array[FunctionSchema],
  db_name : String,
  struct_array_fields : Array[StructArrayFieldSchema],
  version : Int,
  external_source : String,
  external_spec : String,
  do_physical_backfill : Bool,
  file_resource_ids : Array[Int64],
  enable_namespace : Bool,
) -> CollectionSchema {
  CollectionSchema::{
    name,
    description,
    auto_id,
    fields,
    enable_dynamic_field,
    properties,
    functions,
    db_name,
    struct_array_fields,
    version,
    external_source,
    external_spec,
    do_physical_backfill,
    file_resource_ids,
    enable_namespace,
  }
}

///|
pub impl @lib.Read for CollectionSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> CollectionSchema raise {
  let msg : CollectionSchema = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.description = reader |> @lib.read_string()
      (3, _) => msg.auto_id = reader |> @lib.read_bool()
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields.push((reader |> @lib.read_message() : FieldSchema))
      (5, _) => msg.enable_dynamic_field = reader |> @lib.read_bool()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.properties.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.functions.push((reader |> @lib.read_message() : FunctionSchema))
      (8, _) => msg.db_name = reader |> @lib.read_string()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.struct_array_fields.push(
          (reader |> @lib.read_message() : StructArrayFieldSchema),
        )
      (10, _) => msg.version = reader |> @lib.read_int32()
      (11, _) => msg.external_source = reader |> @lib.read_string()
      (12, _) => msg.external_spec = reader |> @lib.read_string()
      (13, _) => msg.do_physical_backfill = reader |> @lib.read_bool()
      (14, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.file_resource_ids.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (14, @lib.WIRE_TYPE_VARINT) =>
        msg.file_resource_ids.push(reader |> @lib.read_int64())
      (15, _) => msg.enable_namespace = reader |> @lib.read_bool()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for CollectionSchema with fn write(
  self : CollectionSchema,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  if self.description != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.description)
  }
  if self.auto_id != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_bool(self.auto_id)
  }
  for item in self.fields {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
  if self.enable_dynamic_field != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_bool(self.enable_dynamic_field)
  }
  for item in self.properties {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_message(item)
  }
  for item in self.functions {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_message(item)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(66UL)
    writer |> @lib.write_string(self.db_name)
  }
  for item in self.struct_array_fields {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_message(item)
  }
  if self.version != Default::default() {
    writer |> @lib.write_varint(80UL)
    writer |> @lib.write_int32(self.version)
  }
  if self.external_source != Default::default() {
    writer |> @lib.write_varint(90UL)
    writer |> @lib.write_string(self.external_source)
  }
  if self.external_spec != Default::default() {
    writer |> @lib.write_varint(98UL)
    writer |> @lib.write_string(self.external_spec)
  }
  if self.do_physical_backfill != Default::default() {
    writer |> @lib.write_varint(104UL)
    writer |> @lib.write_bool(self.do_physical_backfill)
  }
  if !self.file_resource_ids.is_empty() {
    writer |> @lib.write_varint(114UL)
    let size = self.file_resource_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.file_resource_ids {
      writer |> @lib.write_int64(item)
    }
  }
  if self.enable_namespace != Default::default() {
    writer |> @lib.write_varint(120UL)
    writer |> @lib.write_bool(self.enable_namespace)
  }
}

///|
pub impl ToJson for CollectionSchema with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.name != Default::default() {
    json["name"] = ToJson::to_json(self.name)
  }
  if self.description != Default::default() {
    json["description"] = ToJson::to_json(self.description)
  }
  if self.auto_id != Default::default() {
    json["autoID"] = ToJson::to_json(self.auto_id)
  }
  if self.fields != Default::default() {
    json["fields"] = ToJson::to_json(self.fields)
  }
  if self.enable_dynamic_field != Default::default() {
    json["enableDynamicField"] = ToJson::to_json(self.enable_dynamic_field)
  }
  if self.properties != Default::default() {
    json["properties"] = ToJson::to_json(self.properties)
  }
  if self.functions != Default::default() {
    json["functions"] = ToJson::to_json(self.functions)
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.struct_array_fields != Default::default() {
    json["structArrayFields"] = ToJson::to_json(self.struct_array_fields)
  }
  if self.version != Default::default() {
    json["version"] = ToJson::to_json(self.version)
  }
  if self.external_source != Default::default() {
    json["externalSource"] = ToJson::to_json(self.external_source)
  }
  if self.external_spec != Default::default() {
    json["externalSpec"] = ToJson::to_json(self.external_spec)
  }
  if self.do_physical_backfill != Default::default() {
    json["doPhysicalBackfill"] = ToJson::to_json(self.do_physical_backfill)
  }
  if self.file_resource_ids != Default::default() {
    json["fileResourceIds"] = ToJson::to_json(self.file_resource_ids)
  }
  if self.enable_namespace != Default::default() {
    json["enableNamespace"] = ToJson::to_json(self.enable_namespace)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for CollectionSchema with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> CollectionSchema raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for CollectionSchema"),
    )
  }
  let message : CollectionSchema = Default::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("description", value) =>
        message.description = @json.from_json(value, path~)
      ("autoID", value) => message.auto_id = @json.from_json(value, path~)
      ("fields", Array(value)) =>
        message.fields = value.map(v => @json.from_json(v, path~))
      ("enableDynamicField", value) =>
        message.enable_dynamic_field = @json.from_json(value, path~)
      ("properties", Array(value)) =>
        message.properties = value.map(v => @json.from_json(v, path~))
      ("functions", Array(value)) =>
        message.functions = value.map(v => @json.from_json(v, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("structArrayFields", Array(value)) =>
        message.struct_array_fields = value.map(v => @json.from_json(v, path~))
      ("version", value) => message.version = @json.from_json(value, path~)
      ("externalSource", value) =>
        message.external_source = @json.from_json(value, path~)
      ("externalSpec", value) =>
        message.external_spec = @json.from_json(value, path~)
      ("doPhysicalBackfill", value) =>
        message.do_physical_backfill = @json.from_json(value, path~)
      ("fileResourceIds", Array(value)) =>
        message.file_resource_ids = value.map(v => @json.from_json(v, path~))
      ("enableNamespace", value) =>
        message.enable_namespace = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for CollectionSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> CollectionSchema raise {
  let msg : CollectionSchema = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.description = reader |> @lib.async_read_string()
      (3, _) => msg.auto_id = reader |> @lib.async_read_bool()
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields.push((reader |> @lib.async_read_message() : FieldSchema))
      (5, _) => msg.enable_dynamic_field = reader |> @lib.async_read_bool()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.properties.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.functions.push(
          (reader |> @lib.async_read_message() : FunctionSchema),
        )
      (8, _) => msg.db_name = reader |> @lib.async_read_string()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.struct_array_fields.push(
          (reader |> @lib.async_read_message() : StructArrayFieldSchema),
        )
      (10, _) => msg.version = reader |> @lib.async_read_int32()
      (11, _) => msg.external_source = reader |> @lib.async_read_string()
      (12, _) => msg.external_spec = reader |> @lib.async_read_string()
      (13, _) => msg.do_physical_backfill = reader |> @lib.async_read_bool()
      (14, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.file_resource_ids.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (14, @lib.WIRE_TYPE_VARINT) =>
        msg.file_resource_ids.push(reader |> @lib.async_read_int64())
      (15, _) => msg.enable_namespace = reader |> @lib.async_read_bool()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for CollectionSchema with fn write(
  self : CollectionSchema,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.description != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.description)
  }
  if self.auto_id != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_bool(self.auto_id)
  }
  for item in self.fields {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
  if self.enable_dynamic_field != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_bool(self.enable_dynamic_field)
  }
  for item in self.properties {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.functions {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_message(item)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(66UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  for item in self.struct_array_fields {
    writer |> @lib.async_write_varint(74UL)
    writer |> @lib.async_write_message(item)
  }
  if self.version != Default::default() {
    writer |> @lib.async_write_varint(80UL)
    writer |> @lib.async_write_int32(self.version)
  }
  if self.external_source != Default::default() {
    writer |> @lib.async_write_varint(90UL)
    writer |> @lib.async_write_string(self.external_source)
  }
  if self.external_spec != Default::default() {
    writer |> @lib.async_write_varint(98UL)
    writer |> @lib.async_write_string(self.external_spec)
  }
  if self.do_physical_backfill != Default::default() {
    writer |> @lib.async_write_varint(104UL)
    writer |> @lib.async_write_bool(self.do_physical_backfill)
  }
  if !self.file_resource_ids.is_empty() {
    writer |> @lib.async_write_varint(114UL)
    let size = self.file_resource_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.file_resource_ids {
      writer |> @lib.async_write_int64(item)
    }
  }
  if self.enable_namespace != Default::default() {
    writer |> @lib.async_write_varint(120UL)
    writer |> @lib.async_write_bool(self.enable_namespace)
  }
}

///|
pub(all) struct CollectionShardInfo {
  mut last_truncate_time_tick : UInt64
  mut state : ShardState
  mut vchannel_name : String
  mut routing : CollectionShardInfo_Routing
} derive(Eq, Debug)

///|
pub(all) enum CollectionShardInfo_Routing {
  HashRouting(HashRouting)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for CollectionShardInfo_Routing with fn default() -> CollectionShardInfo_Routing {
  NotSet
}

///|
pub impl @json.FromJson for CollectionShardInfo_Routing with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> CollectionShardInfo_Routing raise {
  try
    CollectionShardInfo_Routing::HashRouting(json |> @json.from_json(path~))
  catch {
    _ => ()
  } noraise {
    v => return v
  }
  CollectionShardInfo_Routing::NotSet
}

///|
pub impl ToJson for CollectionShardInfo_Routing with fn to_json(
  self : CollectionShardInfo_Routing,
) -> Json {
  match self {
    CollectionShardInfo_Routing::HashRouting(v) => ToJson::to_json(v)
    CollectionShardInfo_Routing::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for CollectionShardInfo with fn size_of(self) {
  let mut size = 0U
  if self.last_truncate_time_tick != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.last_truncate_time_tick))
  }
  if self.state != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.state))
  }
  if self.vchannel_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.vchannel_name),
    )
  }
  match self.routing {
    HashRouting(v) =>
      size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for CollectionShardInfo with fn default() -> CollectionShardInfo {
  CollectionShardInfo::{
    last_truncate_time_tick: Default::default(),
    state: Default::default(),
    vchannel_name: Default::default(),
    routing: CollectionShardInfo_Routing::NotSet,
  }
}

///|
#alias(new, deprecated)
pub fn CollectionShardInfo::CollectionShardInfo(
  last_truncate_time_tick : UInt64,
  state : ShardState,
  vchannel_name : String,
  routing? : CollectionShardInfo_Routing = CollectionShardInfo_Routing::NotSet,
) -> CollectionShardInfo {
  CollectionShardInfo::{
    last_truncate_time_tick,
    state,
    vchannel_name,
    routing,
  }
}

///|
pub impl @lib.Read for CollectionShardInfo with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> CollectionShardInfo raise {
  let msg : CollectionShardInfo = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.last_truncate_time_tick = reader |> @lib.read_uint64()
      (2, _) => msg.state = reader |> @lib.read_enum() |> ShardState::from_enum
      (3, _) => msg.vchannel_name = reader |> @lib.read_string()
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.routing = (reader |> @lib.read_message() : HashRouting)
          |> CollectionShardInfo_Routing::HashRouting
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for CollectionShardInfo with fn write(
  self : CollectionShardInfo,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.last_truncate_time_tick != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_uint64(self.last_truncate_time_tick)
  }
  if self.state != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_enum(self.state.to_enum())
  }
  if self.vchannel_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.vchannel_name)
  }
  match self.routing {
    CollectionShardInfo_Routing::HashRouting(v) => {
      writer |> @lib.write_varint(34UL)
      writer |> @lib.write_message(v)
    }
    CollectionShardInfo_Routing::NotSet => ()
  }
}

///|
pub impl ToJson for CollectionShardInfo with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.last_truncate_time_tick != Default::default() {
    json["lastTruncateTimeTick"] = ToJson::to_json(self.last_truncate_time_tick)
  }
  if self.state != Default::default() {
    json["state"] = ToJson::to_json(self.state)
  }
  if self.vchannel_name != Default::default() {
    json["vchannelName"] = ToJson::to_json(self.vchannel_name)
  }
  match self.routing {
    NotSet => ()
    HashRouting(v) => json["hashRouting"] = ToJson::to_json(v)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for CollectionShardInfo with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> CollectionShardInfo raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for CollectionShardInfo"),
    )
  }
  let message : CollectionShardInfo = Default::default()
  for key, value in obj {
    match (key, value) {
      ("lastTruncateTimeTick", value) =>
        message.last_truncate_time_tick = @json.from_json(value, path~)
      ("state", value) => message.state = @json.from_json(value, path~)
      ("vchannelName", value) =>
        message.vchannel_name = @json.from_json(value, path~)
      ("hashRouting", value) => message.routing = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for CollectionShardInfo with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> CollectionShardInfo raise {
  let msg : CollectionShardInfo = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.last_truncate_time_tick = reader |> @lib.async_read_uint64()
      (2, _) =>
        msg.state = reader |> @lib.async_read_enum() |> ShardState::from_enum
      (3, _) => msg.vchannel_name = reader |> @lib.async_read_string()
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.routing = (reader |> @lib.async_read_message() : HashRouting)
          |> CollectionShardInfo_Routing::HashRouting
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for CollectionShardInfo with fn write(
  self : CollectionShardInfo,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.last_truncate_time_tick != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_uint64(self.last_truncate_time_tick)
  }
  if self.state != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_enum(self.state.to_enum())
  }
  if self.vchannel_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.vchannel_name)
  }
  match self.routing {
    CollectionShardInfo_Routing::HashRouting(v) => {
      writer |> @lib.async_write_varint(34UL)
      writer |> @lib.async_write_message(v)
    }
    CollectionShardInfo_Routing::NotSet => ()
  }
}

///|
pub(all) struct FieldSchema {
  mut field_id : Int64
  mut name : String
  mut is_primary_key : Bool
  mut description : String
  mut data_type : DataType
  mut type_params : Array[@common.KeyValuePair]
  mut index_params : Array[@common.KeyValuePair]
  mut auto_id : Bool
  mut state : FieldState
  mut element_type : DataType
  mut default_value : ValueField?
  mut is_dynamic : Bool
  mut is_partition_key : Bool
  mut is_clustering_key : Bool
  mut nullable : Bool
  mut is_function_output : Bool
  mut external_field : String
  mut type_schema : TypeSchema?
  mut element_nullable : Bool
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FieldSchema with fn size_of(self) {
  let mut size = 0U
  if self.field_id != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.field_id))
  }
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.name))
  }
  if self.is_primary_key != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.is_primary_key))
  }
  if self.description != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.description),
    )
  }
  if self.data_type != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.data_type))
  }
  for s in self.type_params {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  for s in self.index_params {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(s))
  }
  if self.auto_id != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.auto_id))
  }
  if self.state != Default::default() {
    size += @lib.size_of_field(9U, @lib.size_of(self.state))
  }
  if self.element_type != Default::default() {
    size += @lib.size_of_field(10U, @lib.size_of(self.element_type))
  }
  if self.default_value is Some(v) {
    size += @lib.size_of_length_delimited_field(11U, @lib.size_of(v))
  }
  if self.is_dynamic != Default::default() {
    size += @lib.size_of_field(12U, @lib.size_of(self.is_dynamic))
  }
  if self.is_partition_key != Default::default() {
    size += @lib.size_of_field(13U, @lib.size_of(self.is_partition_key))
  }
  if self.is_clustering_key != Default::default() {
    size += @lib.size_of_field(14U, @lib.size_of(self.is_clustering_key))
  }
  if self.nullable != Default::default() {
    size += @lib.size_of_field(15U, @lib.size_of(self.nullable))
  }
  if self.is_function_output != Default::default() {
    size += @lib.size_of_field(16U, @lib.size_of(self.is_function_output))
  }
  if self.external_field != Default::default() {
    size += @lib.size_of_length_delimited_field(
      17U,
      @lib.size_of(self.external_field),
    )
  }
  if self.type_schema is Some(v) {
    size += @lib.size_of_length_delimited_field(18U, @lib.size_of(v))
  }
  if self.element_nullable != Default::default() {
    size += @lib.size_of_field(19U, @lib.size_of(self.element_nullable))
  }
  size
}

///|
pub impl Default for FieldSchema with fn default() -> FieldSchema {
  FieldSchema::{
    field_id: Default::default(),
    name: Default::default(),
    is_primary_key: Default::default(),
    description: Default::default(),
    data_type: Default::default(),
    type_params: [],
    index_params: [],
    auto_id: Default::default(),
    state: Default::default(),
    element_type: Default::default(),
    default_value: None,
    is_dynamic: Default::default(),
    is_partition_key: Default::default(),
    is_clustering_key: Default::default(),
    nullable: Default::default(),
    is_function_output: Default::default(),
    external_field: Default::default(),
    type_schema: None,
    element_nullable: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn FieldSchema::FieldSchema(
  field_id : Int64,
  name : String,
  is_primary_key : Bool,
  description : String,
  data_type : DataType,
  type_params : Array[@common.KeyValuePair],
  index_params : Array[@common.KeyValuePair],
  auto_id : Bool,
  state : FieldState,
  element_type : DataType,
  default_value? : ValueField,
  is_dynamic : Bool,
  is_partition_key : Bool,
  is_clustering_key : Bool,
  nullable : Bool,
  is_function_output : Bool,
  external_field : String,
  type_schema? : TypeSchema,
  element_nullable : Bool,
) -> FieldSchema {
  FieldSchema::{
    field_id,
    name,
    is_primary_key,
    description,
    data_type,
    type_params,
    index_params,
    auto_id,
    state,
    element_type,
    default_value,
    is_dynamic,
    is_partition_key,
    is_clustering_key,
    nullable,
    is_function_output,
    external_field,
    type_schema,
    element_nullable,
  }
}

///|
pub impl @lib.Read for FieldSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FieldSchema raise {
  let msg : FieldSchema = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.field_id = reader |> @lib.read_int64()
      (2, _) => msg.name = reader |> @lib.read_string()
      (3, _) => msg.is_primary_key = reader |> @lib.read_bool()
      (4, _) => msg.description = reader |> @lib.read_string()
      (5, _) =>
        msg.data_type = reader |> @lib.read_enum() |> DataType::from_enum
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.type_params.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.index_params.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (8, _) => msg.auto_id = reader |> @lib.read_bool()
      (9, _) => msg.state = reader |> @lib.read_enum() |> FieldState::from_enum
      (10, _) =>
        msg.element_type = reader |> @lib.read_enum() |> DataType::from_enum
      (11, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.default_value = (reader |> @lib.read_message() : ValueField) |> Some
      (12, _) => msg.is_dynamic = reader |> @lib.read_bool()
      (13, _) => msg.is_partition_key = reader |> @lib.read_bool()
      (14, _) => msg.is_clustering_key = reader |> @lib.read_bool()
      (15, _) => msg.nullable = reader |> @lib.read_bool()
      (16, _) => msg.is_function_output = reader |> @lib.read_bool()
      (17, _) => msg.external_field = reader |> @lib.read_string()
      (18, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.type_schema = (reader |> @lib.read_message() : TypeSchema) |> Some
      (19, _) => msg.element_nullable = reader |> @lib.read_bool()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FieldSchema with fn write(
  self : FieldSchema,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.field_id != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int64(self.field_id)
  }
  if self.name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.name)
  }
  if self.is_primary_key != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_bool(self.is_primary_key)
  }
  if self.description != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.description)
  }
  if self.data_type != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_enum(self.data_type.to_enum())
  }
  for item in self.type_params {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_message(item)
  }
  for item in self.index_params {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_message(item)
  }
  if self.auto_id != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_bool(self.auto_id)
  }
  if self.state != Default::default() {
    writer |> @lib.write_varint(72UL)
    writer |> @lib.write_enum(self.state.to_enum())
  }
  if self.element_type != Default::default() {
    writer |> @lib.write_varint(80UL)
    writer |> @lib.write_enum(self.element_type.to_enum())
  }
  if self.default_value is Some(v) {
    writer |> @lib.write_varint(90UL)
    writer |> @lib.write_message(v)
  }
  if self.is_dynamic != Default::default() {
    writer |> @lib.write_varint(96UL)
    writer |> @lib.write_bool(self.is_dynamic)
  }
  if self.is_partition_key != Default::default() {
    writer |> @lib.write_varint(104UL)
    writer |> @lib.write_bool(self.is_partition_key)
  }
  if self.is_clustering_key != Default::default() {
    writer |> @lib.write_varint(112UL)
    writer |> @lib.write_bool(self.is_clustering_key)
  }
  if self.nullable != Default::default() {
    writer |> @lib.write_varint(120UL)
    writer |> @lib.write_bool(self.nullable)
  }
  if self.is_function_output != Default::default() {
    writer |> @lib.write_varint(128UL)
    writer |> @lib.write_bool(self.is_function_output)
  }
  if self.external_field != Default::default() {
    writer |> @lib.write_varint(138UL)
    writer |> @lib.write_string(self.external_field)
  }
  if self.type_schema is Some(v) {
    writer |> @lib.write_varint(146UL)
    writer |> @lib.write_message(v)
  }
  if self.element_nullable != Default::default() {
    writer |> @lib.write_varint(152UL)
    writer |> @lib.write_bool(self.element_nullable)
  }
}

///|
pub impl ToJson for FieldSchema with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.field_id != Default::default() {
    json["fieldID"] = ToJson::to_json(self.field_id)
  }
  if self.name != Default::default() {
    json["name"] = ToJson::to_json(self.name)
  }
  if self.is_primary_key != Default::default() {
    json["isPrimaryKey"] = ToJson::to_json(self.is_primary_key)
  }
  if self.description != Default::default() {
    json["description"] = ToJson::to_json(self.description)
  }
  if self.data_type != Default::default() {
    json["dataType"] = ToJson::to_json(self.data_type)
  }
  if self.type_params != Default::default() {
    json["typeParams"] = ToJson::to_json(self.type_params)
  }
  if self.index_params != Default::default() {
    json["indexParams"] = ToJson::to_json(self.index_params)
  }
  if self.auto_id != Default::default() {
    json["autoID"] = ToJson::to_json(self.auto_id)
  }
  if self.state != Default::default() {
    json["state"] = ToJson::to_json(self.state)
  }
  if self.element_type != Default::default() {
    json["elementType"] = ToJson::to_json(self.element_type)
  }
  match self.default_value {
    Some(v) => json["defaultValue"] = ToJson::to_json(v)
    _ => ()
  }
  if self.is_dynamic != Default::default() {
    json["isDynamic"] = ToJson::to_json(self.is_dynamic)
  }
  if self.is_partition_key != Default::default() {
    json["isPartitionKey"] = ToJson::to_json(self.is_partition_key)
  }
  if self.is_clustering_key != Default::default() {
    json["isClusteringKey"] = ToJson::to_json(self.is_clustering_key)
  }
  if self.nullable != Default::default() {
    json["nullable"] = ToJson::to_json(self.nullable)
  }
  if self.is_function_output != Default::default() {
    json["isFunctionOutput"] = ToJson::to_json(self.is_function_output)
  }
  if self.external_field != Default::default() {
    json["externalField"] = ToJson::to_json(self.external_field)
  }
  match self.type_schema {
    Some(v) => json["typeSchema"] = ToJson::to_json(v)
    _ => ()
  }
  if self.element_nullable != Default::default() {
    json["elementNullable"] = ToJson::to_json(self.element_nullable)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FieldSchema with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FieldSchema raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FieldSchema"))
  }
  let message : FieldSchema = Default::default()
  for key, value in obj {
    match (key, value) {
      ("fieldID", value) => message.field_id = @json.from_json(value, path~)
      ("name", value) => message.name = @json.from_json(value, path~)
      ("isPrimaryKey", value) =>
        message.is_primary_key = @json.from_json(value, path~)
      ("description", value) =>
        message.description = @json.from_json(value, path~)
      ("dataType", value) => message.data_type = @json.from_json(value, path~)
      ("typeParams", Array(value)) =>
        message.type_params = value.map(v => @json.from_json(v, path~))
      ("indexParams", Array(value)) =>
        message.index_params = value.map(v => @json.from_json(v, path~))
      ("autoID", value) => message.auto_id = @json.from_json(value, path~)
      ("state", value) => message.state = @json.from_json(value, path~)
      ("elementType", value) =>
        message.element_type = @json.from_json(value, path~)
      ("defaultValue", value) =>
        message.default_value = Some(@json.from_json(value, path~))
      ("isDynamic", value) => message.is_dynamic = @json.from_json(value, path~)
      ("isPartitionKey", value) =>
        message.is_partition_key = @json.from_json(value, path~)
      ("isClusteringKey", value) =>
        message.is_clustering_key = @json.from_json(value, path~)
      ("nullable", value) => message.nullable = @json.from_json(value, path~)
      ("isFunctionOutput", value) =>
        message.is_function_output = @json.from_json(value, path~)
      ("externalField", value) =>
        message.external_field = @json.from_json(value, path~)
      ("typeSchema", value) =>
        message.type_schema = Some(@json.from_json(value, path~))
      ("elementNullable", value) =>
        message.element_nullable = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FieldSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FieldSchema raise {
  let msg : FieldSchema = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.field_id = reader |> @lib.async_read_int64()
      (2, _) => msg.name = reader |> @lib.async_read_string()
      (3, _) => msg.is_primary_key = reader |> @lib.async_read_bool()
      (4, _) => msg.description = reader |> @lib.async_read_string()
      (5, _) =>
        msg.data_type = reader |> @lib.async_read_enum() |> DataType::from_enum
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.type_params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.index_params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (8, _) => msg.auto_id = reader |> @lib.async_read_bool()
      (9, _) =>
        msg.state = reader |> @lib.async_read_enum() |> FieldState::from_enum
      (10, _) =>
        msg.element_type = reader
          |> @lib.async_read_enum()
          |> DataType::from_enum
      (11, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.default_value = (reader |> @lib.async_read_message() : ValueField)
          |> Some
      (12, _) => msg.is_dynamic = reader |> @lib.async_read_bool()
      (13, _) => msg.is_partition_key = reader |> @lib.async_read_bool()
      (14, _) => msg.is_clustering_key = reader |> @lib.async_read_bool()
      (15, _) => msg.nullable = reader |> @lib.async_read_bool()
      (16, _) => msg.is_function_output = reader |> @lib.async_read_bool()
      (17, _) => msg.external_field = reader |> @lib.async_read_string()
      (18, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.type_schema = (reader |> @lib.async_read_message() : TypeSchema)
          |> Some
      (19, _) => msg.element_nullable = reader |> @lib.async_read_bool()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FieldSchema with fn write(
  self : FieldSchema,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.field_id != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int64(self.field_id)
  }
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.is_primary_key != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_bool(self.is_primary_key)
  }
  if self.description != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.description)
  }
  if self.data_type != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_enum(self.data_type.to_enum())
  }
  for item in self.type_params {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.index_params {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_message(item)
  }
  if self.auto_id != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_bool(self.auto_id)
  }
  if self.state != Default::default() {
    writer |> @lib.async_write_varint(72UL)
    writer |> @lib.async_write_enum(self.state.to_enum())
  }
  if self.element_type != Default::default() {
    writer |> @lib.async_write_varint(80UL)
    writer |> @lib.async_write_enum(self.element_type.to_enum())
  }
  if self.default_value is Some(v) {
    writer |> @lib.async_write_varint(90UL)
    writer |> @lib.async_write_message(v)
  }
  if self.is_dynamic != Default::default() {
    writer |> @lib.async_write_varint(96UL)
    writer |> @lib.async_write_bool(self.is_dynamic)
  }
  if self.is_partition_key != Default::default() {
    writer |> @lib.async_write_varint(104UL)
    writer |> @lib.async_write_bool(self.is_partition_key)
  }
  if self.is_clustering_key != Default::default() {
    writer |> @lib.async_write_varint(112UL)
    writer |> @lib.async_write_bool(self.is_clustering_key)
  }
  if self.nullable != Default::default() {
    writer |> @lib.async_write_varint(120UL)
    writer |> @lib.async_write_bool(self.nullable)
  }
  if self.is_function_output != Default::default() {
    writer |> @lib.async_write_varint(128UL)
    writer |> @lib.async_write_bool(self.is_function_output)
  }
  if self.external_field != Default::default() {
    writer |> @lib.async_write_varint(138UL)
    writer |> @lib.async_write_string(self.external_field)
  }
  if self.type_schema is Some(v) {
    writer |> @lib.async_write_varint(146UL)
    writer |> @lib.async_write_message(v)
  }
  if self.element_nullable != Default::default() {
    writer |> @lib.async_write_varint(152UL)
    writer |> @lib.async_write_bool(self.element_nullable)
  }
}

///|
pub(all) struct FunctionSchema {
  mut name : String
  mut id : Int64
  mut description : String
  mut type_ : FunctionType
  mut input_field_names : Array[String]
  mut input_field_ids : Array[Int64]
  mut output_field_names : Array[String]
  mut output_field_ids : Array[Int64]
  mut params : Array[@common.KeyValuePair]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FunctionSchema with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  if self.id != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.id))
  }
  if self.description != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.description),
    )
  }
  if self.type_ != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.type_))
  }
  for s in self.input_field_names {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  if !self.input_field_ids.is_empty() {
    size += @lib.size_of_length_delimited_field(
      6U,
      self.input_field_ids.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  for s in self.output_field_names {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(s))
  }
  if !self.output_field_ids.is_empty() {
    size += @lib.size_of_length_delimited_field(
      8U,
      self.output_field_ids.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  for s in self.params {
    size += @lib.size_of_length_delimited_field(9U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for FunctionSchema with fn default() -> FunctionSchema {
  FunctionSchema::{
    name: Default::default(),
    id: Default::default(),
    description: Default::default(),
    type_: Default::default(),
    input_field_names: [],
    input_field_ids: [],
    output_field_names: [],
    output_field_ids: [],
    params: [],
  }
}

///|
#alias(new, deprecated)
pub fn FunctionSchema::FunctionSchema(
  name : String,
  id : Int64,
  description : String,
  type_ : FunctionType,
  input_field_names : Array[String],
  input_field_ids : Array[Int64],
  output_field_names : Array[String],
  output_field_ids : Array[Int64],
  params : Array[@common.KeyValuePair],
) -> FunctionSchema {
  FunctionSchema::{
    name,
    id,
    description,
    type_,
    input_field_names,
    input_field_ids,
    output_field_names,
    output_field_ids,
    params,
  }
}

///|
pub impl @lib.Read for FunctionSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FunctionSchema raise {
  let msg : FunctionSchema = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.id = reader |> @lib.read_int64()
      (3, _) => msg.description = reader |> @lib.read_string()
      (4, _) =>
        msg.type_ = reader |> @lib.read_enum() |> FunctionType::from_enum
      (5, _) => msg.input_field_names.push(reader |> @lib.read_string())
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.input_field_ids.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.input_field_ids.push(reader |> @lib.read_int64())
      (7, _) => msg.output_field_names.push(reader |> @lib.read_string())
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.output_field_ids.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (8, @lib.WIRE_TYPE_VARINT) =>
        msg.output_field_ids.push(reader |> @lib.read_int64())
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.params.push((reader |> @lib.read_message() : @common.KeyValuePair))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FunctionSchema with fn write(
  self : FunctionSchema,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  if self.id != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.id)
  }
  if self.description != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.description)
  }
  if self.type_ != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_enum(self.type_.to_enum())
  }
  for item in self.input_field_names {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(item)
  }
  if !self.input_field_ids.is_empty() {
    writer |> @lib.write_varint(50UL)
    let size = self.input_field_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.input_field_ids {
      writer |> @lib.write_int64(item)
    }
  }
  for item in self.output_field_names {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_string(item)
  }
  if !self.output_field_ids.is_empty() {
    writer |> @lib.write_varint(66UL)
    let size = self.output_field_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.output_field_ids {
      writer |> @lib.write_int64(item)
    }
  }
  for item in self.params {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_message(item)
  }
}

///|
pub impl ToJson for FunctionSchema with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.name != Default::default() {
    json["name"] = ToJson::to_json(self.name)
  }
  if self.id != Default::default() {
    json["id"] = ToJson::to_json(self.id)
  }
  if self.description != Default::default() {
    json["description"] = ToJson::to_json(self.description)
  }
  if self.type_ != Default::default() {
    json["type"] = ToJson::to_json(self.type_)
  }
  if self.input_field_names != Default::default() {
    json["inputFieldNames"] = ToJson::to_json(self.input_field_names)
  }
  if self.input_field_ids != Default::default() {
    json["inputFieldIds"] = ToJson::to_json(self.input_field_ids)
  }
  if self.output_field_names != Default::default() {
    json["outputFieldNames"] = ToJson::to_json(self.output_field_names)
  }
  if self.output_field_ids != Default::default() {
    json["outputFieldIds"] = ToJson::to_json(self.output_field_ids)
  }
  if self.params != Default::default() {
    json["params"] = ToJson::to_json(self.params)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FunctionSchema with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FunctionSchema raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FunctionSchema"))
  }
  let message : FunctionSchema = Default::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("id", value) => message.id = @json.from_json(value, path~)
      ("description", value) =>
        message.description = @json.from_json(value, path~)
      ("type", value) => message.type_ = @json.from_json(value, path~)
      ("inputFieldNames", Array(value)) =>
        message.input_field_names = value.map(v => @json.from_json(v, path~))
      ("inputFieldIds", Array(value)) =>
        message.input_field_ids = value.map(v => @json.from_json(v, path~))
      ("outputFieldNames", Array(value)) =>
        message.output_field_names = value.map(v => @json.from_json(v, path~))
      ("outputFieldIds", Array(value)) =>
        message.output_field_ids = value.map(v => @json.from_json(v, path~))
      ("params", Array(value)) =>
        message.params = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FunctionSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FunctionSchema raise {
  let msg : FunctionSchema = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.id = reader |> @lib.async_read_int64()
      (3, _) => msg.description = reader |> @lib.async_read_string()
      (4, _) =>
        msg.type_ = reader |> @lib.async_read_enum() |> FunctionType::from_enum
      (5, _) => msg.input_field_names.push(reader |> @lib.async_read_string())
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.input_field_ids.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.input_field_ids.push(reader |> @lib.async_read_int64())
      (7, _) => msg.output_field_names.push(reader |> @lib.async_read_string())
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.output_field_ids.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (8, @lib.WIRE_TYPE_VARINT) =>
        msg.output_field_ids.push(reader |> @lib.async_read_int64())
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FunctionSchema with fn write(
  self : FunctionSchema,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.id != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.id)
  }
  if self.description != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.description)
  }
  if self.type_ != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_enum(self.type_.to_enum())
  }
  for item in self.input_field_names {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(item)
  }
  if !self.input_field_ids.is_empty() {
    writer |> @lib.async_write_varint(50UL)
    let size = self.input_field_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.input_field_ids {
      writer |> @lib.async_write_int64(item)
    }
  }
  for item in self.output_field_names {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_string(item)
  }
  if !self.output_field_ids.is_empty() {
    writer |> @lib.async_write_varint(66UL)
    let size = self.output_field_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.output_field_ids {
      writer |> @lib.async_write_int64(item)
    }
  }
  for item in self.params {
    writer |> @lib.async_write_varint(74UL)
    writer |> @lib.async_write_message(item)
  }
}

///|
pub(all) struct HashRouting {
  mut buckets : Array[UInt64]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for HashRouting with fn size_of(self) {
  let mut size = 0U
  if !self.buckets.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.buckets.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  size
}

///|
pub impl Default for HashRouting with fn default() -> HashRouting {
  HashRouting::{ buckets: [], }
}

///|
#alias(new, deprecated)
pub fn HashRouting::HashRouting(buckets : Array[UInt64]) -> HashRouting {
  HashRouting::{ buckets, }
}

///|
pub impl @lib.Read for HashRouting with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> HashRouting raise {
  let msg : HashRouting = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.buckets.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.buckets.push(reader |> @lib.read_uint64())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for HashRouting with fn write(
  self : HashRouting,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.buckets.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.buckets.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.buckets {
      writer |> @lib.write_uint64(item)
    }
  }
}

///|
pub impl ToJson for HashRouting with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.buckets != Default::default() {
    json["buckets"] = ToJson::to_json(self.buckets)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for HashRouting with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> HashRouting raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for HashRouting"))
  }
  let message : HashRouting = Default::default()
  for key, value in obj {
    match (key, value) {
      ("buckets", Array(value)) =>
        message.buckets = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for HashRouting with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> HashRouting raise {
  let msg : HashRouting = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.buckets.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.buckets.push(reader |> @lib.async_read_uint64())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for HashRouting with fn write(
  self : HashRouting,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.buckets.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.buckets.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.buckets {
      writer |> @lib.async_write_uint64(item)
    }
  }
}

///|
pub(all) struct StructArrayFieldSchema {
  mut field_id : Int64
  mut name : String
  mut description : String
  mut fields : Array[FieldSchema]
  mut type_params : Array[@common.KeyValuePair]
  mut nullable : Bool
} derive(Eq, Debug)

///|
pub impl @lib.Sized for StructArrayFieldSchema with fn size_of(self) {
  let mut size = 0U
  if self.field_id != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.field_id))
  }
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.name))
  }
  if self.description != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.description),
    )
  }
  for s in self.fields {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  for s in self.type_params {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  if self.nullable != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.nullable))
  }
  size
}

///|
pub impl Default for StructArrayFieldSchema with fn default() -> StructArrayFieldSchema {
  StructArrayFieldSchema::{
    field_id: Default::default(),
    name: Default::default(),
    description: Default::default(),
    fields: [],
    type_params: [],
    nullable: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn StructArrayFieldSchema::StructArrayFieldSchema(
  field_id : Int64,
  name : String,
  description : String,
  fields : Array[FieldSchema],
  type_params : Array[@common.KeyValuePair],
  nullable : Bool,
) -> StructArrayFieldSchema {
  StructArrayFieldSchema::{
    field_id,
    name,
    description,
    fields,
    type_params,
    nullable,
  }
}

///|
pub impl @lib.Read for StructArrayFieldSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> StructArrayFieldSchema raise {
  let msg : StructArrayFieldSchema = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.field_id = reader |> @lib.read_int64()
      (2, _) => msg.name = reader |> @lib.read_string()
      (3, _) => msg.description = reader |> @lib.read_string()
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields.push((reader |> @lib.read_message() : FieldSchema))
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.type_params.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (6, _) => msg.nullable = reader |> @lib.read_bool()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for StructArrayFieldSchema with fn write(
  self : StructArrayFieldSchema,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.field_id != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int64(self.field_id)
  }
  if self.name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.name)
  }
  if self.description != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.description)
  }
  for item in self.fields {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
  for item in self.type_params {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(item)
  }
  if self.nullable != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_bool(self.nullable)
  }
}

///|
pub impl ToJson for StructArrayFieldSchema with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.field_id != Default::default() {
    json["fieldID"] = ToJson::to_json(self.field_id)
  }
  if self.name != Default::default() {
    json["name"] = ToJson::to_json(self.name)
  }
  if self.description != Default::default() {
    json["description"] = ToJson::to_json(self.description)
  }
  if self.fields != Default::default() {
    json["fields"] = ToJson::to_json(self.fields)
  }
  if self.type_params != Default::default() {
    json["typeParams"] = ToJson::to_json(self.type_params)
  }
  if self.nullable != Default::default() {
    json["nullable"] = ToJson::to_json(self.nullable)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for StructArrayFieldSchema with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> StructArrayFieldSchema raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for StructArrayFieldSchema"),
    )
  }
  let message : StructArrayFieldSchema = Default::default()
  for key, value in obj {
    match (key, value) {
      ("fieldID", value) => message.field_id = @json.from_json(value, path~)
      ("name", value) => message.name = @json.from_json(value, path~)
      ("description", value) =>
        message.description = @json.from_json(value, path~)
      ("fields", Array(value)) =>
        message.fields = value.map(v => @json.from_json(v, path~))
      ("typeParams", Array(value)) =>
        message.type_params = value.map(v => @json.from_json(v, path~))
      ("nullable", value) => message.nullable = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for StructArrayFieldSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> StructArrayFieldSchema raise {
  let msg : StructArrayFieldSchema = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.field_id = reader |> @lib.async_read_int64()
      (2, _) => msg.name = reader |> @lib.async_read_string()
      (3, _) => msg.description = reader |> @lib.async_read_string()
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields.push((reader |> @lib.async_read_message() : FieldSchema))
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.type_params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (6, _) => msg.nullable = reader |> @lib.async_read_bool()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for StructArrayFieldSchema with fn write(
  self : StructArrayFieldSchema,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.field_id != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int64(self.field_id)
  }
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.description != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.description)
  }
  for item in self.fields {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.type_params {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(item)
  }
  if self.nullable != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_bool(self.nullable)
  }
}

///|
pub(all) struct TypeSchema {
  mut type_params : Array[@common.KeyValuePair]
  mut nullable : Bool
  mut kind : TypeSchema_Kind
} derive(Eq, Debug)

///|
pub(all) enum TypeSchema_Kind {
  LeafType(DataType)
  ArrayElement(TypeSchema)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for TypeSchema_Kind with fn default() -> TypeSchema_Kind {
  NotSet
}

///|
pub impl @json.FromJson for TypeSchema_Kind with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> TypeSchema_Kind raise {
  try TypeSchema_Kind::LeafType(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try TypeSchema_Kind::ArrayElement(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  TypeSchema_Kind::NotSet
}

///|
pub impl ToJson for TypeSchema_Kind with fn to_json(self : TypeSchema_Kind) -> Json {
  match self {
    TypeSchema_Kind::LeafType(v) => ToJson::to_json(v)
    TypeSchema_Kind::ArrayElement(v) => ToJson::to_json(v)
    TypeSchema_Kind::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for TypeSchema with fn size_of(self) {
  let mut size = 0U
  for s in self.type_params {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  if self.nullable != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.nullable))
  }
  match self.kind {
    LeafType(v) => size += @lib.size_of_field(1U, @lib.size_of(v))
    ArrayElement(v) =>
      size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for TypeSchema with fn default() -> TypeSchema {
  TypeSchema::{
    type_params: [],
    nullable: Default::default(),
    kind: TypeSchema_Kind::NotSet,
  }
}

///|
#alias(new, deprecated)
pub fn TypeSchema::TypeSchema(
  type_params : Array[@common.KeyValuePair],
  nullable : Bool,
  kind? : TypeSchema_Kind = TypeSchema_Kind::NotSet,
) -> TypeSchema {
  TypeSchema::{ type_params, nullable, kind, }
}

///|
pub impl @lib.Read for TypeSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> TypeSchema raise {
  let msg : TypeSchema = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.type_params.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (4, _) => msg.nullable = reader |> @lib.read_bool()
      (1, _) =>
        msg.kind = reader
          |> @lib.read_enum()
          |> DataType::from_enum
          |> TypeSchema_Kind::LeafType
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.kind = (reader |> @lib.read_message() : TypeSchema)
          |> TypeSchema_Kind::ArrayElement
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for TypeSchema with fn write(
  self : TypeSchema,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.type_params {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
  if self.nullable != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_bool(self.nullable)
  }
  match self.kind {
    TypeSchema_Kind::LeafType(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    TypeSchema_Kind::ArrayElement(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_message(v)
    }
    TypeSchema_Kind::NotSet => ()
  }
}

///|
pub impl ToJson for TypeSchema with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.type_params != Default::default() {
    json["typeParams"] = ToJson::to_json(self.type_params)
  }
  if self.nullable != Default::default() {
    json["nullable"] = ToJson::to_json(self.nullable)
  }
  match self.kind {
    NotSet => ()
    LeafType(v) => json["leafType"] = ToJson::to_json(v)
    ArrayElement(v) => json["arrayElement"] = ToJson::to_json(v)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for TypeSchema with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> TypeSchema raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for TypeSchema"))
  }
  let message : TypeSchema = Default::default()
  for key, value in obj {
    match (key, value) {
      ("typeParams", Array(value)) =>
        message.type_params = value.map(v => @json.from_json(v, path~))
      ("nullable", value) => message.nullable = @json.from_json(value, path~)
      ("leafType", value) => message.kind = @json.from_json(value, path~)
      ("arrayElement", value) => message.kind = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for TypeSchema with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> TypeSchema raise {
  let msg : TypeSchema = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.type_params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (4, _) => msg.nullable = reader |> @lib.async_read_bool()
      (1, _) =>
        msg.kind = reader
          |> @lib.async_read_enum()
          |> DataType::from_enum
          |> TypeSchema_Kind::LeafType
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.kind = (reader |> @lib.async_read_message() : TypeSchema)
          |> TypeSchema_Kind::ArrayElement
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for TypeSchema with fn write(
  self : TypeSchema,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.type_params {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
  if self.nullable != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_bool(self.nullable)
  }
  match self.kind {
    TypeSchema_Kind::LeafType(v) => {
      writer |> @lib.async_write_varint(8UL)
      writer |> @lib.async_write_enum(v.to_enum())
    }
    TypeSchema_Kind::ArrayElement(v) => {
      writer |> @lib.async_write_varint(18UL)
      writer |> @lib.async_write_message(v)
    }
    TypeSchema_Kind::NotSet => ()
  }
}

///|
pub(all) struct ValueField {
  mut data : ValueField_Data
} derive(Eq, Debug)

///|
pub(all) enum ValueField_Data {
  BoolData(Bool)
  IntData(Int)
  LongData(Int64)
  FloatData(Float)
  DoubleData(Double)
  StringData(String)
  BytesData(Bytes)
  TimestamptzData(Int64)
  DateData(Int)
  TimeData(Int64)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for ValueField_Data with fn default() -> ValueField_Data {
  NotSet
}

///|
pub impl @json.FromJson for ValueField_Data with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ValueField_Data raise {
  try ValueField_Data::BoolData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::IntData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::LongData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::FloatData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::DoubleData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::StringData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::BytesData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::TimestamptzData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::DateData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ValueField_Data::TimeData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  ValueField_Data::NotSet
}

///|
pub impl ToJson for ValueField_Data with fn to_json(self : ValueField_Data) -> Json {
  match self {
    ValueField_Data::BoolData(v) => ToJson::to_json(v)
    ValueField_Data::IntData(v) => ToJson::to_json(v)
    ValueField_Data::LongData(v) => ToJson::to_json(v)
    ValueField_Data::FloatData(v) => ToJson::to_json(v)
    ValueField_Data::DoubleData(v) => ToJson::to_json(v)
    ValueField_Data::StringData(v) => ToJson::to_json(v)
    ValueField_Data::BytesData(v) => ToJson::to_json(v)
    ValueField_Data::TimestamptzData(v) => ToJson::to_json(v)
    ValueField_Data::DateData(v) => ToJson::to_json(v)
    ValueField_Data::TimeData(v) => ToJson::to_json(v)
    ValueField_Data::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for ValueField with fn size_of(self) {
  let mut size = 0U
  match self.data {
    BoolData(v) => size += @lib.size_of_field(1U, @lib.size_of(v))
    IntData(v) => size += @lib.size_of_field(2U, @lib.size_of(v))
    LongData(v) => size += @lib.size_of_field(3U, @lib.size_of(v))
    FloatData(_) => size += @lib.size_of_field(4U, 4U)
    DoubleData(_) => size += @lib.size_of_field(5U, 8U)
    StringData(v) =>
      size += @lib.size_of_length_delimited_field(6U, @lib.size_of(v))
    BytesData(v) =>
      size += @lib.size_of_length_delimited_field(7U, @lib.size_of(v))
    TimestamptzData(v) => size += @lib.size_of_field(8U, @lib.size_of(v))
    DateData(v) => size += @lib.size_of_field(9U, @lib.size_of(v))
    TimeData(v) => size += @lib.size_of_field(10U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for ValueField with fn default() -> ValueField {
  ValueField::{ data: ValueField_Data::NotSet, }
}

///|
#alias(new, deprecated)
pub fn ValueField::ValueField(
  data? : ValueField_Data = ValueField_Data::NotSet,
) -> ValueField {
  ValueField::{ data, }
}

///|
pub impl @lib.Read for ValueField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ValueField raise {
  let msg : ValueField = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.data = reader |> @lib.read_bool() |> ValueField_Data::BoolData
      (2, _) =>
        msg.data = reader |> @lib.read_int32() |> ValueField_Data::IntData
      (3, _) =>
        msg.data = reader |> @lib.read_int64() |> ValueField_Data::LongData
      (4, _) =>
        msg.data = reader |> @lib.read_float() |> ValueField_Data::FloatData
      (5, _) =>
        msg.data = reader |> @lib.read_double() |> ValueField_Data::DoubleData
      (6, _) =>
        msg.data = reader |> @lib.read_string() |> ValueField_Data::StringData
      (7, _) =>
        msg.data = reader |> @lib.read_bytes() |> ValueField_Data::BytesData
      (8, _) =>
        msg.data = reader
          |> @lib.read_int64()
          |> ValueField_Data::TimestamptzData
      (9, _) =>
        msg.data = reader |> @lib.read_int32() |> ValueField_Data::DateData
      (10, _) =>
        msg.data = reader |> @lib.read_int64() |> ValueField_Data::TimeData
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ValueField with fn write(
  self : ValueField,
  writer : &@lib.Writer,
) -> Unit raise {
  match self.data {
    ValueField_Data::BoolData(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_bool(v)
    }
    ValueField_Data::IntData(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_int32(v)
    }
    ValueField_Data::LongData(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_int64(v)
    }
    ValueField_Data::FloatData(v) => {
      writer |> @lib.write_varint(37UL)
      writer |> @lib.write_float(v)
    }
    ValueField_Data::DoubleData(v) => {
      writer |> @lib.write_varint(41UL)
      writer |> @lib.write_double(v)
    }
    ValueField_Data::StringData(v) => {
      writer |> @lib.write_varint(50UL)
      writer |> @lib.write_string(v)
    }
    ValueField_Data::BytesData(v) => {
      writer |> @lib.write_varint(58UL)
      writer |> @lib.write_bytes(v)
    }
    ValueField_Data::TimestamptzData(v) => {
      writer |> @lib.write_varint(64UL)
      writer |> @lib.write_int64(v)
    }
    ValueField_Data::DateData(v) => {
      writer |> @lib.write_varint(72UL)
      writer |> @lib.write_int32(v)
    }
    ValueField_Data::TimeData(v) => {
      writer |> @lib.write_varint(80UL)
      writer |> @lib.write_int64(v)
    }
    ValueField_Data::NotSet => ()
  }
}

///|
pub impl ToJson for ValueField with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.data {
    NotSet => ()
    BoolData(v) => json["boolData"] = ToJson::to_json(v)
    IntData(v) => json["intData"] = ToJson::to_json(v)
    LongData(v) => json["longData"] = ToJson::to_json(v)
    FloatData(v) => json["floatData"] = ToJson::to_json(v)
    DoubleData(v) => json["doubleData"] = ToJson::to_json(v)
    StringData(v) => json["stringData"] = ToJson::to_json(v)
    BytesData(v) => json["bytesData"] = ToJson::to_json(v)
    TimestamptzData(v) => json["timestamptzData"] = ToJson::to_json(v)
    DateData(v) => json["dateData"] = ToJson::to_json(v)
    TimeData(v) => json["timeData"] = ToJson::to_json(v)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ValueField with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ValueField raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ValueField"))
  }
  let message : ValueField = Default::default()
  for key, value in obj {
    match (key, value) {
      ("boolData", value) => message.data = @json.from_json(value, path~)
      ("intData", value) => message.data = @json.from_json(value, path~)
      ("longData", value) => message.data = @json.from_json(value, path~)
      ("floatData", value) => message.data = @json.from_json(value, path~)
      ("doubleData", value) => message.data = @json.from_json(value, path~)
      ("stringData", value) => message.data = @json.from_json(value, path~)
      ("bytesData", value) => message.data = @json.from_json(value, path~)
      ("timestamptzData", value) => message.data = @json.from_json(value, path~)
      ("dateData", value) => message.data = @json.from_json(value, path~)
      ("timeData", value) => message.data = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ValueField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ValueField raise {
  let msg : ValueField = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.data = reader |> @lib.async_read_bool() |> ValueField_Data::BoolData
      (2, _) =>
        msg.data = reader |> @lib.async_read_int32() |> ValueField_Data::IntData
      (3, _) =>
        msg.data = reader
          |> @lib.async_read_int64()
          |> ValueField_Data::LongData
      (4, _) =>
        msg.data = reader
          |> @lib.async_read_float()
          |> ValueField_Data::FloatData
      (5, _) =>
        msg.data = reader
          |> @lib.async_read_double()
          |> ValueField_Data::DoubleData
      (6, _) =>
        msg.data = reader
          |> @lib.async_read_string()
          |> ValueField_Data::StringData
      (7, _) =>
        msg.data = reader
          |> @lib.async_read_bytes()
          |> ValueField_Data::BytesData
      (8, _) =>
        msg.data = reader
          |> @lib.async_read_int64()
          |> ValueField_Data::TimestamptzData
      (9, _) =>
        msg.data = reader
          |> @lib.async_read_int32()
          |> ValueField_Data::DateData
      (10, _) =>
        msg.data = reader
          |> @lib.async_read_int64()
          |> ValueField_Data::TimeData
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ValueField with fn write(
  self : ValueField,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  match self.data {
    ValueField_Data::BoolData(v) => {
      writer |> @lib.async_write_varint(8UL)
      writer |> @lib.async_write_bool(v)
    }
    ValueField_Data::IntData(v) => {
      writer |> @lib.async_write_varint(16UL)
      writer |> @lib.async_write_int32(v)
    }
    ValueField_Data::LongData(v) => {
      writer |> @lib.async_write_varint(24UL)
      writer |> @lib.async_write_int64(v)
    }
    ValueField_Data::FloatData(v) => {
      writer |> @lib.async_write_varint(37UL)
      writer |> @lib.async_write_float(v)
    }
    ValueField_Data::DoubleData(v) => {
      writer |> @lib.async_write_varint(41UL)
      writer |> @lib.async_write_double(v)
    }
    ValueField_Data::StringData(v) => {
      writer |> @lib.async_write_varint(50UL)
      writer |> @lib.async_write_string(v)
    }
    ValueField_Data::BytesData(v) => {
      writer |> @lib.async_write_varint(58UL)
      writer |> @lib.async_write_bytes(v)
    }
    ValueField_Data::TimestamptzData(v) => {
      writer |> @lib.async_write_varint(64UL)
      writer |> @lib.async_write_int64(v)
    }
    ValueField_Data::DateData(v) => {
      writer |> @lib.async_write_varint(72UL)
      writer |> @lib.async_write_int32(v)
    }
    ValueField_Data::TimeData(v) => {
      writer |> @lib.async_write_varint(80UL)
      writer |> @lib.async_write_int64(v)
    }
    ValueField_Data::NotSet => ()
  }
}

///|
pub(all) struct BoolArray {
  mut data : Array[Bool]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BoolArray with fn size_of(self) {
  let mut size = 0U
  if !self.data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  size
}

///|
pub impl Default for BoolArray with fn default() -> BoolArray {
  BoolArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn BoolArray::BoolArray(data : Array[Bool]) -> BoolArray {
  BoolArray::{ data, }
}

///|
pub impl @lib.Read for BoolArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BoolArray raise {
  let msg : BoolArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.read_packed(@lib.read_bool, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) => msg.data.push(reader |> @lib.read_bool())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BoolArray with fn write(
  self : BoolArray,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.data {
      writer |> @lib.write_bool(item)
    }
  }
}

///|
pub impl ToJson for BoolArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BoolArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BoolArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BoolArray"))
  }
  let message : BoolArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BoolArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BoolArray raise {
  let msg : BoolArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_bool, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.data.push(reader |> @lib.async_read_bool())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BoolArray with fn write(
  self : BoolArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.data {
      writer |> @lib.async_write_bool(item)
    }
  }
}

///|
pub(all) struct IntArray {
  mut data : Array[Int]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for IntArray with fn size_of(self) {
  let mut size = 0U
  if !self.data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  size
}

///|
pub impl Default for IntArray with fn default() -> IntArray {
  IntArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn IntArray::IntArray(data : Array[Int]) -> IntArray {
  IntArray::{ data, }
}

///|
pub impl @lib.Read for IntArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> IntArray raise {
  let msg : IntArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) => msg.data.push(reader |> @lib.read_int32())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for IntArray with fn write(
  self : IntArray,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.data {
      writer |> @lib.write_int32(item)
    }
  }
}

///|
pub impl ToJson for IntArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for IntArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> IntArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for IntArray"))
  }
  let message : IntArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for IntArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> IntArray raise {
  let msg : IntArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int32, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.data.push(reader |> @lib.async_read_int32())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for IntArray with fn write(
  self : IntArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.data {
      writer |> @lib.async_write_int32(item)
    }
  }
}

///|
pub(all) struct LongArray {
  mut data : Array[Int64]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for LongArray with fn size_of(self) {
  let mut size = 0U
  if !self.data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  size
}

///|
pub impl Default for LongArray with fn default() -> LongArray {
  LongArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn LongArray::LongArray(data : Array[Int64]) -> LongArray {
  LongArray::{ data, }
}

///|
pub impl @lib.Read for LongArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> LongArray raise {
  let msg : LongArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) => msg.data.push(reader |> @lib.read_int64())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for LongArray with fn write(
  self : LongArray,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.data {
      writer |> @lib.write_int64(item)
    }
  }
}

///|
pub impl ToJson for LongArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for LongArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> LongArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for LongArray"))
  }
  let message : LongArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for LongArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> LongArray raise {
  let msg : LongArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.data.push(reader |> @lib.async_read_int64())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for LongArray with fn write(
  self : LongArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.data {
      writer |> @lib.async_write_int64(item)
    }
  }
}

///|
pub(all) struct FloatArray {
  mut data : Array[Float]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FloatArray with fn size_of(self) {
  let mut size = 0U
  if !self.data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.data.length().reinterpret_as_uint() * 4,
    )
  }
  size
}

///|
pub impl Default for FloatArray with fn default() -> FloatArray {
  FloatArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn FloatArray::FloatArray(data : Array[Float]) -> FloatArray {
  FloatArray::{ data, }
}

///|
pub impl @lib.Read for FloatArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FloatArray raise {
  let msg : FloatArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.read_packed(@lib.read_float, Some(4))).iter(),
        )
      (1, @lib.WIRE_TYPE_FIXED32) => msg.data.push(reader |> @lib.read_float())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FloatArray with fn write(
  self : FloatArray,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.data.length().reinterpret_as_uint() * 4
    writer |> @lib.write_uint32(size)
    for item in self.data {
      writer |> @lib.write_float(item)
    }
  }
}

///|
pub impl ToJson for FloatArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FloatArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FloatArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FloatArray"))
  }
  let message : FloatArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => {
          Float::from_double(@json.from_json(v, path~))
        })
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FloatArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FloatArray raise {
  let msg : FloatArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_float, Some(4))).iter(),
        )
      (1, @lib.WIRE_TYPE_FIXED32) =>
        msg.data.push(reader |> @lib.async_read_float())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FloatArray with fn write(
  self : FloatArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.data.length().reinterpret_as_uint() * 4
    writer |> @lib.async_write_uint32(size)
    for item in self.data {
      writer |> @lib.async_write_float(item)
    }
  }
}

///|
pub(all) struct DoubleArray {
  mut data : Array[Double]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DoubleArray with fn size_of(self) {
  let mut size = 0U
  if !self.data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.data.length().reinterpret_as_uint() * 8,
    )
  }
  size
}

///|
pub impl Default for DoubleArray with fn default() -> DoubleArray {
  DoubleArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn DoubleArray::DoubleArray(data : Array[Double]) -> DoubleArray {
  DoubleArray::{ data, }
}

///|
pub impl @lib.Read for DoubleArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DoubleArray raise {
  let msg : DoubleArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.read_packed(@lib.read_double, Some(8))).iter(),
        )
      (1, @lib.WIRE_TYPE_FIXED64) => msg.data.push(reader |> @lib.read_double())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DoubleArray with fn write(
  self : DoubleArray,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.data.length().reinterpret_as_uint() * 8
    writer |> @lib.write_uint32(size)
    for item in self.data {
      writer |> @lib.write_double(item)
    }
  }
}

///|
pub impl ToJson for DoubleArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DoubleArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DoubleArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for DoubleArray"))
  }
  let message : DoubleArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DoubleArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DoubleArray raise {
  let msg : DoubleArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_double, Some(8))).iter(),
        )
      (1, @lib.WIRE_TYPE_FIXED64) =>
        msg.data.push(reader |> @lib.async_read_double())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DoubleArray with fn write(
  self : DoubleArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.data.length().reinterpret_as_uint() * 8
    writer |> @lib.async_write_uint32(size)
    for item in self.data {
      writer |> @lib.async_write_double(item)
    }
  }
}

///|
pub(all) struct BytesArray {
  mut data : Array[Bytes]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BytesArray with fn size_of(self) {
  let mut size = 0U
  for s in self.data {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for BytesArray with fn default() -> BytesArray {
  BytesArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn BytesArray::BytesArray(data : Array[Bytes]) -> BytesArray {
  BytesArray::{ data, }
}

///|
pub impl @lib.Read for BytesArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BytesArray raise {
  let msg : BytesArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.read_bytes())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BytesArray with fn write(
  self : BytesArray,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_bytes(item)
  }
}

///|
pub impl ToJson for BytesArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = self.data.map(@lib.base64_encode).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BytesArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BytesArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BytesArray"))
  }
  let message : BytesArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BytesArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BytesArray raise {
  let msg : BytesArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.async_read_bytes())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BytesArray with fn write(
  self : BytesArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_bytes(item)
  }
}

///|
pub(all) struct StringArray {
  mut data : Array[String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for StringArray with fn size_of(self) {
  let mut size = 0U
  for s in self.data {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for StringArray with fn default() -> StringArray {
  StringArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn StringArray::StringArray(data : Array[String]) -> StringArray {
  StringArray::{ data, }
}

///|
pub impl @lib.Read for StringArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> StringArray raise {
  let msg : StringArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.read_string())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for StringArray with fn write(
  self : StringArray,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(item)
  }
}

///|
pub impl ToJson for StringArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for StringArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> StringArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for StringArray"))
  }
  let message : StringArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for StringArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> StringArray raise {
  let msg : StringArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.async_read_string())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for StringArray with fn write(
  self : StringArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(item)
  }
}

///|
pub(all) struct UUIDArray {
  mut data : Array[Bytes]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for UUIDArray with fn size_of(self) {
  let mut size = 0U
  for s in self.data {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for UUIDArray with fn default() -> UUIDArray {
  UUIDArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn UUIDArray::UUIDArray(data : Array[Bytes]) -> UUIDArray {
  UUIDArray::{ data, }
}

///|
pub impl @lib.Read for UUIDArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> UUIDArray raise {
  let msg : UUIDArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.read_bytes())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for UUIDArray with fn write(
  self : UUIDArray,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_bytes(item)
  }
}

///|
pub impl ToJson for UUIDArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = self.data.map(@lib.base64_encode).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for UUIDArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> UUIDArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for UUIDArray"))
  }
  let message : UUIDArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for UUIDArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> UUIDArray raise {
  let msg : UUIDArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.async_read_bytes())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for UUIDArray with fn write(
  self : UUIDArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_bytes(item)
  }
}

///|
pub(all) struct ArrayArray {
  mut data : Array[ScalarField]
  mut element_type : DataType
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ArrayArray with fn size_of(self) {
  let mut size = 0U
  for s in self.data {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  if self.element_type != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.element_type))
  }
  size
}

///|
pub impl Default for ArrayArray with fn default() -> ArrayArray {
  ArrayArray::{ data: [], element_type: Default::default(), }
}

///|
#alias(new, deprecated)
pub fn ArrayArray::ArrayArray(
  data : Array[ScalarField],
  element_type : DataType,
) -> ArrayArray {
  ArrayArray::{ data, element_type, }
}

///|
pub impl @lib.Read for ArrayArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ArrayArray raise {
  let msg : ArrayArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push((reader |> @lib.read_message() : ScalarField))
      (2, _) =>
        msg.element_type = reader |> @lib.read_enum() |> DataType::from_enum
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ArrayArray with fn write(
  self : ArrayArray,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(item)
  }
  if self.element_type != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_enum(self.element_type.to_enum())
  }
}

///|
pub impl ToJson for ArrayArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  if self.element_type != Default::default() {
    json["elementType"] = ToJson::to_json(self.element_type)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ArrayArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ArrayArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ArrayArray"))
  }
  let message : ArrayArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      ("elementType", value) =>
        message.element_type = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ArrayArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ArrayArray raise {
  let msg : ArrayArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push((reader |> @lib.async_read_message() : ScalarField))
      (2, _) =>
        msg.element_type = reader
          |> @lib.async_read_enum()
          |> DataType::from_enum
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ArrayArray with fn write(
  self : ArrayArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(item)
  }
  if self.element_type != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_enum(self.element_type.to_enum())
  }
}

///|
pub(all) struct JSONArray {
  mut data : Array[Bytes]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for JSONArray with fn size_of(self) {
  let mut size = 0U
  for s in self.data {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for JSONArray with fn default() -> JSONArray {
  JSONArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn JSONArray::JSONArray(data : Array[Bytes]) -> JSONArray {
  JSONArray::{ data, }
}

///|
pub impl @lib.Read for JSONArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> JSONArray raise {
  let msg : JSONArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.read_bytes())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for JSONArray with fn write(
  self : JSONArray,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_bytes(item)
  }
}

///|
pub impl ToJson for JSONArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = self.data.map(@lib.base64_encode).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for JSONArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> JSONArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for JSONArray"))
  }
  let message : JSONArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for JSONArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> JSONArray raise {
  let msg : JSONArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.async_read_bytes())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for JSONArray with fn write(
  self : JSONArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_bytes(item)
  }
}

///|
pub(all) struct GeometryArray {
  mut data : Array[Bytes]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for GeometryArray with fn size_of(self) {
  let mut size = 0U
  for s in self.data {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for GeometryArray with fn default() -> GeometryArray {
  GeometryArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn GeometryArray::GeometryArray(data : Array[Bytes]) -> GeometryArray {
  GeometryArray::{ data, }
}

///|
pub impl @lib.Read for GeometryArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> GeometryArray raise {
  let msg : GeometryArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.read_bytes())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GeometryArray with fn write(
  self : GeometryArray,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_bytes(item)
  }
}

///|
pub impl ToJson for GeometryArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = self.data.map(@lib.base64_encode).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GeometryArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> GeometryArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for GeometryArray"))
  }
  let message : GeometryArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for GeometryArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> GeometryArray raise {
  let msg : GeometryArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.async_read_bytes())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for GeometryArray with fn write(
  self : GeometryArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_bytes(item)
  }
}

///|
pub(all) struct GeometryWktArray {
  mut data : Array[String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for GeometryWktArray with fn size_of(self) {
  let mut size = 0U
  for s in self.data {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for GeometryWktArray with fn default() -> GeometryWktArray {
  GeometryWktArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn GeometryWktArray::GeometryWktArray(
  data : Array[String],
) -> GeometryWktArray {
  GeometryWktArray::{ data, }
}

///|
pub impl @lib.Read for GeometryWktArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> GeometryWktArray raise {
  let msg : GeometryWktArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.read_string())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GeometryWktArray with fn write(
  self : GeometryWktArray,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(item)
  }
}

///|
pub impl ToJson for GeometryWktArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GeometryWktArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> GeometryWktArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GeometryWktArray"),
    )
  }
  let message : GeometryWktArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for GeometryWktArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> GeometryWktArray raise {
  let msg : GeometryWktArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.data.push(reader |> @lib.async_read_string())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for GeometryWktArray with fn write(
  self : GeometryWktArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.data {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(item)
  }
}

///|
pub(all) struct TimestamptzArray {
  mut data : Array[Int64]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for TimestamptzArray with fn size_of(self) {
  let mut size = 0U
  if !self.data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  size
}

///|
pub impl Default for TimestamptzArray with fn default() -> TimestamptzArray {
  TimestamptzArray::{ data: [], }
}

///|
#alias(new, deprecated)
pub fn TimestamptzArray::TimestamptzArray(
  data : Array[Int64],
) -> TimestamptzArray {
  TimestamptzArray::{ data, }
}

///|
pub impl @lib.Read for TimestamptzArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> TimestamptzArray raise {
  let msg : TimestamptzArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) => msg.data.push(reader |> @lib.read_int64())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for TimestamptzArray with fn write(
  self : TimestamptzArray,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.data {
      writer |> @lib.write_int64(item)
    }
  }
}

///|
pub impl ToJson for TimestamptzArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for TimestamptzArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> TimestamptzArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for TimestamptzArray"),
    )
  }
  let message : TimestamptzArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for TimestamptzArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> TimestamptzArray raise {
  let msg : TimestamptzArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.data.push(reader |> @lib.async_read_int64())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for TimestamptzArray with fn write(
  self : TimestamptzArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.data.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.data {
      writer |> @lib.async_write_int64(item)
    }
  }
}

///|
pub(all) struct ScalarField {
  mut valid_data : Array[Bool]
  mut data : ScalarField_Data
} derive(Eq, Debug)

///|
pub(all) enum ScalarField_Data {
  BoolData(BoolArray)
  IntData(IntArray)
  LongData(LongArray)
  FloatData(FloatArray)
  DoubleData(DoubleArray)
  StringData(StringArray)
  BytesData(BytesArray)
  ArrayData(ArrayArray)
  JsonData(JSONArray)
  GeometryData(GeometryArray)
  TimestamptzData(TimestamptzArray)
  GeometryWktData(GeometryWktArray)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for ScalarField_Data with fn default() -> ScalarField_Data {
  NotSet
}

///|
pub impl @json.FromJson for ScalarField_Data with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ScalarField_Data raise {
  try ScalarField_Data::BoolData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::IntData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::LongData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::FloatData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::DoubleData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::StringData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::BytesData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::ArrayData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::JsonData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::GeometryData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::TimestamptzData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try ScalarField_Data::GeometryWktData(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  ScalarField_Data::NotSet
}

///|
pub impl ToJson for ScalarField_Data with fn to_json(self : ScalarField_Data) -> Json {
  match self {
    ScalarField_Data::BoolData(v) => ToJson::to_json(v)
    ScalarField_Data::IntData(v) => ToJson::to_json(v)
    ScalarField_Data::LongData(v) => ToJson::to_json(v)
    ScalarField_Data::FloatData(v) => ToJson::to_json(v)
    ScalarField_Data::DoubleData(v) => ToJson::to_json(v)
    ScalarField_Data::StringData(v) => ToJson::to_json(v)
    ScalarField_Data::BytesData(v) => ToJson::to_json(v)
    ScalarField_Data::ArrayData(v) => ToJson::to_json(v)
    ScalarField_Data::JsonData(v) => ToJson::to_json(v)
    ScalarField_Data::GeometryData(v) => ToJson::to_json(v)
    ScalarField_Data::TimestamptzData(v) => ToJson::to_json(v)
    ScalarField_Data::GeometryWktData(v) => ToJson::to_json(v)
    ScalarField_Data::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for ScalarField with fn size_of(self) {
  let mut size = 0U
  if !self.valid_data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      17U,
      self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  match self.data {
    BoolData(v) =>
      size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
    IntData(v) =>
      size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    LongData(v) =>
      size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
    FloatData(v) =>
      size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
    DoubleData(v) =>
      size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
    StringData(v) =>
      size += @lib.size_of_length_delimited_field(6U, @lib.size_of(v))
    BytesData(v) =>
      size += @lib.size_of_length_delimited_field(7U, @lib.size_of(v))
    ArrayData(v) =>
      size += @lib.size_of_length_delimited_field(8U, @lib.size_of(v))
    JsonData(v) =>
      size += @lib.size_of_length_delimited_field(9U, @lib.size_of(v))
    GeometryData(v) =>
      size += @lib.size_of_length_delimited_field(10U, @lib.size_of(v))
    TimestamptzData(v) =>
      size += @lib.size_of_length_delimited_field(11U, @lib.size_of(v))
    GeometryWktData(v) =>
      size += @lib.size_of_length_delimited_field(12U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for ScalarField with fn default() -> ScalarField {
  ScalarField::{ valid_data: [], data: ScalarField_Data::NotSet, }
}

///|
#alias(new, deprecated)
pub fn ScalarField::ScalarField(
  valid_data : Array[Bool],
  data? : ScalarField_Data = ScalarField_Data::NotSet,
) -> ScalarField {
  ScalarField::{ valid_data, data, }
}

///|
pub impl @lib.Read for ScalarField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ScalarField raise {
  let msg : ScalarField = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (17, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.valid_data.push_iter(
          (reader |> @lib.read_packed(@lib.read_bool, None)).iter(),
        )
      (17, @lib.WIRE_TYPE_VARINT) =>
        msg.valid_data.push(reader |> @lib.read_bool())
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : BoolArray)
          |> ScalarField_Data::BoolData
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : IntArray)
          |> ScalarField_Data::IntData
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : LongArray)
          |> ScalarField_Data::LongData
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : FloatArray)
          |> ScalarField_Data::FloatData
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : DoubleArray)
          |> ScalarField_Data::DoubleData
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : StringArray)
          |> ScalarField_Data::StringData
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : BytesArray)
          |> ScalarField_Data::BytesData
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : ArrayArray)
          |> ScalarField_Data::ArrayData
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : JSONArray)
          |> ScalarField_Data::JsonData
      (10, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : GeometryArray)
          |> ScalarField_Data::GeometryData
      (11, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : TimestamptzArray)
          |> ScalarField_Data::TimestamptzData
      (12, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : GeometryWktArray)
          |> ScalarField_Data::GeometryWktData
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ScalarField with fn write(
  self : ScalarField,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.valid_data.is_empty() {
    writer |> @lib.write_varint(138UL)
    let size = self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.valid_data {
      writer |> @lib.write_bool(item)
    }
  }
  match self.data {
    ScalarField_Data::BoolData(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::IntData(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::LongData(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::FloatData(v) => {
      writer |> @lib.write_varint(34UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::DoubleData(v) => {
      writer |> @lib.write_varint(42UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::StringData(v) => {
      writer |> @lib.write_varint(50UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::BytesData(v) => {
      writer |> @lib.write_varint(58UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::ArrayData(v) => {
      writer |> @lib.write_varint(66UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::JsonData(v) => {
      writer |> @lib.write_varint(74UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::GeometryData(v) => {
      writer |> @lib.write_varint(82UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::TimestamptzData(v) => {
      writer |> @lib.write_varint(90UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::GeometryWktData(v) => {
      writer |> @lib.write_varint(98UL)
      writer |> @lib.write_message(v)
    }
    ScalarField_Data::NotSet => ()
  }
}

///|
pub impl ToJson for ScalarField with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.valid_data != Default::default() {
    json["validData"] = ToJson::to_json(self.valid_data)
  }
  match self.data {
    NotSet => ()
    BoolData(v) => json["boolData"] = ToJson::to_json(v)
    IntData(v) => json["intData"] = ToJson::to_json(v)
    LongData(v) => json["longData"] = ToJson::to_json(v)
    FloatData(v) => json["floatData"] = ToJson::to_json(v)
    DoubleData(v) => json["doubleData"] = ToJson::to_json(v)
    StringData(v) => json["stringData"] = ToJson::to_json(v)
    BytesData(v) => json["bytesData"] = ToJson::to_json(v)
    ArrayData(v) => json["arrayData"] = ToJson::to_json(v)
    JsonData(v) => json["jsonData"] = ToJson::to_json(v)
    GeometryData(v) => json["geometryData"] = ToJson::to_json(v)
    TimestamptzData(v) => json["timestamptzData"] = ToJson::to_json(v)
    GeometryWktData(v) => json["geometryWktData"] = ToJson::to_json(v)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ScalarField with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ScalarField raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ScalarField"))
  }
  let message : ScalarField = Default::default()
  for key, value in obj {
    match (key, value) {
      ("validData", Array(value)) =>
        message.valid_data = value.map(v => @json.from_json(v, path~))
      ("boolData", value) => message.data = @json.from_json(value, path~)
      ("intData", value) => message.data = @json.from_json(value, path~)
      ("longData", value) => message.data = @json.from_json(value, path~)
      ("floatData", value) => message.data = @json.from_json(value, path~)
      ("doubleData", value) => message.data = @json.from_json(value, path~)
      ("stringData", value) => message.data = @json.from_json(value, path~)
      ("bytesData", value) => message.data = @json.from_json(value, path~)
      ("arrayData", value) => message.data = @json.from_json(value, path~)
      ("jsonData", value) => message.data = @json.from_json(value, path~)
      ("geometryData", value) => message.data = @json.from_json(value, path~)
      ("timestamptzData", value) => message.data = @json.from_json(value, path~)
      ("geometryWktData", value) => message.data = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ScalarField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ScalarField raise {
  let msg : ScalarField = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (17, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.valid_data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_bool, None)).iter(),
        )
      (17, @lib.WIRE_TYPE_VARINT) =>
        msg.valid_data.push(reader |> @lib.async_read_bool())
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : BoolArray)
          |> ScalarField_Data::BoolData
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : IntArray)
          |> ScalarField_Data::IntData
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : LongArray)
          |> ScalarField_Data::LongData
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : FloatArray)
          |> ScalarField_Data::FloatData
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : DoubleArray)
          |> ScalarField_Data::DoubleData
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : StringArray)
          |> ScalarField_Data::StringData
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : BytesArray)
          |> ScalarField_Data::BytesData
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : ArrayArray)
          |> ScalarField_Data::ArrayData
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : JSONArray)
          |> ScalarField_Data::JsonData
      (10, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : GeometryArray)
          |> ScalarField_Data::GeometryData
      (11, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : TimestamptzArray)
          |> ScalarField_Data::TimestamptzData
      (12, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : GeometryWktArray)
          |> ScalarField_Data::GeometryWktData
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ScalarField with fn write(
  self : ScalarField,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.valid_data.is_empty() {
    writer |> @lib.async_write_varint(138UL)
    let size = self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.valid_data {
      writer |> @lib.async_write_bool(item)
    }
  }
  match self.data {
    ScalarField_Data::BoolData(v) => {
      writer |> @lib.async_write_varint(10UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::IntData(v) => {
      writer |> @lib.async_write_varint(18UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::LongData(v) => {
      writer |> @lib.async_write_varint(26UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::FloatData(v) => {
      writer |> @lib.async_write_varint(34UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::DoubleData(v) => {
      writer |> @lib.async_write_varint(42UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::StringData(v) => {
      writer |> @lib.async_write_varint(50UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::BytesData(v) => {
      writer |> @lib.async_write_varint(58UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::ArrayData(v) => {
      writer |> @lib.async_write_varint(66UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::JsonData(v) => {
      writer |> @lib.async_write_varint(74UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::GeometryData(v) => {
      writer |> @lib.async_write_varint(82UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::TimestamptzData(v) => {
      writer |> @lib.async_write_varint(90UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::GeometryWktData(v) => {
      writer |> @lib.async_write_varint(98UL)
      writer |> @lib.async_write_message(v)
    }
    ScalarField_Data::NotSet => ()
  }
}

///|
pub(all) struct SparseFloatArray {
  mut contents : Array[Bytes]
  mut dim : Int64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for SparseFloatArray with fn size_of(self) {
  let mut size = 0U
  for s in self.contents {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  if self.dim != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.dim))
  }
  size
}

///|
pub impl Default for SparseFloatArray with fn default() -> SparseFloatArray {
  SparseFloatArray::{ contents: [], dim: Default::default(), }
}

///|
#alias(new, deprecated)
pub fn SparseFloatArray::SparseFloatArray(
  contents : Array[Bytes],
  dim : Int64,
) -> SparseFloatArray {
  SparseFloatArray::{ contents, dim, }
}

///|
pub impl @lib.Read for SparseFloatArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> SparseFloatArray raise {
  let msg : SparseFloatArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.contents.push(reader |> @lib.read_bytes())
      (2, _) => msg.dim = reader |> @lib.read_int64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for SparseFloatArray with fn write(
  self : SparseFloatArray,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.contents {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_bytes(item)
  }
  if self.dim != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.dim)
  }
}

///|
pub impl ToJson for SparseFloatArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.contents != Default::default() {
    json["contents"] = self.contents.map(@lib.base64_encode).to_json()
  }
  if self.dim != Default::default() {
    json["dim"] = ToJson::to_json(self.dim)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SparseFloatArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> SparseFloatArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for SparseFloatArray"),
    )
  }
  let message : SparseFloatArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("contents", Array(value)) =>
        message.contents = value.map(v => @json.from_json(v, path~))
      ("dim", value) => message.dim = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for SparseFloatArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> SparseFloatArray raise {
  let msg : SparseFloatArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.contents.push(reader |> @lib.async_read_bytes())
      (2, _) => msg.dim = reader |> @lib.async_read_int64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for SparseFloatArray with fn write(
  self : SparseFloatArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.contents {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_bytes(item)
  }
  if self.dim != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.dim)
  }
}

///|
pub(all) struct VectorField {
  mut dim : Int64
  mut valid_data : Array[Bool]
  mut data : VectorField_Data
} derive(Eq, Debug)

///|
pub(all) enum VectorField_Data {
  FloatVector(FloatArray)
  BinaryVector(Bytes)
  Float16Vector(Bytes)
  Bfloat16Vector(Bytes)
  SparseFloatVector(SparseFloatArray)
  Int8Vector(Bytes)
  VectorArray(VectorArray)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for VectorField_Data with fn default() -> VectorField_Data {
  NotSet
}

///|
pub impl @json.FromJson for VectorField_Data with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> VectorField_Data raise {
  try VectorField_Data::FloatVector(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try VectorField_Data::BinaryVector(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try VectorField_Data::Float16Vector(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try VectorField_Data::Bfloat16Vector(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try
    VectorField_Data::SparseFloatVector(json |> @json.from_json(path~))
  catch {
    _ => ()
  } noraise {
    v => return v
  }
  try VectorField_Data::Int8Vector(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try VectorField_Data::VectorArray(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  VectorField_Data::NotSet
}

///|
pub impl ToJson for VectorField_Data with fn to_json(self : VectorField_Data) -> Json {
  match self {
    VectorField_Data::FloatVector(v) => ToJson::to_json(v)
    VectorField_Data::BinaryVector(v) => ToJson::to_json(v)
    VectorField_Data::Float16Vector(v) => ToJson::to_json(v)
    VectorField_Data::Bfloat16Vector(v) => ToJson::to_json(v)
    VectorField_Data::SparseFloatVector(v) => ToJson::to_json(v)
    VectorField_Data::Int8Vector(v) => ToJson::to_json(v)
    VectorField_Data::VectorArray(v) => ToJson::to_json(v)
    VectorField_Data::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for VectorField with fn size_of(self) {
  let mut size = 0U
  if self.dim != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.dim))
  }
  if !self.valid_data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      9U,
      self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  match self.data {
    FloatVector(v) =>
      size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    BinaryVector(v) =>
      size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
    Float16Vector(v) =>
      size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
    Bfloat16Vector(v) =>
      size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
    SparseFloatVector(v) =>
      size += @lib.size_of_length_delimited_field(6U, @lib.size_of(v))
    Int8Vector(v) =>
      size += @lib.size_of_length_delimited_field(7U, @lib.size_of(v))
    VectorArray(v) =>
      size += @lib.size_of_length_delimited_field(8U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for VectorField with fn default() -> VectorField {
  VectorField::{
    dim: Default::default(),
    valid_data: [],
    data: VectorField_Data::NotSet,
  }
}

///|
#alias(new, deprecated)
pub fn VectorField::VectorField(
  dim : Int64,
  valid_data : Array[Bool],
  data? : VectorField_Data = VectorField_Data::NotSet,
) -> VectorField {
  VectorField::{ dim, valid_data, data, }
}

///|
pub impl @lib.Read for VectorField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> VectorField raise {
  let msg : VectorField = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.dim = reader |> @lib.read_int64()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.valid_data.push_iter(
          (reader |> @lib.read_packed(@lib.read_bool, None)).iter(),
        )
      (9, @lib.WIRE_TYPE_VARINT) =>
        msg.valid_data.push(reader |> @lib.read_bool())
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : FloatArray)
          |> VectorField_Data::FloatVector
      (3, _) =>
        msg.data = reader |> @lib.read_bytes() |> VectorField_Data::BinaryVector
      (4, _) =>
        msg.data = reader
          |> @lib.read_bytes()
          |> VectorField_Data::Float16Vector
      (5, _) =>
        msg.data = reader
          |> @lib.read_bytes()
          |> VectorField_Data::Bfloat16Vector
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : SparseFloatArray)
          |> VectorField_Data::SparseFloatVector
      (7, _) =>
        msg.data = reader |> @lib.read_bytes() |> VectorField_Data::Int8Vector
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.read_message() : VectorArray)
          |> VectorField_Data::VectorArray
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for VectorField with fn write(
  self : VectorField,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.dim != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int64(self.dim)
  }
  if !self.valid_data.is_empty() {
    writer |> @lib.write_varint(74UL)
    let size = self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.valid_data {
      writer |> @lib.write_bool(item)
    }
  }
  match self.data {
    VectorField_Data::FloatVector(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_message(v)
    }
    VectorField_Data::BinaryVector(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_bytes(v)
    }
    VectorField_Data::Float16Vector(v) => {
      writer |> @lib.write_varint(34UL)
      writer |> @lib.write_bytes(v)
    }
    VectorField_Data::Bfloat16Vector(v) => {
      writer |> @lib.write_varint(42UL)
      writer |> @lib.write_bytes(v)
    }
    VectorField_Data::SparseFloatVector(v) => {
      writer |> @lib.write_varint(50UL)
      writer |> @lib.write_message(v)
    }
    VectorField_Data::Int8Vector(v) => {
      writer |> @lib.write_varint(58UL)
      writer |> @lib.write_bytes(v)
    }
    VectorField_Data::VectorArray(v) => {
      writer |> @lib.write_varint(66UL)
      writer |> @lib.write_message(v)
    }
    VectorField_Data::NotSet => ()
  }
}

///|
pub impl ToJson for VectorField with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.dim != Default::default() {
    json["dim"] = ToJson::to_json(self.dim)
  }
  if self.valid_data != Default::default() {
    json["validData"] = ToJson::to_json(self.valid_data)
  }
  match self.data {
    NotSet => ()
    FloatVector(v) => json["floatVector"] = ToJson::to_json(v)
    BinaryVector(v) => json["binaryVector"] = ToJson::to_json(v)
    Float16Vector(v) => json["float16Vector"] = ToJson::to_json(v)
    Bfloat16Vector(v) => json["bfloat16Vector"] = ToJson::to_json(v)
    SparseFloatVector(v) => json["sparseFloatVector"] = ToJson::to_json(v)
    Int8Vector(v) => json["int8Vector"] = ToJson::to_json(v)
    VectorArray(v) => json["vectorArray"] = ToJson::to_json(v)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for VectorField with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> VectorField raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for VectorField"))
  }
  let message : VectorField = Default::default()
  for key, value in obj {
    match (key, value) {
      ("dim", value) => message.dim = @json.from_json(value, path~)
      ("validData", Array(value)) =>
        message.valid_data = value.map(v => @json.from_json(v, path~))
      ("floatVector", value) => message.data = @json.from_json(value, path~)
      ("binaryVector", value) => message.data = @json.from_json(value, path~)
      ("float16Vector", value) => message.data = @json.from_json(value, path~)
      ("bfloat16Vector", value) => message.data = @json.from_json(value, path~)
      ("sparseFloatVector", value) =>
        message.data = @json.from_json(value, path~)
      ("int8Vector", value) => message.data = @json.from_json(value, path~)
      ("vectorArray", value) => message.data = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for VectorField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> VectorField raise {
  let msg : VectorField = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.dim = reader |> @lib.async_read_int64()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.valid_data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_bool, None)).iter(),
        )
      (9, @lib.WIRE_TYPE_VARINT) =>
        msg.valid_data.push(reader |> @lib.async_read_bool())
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : FloatArray)
          |> VectorField_Data::FloatVector
      (3, _) =>
        msg.data = reader
          |> @lib.async_read_bytes()
          |> VectorField_Data::BinaryVector
      (4, _) =>
        msg.data = reader
          |> @lib.async_read_bytes()
          |> VectorField_Data::Float16Vector
      (5, _) =>
        msg.data = reader
          |> @lib.async_read_bytes()
          |> VectorField_Data::Bfloat16Vector
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : SparseFloatArray)
          |> VectorField_Data::SparseFloatVector
      (7, _) =>
        msg.data = reader
          |> @lib.async_read_bytes()
          |> VectorField_Data::Int8Vector
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data = (reader |> @lib.async_read_message() : VectorArray)
          |> VectorField_Data::VectorArray
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for VectorField with fn write(
  self : VectorField,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.dim != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int64(self.dim)
  }
  if !self.valid_data.is_empty() {
    writer |> @lib.async_write_varint(74UL)
    let size = self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.valid_data {
      writer |> @lib.async_write_bool(item)
    }
  }
  match self.data {
    VectorField_Data::FloatVector(v) => {
      writer |> @lib.async_write_varint(18UL)
      writer |> @lib.async_write_message(v)
    }
    VectorField_Data::BinaryVector(v) => {
      writer |> @lib.async_write_varint(26UL)
      writer |> @lib.async_write_bytes(v)
    }
    VectorField_Data::Float16Vector(v) => {
      writer |> @lib.async_write_varint(34UL)
      writer |> @lib.async_write_bytes(v)
    }
    VectorField_Data::Bfloat16Vector(v) => {
      writer |> @lib.async_write_varint(42UL)
      writer |> @lib.async_write_bytes(v)
    }
    VectorField_Data::SparseFloatVector(v) => {
      writer |> @lib.async_write_varint(50UL)
      writer |> @lib.async_write_message(v)
    }
    VectorField_Data::Int8Vector(v) => {
      writer |> @lib.async_write_varint(58UL)
      writer |> @lib.async_write_bytes(v)
    }
    VectorField_Data::VectorArray(v) => {
      writer |> @lib.async_write_varint(66UL)
      writer |> @lib.async_write_message(v)
    }
    VectorField_Data::NotSet => ()
  }
}

///|
pub(all) struct VectorArray {
  mut dim : Int64
  mut data : Array[VectorField]
  mut element_type : DataType
} derive(Eq, Debug)

///|
pub impl @lib.Sized for VectorArray with fn size_of(self) {
  let mut size = 0U
  if self.dim != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.dim))
  }
  for s in self.data {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  if self.element_type != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.element_type))
  }
  size
}

///|
pub impl Default for VectorArray with fn default() -> VectorArray {
  VectorArray::{
    dim: Default::default(),
    data: [],
    element_type: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn VectorArray::VectorArray(
  dim : Int64,
  data : Array[VectorField],
  element_type : DataType,
) -> VectorArray {
  VectorArray::{ dim, data, element_type, }
}

///|
pub impl @lib.Read for VectorArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> VectorArray raise {
  let msg : VectorArray = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.dim = reader |> @lib.read_int64()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push((reader |> @lib.read_message() : VectorField))
      (3, _) =>
        msg.element_type = reader |> @lib.read_enum() |> DataType::from_enum
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for VectorArray with fn write(
  self : VectorArray,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.dim != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int64(self.dim)
  }
  for item in self.data {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(item)
  }
  if self.element_type != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_enum(self.element_type.to_enum())
  }
}

///|
pub impl ToJson for VectorArray with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.dim != Default::default() {
    json["dim"] = ToJson::to_json(self.dim)
  }
  if self.data != Default::default() {
    json["data"] = ToJson::to_json(self.data)
  }
  if self.element_type != Default::default() {
    json["elementType"] = ToJson::to_json(self.element_type)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for VectorArray with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> VectorArray raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for VectorArray"))
  }
  let message : VectorArray = Default::default()
  for key, value in obj {
    match (key, value) {
      ("dim", value) => message.dim = @json.from_json(value, path~)
      ("data", Array(value)) =>
        message.data = value.map(v => @json.from_json(v, path~))
      ("elementType", value) =>
        message.element_type = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for VectorArray with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> VectorArray raise {
  let msg : VectorArray = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.dim = reader |> @lib.async_read_int64()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.data.push((reader |> @lib.async_read_message() : VectorField))
      (3, _) =>
        msg.element_type = reader
          |> @lib.async_read_enum()
          |> DataType::from_enum
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for VectorArray with fn write(
  self : VectorArray,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.dim != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int64(self.dim)
  }
  for item in self.data {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(item)
  }
  if self.element_type != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_enum(self.element_type.to_enum())
  }
}

///|
pub(all) struct FieldData {
  mut type_ : DataType
  mut field_name : String
  mut field_id : Int64
  mut is_dynamic : Bool
  mut valid_data : Array[Bool]
  mut field : FieldData_Field
} derive(Eq, Debug)

///|
pub(all) enum FieldData_Field {
  Scalars(ScalarField)
  Vectors(VectorField)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for FieldData_Field with fn default() -> FieldData_Field {
  NotSet
}

///|
pub impl @json.FromJson for FieldData_Field with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FieldData_Field raise {
  try FieldData_Field::Scalars(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try FieldData_Field::Vectors(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  FieldData_Field::NotSet
}

///|
pub impl ToJson for FieldData_Field with fn to_json(self : FieldData_Field) -> Json {
  match self {
    FieldData_Field::Scalars(v) => ToJson::to_json(v)
    FieldData_Field::Vectors(v) => ToJson::to_json(v)
    FieldData_Field::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for FieldData with fn size_of(self) {
  let mut size = 0U
  if self.type_ != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.type_))
  }
  if self.field_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      2U,
      @lib.size_of(self.field_name),
    )
  }
  if self.field_id != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.field_id))
  }
  if self.is_dynamic != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.is_dynamic))
  }
  if !self.valid_data.is_empty() {
    size += @lib.size_of_length_delimited_field(
      7U,
      self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  match self.field {
    Scalars(v) =>
      size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
    Vectors(v) =>
      size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for FieldData with fn default() -> FieldData {
  FieldData::{
    type_: Default::default(),
    field_name: Default::default(),
    field_id: Default::default(),
    is_dynamic: Default::default(),
    valid_data: [],
    field: FieldData_Field::NotSet,
  }
}

///|
#alias(new, deprecated)
pub fn FieldData::FieldData(
  type_ : DataType,
  field_name : String,
  field_id : Int64,
  is_dynamic : Bool,
  valid_data : Array[Bool],
  field? : FieldData_Field = FieldData_Field::NotSet,
) -> FieldData {
  FieldData::{ type_, field_name, field_id, is_dynamic, valid_data, field, }
}

///|
pub impl @lib.Read for FieldData with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FieldData raise {
  let msg : FieldData = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.type_ = reader |> @lib.read_enum() |> DataType::from_enum
      (2, _) => msg.field_name = reader |> @lib.read_string()
      (5, _) => msg.field_id = reader |> @lib.read_int64()
      (6, _) => msg.is_dynamic = reader |> @lib.read_bool()
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.valid_data.push_iter(
          (reader |> @lib.read_packed(@lib.read_bool, None)).iter(),
        )
      (7, @lib.WIRE_TYPE_VARINT) =>
        msg.valid_data.push(reader |> @lib.read_bool())
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.field = (reader |> @lib.read_message() : ScalarField)
          |> FieldData_Field::Scalars
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.field = (reader |> @lib.read_message() : VectorField)
          |> FieldData_Field::Vectors
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FieldData with fn write(
  self : FieldData,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.type_ != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_enum(self.type_.to_enum())
  }
  if self.field_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.field_name)
  }
  if self.field_id != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_int64(self.field_id)
  }
  if self.is_dynamic != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_bool(self.is_dynamic)
  }
  if !self.valid_data.is_empty() {
    writer |> @lib.write_varint(58UL)
    let size = self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.valid_data {
      writer |> @lib.write_bool(item)
    }
  }
  match self.field {
    FieldData_Field::Scalars(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_message(v)
    }
    FieldData_Field::Vectors(v) => {
      writer |> @lib.write_varint(34UL)
      writer |> @lib.write_message(v)
    }
    FieldData_Field::NotSet => ()
  }
}

///|
pub impl ToJson for FieldData with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.type_ != Default::default() {
    json["type"] = ToJson::to_json(self.type_)
  }
  if self.field_name != Default::default() {
    json["fieldName"] = ToJson::to_json(self.field_name)
  }
  if self.field_id != Default::default() {
    json["fieldId"] = ToJson::to_json(self.field_id)
  }
  if self.is_dynamic != Default::default() {
    json["isDynamic"] = ToJson::to_json(self.is_dynamic)
  }
  if self.valid_data != Default::default() {
    json["validData"] = ToJson::to_json(self.valid_data)
  }
  match self.field {
    NotSet => ()
    Scalars(v) => json["scalars"] = ToJson::to_json(v)
    Vectors(v) => json["vectors"] = ToJson::to_json(v)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FieldData with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FieldData raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FieldData"))
  }
  let message : FieldData = Default::default()
  for key, value in obj {
    match (key, value) {
      ("type", value) => message.type_ = @json.from_json(value, path~)
      ("fieldName", value) => message.field_name = @json.from_json(value, path~)
      ("fieldId", value) => message.field_id = @json.from_json(value, path~)
      ("isDynamic", value) => message.is_dynamic = @json.from_json(value, path~)
      ("validData", Array(value)) =>
        message.valid_data = value.map(v => @json.from_json(v, path~))
      ("scalars", value) => message.field = @json.from_json(value, path~)
      ("vectors", value) => message.field = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FieldData with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FieldData raise {
  let msg : FieldData = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.type_ = reader |> @lib.async_read_enum() |> DataType::from_enum
      (2, _) => msg.field_name = reader |> @lib.async_read_string()
      (5, _) => msg.field_id = reader |> @lib.async_read_int64()
      (6, _) => msg.is_dynamic = reader |> @lib.async_read_bool()
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.valid_data.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_bool, None)).iter(),
        )
      (7, @lib.WIRE_TYPE_VARINT) =>
        msg.valid_data.push(reader |> @lib.async_read_bool())
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.field = (reader |> @lib.async_read_message() : ScalarField)
          |> FieldData_Field::Scalars
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.field = (reader |> @lib.async_read_message() : VectorField)
          |> FieldData_Field::Vectors
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FieldData with fn write(
  self : FieldData,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.type_ != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_enum(self.type_.to_enum())
  }
  if self.field_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.field_name)
  }
  if self.field_id != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_int64(self.field_id)
  }
  if self.is_dynamic != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_bool(self.is_dynamic)
  }
  if !self.valid_data.is_empty() {
    writer |> @lib.async_write_varint(58UL)
    let size = self.valid_data.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.valid_data {
      writer |> @lib.async_write_bool(item)
    }
  }
  match self.field {
    FieldData_Field::Scalars(v) => {
      writer |> @lib.async_write_varint(26UL)
      writer |> @lib.async_write_message(v)
    }
    FieldData_Field::Vectors(v) => {
      writer |> @lib.async_write_varint(34UL)
      writer |> @lib.async_write_message(v)
    }
    FieldData_Field::NotSet => ()
  }
}

///|
pub(all) struct IDs {
  mut id_field : IDs_IdField
} derive(Eq, Debug)

///|
pub(all) enum IDs_IdField {
  IntId(LongArray)
  StrId(StringArray)
  UuidId(UUIDArray)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for IDs_IdField with fn default() -> IDs_IdField {
  NotSet
}

///|
pub impl @json.FromJson for IDs_IdField with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> IDs_IdField raise {
  try IDs_IdField::IntId(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try IDs_IdField::StrId(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try IDs_IdField::UuidId(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  IDs_IdField::NotSet
}

///|
pub impl ToJson for IDs_IdField with fn to_json(self : IDs_IdField) -> Json {
  match self {
    IDs_IdField::IntId(v) => ToJson::to_json(v)
    IDs_IdField::StrId(v) => ToJson::to_json(v)
    IDs_IdField::UuidId(v) => ToJson::to_json(v)
    IDs_IdField::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for IDs with fn size_of(self) {
  let mut size = 0U
  match self.id_field {
    IntId(v) => size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
    StrId(v) => size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    UuidId(v) =>
      size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for IDs with fn default() -> IDs {
  IDs::{ id_field: IDs_IdField::NotSet, }
}

///|
#alias(new, deprecated)
pub fn IDs::IDs(id_field? : IDs_IdField = IDs_IdField::NotSet) -> IDs {
  IDs::{ id_field, }
}

///|
pub impl @lib.Read for IDs with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> IDs raise {
  let msg : IDs = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.id_field = (reader |> @lib.read_message() : LongArray)
          |> IDs_IdField::IntId
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.id_field = (reader |> @lib.read_message() : StringArray)
          |> IDs_IdField::StrId
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.id_field = (reader |> @lib.read_message() : UUIDArray)
          |> IDs_IdField::UuidId
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for IDs with fn write(self : IDs, writer : &@lib.Writer) -> Unit raise {
  match self.id_field {
    IDs_IdField::IntId(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_message(v)
    }
    IDs_IdField::StrId(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_message(v)
    }
    IDs_IdField::UuidId(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_message(v)
    }
    IDs_IdField::NotSet => ()
  }
}

///|
pub impl ToJson for IDs with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.id_field {
    NotSet => ()
    IntId(v) => json["intId"] = ToJson::to_json(v)
    StrId(v) => json["strId"] = ToJson::to_json(v)
    UuidId(v) => json["uuidId"] = ToJson::to_json(v)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for IDs with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> IDs raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for IDs"))
  }
  let message : IDs = Default::default()
  for key, value in obj {
    match (key, value) {
      ("intId", value) => message.id_field = @json.from_json(value, path~)
      ("strId", value) => message.id_field = @json.from_json(value, path~)
      ("uuidId", value) => message.id_field = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for IDs with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> IDs raise {
  let msg : IDs = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.id_field = (reader |> @lib.async_read_message() : LongArray)
          |> IDs_IdField::IntId
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.id_field = (reader |> @lib.async_read_message() : StringArray)
          |> IDs_IdField::StrId
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.id_field = (reader |> @lib.async_read_message() : UUIDArray)
          |> IDs_IdField::UuidId
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for IDs with fn write(
  self : IDs,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  match self.id_field {
    IDs_IdField::IntId(v) => {
      writer |> @lib.async_write_varint(10UL)
      writer |> @lib.async_write_message(v)
    }
    IDs_IdField::StrId(v) => {
      writer |> @lib.async_write_varint(18UL)
      writer |> @lib.async_write_message(v)
    }
    IDs_IdField::UuidId(v) => {
      writer |> @lib.async_write_varint(26UL)
      writer |> @lib.async_write_message(v)
    }
    IDs_IdField::NotSet => ()
  }
}

///|
pub(all) struct SearchIteratorV2Results {
  mut token : String
  mut last_bound : Float
} derive(Eq, Debug)

///|
pub impl @lib.Sized for SearchIteratorV2Results with fn size_of(self) {
  let mut size = 0U
  if self.token != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.token))
  }
  if self.last_bound != Default::default() {
    size += @lib.size_of_field(2U, 4U)
  }
  size
}

///|
pub impl Default for SearchIteratorV2Results with fn default() -> SearchIteratorV2Results {
  SearchIteratorV2Results::{
    token: Default::default(),
    last_bound: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn SearchIteratorV2Results::SearchIteratorV2Results(
  token : String,
  last_bound : Float,
) -> SearchIteratorV2Results {
  SearchIteratorV2Results::{ token, last_bound, }
}

///|
pub impl @lib.Read for SearchIteratorV2Results with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> SearchIteratorV2Results raise {
  let msg : SearchIteratorV2Results = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.token = reader |> @lib.read_string()
      (2, _) => msg.last_bound = reader |> @lib.read_float()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for SearchIteratorV2Results with fn write(
  self : SearchIteratorV2Results,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.token != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.token)
  }
  if self.last_bound != Default::default() {
    writer |> @lib.write_varint(21UL)
    writer |> @lib.write_float(self.last_bound)
  }
}

///|
pub impl ToJson for SearchIteratorV2Results with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.token != Default::default() {
    json["token"] = ToJson::to_json(self.token)
  }
  if self.last_bound != Default::default() {
    json["lastBound"] = ToJson::to_json(self.last_bound)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SearchIteratorV2Results with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> SearchIteratorV2Results raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for SearchIteratorV2Results"),
    )
  }
  let message : SearchIteratorV2Results = Default::default()
  for key, value in obj {
    match (key, value) {
      ("token", value) => message.token = @json.from_json(value, path~)
      ("lastBound", Number(value, ..)) =>
        message.last_bound = Float::from_double(value)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for SearchIteratorV2Results with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> SearchIteratorV2Results raise {
  let msg : SearchIteratorV2Results = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.token = reader |> @lib.async_read_string()
      (2, _) => msg.last_bound = reader |> @lib.async_read_float()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for SearchIteratorV2Results with fn write(
  self : SearchIteratorV2Results,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.token != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.token)
  }
  if self.last_bound != Default::default() {
    writer |> @lib.async_write_varint(21UL)
    writer |> @lib.async_write_float(self.last_bound)
  }
}

///|
pub(all) struct SearchResultData {
  mut num_queries : Int64
  mut top_k : Int64
  mut fields_data : Array[FieldData]
  mut scores : Array[Float]
  mut ids : IDs?
  mut topks : Array[Int64]
  mut output_fields : Array[String]
  mut group_by_field_value : FieldData?
  mut all_search_count : Int64
  mut distances : Array[Float]
  mut search_iterator_v2_results : SearchIteratorV2Results?
  mut recalls : Array[Float]
  mut primary_field_name : String
  mut element_indices : LongArray?
  mut group_by_field_values : Array[FieldData]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for SearchResultData with fn size_of(self) {
  let mut size = 0U
  if self.num_queries != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.num_queries))
  }
  if self.top_k != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.top_k))
  }
  for s in self.fields_data {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  if !self.scores.is_empty() {
    size += @lib.size_of_length_delimited_field(
      4U,
      self.scores.length().reinterpret_as_uint() * 4,
    )
  }
  if self.ids is Some(v) {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
  }
  if !self.topks.is_empty() {
    size += @lib.size_of_length_delimited_field(
      6U,
      self.topks.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  for s in self.output_fields {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(s))
  }
  if self.group_by_field_value is Some(v) {
    size += @lib.size_of_length_delimited_field(8U, @lib.size_of(v))
  }
  if self.all_search_count != Default::default() {
    size += @lib.size_of_field(9U, @lib.size_of(self.all_search_count))
  }
  if !self.distances.is_empty() {
    size += @lib.size_of_length_delimited_field(
      10U,
      self.distances.length().reinterpret_as_uint() * 4,
    )
  }
  if self.search_iterator_v2_results is Some(v) {
    size += @lib.size_of_length_delimited_field(11U, @lib.size_of(v))
  }
  if !self.recalls.is_empty() {
    size += @lib.size_of_length_delimited_field(
      12U,
      self.recalls.length().reinterpret_as_uint() * 4,
    )
  }
  if self.primary_field_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      13U,
      @lib.size_of(self.primary_field_name),
    )
  }
  if self.element_indices is Some(v) {
    size += @lib.size_of_length_delimited_field(15U, @lib.size_of(v))
  }
  for s in self.group_by_field_values {
    size += @lib.size_of_length_delimited_field(17U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for SearchResultData with fn default() -> SearchResultData {
  SearchResultData::{
    num_queries: Default::default(),
    top_k: Default::default(),
    fields_data: [],
    scores: [],
    ids: None,
    topks: [],
    output_fields: [],
    group_by_field_value: None,
    all_search_count: Default::default(),
    distances: [],
    search_iterator_v2_results: None,
    recalls: [],
    primary_field_name: Default::default(),
    element_indices: None,
    group_by_field_values: [],
  }
}

///|
#alias(new, deprecated)
pub fn SearchResultData::SearchResultData(
  num_queries : Int64,
  top_k : Int64,
  fields_data : Array[FieldData],
  scores : Array[Float],
  ids? : IDs,
  topks : Array[Int64],
  output_fields : Array[String],
  group_by_field_value? : FieldData,
  all_search_count : Int64,
  distances : Array[Float],
  search_iterator_v2_results? : SearchIteratorV2Results,
  recalls : Array[Float],
  primary_field_name : String,
  element_indices? : LongArray,
  group_by_field_values : Array[FieldData],
) -> SearchResultData {
  SearchResultData::{
    num_queries,
    top_k,
    fields_data,
    scores,
    ids,
    topks,
    output_fields,
    group_by_field_value,
    all_search_count,
    distances,
    search_iterator_v2_results,
    recalls,
    primary_field_name,
    element_indices,
    group_by_field_values,
  }
}

///|
pub impl @lib.Read for SearchResultData with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> SearchResultData raise {
  let msg : SearchResultData = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.num_queries = reader |> @lib.read_int64()
      (2, _) => msg.top_k = reader |> @lib.read_int64()
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields_data.push((reader |> @lib.read_message() : FieldData))
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.scores.push_iter(
          (reader |> @lib.read_packed(@lib.read_float, Some(4))).iter(),
        )
      (4, @lib.WIRE_TYPE_FIXED32) =>
        msg.scores.push(reader |> @lib.read_float())
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.ids = (reader |> @lib.read_message() : IDs) |> Some
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.topks.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) => msg.topks.push(reader |> @lib.read_int64())
      (7, _) => msg.output_fields.push(reader |> @lib.read_string())
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.group_by_field_value = (reader |> @lib.read_message() : FieldData)
          |> Some
      (9, _) => msg.all_search_count = reader |> @lib.read_int64()
      (10, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.distances.push_iter(
          (reader |> @lib.read_packed(@lib.read_float, Some(4))).iter(),
        )
      (10, @lib.WIRE_TYPE_FIXED32) =>
        msg.distances.push(reader |> @lib.read_float())
      (11, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.search_iterator_v2_results = (
            reader |> @lib.read_message() : SearchIteratorV2Results)
          |> Some
      (12, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.recalls.push_iter(
          (reader |> @lib.read_packed(@lib.read_float, Some(4))).iter(),
        )
      (12, @lib.WIRE_TYPE_FIXED32) =>
        msg.recalls.push(reader |> @lib.read_float())
      (13, _) => msg.primary_field_name = reader |> @lib.read_string()
      (15, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.element_indices = (reader |> @lib.read_message() : LongArray)
          |> Some
      (17, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.group_by_field_values.push(
          (reader |> @lib.read_message() : FieldData),
        )
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for SearchResultData with fn write(
  self : SearchResultData,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.num_queries != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int64(self.num_queries)
  }
  if self.top_k != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.top_k)
  }
  for item in self.fields_data {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
  if !self.scores.is_empty() {
    writer |> @lib.write_varint(34UL)
    let size = self.scores.length().reinterpret_as_uint() * 4
    writer |> @lib.write_uint32(size)
    for item in self.scores {
      writer |> @lib.write_float(item)
    }
  }
  if self.ids is Some(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(v)
  }
  if !self.topks.is_empty() {
    writer |> @lib.write_varint(50UL)
    let size = self.topks.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.topks {
      writer |> @lib.write_int64(item)
    }
  }
  for item in self.output_fields {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_string(item)
  }
  if self.group_by_field_value is Some(v) {
    writer |> @lib.write_varint(66UL)
    writer |> @lib.write_message(v)
  }
  if self.all_search_count != Default::default() {
    writer |> @lib.write_varint(72UL)
    writer |> @lib.write_int64(self.all_search_count)
  }
  if !self.distances.is_empty() {
    writer |> @lib.write_varint(82UL)
    let size = self.distances.length().reinterpret_as_uint() * 4
    writer |> @lib.write_uint32(size)
    for item in self.distances {
      writer |> @lib.write_float(item)
    }
  }
  if self.search_iterator_v2_results is Some(v) {
    writer |> @lib.write_varint(90UL)
    writer |> @lib.write_message(v)
  }
  if !self.recalls.is_empty() {
    writer |> @lib.write_varint(98UL)
    let size = self.recalls.length().reinterpret_as_uint() * 4
    writer |> @lib.write_uint32(size)
    for item in self.recalls {
      writer |> @lib.write_float(item)
    }
  }
  if self.primary_field_name != Default::default() {
    writer |> @lib.write_varint(106UL)
    writer |> @lib.write_string(self.primary_field_name)
  }
  if self.element_indices is Some(v) {
    writer |> @lib.write_varint(122UL)
    writer |> @lib.write_message(v)
  }
  for item in self.group_by_field_values {
    writer |> @lib.write_varint(138UL)
    writer |> @lib.write_message(item)
  }
}

///|
pub impl ToJson for SearchResultData with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.num_queries != Default::default() {
    json["numQueries"] = ToJson::to_json(self.num_queries)
  }
  if self.top_k != Default::default() {
    json["topK"] = ToJson::to_json(self.top_k)
  }
  if self.fields_data != Default::default() {
    json["fieldsData"] = ToJson::to_json(self.fields_data)
  }
  if self.scores != Default::default() {
    json["scores"] = ToJson::to_json(self.scores)
  }
  match self.ids {
    Some(v) => json["ids"] = ToJson::to_json(v)
    _ => ()
  }
  if self.topks != Default::default() {
    json["topks"] = ToJson::to_json(self.topks)
  }
  if self.output_fields != Default::default() {
    json["outputFields"] = ToJson::to_json(self.output_fields)
  }
  match self.group_by_field_value {
    Some(v) => json["groupByFieldValue"] = ToJson::to_json(v)
    _ => ()
  }
  if self.all_search_count != Default::default() {
    json["allSearchCount"] = ToJson::to_json(self.all_search_count)
  }
  if self.distances != Default::default() {
    json["distances"] = ToJson::to_json(self.distances)
  }
  match self.search_iterator_v2_results {
    Some(v) => json["searchIteratorV2Results"] = ToJson::to_json(v)
    _ => ()
  }
  if self.recalls != Default::default() {
    json["recalls"] = ToJson::to_json(self.recalls)
  }
  if self.primary_field_name != Default::default() {
    json["primaryFieldName"] = ToJson::to_json(self.primary_field_name)
  }
  match self.element_indices {
    Some(v) => json["elementIndices"] = ToJson::to_json(v)
    _ => ()
  }
  if self.group_by_field_values != Default::default() {
    json["groupByFieldValues"] = ToJson::to_json(self.group_by_field_values)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SearchResultData with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> SearchResultData raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for SearchResultData"),
    )
  }
  let message : SearchResultData = Default::default()
  for key, value in obj {
    match (key, value) {
      ("numQueries", value) =>
        message.num_queries = @json.from_json(value, path~)
      ("topK", value) => message.top_k = @json.from_json(value, path~)
      ("fieldsData", Array(value)) =>
        message.fields_data = value.map(v => @json.from_json(v, path~))
      ("scores", Array(value)) =>
        message.scores = value.map(v => {
          Float::from_double(@json.from_json(v, path~))
        })
      ("ids", value) => message.ids = Some(@json.from_json(value, path~))
      ("topks", Array(value)) =>
        message.topks = value.map(v => @json.from_json(v, path~))
      ("outputFields", Array(value)) =>
        message.output_fields = value.map(v => @json.from_json(v, path~))
      ("groupByFieldValue", value) =>
        message.group_by_field_value = Some(@json.from_json(value, path~))
      ("allSearchCount", value) =>
        message.all_search_count = @json.from_json(value, path~)
      ("distances", Array(value)) =>
        message.distances = value.map(v => {
          Float::from_double(@json.from_json(v, path~))
        })
      ("searchIteratorV2Results", value) =>
        message.search_iterator_v2_results = Some(@json.from_json(value, path~))
      ("recalls", Array(value)) =>
        message.recalls = value.map(v => {
          Float::from_double(@json.from_json(v, path~))
        })
      ("primaryFieldName", value) =>
        message.primary_field_name = @json.from_json(value, path~)
      ("elementIndices", value) =>
        message.element_indices = Some(@json.from_json(value, path~))
      ("groupByFieldValues", Array(value)) =>
        message.group_by_field_values = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for SearchResultData with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> SearchResultData raise {
  let msg : SearchResultData = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.num_queries = reader |> @lib.async_read_int64()
      (2, _) => msg.top_k = reader |> @lib.async_read_int64()
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields_data.push((reader |> @lib.async_read_message() : FieldData))
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.scores.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_float, Some(4))).iter(),
        )
      (4, @lib.WIRE_TYPE_FIXED32) =>
        msg.scores.push(reader |> @lib.async_read_float())
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.ids = (reader |> @lib.async_read_message() : IDs) |> Some
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.topks.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.topks.push(reader |> @lib.async_read_int64())
      (7, _) => msg.output_fields.push(reader |> @lib.async_read_string())
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.group_by_field_value = (
            reader |> @lib.async_read_message() : FieldData)
          |> Some
      (9, _) => msg.all_search_count = reader |> @lib.async_read_int64()
      (10, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.distances.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_float, Some(4))).iter(),
        )
      (10, @lib.WIRE_TYPE_FIXED32) =>
        msg.distances.push(reader |> @lib.async_read_float())
      (11, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.search_iterator_v2_results = (
            reader |> @lib.async_read_message() : SearchIteratorV2Results)
          |> Some
      (12, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.recalls.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_float, Some(4))).iter(),
        )
      (12, @lib.WIRE_TYPE_FIXED32) =>
        msg.recalls.push(reader |> @lib.async_read_float())
      (13, _) => msg.primary_field_name = reader |> @lib.async_read_string()
      (15, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.element_indices = (reader |> @lib.async_read_message() : LongArray)
          |> Some
      (17, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.group_by_field_values.push(
          (reader |> @lib.async_read_message() : FieldData),
        )
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for SearchResultData with fn write(
  self : SearchResultData,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.num_queries != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int64(self.num_queries)
  }
  if self.top_k != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.top_k)
  }
  for item in self.fields_data {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
  if !self.scores.is_empty() {
    writer |> @lib.async_write_varint(34UL)
    let size = self.scores.length().reinterpret_as_uint() * 4
    writer |> @lib.async_write_uint32(size)
    for item in self.scores {
      writer |> @lib.async_write_float(item)
    }
  }
  if self.ids is Some(v) {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(v)
  }
  if !self.topks.is_empty() {
    writer |> @lib.async_write_varint(50UL)
    let size = self.topks.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.topks {
      writer |> @lib.async_write_int64(item)
    }
  }
  for item in self.output_fields {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_string(item)
  }
  if self.group_by_field_value is Some(v) {
    writer |> @lib.async_write_varint(66UL)
    writer |> @lib.async_write_message(v)
  }
  if self.all_search_count != Default::default() {
    writer |> @lib.async_write_varint(72UL)
    writer |> @lib.async_write_int64(self.all_search_count)
  }
  if !self.distances.is_empty() {
    writer |> @lib.async_write_varint(82UL)
    let size = self.distances.length().reinterpret_as_uint() * 4
    writer |> @lib.async_write_uint32(size)
    for item in self.distances {
      writer |> @lib.async_write_float(item)
    }
  }
  if self.search_iterator_v2_results is Some(v) {
    writer |> @lib.async_write_varint(90UL)
    writer |> @lib.async_write_message(v)
  }
  if !self.recalls.is_empty() {
    writer |> @lib.async_write_varint(98UL)
    let size = self.recalls.length().reinterpret_as_uint() * 4
    writer |> @lib.async_write_uint32(size)
    for item in self.recalls {
      writer |> @lib.async_write_float(item)
    }
  }
  if self.primary_field_name != Default::default() {
    writer |> @lib.async_write_varint(106UL)
    writer |> @lib.async_write_string(self.primary_field_name)
  }
  if self.element_indices is Some(v) {
    writer |> @lib.async_write_varint(122UL)
    writer |> @lib.async_write_message(v)
  }
  for item in self.group_by_field_values {
    writer |> @lib.async_write_varint(138UL)
    writer |> @lib.async_write_message(item)
  }
}
