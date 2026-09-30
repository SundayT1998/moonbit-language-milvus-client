///|
pub(all) enum ShowType {
  All
  InMemory
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn ShowType::to_enum(self : ShowType) -> @lib.Enum {
  match self {
    ShowType::All => 0
    ShowType::InMemory => 1
    ShowType::Unknown(value) => value
  }
}

///|
pub fn ShowType::from_enum(i : @lib.Enum) -> ShowType {
  match i.0 {
    0 => ShowType::All
    1 => ShowType::InMemory
    _ => ShowType::Unknown(i)
  }
}

///|
pub impl Default for ShowType with fn default() -> ShowType {
  ShowType::All
}

///|
pub impl @lib.Sized for ShowType with fn size_of(self : ShowType) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for ShowType with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ShowType raise {
  match json {
    String("All") => ShowType::All
    String("InMemory") => ShowType::InMemory
    Number(0, ..) => ShowType::All
    Number(1, ..) => ShowType::InMemory
    Number(value, ..) =>
      if value.trunc() == value {
        ShowType::Unknown(@lib.Enum(value.to_uint()))
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
pub impl ToJson for ShowType with fn to_json(self : ShowType) -> Json {
  match self {
    ShowType::All => "All"
    ShowType::InMemory => "InMemory"
    ShowType::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) struct CreateIndexRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut field_name : String
  mut extra_params : Array[@common.KeyValuePair]
  mut index_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for CreateIndexRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.field_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.field_name),
    )
  }
  for s in self.extra_params {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  if self.index_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      6U,
      @lib.size_of(self.index_name),
    )
  }
  size
}

///|
pub impl Default for CreateIndexRequest with fn default() -> CreateIndexRequest {
  CreateIndexRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    field_name: Default::default(),
    extra_params: [],
    index_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn CreateIndexRequest::CreateIndexRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  field_name : String,
  extra_params : Array[@common.KeyValuePair],
  index_name : String,
) -> CreateIndexRequest {
  CreateIndexRequest::{
    base,
    db_name,
    collection_name,
    field_name,
    extra_params,
    index_name,
  }
}

///|
pub impl @lib.Read for CreateIndexRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> CreateIndexRequest raise {
  let msg : CreateIndexRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.field_name = reader |> @lib.read_string()
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.extra_params.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (6, _) => msg.index_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for CreateIndexRequest with fn write(
  self : CreateIndexRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.field_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.field_name)
  }
  for item in self.extra_params {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(item)
  }
  if self.index_name != Default::default() {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_string(self.index_name)
  }
}

///|
pub impl ToJson for CreateIndexRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.field_name != Default::default() {
    json["fieldName"] = ToJson::to_json(self.field_name)
  }
  if self.extra_params != Default::default() {
    json["extraParams"] = ToJson::to_json(self.extra_params)
  }
  if self.index_name != Default::default() {
    json["indexName"] = ToJson::to_json(self.index_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for CreateIndexRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> CreateIndexRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for CreateIndexRequest"),
    )
  }
  let message : CreateIndexRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("fieldName", value) => message.field_name = @json.from_json(value, path~)
      ("extraParams", Array(value)) =>
        message.extra_params = value.map(v => @json.from_json(v, path~))
      ("indexName", value) => message.index_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for CreateIndexRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> CreateIndexRequest raise {
  let msg : CreateIndexRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.field_name = reader |> @lib.async_read_string()
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.extra_params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (6, _) => msg.index_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for CreateIndexRequest with fn write(
  self : CreateIndexRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.field_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.field_name)
  }
  for item in self.extra_params {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(item)
  }
  if self.index_name != Default::default() {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_string(self.index_name)
  }
}

///|
pub(all) struct DescribeIndexRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut field_name : String
  mut index_name : String
  mut timestamp : UInt64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DescribeIndexRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.field_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.field_name),
    )
  }
  if self.index_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      5U,
      @lib.size_of(self.index_name),
    )
  }
  if self.timestamp != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.timestamp))
  }
  size
}

///|
pub impl Default for DescribeIndexRequest with fn default() -> DescribeIndexRequest {
  DescribeIndexRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    field_name: Default::default(),
    index_name: Default::default(),
    timestamp: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn DescribeIndexRequest::DescribeIndexRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  field_name : String,
  index_name : String,
  timestamp : UInt64,
) -> DescribeIndexRequest {
  DescribeIndexRequest::{
    base,
    db_name,
    collection_name,
    field_name,
    index_name,
    timestamp,
  }
}

///|
pub impl @lib.Read for DescribeIndexRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DescribeIndexRequest raise {
  let msg : DescribeIndexRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.field_name = reader |> @lib.read_string()
      (5, _) => msg.index_name = reader |> @lib.read_string()
      (6, _) => msg.timestamp = reader |> @lib.read_uint64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DescribeIndexRequest with fn write(
  self : DescribeIndexRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.field_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.field_name)
  }
  if self.index_name != Default::default() {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(self.index_name)
  }
  if self.timestamp != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_uint64(self.timestamp)
  }
}

///|
pub impl ToJson for DescribeIndexRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.field_name != Default::default() {
    json["fieldName"] = ToJson::to_json(self.field_name)
  }
  if self.index_name != Default::default() {
    json["indexName"] = ToJson::to_json(self.index_name)
  }
  if self.timestamp != Default::default() {
    json["timestamp"] = ToJson::to_json(self.timestamp)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DescribeIndexRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DescribeIndexRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DescribeIndexRequest"),
    )
  }
  let message : DescribeIndexRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("fieldName", value) => message.field_name = @json.from_json(value, path~)
      ("indexName", value) => message.index_name = @json.from_json(value, path~)
      ("timestamp", value) => message.timestamp = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DescribeIndexRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DescribeIndexRequest raise {
  let msg : DescribeIndexRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.field_name = reader |> @lib.async_read_string()
      (5, _) => msg.index_name = reader |> @lib.async_read_string()
      (6, _) => msg.timestamp = reader |> @lib.async_read_uint64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DescribeIndexRequest with fn write(
  self : DescribeIndexRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.field_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.field_name)
  }
  if self.index_name != Default::default() {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(self.index_name)
  }
  if self.timestamp != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_uint64(self.timestamp)
  }
}

///|
pub(all) struct IndexDescription {
  mut index_name : String
  mut index_id : Int64
  mut params : Array[@common.KeyValuePair]
  mut field_name : String
  mut indexed_rows : Int64
  mut total_rows : Int64
  mut state : @common.IndexState
  mut index_state_fail_reason : String
  mut pending_index_rows : Int64
  mut min_index_version : Int
  mut max_index_version : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for IndexDescription with fn size_of(self) {
  let mut size = 0U
  if self.index_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      1U,
      @lib.size_of(self.index_name),
    )
  }
  if self.index_id != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.index_id))
  }
  for s in self.params {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  if self.field_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.field_name),
    )
  }
  if self.indexed_rows != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.indexed_rows))
  }
  if self.total_rows != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.total_rows))
  }
  if self.state != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.state))
  }
  if self.index_state_fail_reason != Default::default() {
    size += @lib.size_of_length_delimited_field(
      8U,
      @lib.size_of(self.index_state_fail_reason),
    )
  }
  if self.pending_index_rows != Default::default() {
    size += @lib.size_of_field(9U, @lib.size_of(self.pending_index_rows))
  }
  if self.min_index_version != Default::default() {
    size += @lib.size_of_field(10U, @lib.size_of(self.min_index_version))
  }
  if self.max_index_version != Default::default() {
    size += @lib.size_of_field(11U, @lib.size_of(self.max_index_version))
  }
  size
}

///|
pub impl Default for IndexDescription with fn default() -> IndexDescription {
  IndexDescription::{
    index_name: Default::default(),
    index_id: Default::default(),
    params: [],
    field_name: Default::default(),
    indexed_rows: Default::default(),
    total_rows: Default::default(),
    state: Default::default(),
    index_state_fail_reason: Default::default(),
    pending_index_rows: Default::default(),
    min_index_version: Default::default(),
    max_index_version: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn IndexDescription::IndexDescription(
  index_name : String,
  index_id : Int64,
  params : Array[@common.KeyValuePair],
  field_name : String,
  indexed_rows : Int64,
  total_rows : Int64,
  state : @common.IndexState,
  index_state_fail_reason : String,
  pending_index_rows : Int64,
  min_index_version : Int,
  max_index_version : Int,
) -> IndexDescription {
  IndexDescription::{
    index_name,
    index_id,
    params,
    field_name,
    indexed_rows,
    total_rows,
    state,
    index_state_fail_reason,
    pending_index_rows,
    min_index_version,
    max_index_version,
  }
}

///|
pub impl @lib.Read for IndexDescription with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> IndexDescription raise {
  let msg : IndexDescription = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.index_name = reader |> @lib.read_string()
      (2, _) => msg.index_id = reader |> @lib.read_int64()
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.params.push((reader |> @lib.read_message() : @common.KeyValuePair))
      (4, _) => msg.field_name = reader |> @lib.read_string()
      (5, _) => msg.indexed_rows = reader |> @lib.read_int64()
      (6, _) => msg.total_rows = reader |> @lib.read_int64()
      (7, _) =>
        msg.state = reader |> @lib.read_enum() |> @common.IndexState::from_enum
      (8, _) => msg.index_state_fail_reason = reader |> @lib.read_string()
      (9, _) => msg.pending_index_rows = reader |> @lib.read_int64()
      (10, _) => msg.min_index_version = reader |> @lib.read_int32()
      (11, _) => msg.max_index_version = reader |> @lib.read_int32()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for IndexDescription with fn write(
  self : IndexDescription,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.index_name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.index_name)
  }
  if self.index_id != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.index_id)
  }
  for item in self.params {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
  if self.field_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.field_name)
  }
  if self.indexed_rows != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_int64(self.indexed_rows)
  }
  if self.total_rows != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_int64(self.total_rows)
  }
  if self.state != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_enum(self.state.to_enum())
  }
  if self.index_state_fail_reason != Default::default() {
    writer |> @lib.write_varint(66UL)
    writer |> @lib.write_string(self.index_state_fail_reason)
  }
  if self.pending_index_rows != Default::default() {
    writer |> @lib.write_varint(72UL)
    writer |> @lib.write_int64(self.pending_index_rows)
  }
  if self.min_index_version != Default::default() {
    writer |> @lib.write_varint(80UL)
    writer |> @lib.write_int32(self.min_index_version)
  }
  if self.max_index_version != Default::default() {
    writer |> @lib.write_varint(88UL)
    writer |> @lib.write_int32(self.max_index_version)
  }
}

///|
pub impl ToJson for IndexDescription with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.index_name != Default::default() {
    json["indexName"] = ToJson::to_json(self.index_name)
  }
  if self.index_id != Default::default() {
    json["indexID"] = ToJson::to_json(self.index_id)
  }
  if self.params != Default::default() {
    json["params"] = ToJson::to_json(self.params)
  }
  if self.field_name != Default::default() {
    json["fieldName"] = ToJson::to_json(self.field_name)
  }
  if self.indexed_rows != Default::default() {
    json["indexedRows"] = ToJson::to_json(self.indexed_rows)
  }
  if self.total_rows != Default::default() {
    json["totalRows"] = ToJson::to_json(self.total_rows)
  }
  if self.state != Default::default() {
    json["state"] = ToJson::to_json(self.state)
  }
  if self.index_state_fail_reason != Default::default() {
    json["indexStateFailReason"] = ToJson::to_json(self.index_state_fail_reason)
  }
  if self.pending_index_rows != Default::default() {
    json["pendingIndexRows"] = ToJson::to_json(self.pending_index_rows)
  }
  if self.min_index_version != Default::default() {
    json["minIndexVersion"] = ToJson::to_json(self.min_index_version)
  }
  if self.max_index_version != Default::default() {
    json["maxIndexVersion"] = ToJson::to_json(self.max_index_version)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for IndexDescription with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> IndexDescription raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for IndexDescription"),
    )
  }
  let message : IndexDescription = Default::default()
  for key, value in obj {
    match (key, value) {
      ("indexName", value) => message.index_name = @json.from_json(value, path~)
      ("indexID", value) => message.index_id = @json.from_json(value, path~)
      ("params", Array(value)) =>
        message.params = value.map(v => @json.from_json(v, path~))
      ("fieldName", value) => message.field_name = @json.from_json(value, path~)
      ("indexedRows", value) =>
        message.indexed_rows = @json.from_json(value, path~)
      ("totalRows", value) => message.total_rows = @json.from_json(value, path~)
      ("state", value) => message.state = @json.from_json(value, path~)
      ("indexStateFailReason", value) =>
        message.index_state_fail_reason = @json.from_json(value, path~)
      ("pendingIndexRows", value) =>
        message.pending_index_rows = @json.from_json(value, path~)
      ("minIndexVersion", value) =>
        message.min_index_version = @json.from_json(value, path~)
      ("maxIndexVersion", value) =>
        message.max_index_version = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for IndexDescription with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> IndexDescription raise {
  let msg : IndexDescription = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.index_name = reader |> @lib.async_read_string()
      (2, _) => msg.index_id = reader |> @lib.async_read_int64()
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (4, _) => msg.field_name = reader |> @lib.async_read_string()
      (5, _) => msg.indexed_rows = reader |> @lib.async_read_int64()
      (6, _) => msg.total_rows = reader |> @lib.async_read_int64()
      (7, _) =>
        msg.state = reader
          |> @lib.async_read_enum()
          |> @common.IndexState::from_enum
      (8, _) => msg.index_state_fail_reason = reader |> @lib.async_read_string()
      (9, _) => msg.pending_index_rows = reader |> @lib.async_read_int64()
      (10, _) => msg.min_index_version = reader |> @lib.async_read_int32()
      (11, _) => msg.max_index_version = reader |> @lib.async_read_int32()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for IndexDescription with fn write(
  self : IndexDescription,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.index_name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.index_name)
  }
  if self.index_id != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.index_id)
  }
  for item in self.params {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
  if self.field_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.field_name)
  }
  if self.indexed_rows != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_int64(self.indexed_rows)
  }
  if self.total_rows != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_int64(self.total_rows)
  }
  if self.state != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_enum(self.state.to_enum())
  }
  if self.index_state_fail_reason != Default::default() {
    writer |> @lib.async_write_varint(66UL)
    writer |> @lib.async_write_string(self.index_state_fail_reason)
  }
  if self.pending_index_rows != Default::default() {
    writer |> @lib.async_write_varint(72UL)
    writer |> @lib.async_write_int64(self.pending_index_rows)
  }
  if self.min_index_version != Default::default() {
    writer |> @lib.async_write_varint(80UL)
    writer |> @lib.async_write_int32(self.min_index_version)
  }
  if self.max_index_version != Default::default() {
    writer |> @lib.async_write_varint(88UL)
    writer |> @lib.async_write_int32(self.max_index_version)
  }
}

///|
pub(all) struct DescribeIndexResponse {
  mut status : @common.Status?
  mut index_descriptions : Array[IndexDescription]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DescribeIndexResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  for s in self.index_descriptions {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for DescribeIndexResponse with fn default() -> DescribeIndexResponse {
  DescribeIndexResponse::{ status: None, index_descriptions: [], }
}

///|
#alias(new, deprecated)
pub fn DescribeIndexResponse::DescribeIndexResponse(
  status? : @common.Status,
  index_descriptions : Array[IndexDescription],
) -> DescribeIndexResponse {
  DescribeIndexResponse::{ status, index_descriptions, }
}

///|
pub impl @lib.Read for DescribeIndexResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DescribeIndexResponse raise {
  let msg : DescribeIndexResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.index_descriptions.push(
          (reader |> @lib.read_message() : IndexDescription),
        )
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DescribeIndexResponse with fn write(
  self : DescribeIndexResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  for item in self.index_descriptions {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(item)
  }
}

///|
pub impl ToJson for DescribeIndexResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.index_descriptions != Default::default() {
    json["indexDescriptions"] = ToJson::to_json(self.index_descriptions)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DescribeIndexResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DescribeIndexResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DescribeIndexResponse"),
    )
  }
  let message : DescribeIndexResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("indexDescriptions", Array(value)) =>
        message.index_descriptions = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DescribeIndexResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DescribeIndexResponse raise {
  let msg : DescribeIndexResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.index_descriptions.push(
          (reader |> @lib.async_read_message() : IndexDescription),
        )
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DescribeIndexResponse with fn write(
  self : DescribeIndexResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  for item in self.index_descriptions {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(item)
  }
}

///|
pub(all) struct DropIndexRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut field_name : String
  mut index_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DropIndexRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.field_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.field_name),
    )
  }
  if self.index_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      5U,
      @lib.size_of(self.index_name),
    )
  }
  size
}

///|
pub impl Default for DropIndexRequest with fn default() -> DropIndexRequest {
  DropIndexRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    field_name: Default::default(),
    index_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn DropIndexRequest::DropIndexRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  field_name : String,
  index_name : String,
) -> DropIndexRequest {
  DropIndexRequest::{ base, db_name, collection_name, field_name, index_name, }
}

///|
pub impl @lib.Read for DropIndexRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DropIndexRequest raise {
  let msg : DropIndexRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.field_name = reader |> @lib.read_string()
      (5, _) => msg.index_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DropIndexRequest with fn write(
  self : DropIndexRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.field_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.field_name)
  }
  if self.index_name != Default::default() {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(self.index_name)
  }
}

///|
pub impl ToJson for DropIndexRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.field_name != Default::default() {
    json["fieldName"] = ToJson::to_json(self.field_name)
  }
  if self.index_name != Default::default() {
    json["indexName"] = ToJson::to_json(self.index_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DropIndexRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DropIndexRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DropIndexRequest"),
    )
  }
  let message : DropIndexRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("fieldName", value) => message.field_name = @json.from_json(value, path~)
      ("indexName", value) => message.index_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DropIndexRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DropIndexRequest raise {
  let msg : DropIndexRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.field_name = reader |> @lib.async_read_string()
      (5, _) => msg.index_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DropIndexRequest with fn write(
  self : DropIndexRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.field_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.field_name)
  }
  if self.index_name != Default::default() {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(self.index_name)
  }
}

///|
pub(all) struct LoadCollectionRequest_LoadParamsEntry {
  mut key : String
  mut value : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for LoadCollectionRequest_LoadParamsEntry with fn size_of(
  self,
) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for LoadCollectionRequest_LoadParamsEntry with fn default() -> LoadCollectionRequest_LoadParamsEntry {
  LoadCollectionRequest_LoadParamsEntry::{
    key: Default::default(),
    value: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn LoadCollectionRequest_LoadParamsEntry::LoadCollectionRequest_LoadParamsEntry(
  key : String,
  value : String,
) -> LoadCollectionRequest_LoadParamsEntry {
  LoadCollectionRequest_LoadParamsEntry::{ key, value, }
}

///|
pub impl @lib.Read for LoadCollectionRequest_LoadParamsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> LoadCollectionRequest_LoadParamsEntry raise {
  let msg : LoadCollectionRequest_LoadParamsEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for LoadCollectionRequest_LoadParamsEntry with fn write(
  self : LoadCollectionRequest_LoadParamsEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.value)
  }
}

///|
pub impl ToJson for LoadCollectionRequest_LoadParamsEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for LoadCollectionRequest_LoadParamsEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> LoadCollectionRequest_LoadParamsEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for LoadCollectionRequest_LoadParamsEntry"),
    )
  }
  let message : LoadCollectionRequest_LoadParamsEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for LoadCollectionRequest_LoadParamsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> LoadCollectionRequest_LoadParamsEntry raise {
  let msg : LoadCollectionRequest_LoadParamsEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for LoadCollectionRequest_LoadParamsEntry with fn write(
  self : LoadCollectionRequest_LoadParamsEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.value)
  }
}

///|
pub(all) struct LoadCollectionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut replica_number : Int
  mut resource_groups : Array[String]
  mut refresh : Bool
  mut load_fields : Array[String]
  mut skip_load_dynamic_field : Bool
  mut load_params : Map[String, String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for LoadCollectionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.replica_number != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.replica_number))
  }
  for s in self.resource_groups {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  if self.refresh != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.refresh))
  }
  for s in self.load_fields {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(s))
  }
  if self.skip_load_dynamic_field != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.skip_load_dynamic_field))
  }
  for k, v in self.load_params {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(9U, key_size + value_size)
  }
  size
}

///|
pub impl Default for LoadCollectionRequest with fn default() -> LoadCollectionRequest {
  LoadCollectionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    replica_number: Default::default(),
    resource_groups: [],
    refresh: Default::default(),
    load_fields: [],
    skip_load_dynamic_field: Default::default(),
    load_params: {},
  }
}

///|
#alias(new, deprecated)
pub fn LoadCollectionRequest::LoadCollectionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  replica_number : Int,
  resource_groups : Array[String],
  refresh : Bool,
  load_fields : Array[String],
  skip_load_dynamic_field : Bool,
  load_params : Map[String, String],
) -> LoadCollectionRequest {
  LoadCollectionRequest::{
    base,
    db_name,
    collection_name,
    replica_number,
    resource_groups,
    refresh,
    load_fields,
    skip_load_dynamic_field,
    load_params,
  }
}

///|
pub impl @lib.Read for LoadCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> LoadCollectionRequest raise {
  let msg : LoadCollectionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.replica_number = reader |> @lib.read_int32()
      (5, _) => msg.resource_groups.push(reader |> @lib.read_string())
      (6, _) => msg.refresh = reader |> @lib.read_bool()
      (7, _) => msg.load_fields.push(reader |> @lib.read_string())
      (8, _) => msg.skip_load_dynamic_field = reader |> @lib.read_bool()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : LoadCollectionRequest_LoadParamsEntry)
        msg.load_params[key] = value
      }
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for LoadCollectionRequest with fn write(
  self : LoadCollectionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.replica_number != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_int32(self.replica_number)
  }
  for item in self.resource_groups {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(item)
  }
  if self.refresh != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_bool(self.refresh)
  }
  for item in self.load_fields {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_string(item)
  }
  if self.skip_load_dynamic_field != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_bool(self.skip_load_dynamic_field)
  }
  let keys = self.load_params.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.load_params.get(k).unwrap()
    writer |> @lib.write_varint(74UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(v)
  }
}

///|
pub impl ToJson for LoadCollectionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.replica_number != Default::default() {
    json["replicaNumber"] = ToJson::to_json(self.replica_number)
  }
  if self.resource_groups != Default::default() {
    json["resourceGroups"] = ToJson::to_json(self.resource_groups)
  }
  if self.refresh != Default::default() {
    json["refresh"] = ToJson::to_json(self.refresh)
  }
  if self.load_fields != Default::default() {
    json["loadFields"] = ToJson::to_json(self.load_fields)
  }
  if self.skip_load_dynamic_field != Default::default() {
    json["skipLoadDynamicField"] = ToJson::to_json(self.skip_load_dynamic_field)
  }
  if self.load_params != Default::default() {
    json["loadParams"] = ToJson::to_json(self.load_params)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for LoadCollectionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> LoadCollectionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for LoadCollectionRequest"),
    )
  }
  let message : LoadCollectionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("replicaNumber", value) =>
        message.replica_number = @json.from_json(value, path~)
      ("resourceGroups", Array(value)) =>
        message.resource_groups = value.map(v => @json.from_json(v, path~))
      ("refresh", value) => message.refresh = @json.from_json(value, path~)
      ("loadFields", Array(value)) =>
        message.load_fields = value.map(v => @json.from_json(v, path~))
      ("skipLoadDynamicField", value) =>
        message.skip_load_dynamic_field = @json.from_json(value, path~)
      ("loadParams", _) => message.load_params = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for LoadCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> LoadCollectionRequest raise {
  let msg : LoadCollectionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.replica_number = reader |> @lib.async_read_int32()
      (5, _) => msg.resource_groups.push(reader |> @lib.async_read_string())
      (6, _) => msg.refresh = reader |> @lib.async_read_bool()
      (7, _) => msg.load_fields.push(reader |> @lib.async_read_string())
      (8, _) => msg.skip_load_dynamic_field = reader |> @lib.async_read_bool()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() :
          LoadCollectionRequest_LoadParamsEntry)
        msg.load_params[key] = value
      }
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for LoadCollectionRequest with fn write(
  self : LoadCollectionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.replica_number != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_int32(self.replica_number)
  }
  for item in self.resource_groups {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(item)
  }
  if self.refresh != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_bool(self.refresh)
  }
  for item in self.load_fields {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_string(item)
  }
  if self.skip_load_dynamic_field != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_bool(self.skip_load_dynamic_field)
  }
  let keys = self.load_params.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.load_params.get(k).unwrap()
    writer |> @lib.async_write_varint(74UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(v)
  }
}

///|
pub(all) struct ReleaseCollectionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ReleaseCollectionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  size
}

///|
pub impl Default for ReleaseCollectionRequest with fn default() -> ReleaseCollectionRequest {
  ReleaseCollectionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn ReleaseCollectionRequest::ReleaseCollectionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
) -> ReleaseCollectionRequest {
  ReleaseCollectionRequest::{ base, db_name, collection_name, }
}

///|
pub impl @lib.Read for ReleaseCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ReleaseCollectionRequest raise {
  let msg : ReleaseCollectionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ReleaseCollectionRequest with fn write(
  self : ReleaseCollectionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
}

///|
pub impl ToJson for ReleaseCollectionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ReleaseCollectionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ReleaseCollectionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ReleaseCollectionRequest"),
    )
  }
  let message : ReleaseCollectionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ReleaseCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ReleaseCollectionRequest raise {
  let msg : ReleaseCollectionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ReleaseCollectionRequest with fn write(
  self : ReleaseCollectionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
}

///|
pub(all) struct GetLoadStateRequest {
  mut base : @common.MsgBase?
  mut collection_name : String
  mut partition_names : Array[String]
  mut db_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for GetLoadStateRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      2U,
      @lib.size_of(self.collection_name),
    )
  }
  for s in self.partition_names {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(self.db_name))
  }
  size
}

///|
pub impl Default for GetLoadStateRequest with fn default() -> GetLoadStateRequest {
  GetLoadStateRequest::{
    base: None,
    collection_name: Default::default(),
    partition_names: [],
    db_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn GetLoadStateRequest::GetLoadStateRequest(
  base? : @common.MsgBase,
  collection_name : String,
  partition_names : Array[String],
  db_name : String,
) -> GetLoadStateRequest {
  GetLoadStateRequest::{ base, collection_name, partition_names, db_name, }
}

///|
pub impl @lib.Read for GetLoadStateRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> GetLoadStateRequest raise {
  let msg : GetLoadStateRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.collection_name = reader |> @lib.read_string()
      (3, _) => msg.partition_names.push(reader |> @lib.read_string())
      (4, _) => msg.db_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GetLoadStateRequest with fn write(
  self : GetLoadStateRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(item)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.db_name)
  }
}

///|
pub impl ToJson for GetLoadStateRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_names != Default::default() {
    json["partitionNames"] = ToJson::to_json(self.partition_names)
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GetLoadStateRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> GetLoadStateRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GetLoadStateRequest"),
    )
  }
  let message : GetLoadStateRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionNames", Array(value)) =>
        message.partition_names = value.map(v => @json.from_json(v, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for GetLoadStateRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> GetLoadStateRequest raise {
  let msg : GetLoadStateRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.collection_name = reader |> @lib.async_read_string()
      (3, _) => msg.partition_names.push(reader |> @lib.async_read_string())
      (4, _) => msg.db_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for GetLoadStateRequest with fn write(
  self : GetLoadStateRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(item)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.db_name)
  }
}

///|
pub(all) struct GetLoadStateResponse {
  mut status : @common.Status?
  mut state : @common.LoadState
} derive(Eq, Debug)

///|
pub impl @lib.Sized for GetLoadStateResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.state != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.state))
  }
  size
}

///|
pub impl Default for GetLoadStateResponse with fn default() -> GetLoadStateResponse {
  GetLoadStateResponse::{ status: None, state: Default::default(), }
}

///|
#alias(new, deprecated)
pub fn GetLoadStateResponse::GetLoadStateResponse(
  status? : @common.Status,
  state : @common.LoadState,
) -> GetLoadStateResponse {
  GetLoadStateResponse::{ status, state, }
}

///|
pub impl @lib.Read for GetLoadStateResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> GetLoadStateResponse raise {
  let msg : GetLoadStateResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, _) =>
        msg.state = reader |> @lib.read_enum() |> @common.LoadState::from_enum
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GetLoadStateResponse with fn write(
  self : GetLoadStateResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.state != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_enum(self.state.to_enum())
  }
}

///|
pub impl ToJson for GetLoadStateResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.state != Default::default() {
    json["state"] = ToJson::to_json(self.state)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GetLoadStateResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> GetLoadStateResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GetLoadStateResponse"),
    )
  }
  let message : GetLoadStateResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("state", value) => message.state = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for GetLoadStateResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> GetLoadStateResponse raise {
  let msg : GetLoadStateResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, _) =>
        msg.state = reader
          |> @lib.async_read_enum()
          |> @common.LoadState::from_enum
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for GetLoadStateResponse with fn write(
  self : GetLoadStateResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.state != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_enum(self.state.to_enum())
  }
}

///|
pub(all) struct DescribeCollectionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut collection_id : Int64
  mut time_stamp : UInt64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DescribeCollectionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.collection_id != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.collection_id))
  }
  if self.time_stamp != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.time_stamp))
  }
  size
}

///|
pub impl Default for DescribeCollectionRequest with fn default() -> DescribeCollectionRequest {
  DescribeCollectionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    collection_id: Default::default(),
    time_stamp: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn DescribeCollectionRequest::DescribeCollectionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  collection_id : Int64,
  time_stamp : UInt64,
) -> DescribeCollectionRequest {
  DescribeCollectionRequest::{
    base,
    db_name,
    collection_name,
    collection_id,
    time_stamp,
  }
}

///|
pub impl @lib.Read for DescribeCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DescribeCollectionRequest raise {
  let msg : DescribeCollectionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.collection_id = reader |> @lib.read_int64()
      (5, _) => msg.time_stamp = reader |> @lib.read_uint64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DescribeCollectionRequest with fn write(
  self : DescribeCollectionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.collection_id != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_int64(self.collection_id)
  }
  if self.time_stamp != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_uint64(self.time_stamp)
  }
}

///|
pub impl ToJson for DescribeCollectionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.collection_id != Default::default() {
    json["collectionID"] = ToJson::to_json(self.collection_id)
  }
  if self.time_stamp != Default::default() {
    json["timeStamp"] = ToJson::to_json(self.time_stamp)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DescribeCollectionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DescribeCollectionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DescribeCollectionRequest"),
    )
  }
  let message : DescribeCollectionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("collectionID", value) =>
        message.collection_id = @json.from_json(value, path~)
      ("timeStamp", value) => message.time_stamp = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DescribeCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DescribeCollectionRequest raise {
  let msg : DescribeCollectionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.collection_id = reader |> @lib.async_read_int64()
      (5, _) => msg.time_stamp = reader |> @lib.async_read_uint64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DescribeCollectionRequest with fn write(
  self : DescribeCollectionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.collection_id != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_int64(self.collection_id)
  }
  if self.time_stamp != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_uint64(self.time_stamp)
  }
}

///|
pub(all) struct DescribeCollectionResponse {
  mut status : @common.Status?
  mut schema : @schema.CollectionSchema?
  mut collection_id : Int64
  mut virtual_channel_names : Array[String]
  mut physical_channel_names : Array[String]
  mut created_timestamp : UInt64
  mut created_utc_timestamp : UInt64
  mut shards_num : Int
  mut aliases : Array[String]
  mut start_positions : Array[@common.KeyDataPair]
  mut consistency_level : @common.ConsistencyLevel
  mut collection_name : String
  mut properties : Array[@common.KeyValuePair]
  mut db_name : String
  mut num_partitions : Int64
  mut db_id : Int64
  mut request_time : UInt64
  mut update_timestamp : UInt64
  mut update_timestamp_str : String
  mut shard_infos : Array[@schema.CollectionShardInfo]
  mut shard_by : String
  mut routing_modulus : UInt64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DescribeCollectionResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.schema is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.collection_id != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.collection_id))
  }
  for s in self.virtual_channel_names {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  for s in self.physical_channel_names {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  if self.created_timestamp != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.created_timestamp))
  }
  if self.created_utc_timestamp != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.created_utc_timestamp))
  }
  if self.shards_num != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.shards_num))
  }
  for s in self.aliases {
    size += @lib.size_of_length_delimited_field(9U, @lib.size_of(s))
  }
  for s in self.start_positions {
    size += @lib.size_of_length_delimited_field(10U, @lib.size_of(s))
  }
  if self.consistency_level != Default::default() {
    size += @lib.size_of_field(11U, @lib.size_of(self.consistency_level))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      12U,
      @lib.size_of(self.collection_name),
    )
  }
  for s in self.properties {
    size += @lib.size_of_length_delimited_field(13U, @lib.size_of(s))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(14U, @lib.size_of(self.db_name))
  }
  if self.num_partitions != Default::default() {
    size += @lib.size_of_field(15U, @lib.size_of(self.num_partitions))
  }
  if self.db_id != Default::default() {
    size += @lib.size_of_field(16U, @lib.size_of(self.db_id))
  }
  if self.request_time != Default::default() {
    size += @lib.size_of_field(17U, @lib.size_of(self.request_time))
  }
  if self.update_timestamp != Default::default() {
    size += @lib.size_of_field(18U, @lib.size_of(self.update_timestamp))
  }
  if self.update_timestamp_str != Default::default() {
    size += @lib.size_of_length_delimited_field(
      19U,
      @lib.size_of(self.update_timestamp_str),
    )
  }
  for s in self.shard_infos {
    size += @lib.size_of_length_delimited_field(20U, @lib.size_of(s))
  }
  if self.shard_by != Default::default() {
    size += @lib.size_of_length_delimited_field(
      21U,
      @lib.size_of(self.shard_by),
    )
  }
  if self.routing_modulus != Default::default() {
    size += @lib.size_of_field(22U, @lib.size_of(self.routing_modulus))
  }
  size
}

///|
pub impl Default for DescribeCollectionResponse with fn default() -> DescribeCollectionResponse {
  DescribeCollectionResponse::{
    status: None,
    schema: None,
    collection_id: Default::default(),
    virtual_channel_names: [],
    physical_channel_names: [],
    created_timestamp: Default::default(),
    created_utc_timestamp: Default::default(),
    shards_num: Default::default(),
    aliases: [],
    start_positions: [],
    consistency_level: Default::default(),
    collection_name: Default::default(),
    properties: [],
    db_name: Default::default(),
    num_partitions: Default::default(),
    db_id: Default::default(),
    request_time: Default::default(),
    update_timestamp: Default::default(),
    update_timestamp_str: Default::default(),
    shard_infos: [],
    shard_by: Default::default(),
    routing_modulus: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn DescribeCollectionResponse::DescribeCollectionResponse(
  status? : @common.Status,
  schema? : @schema.CollectionSchema,
  collection_id : Int64,
  virtual_channel_names : Array[String],
  physical_channel_names : Array[String],
  created_timestamp : UInt64,
  created_utc_timestamp : UInt64,
  shards_num : Int,
  aliases : Array[String],
  start_positions : Array[@common.KeyDataPair],
  consistency_level : @common.ConsistencyLevel,
  collection_name : String,
  properties : Array[@common.KeyValuePair],
  db_name : String,
  num_partitions : Int64,
  db_id : Int64,
  request_time : UInt64,
  update_timestamp : UInt64,
  update_timestamp_str : String,
  shard_infos : Array[@schema.CollectionShardInfo],
  shard_by : String,
  routing_modulus : UInt64,
) -> DescribeCollectionResponse {
  DescribeCollectionResponse::{
    status,
    schema,
    collection_id,
    virtual_channel_names,
    physical_channel_names,
    created_timestamp,
    created_utc_timestamp,
    shards_num,
    aliases,
    start_positions,
    consistency_level,
    collection_name,
    properties,
    db_name,
    num_partitions,
    db_id,
    request_time,
    update_timestamp,
    update_timestamp_str,
    shard_infos,
    shard_by,
    routing_modulus,
  }
}

///|
pub impl @lib.Read for DescribeCollectionResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DescribeCollectionResponse raise {
  let msg : DescribeCollectionResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.schema = (reader |> @lib.read_message() : @schema.CollectionSchema)
          |> Some
      (3, _) => msg.collection_id = reader |> @lib.read_int64()
      (4, _) => msg.virtual_channel_names.push(reader |> @lib.read_string())
      (5, _) => msg.physical_channel_names.push(reader |> @lib.read_string())
      (6, _) => msg.created_timestamp = reader |> @lib.read_uint64()
      (7, _) => msg.created_utc_timestamp = reader |> @lib.read_uint64()
      (8, _) => msg.shards_num = reader |> @lib.read_int32()
      (9, _) => msg.aliases.push(reader |> @lib.read_string())
      (10, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.start_positions.push(
          (reader |> @lib.read_message() : @common.KeyDataPair),
        )
      (11, _) =>
        msg.consistency_level = reader
          |> @lib.read_enum()
          |> @common.ConsistencyLevel::from_enum
      (12, _) => msg.collection_name = reader |> @lib.read_string()
      (13, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.properties.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (14, _) => msg.db_name = reader |> @lib.read_string()
      (15, _) => msg.num_partitions = reader |> @lib.read_int64()
      (16, _) => msg.db_id = reader |> @lib.read_int64()
      (17, _) => msg.request_time = reader |> @lib.read_uint64()
      (18, _) => msg.update_timestamp = reader |> @lib.read_uint64()
      (19, _) => msg.update_timestamp_str = reader |> @lib.read_string()
      (20, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.shard_infos.push(
          (reader |> @lib.read_message() : @schema.CollectionShardInfo),
        )
      (21, _) => msg.shard_by = reader |> @lib.read_string()
      (22, _) => msg.routing_modulus = reader |> @lib.read_uint64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DescribeCollectionResponse with fn write(
  self : DescribeCollectionResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.schema is Some(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(v)
  }
  if self.collection_id != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_int64(self.collection_id)
  }
  for item in self.virtual_channel_names {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(item)
  }
  for item in self.physical_channel_names {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(item)
  }
  if self.created_timestamp != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_uint64(self.created_timestamp)
  }
  if self.created_utc_timestamp != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_uint64(self.created_utc_timestamp)
  }
  if self.shards_num != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_int32(self.shards_num)
  }
  for item in self.aliases {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_string(item)
  }
  for item in self.start_positions {
    writer |> @lib.write_varint(82UL)
    writer |> @lib.write_message(item)
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.write_varint(88UL)
    writer |> @lib.write_enum(self.consistency_level.to_enum())
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(98UL)
    writer |> @lib.write_string(self.collection_name)
  }
  for item in self.properties {
    writer |> @lib.write_varint(106UL)
    writer |> @lib.write_message(item)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(114UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.num_partitions != Default::default() {
    writer |> @lib.write_varint(120UL)
    writer |> @lib.write_int64(self.num_partitions)
  }
  if self.db_id != Default::default() {
    writer |> @lib.write_varint(128UL)
    writer |> @lib.write_int64(self.db_id)
  }
  if self.request_time != Default::default() {
    writer |> @lib.write_varint(136UL)
    writer |> @lib.write_uint64(self.request_time)
  }
  if self.update_timestamp != Default::default() {
    writer |> @lib.write_varint(144UL)
    writer |> @lib.write_uint64(self.update_timestamp)
  }
  if self.update_timestamp_str != Default::default() {
    writer |> @lib.write_varint(154UL)
    writer |> @lib.write_string(self.update_timestamp_str)
  }
  for item in self.shard_infos {
    writer |> @lib.write_varint(162UL)
    writer |> @lib.write_message(item)
  }
  if self.shard_by != Default::default() {
    writer |> @lib.write_varint(170UL)
    writer |> @lib.write_string(self.shard_by)
  }
  if self.routing_modulus != Default::default() {
    writer |> @lib.write_varint(176UL)
    writer |> @lib.write_uint64(self.routing_modulus)
  }
}

///|
pub impl ToJson for DescribeCollectionResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  match self.schema {
    Some(v) => json["schema"] = ToJson::to_json(v)
    _ => ()
  }
  if self.collection_id != Default::default() {
    json["collectionID"] = ToJson::to_json(self.collection_id)
  }
  if self.virtual_channel_names != Default::default() {
    json["virtualChannelNames"] = ToJson::to_json(self.virtual_channel_names)
  }
  if self.physical_channel_names != Default::default() {
    json["physicalChannelNames"] = ToJson::to_json(self.physical_channel_names)
  }
  if self.created_timestamp != Default::default() {
    json["createdTimestamp"] = ToJson::to_json(self.created_timestamp)
  }
  if self.created_utc_timestamp != Default::default() {
    json["createdUtcTimestamp"] = ToJson::to_json(self.created_utc_timestamp)
  }
  if self.shards_num != Default::default() {
    json["shardsNum"] = ToJson::to_json(self.shards_num)
  }
  if self.aliases != Default::default() {
    json["aliases"] = ToJson::to_json(self.aliases)
  }
  if self.start_positions != Default::default() {
    json["startPositions"] = ToJson::to_json(self.start_positions)
  }
  if self.consistency_level != Default::default() {
    json["consistencyLevel"] = ToJson::to_json(self.consistency_level)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.properties != Default::default() {
    json["properties"] = ToJson::to_json(self.properties)
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.num_partitions != Default::default() {
    json["numPartitions"] = ToJson::to_json(self.num_partitions)
  }
  if self.db_id != Default::default() {
    json["dbId"] = ToJson::to_json(self.db_id)
  }
  if self.request_time != Default::default() {
    json["requestTime"] = ToJson::to_json(self.request_time)
  }
  if self.update_timestamp != Default::default() {
    json["updateTimestamp"] = ToJson::to_json(self.update_timestamp)
  }
  if self.update_timestamp_str != Default::default() {
    json["updateTimestampStr"] = ToJson::to_json(self.update_timestamp_str)
  }
  if self.shard_infos != Default::default() {
    json["shardInfos"] = ToJson::to_json(self.shard_infos)
  }
  if self.shard_by != Default::default() {
    json["shardBy"] = ToJson::to_json(self.shard_by)
  }
  if self.routing_modulus != Default::default() {
    json["routingModulus"] = ToJson::to_json(self.routing_modulus)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DescribeCollectionResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DescribeCollectionResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DescribeCollectionResponse"),
    )
  }
  let message : DescribeCollectionResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("schema", value) => message.schema = Some(@json.from_json(value, path~))
      ("collectionID", value) =>
        message.collection_id = @json.from_json(value, path~)
      ("virtualChannelNames", Array(value)) =>
        message.virtual_channel_names = value.map(v => @json.from_json(v, path~))
      ("physicalChannelNames", Array(value)) =>
        message.physical_channel_names = value.map(v => {
          @json.from_json(v, path~)
        })
      ("createdTimestamp", value) =>
        message.created_timestamp = @json.from_json(value, path~)
      ("createdUtcTimestamp", value) =>
        message.created_utc_timestamp = @json.from_json(value, path~)
      ("shardsNum", value) => message.shards_num = @json.from_json(value, path~)
      ("aliases", Array(value)) =>
        message.aliases = value.map(v => @json.from_json(v, path~))
      ("startPositions", Array(value)) =>
        message.start_positions = value.map(v => @json.from_json(v, path~))
      ("consistencyLevel", value) =>
        message.consistency_level = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("properties", Array(value)) =>
        message.properties = value.map(v => @json.from_json(v, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("numPartitions", value) =>
        message.num_partitions = @json.from_json(value, path~)
      ("dbId", value) => message.db_id = @json.from_json(value, path~)
      ("requestTime", value) =>
        message.request_time = @json.from_json(value, path~)
      ("updateTimestamp", value) =>
        message.update_timestamp = @json.from_json(value, path~)
      ("updateTimestampStr", value) =>
        message.update_timestamp_str = @json.from_json(value, path~)
      ("shardInfos", Array(value)) =>
        message.shard_infos = value.map(v => @json.from_json(v, path~))
      ("shardBy", value) => message.shard_by = @json.from_json(value, path~)
      ("routingModulus", value) =>
        message.routing_modulus = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DescribeCollectionResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DescribeCollectionResponse raise {
  let msg : DescribeCollectionResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.schema = (
            reader |> @lib.async_read_message() : @schema.CollectionSchema)
          |> Some
      (3, _) => msg.collection_id = reader |> @lib.async_read_int64()
      (4, _) =>
        msg.virtual_channel_names.push(reader |> @lib.async_read_string())
      (5, _) =>
        msg.physical_channel_names.push(reader |> @lib.async_read_string())
      (6, _) => msg.created_timestamp = reader |> @lib.async_read_uint64()
      (7, _) => msg.created_utc_timestamp = reader |> @lib.async_read_uint64()
      (8, _) => msg.shards_num = reader |> @lib.async_read_int32()
      (9, _) => msg.aliases.push(reader |> @lib.async_read_string())
      (10, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.start_positions.push(
          (reader |> @lib.async_read_message() : @common.KeyDataPair),
        )
      (11, _) =>
        msg.consistency_level = reader
          |> @lib.async_read_enum()
          |> @common.ConsistencyLevel::from_enum
      (12, _) => msg.collection_name = reader |> @lib.async_read_string()
      (13, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.properties.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (14, _) => msg.db_name = reader |> @lib.async_read_string()
      (15, _) => msg.num_partitions = reader |> @lib.async_read_int64()
      (16, _) => msg.db_id = reader |> @lib.async_read_int64()
      (17, _) => msg.request_time = reader |> @lib.async_read_uint64()
      (18, _) => msg.update_timestamp = reader |> @lib.async_read_uint64()
      (19, _) => msg.update_timestamp_str = reader |> @lib.async_read_string()
      (20, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.shard_infos.push(
          (reader |> @lib.async_read_message() : @schema.CollectionShardInfo),
        )
      (21, _) => msg.shard_by = reader |> @lib.async_read_string()
      (22, _) => msg.routing_modulus = reader |> @lib.async_read_uint64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DescribeCollectionResponse with fn write(
  self : DescribeCollectionResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.schema is Some(v) {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(v)
  }
  if self.collection_id != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_int64(self.collection_id)
  }
  for item in self.virtual_channel_names {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(item)
  }
  for item in self.physical_channel_names {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(item)
  }
  if self.created_timestamp != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_uint64(self.created_timestamp)
  }
  if self.created_utc_timestamp != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_uint64(self.created_utc_timestamp)
  }
  if self.shards_num != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_int32(self.shards_num)
  }
  for item in self.aliases {
    writer |> @lib.async_write_varint(74UL)
    writer |> @lib.async_write_string(item)
  }
  for item in self.start_positions {
    writer |> @lib.async_write_varint(82UL)
    writer |> @lib.async_write_message(item)
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.async_write_varint(88UL)
    writer |> @lib.async_write_enum(self.consistency_level.to_enum())
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(98UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  for item in self.properties {
    writer |> @lib.async_write_varint(106UL)
    writer |> @lib.async_write_message(item)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(114UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.num_partitions != Default::default() {
    writer |> @lib.async_write_varint(120UL)
    writer |> @lib.async_write_int64(self.num_partitions)
  }
  if self.db_id != Default::default() {
    writer |> @lib.async_write_varint(128UL)
    writer |> @lib.async_write_int64(self.db_id)
  }
  if self.request_time != Default::default() {
    writer |> @lib.async_write_varint(136UL)
    writer |> @lib.async_write_uint64(self.request_time)
  }
  if self.update_timestamp != Default::default() {
    writer |> @lib.async_write_varint(144UL)
    writer |> @lib.async_write_uint64(self.update_timestamp)
  }
  if self.update_timestamp_str != Default::default() {
    writer |> @lib.async_write_varint(154UL)
    writer |> @lib.async_write_string(self.update_timestamp_str)
  }
  for item in self.shard_infos {
    writer |> @lib.async_write_varint(162UL)
    writer |> @lib.async_write_message(item)
  }
  if self.shard_by != Default::default() {
    writer |> @lib.async_write_varint(170UL)
    writer |> @lib.async_write_string(self.shard_by)
  }
  if self.routing_modulus != Default::default() {
    writer |> @lib.async_write_varint(176UL)
    writer |> @lib.async_write_uint64(self.routing_modulus)
  }
}

///|
pub(all) struct CreateCollectionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut schema : Bytes
  mut shards_num : Int
  mut consistency_level : @common.ConsistencyLevel
  mut properties : Array[@common.KeyValuePair]
  mut num_partitions : Int64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for CreateCollectionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.schema != Default::default() {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(self.schema))
  }
  if self.shards_num != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.shards_num))
  }
  if self.consistency_level != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.consistency_level))
  }
  for s in self.properties {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(s))
  }
  if self.num_partitions != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.num_partitions))
  }
  size
}

///|
pub impl Default for CreateCollectionRequest with fn default() -> CreateCollectionRequest {
  CreateCollectionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    schema: Default::default(),
    shards_num: Default::default(),
    consistency_level: Default::default(),
    properties: [],
    num_partitions: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn CreateCollectionRequest::CreateCollectionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  schema : Bytes,
  shards_num : Int,
  consistency_level : @common.ConsistencyLevel,
  properties : Array[@common.KeyValuePair],
  num_partitions : Int64,
) -> CreateCollectionRequest {
  CreateCollectionRequest::{
    base,
    db_name,
    collection_name,
    schema,
    shards_num,
    consistency_level,
    properties,
    num_partitions,
  }
}

///|
pub impl @lib.Read for CreateCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> CreateCollectionRequest raise {
  let msg : CreateCollectionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.schema = reader |> @lib.read_bytes()
      (5, _) => msg.shards_num = reader |> @lib.read_int32()
      (6, _) =>
        msg.consistency_level = reader
          |> @lib.read_enum()
          |> @common.ConsistencyLevel::from_enum
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.properties.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (8, _) => msg.num_partitions = reader |> @lib.read_int64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for CreateCollectionRequest with fn write(
  self : CreateCollectionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.schema != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_bytes(self.schema)
  }
  if self.shards_num != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_int32(self.shards_num)
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_enum(self.consistency_level.to_enum())
  }
  for item in self.properties {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_message(item)
  }
  if self.num_partitions != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_int64(self.num_partitions)
  }
}

///|
pub impl ToJson for CreateCollectionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.schema != Default::default() {
    json["schema"] = @lib.base64_encode(self.schema).to_json()
  }
  if self.shards_num != Default::default() {
    json["shardsNum"] = ToJson::to_json(self.shards_num)
  }
  if self.consistency_level != Default::default() {
    json["consistencyLevel"] = ToJson::to_json(self.consistency_level)
  }
  if self.properties != Default::default() {
    json["properties"] = ToJson::to_json(self.properties)
  }
  if self.num_partitions != Default::default() {
    json["numPartitions"] = ToJson::to_json(self.num_partitions)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for CreateCollectionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> CreateCollectionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for CreateCollectionRequest"),
    )
  }
  let message : CreateCollectionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("schema", String(value)) =>
        message.schema = @lib.base64_decode(value) catch {
          _ => raise @json.JsonDecodeError((path, "Invalid base64 encoding"))
        }
      ("shardsNum", value) => message.shards_num = @json.from_json(value, path~)
      ("consistencyLevel", value) =>
        message.consistency_level = @json.from_json(value, path~)
      ("properties", Array(value)) =>
        message.properties = value.map(v => @json.from_json(v, path~))
      ("numPartitions", value) =>
        message.num_partitions = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for CreateCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> CreateCollectionRequest raise {
  let msg : CreateCollectionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.schema = reader |> @lib.async_read_bytes()
      (5, _) => msg.shards_num = reader |> @lib.async_read_int32()
      (6, _) =>
        msg.consistency_level = reader
          |> @lib.async_read_enum()
          |> @common.ConsistencyLevel::from_enum
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.properties.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (8, _) => msg.num_partitions = reader |> @lib.async_read_int64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for CreateCollectionRequest with fn write(
  self : CreateCollectionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.schema != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_bytes(self.schema)
  }
  if self.shards_num != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_int32(self.shards_num)
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_enum(self.consistency_level.to_enum())
  }
  for item in self.properties {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_message(item)
  }
  if self.num_partitions != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_int64(self.num_partitions)
  }
}

///|
pub(all) struct DropCollectionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DropCollectionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  size
}

///|
pub impl Default for DropCollectionRequest with fn default() -> DropCollectionRequest {
  DropCollectionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn DropCollectionRequest::DropCollectionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
) -> DropCollectionRequest {
  DropCollectionRequest::{ base, db_name, collection_name, }
}

///|
pub impl @lib.Read for DropCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DropCollectionRequest raise {
  let msg : DropCollectionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DropCollectionRequest with fn write(
  self : DropCollectionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
}

///|
pub impl ToJson for DropCollectionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DropCollectionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DropCollectionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DropCollectionRequest"),
    )
  }
  let message : DropCollectionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DropCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DropCollectionRequest raise {
  let msg : DropCollectionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DropCollectionRequest with fn write(
  self : DropCollectionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
}

///|
pub(all) struct HasCollectionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut time_stamp : UInt64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for HasCollectionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.time_stamp != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.time_stamp))
  }
  size
}

///|
pub impl Default for HasCollectionRequest with fn default() -> HasCollectionRequest {
  HasCollectionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    time_stamp: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn HasCollectionRequest::HasCollectionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  time_stamp : UInt64,
) -> HasCollectionRequest {
  HasCollectionRequest::{ base, db_name, collection_name, time_stamp, }
}

///|
pub impl @lib.Read for HasCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> HasCollectionRequest raise {
  let msg : HasCollectionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.time_stamp = reader |> @lib.read_uint64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for HasCollectionRequest with fn write(
  self : HasCollectionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.time_stamp != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_uint64(self.time_stamp)
  }
}

///|
pub impl ToJson for HasCollectionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.time_stamp != Default::default() {
    json["timeStamp"] = ToJson::to_json(self.time_stamp)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for HasCollectionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> HasCollectionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for HasCollectionRequest"),
    )
  }
  let message : HasCollectionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("timeStamp", value) => message.time_stamp = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for HasCollectionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> HasCollectionRequest raise {
  let msg : HasCollectionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.time_stamp = reader |> @lib.async_read_uint64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for HasCollectionRequest with fn write(
  self : HasCollectionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.time_stamp != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_uint64(self.time_stamp)
  }
}

///|
pub(all) struct BoolResponse {
  mut status : @common.Status?
  mut value : Bool
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BoolResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.value != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for BoolResponse with fn default() -> BoolResponse {
  BoolResponse::{ status: None, value: Default::default(), }
}

///|
#alias(new, deprecated)
pub fn BoolResponse::BoolResponse(
  status? : @common.Status,
  value : Bool,
) -> BoolResponse {
  BoolResponse::{ status, value, }
}

///|
pub impl @lib.Read for BoolResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BoolResponse raise {
  let msg : BoolResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, _) => msg.value = reader |> @lib.read_bool()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BoolResponse with fn write(
  self : BoolResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_bool(self.value)
  }
}

///|
pub impl ToJson for BoolResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BoolResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BoolResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BoolResponse"))
  }
  let message : BoolResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BoolResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BoolResponse raise {
  let msg : BoolResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, _) => msg.value = reader |> @lib.async_read_bool()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BoolResponse with fn write(
  self : BoolResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_bool(self.value)
  }
}

///|
pub(all) struct ShowCollectionsRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut time_stamp : UInt64
  mut type_ : ShowType
  mut collection_names : Array[String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ShowCollectionsRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.time_stamp != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.time_stamp))
  }
  if self.type_ != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.type_))
  }
  for s in self.collection_names {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for ShowCollectionsRequest with fn default() -> ShowCollectionsRequest {
  ShowCollectionsRequest::{
    base: None,
    db_name: Default::default(),
    time_stamp: Default::default(),
    type_: Default::default(),
    collection_names: [],
  }
}

///|
#alias(new, deprecated)
pub fn ShowCollectionsRequest::ShowCollectionsRequest(
  base? : @common.MsgBase,
  db_name : String,
  time_stamp : UInt64,
  type_ : ShowType,
  collection_names : Array[String],
) -> ShowCollectionsRequest {
  ShowCollectionsRequest::{
    base,
    db_name,
    time_stamp,
    type_,
    collection_names,
  }
}

///|
pub impl @lib.Read for ShowCollectionsRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ShowCollectionsRequest raise {
  let msg : ShowCollectionsRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.time_stamp = reader |> @lib.read_uint64()
      (4, _) => msg.type_ = reader |> @lib.read_enum() |> ShowType::from_enum
      (5, _) => msg.collection_names.push(reader |> @lib.read_string())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ShowCollectionsRequest with fn write(
  self : ShowCollectionsRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.time_stamp != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_uint64(self.time_stamp)
  }
  if self.type_ != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_enum(self.type_.to_enum())
  }
  for item in self.collection_names {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(item)
  }
}

///|
pub impl ToJson for ShowCollectionsRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.time_stamp != Default::default() {
    json["timeStamp"] = ToJson::to_json(self.time_stamp)
  }
  if self.type_ != Default::default() {
    json["type"] = ToJson::to_json(self.type_)
  }
  if self.collection_names != Default::default() {
    json["collectionNames"] = ToJson::to_json(self.collection_names)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ShowCollectionsRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ShowCollectionsRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ShowCollectionsRequest"),
    )
  }
  let message : ShowCollectionsRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("timeStamp", value) => message.time_stamp = @json.from_json(value, path~)
      ("type", value) => message.type_ = @json.from_json(value, path~)
      ("collectionNames", Array(value)) =>
        message.collection_names = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ShowCollectionsRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ShowCollectionsRequest raise {
  let msg : ShowCollectionsRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.time_stamp = reader |> @lib.async_read_uint64()
      (4, _) =>
        msg.type_ = reader |> @lib.async_read_enum() |> ShowType::from_enum
      (5, _) => msg.collection_names.push(reader |> @lib.async_read_string())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ShowCollectionsRequest with fn write(
  self : ShowCollectionsRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.time_stamp != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_uint64(self.time_stamp)
  }
  if self.type_ != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_enum(self.type_.to_enum())
  }
  for item in self.collection_names {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(item)
  }
}

///|
pub(all) struct ShowCollectionsResponse {
  mut status : @common.Status?
  mut collection_names : Array[String]
  mut collection_ids : Array[Int64]
  mut created_timestamps : Array[UInt64]
  mut created_utc_timestamps : Array[UInt64]
  mut in_memory_percentages : Array[Int64]
  mut query_service_available : Array[Bool]
  mut shards_num : Array[Int]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ShowCollectionsResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  for s in self.collection_names {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  if !self.collection_ids.is_empty() {
    size += @lib.size_of_length_delimited_field(
      3U,
      self.collection_ids.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if !self.created_timestamps.is_empty() {
    size += @lib.size_of_length_delimited_field(
      4U,
      self.created_timestamps.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if !self.created_utc_timestamps.is_empty() {
    size += @lib.size_of_length_delimited_field(
      5U,
      self.created_utc_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add),
    )
  }
  if !self.in_memory_percentages.is_empty() {
    size += @lib.size_of_length_delimited_field(
      6U,
      self.in_memory_percentages
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add),
    )
  }
  if !self.query_service_available.is_empty() {
    size += @lib.size_of_length_delimited_field(
      7U,
      self.query_service_available
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add),
    )
  }
  if !self.shards_num.is_empty() {
    size += @lib.size_of_length_delimited_field(
      8U,
      self.shards_num.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  size
}

///|
pub impl Default for ShowCollectionsResponse with fn default() -> ShowCollectionsResponse {
  ShowCollectionsResponse::{
    status: None,
    collection_names: [],
    collection_ids: [],
    created_timestamps: [],
    created_utc_timestamps: [],
    in_memory_percentages: [],
    query_service_available: [],
    shards_num: [],
  }
}

///|
#alias(new, deprecated)
pub fn ShowCollectionsResponse::ShowCollectionsResponse(
  status? : @common.Status,
  collection_names : Array[String],
  collection_ids : Array[Int64],
  created_timestamps : Array[UInt64],
  created_utc_timestamps : Array[UInt64],
  in_memory_percentages : Array[Int64],
  query_service_available : Array[Bool],
  shards_num : Array[Int],
) -> ShowCollectionsResponse {
  ShowCollectionsResponse::{
    status,
    collection_names,
    collection_ids,
    created_timestamps,
    created_utc_timestamps,
    in_memory_percentages,
    query_service_available,
    shards_num,
  }
}

///|
pub impl @lib.Read for ShowCollectionsResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ShowCollectionsResponse raise {
  let msg : ShowCollectionsResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, _) => msg.collection_names.push(reader |> @lib.read_string())
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.collection_ids.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (3, @lib.WIRE_TYPE_VARINT) =>
        msg.collection_ids.push(reader |> @lib.read_int64())
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.created_timestamps.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint64, None)).iter(),
        )
      (4, @lib.WIRE_TYPE_VARINT) =>
        msg.created_timestamps.push(reader |> @lib.read_uint64())
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.created_utc_timestamps.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint64, None)).iter(),
        )
      (5, @lib.WIRE_TYPE_VARINT) =>
        msg.created_utc_timestamps.push(reader |> @lib.read_uint64())
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.in_memory_percentages.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.in_memory_percentages.push(reader |> @lib.read_int64())
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.query_service_available.push_iter(
          (reader |> @lib.read_packed(@lib.read_bool, None)).iter(),
        )
      (7, @lib.WIRE_TYPE_VARINT) =>
        msg.query_service_available.push(reader |> @lib.read_bool())
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.shards_num.push_iter(
          (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
        )
      (8, @lib.WIRE_TYPE_VARINT) =>
        msg.shards_num.push(reader |> @lib.read_int32())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ShowCollectionsResponse with fn write(
  self : ShowCollectionsResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  for item in self.collection_names {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(item)
  }
  if !self.collection_ids.is_empty() {
    writer |> @lib.write_varint(26UL)
    let size = self.collection_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.collection_ids {
      writer |> @lib.write_int64(item)
    }
  }
  if !self.created_timestamps.is_empty() {
    writer |> @lib.write_varint(34UL)
    let size = self.created_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.created_timestamps {
      writer |> @lib.write_uint64(item)
    }
  }
  if !self.created_utc_timestamps.is_empty() {
    writer |> @lib.write_varint(42UL)
    let size = self.created_utc_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.created_utc_timestamps {
      writer |> @lib.write_uint64(item)
    }
  }
  if !self.in_memory_percentages.is_empty() {
    writer |> @lib.write_varint(50UL)
    let size = self.in_memory_percentages
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.in_memory_percentages {
      writer |> @lib.write_int64(item)
    }
  }
  if !self.query_service_available.is_empty() {
    writer |> @lib.write_varint(58UL)
    let size = self.query_service_available
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.query_service_available {
      writer |> @lib.write_bool(item)
    }
  }
  if !self.shards_num.is_empty() {
    writer |> @lib.write_varint(66UL)
    let size = self.shards_num.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.shards_num {
      writer |> @lib.write_int32(item)
    }
  }
}

///|
pub impl ToJson for ShowCollectionsResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.collection_names != Default::default() {
    json["collectionNames"] = ToJson::to_json(self.collection_names)
  }
  if self.collection_ids != Default::default() {
    json["collectionIds"] = ToJson::to_json(self.collection_ids)
  }
  if self.created_timestamps != Default::default() {
    json["createdTimestamps"] = ToJson::to_json(self.created_timestamps)
  }
  if self.created_utc_timestamps != Default::default() {
    json["createdUtcTimestamps"] = ToJson::to_json(self.created_utc_timestamps)
  }
  if self.in_memory_percentages != Default::default() {
    json["inMemoryPercentages"] = ToJson::to_json(self.in_memory_percentages)
  }
  if self.query_service_available != Default::default() {
    json["queryServiceAvailable"] = ToJson::to_json(
      self.query_service_available,
    )
  }
  if self.shards_num != Default::default() {
    json["shardsNum"] = ToJson::to_json(self.shards_num)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ShowCollectionsResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ShowCollectionsResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ShowCollectionsResponse"),
    )
  }
  let message : ShowCollectionsResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("collectionNames", Array(value)) =>
        message.collection_names = value.map(v => @json.from_json(v, path~))
      ("collectionIds", Array(value)) =>
        message.collection_ids = value.map(v => @json.from_json(v, path~))
      ("createdTimestamps", Array(value)) =>
        message.created_timestamps = value.map(v => @json.from_json(v, path~))
      ("createdUtcTimestamps", Array(value)) =>
        message.created_utc_timestamps = value.map(v => {
          @json.from_json(v, path~)
        })
      ("inMemoryPercentages", Array(value)) =>
        message.in_memory_percentages = value.map(v => @json.from_json(v, path~))
      ("queryServiceAvailable", Array(value)) =>
        message.query_service_available = value.map(v => {
          @json.from_json(v, path~)
        })
      ("shardsNum", Array(value)) =>
        message.shards_num = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ShowCollectionsResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ShowCollectionsResponse raise {
  let msg : ShowCollectionsResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, _) => msg.collection_names.push(reader |> @lib.async_read_string())
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.collection_ids.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (3, @lib.WIRE_TYPE_VARINT) =>
        msg.collection_ids.push(reader |> @lib.async_read_int64())
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.created_timestamps.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint64, None)).iter(),
        )
      (4, @lib.WIRE_TYPE_VARINT) =>
        msg.created_timestamps.push(reader |> @lib.async_read_uint64())
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.created_utc_timestamps.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint64, None)).iter(),
        )
      (5, @lib.WIRE_TYPE_VARINT) =>
        msg.created_utc_timestamps.push(reader |> @lib.async_read_uint64())
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.in_memory_percentages.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.in_memory_percentages.push(reader |> @lib.async_read_int64())
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.query_service_available.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_bool, None)).iter(),
        )
      (7, @lib.WIRE_TYPE_VARINT) =>
        msg.query_service_available.push(reader |> @lib.async_read_bool())
      (8, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.shards_num.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int32, None)).iter(),
        )
      (8, @lib.WIRE_TYPE_VARINT) =>
        msg.shards_num.push(reader |> @lib.async_read_int32())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ShowCollectionsResponse with fn write(
  self : ShowCollectionsResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  for item in self.collection_names {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(item)
  }
  if !self.collection_ids.is_empty() {
    writer |> @lib.async_write_varint(26UL)
    let size = self.collection_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.collection_ids {
      writer |> @lib.async_write_int64(item)
    }
  }
  if !self.created_timestamps.is_empty() {
    writer |> @lib.async_write_varint(34UL)
    let size = self.created_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.created_timestamps {
      writer |> @lib.async_write_uint64(item)
    }
  }
  if !self.created_utc_timestamps.is_empty() {
    writer |> @lib.async_write_varint(42UL)
    let size = self.created_utc_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.created_utc_timestamps {
      writer |> @lib.async_write_uint64(item)
    }
  }
  if !self.in_memory_percentages.is_empty() {
    writer |> @lib.async_write_varint(50UL)
    let size = self.in_memory_percentages
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.in_memory_percentages {
      writer |> @lib.async_write_int64(item)
    }
  }
  if !self.query_service_available.is_empty() {
    writer |> @lib.async_write_varint(58UL)
    let size = self.query_service_available
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.query_service_available {
      writer |> @lib.async_write_bool(item)
    }
  }
  if !self.shards_num.is_empty() {
    writer |> @lib.async_write_varint(66UL)
    let size = self.shards_num.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.shards_num {
      writer |> @lib.async_write_int32(item)
    }
  }
}

///|
pub(all) struct InsertRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_name : String
  mut fields_data : Array[@schema.FieldData]
  mut hash_keys : Array[UInt]
  mut num_rows : UInt
  mut schema_timestamp : UInt64
  mut namespace_ : String?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for InsertRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.partition_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.partition_name),
    )
  }
  for s in self.fields_data {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  if !self.hash_keys.is_empty() {
    size += @lib.size_of_length_delimited_field(
      6U,
      self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if self.num_rows != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.num_rows))
  }
  if self.schema_timestamp != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.schema_timestamp))
  }
  if self.namespace_ is Some(v) {
    size += @lib.size_of_length_delimited_field(9U, @lib.size_of(v))
  }
  size
}

///|
pub impl Default for InsertRequest with fn default() -> InsertRequest {
  InsertRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_name: Default::default(),
    fields_data: [],
    hash_keys: [],
    num_rows: Default::default(),
    schema_timestamp: Default::default(),
    namespace_: None,
  }
}

///|
#alias(new, deprecated)
pub fn InsertRequest::InsertRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_name : String,
  fields_data : Array[@schema.FieldData],
  hash_keys : Array[UInt],
  num_rows : UInt,
  schema_timestamp : UInt64,
  namespace_? : String,
) -> InsertRequest {
  InsertRequest::{
    base,
    db_name,
    collection_name,
    partition_name,
    fields_data,
    hash_keys,
    num_rows,
    schema_timestamp,
    namespace_,
  }
}

///|
pub impl @lib.Read for InsertRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> InsertRequest raise {
  let msg : InsertRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_name = reader |> @lib.read_string()
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields_data.push(
          (reader |> @lib.read_message() : @schema.FieldData),
        )
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.hash_keys.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint32, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.hash_keys.push(reader |> @lib.read_uint32())
      (7, _) => msg.num_rows = reader |> @lib.read_uint32()
      (8, _) => msg.schema_timestamp = reader |> @lib.read_uint64()
      (9, _) => msg.namespace_ = reader |> @lib.read_string() |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for InsertRequest with fn write(
  self : InsertRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.partition_name)
  }
  for item in self.fields_data {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(item)
  }
  if !self.hash_keys.is_empty() {
    writer |> @lib.write_varint(50UL)
    let size = self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.hash_keys {
      writer |> @lib.write_uint32(item)
    }
  }
  if self.num_rows != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_uint32(self.num_rows)
  }
  if self.schema_timestamp != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_uint64(self.schema_timestamp)
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_string(v)
  }
}

///|
pub impl ToJson for InsertRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_name != Default::default() {
    json["partitionName"] = ToJson::to_json(self.partition_name)
  }
  if self.fields_data != Default::default() {
    json["fieldsData"] = ToJson::to_json(self.fields_data)
  }
  if self.hash_keys != Default::default() {
    json["hashKeys"] = ToJson::to_json(self.hash_keys)
  }
  if self.num_rows != Default::default() {
    json["numRows"] = ToJson::to_json(self.num_rows)
  }
  if self.schema_timestamp != Default::default() {
    json["schemaTimestamp"] = ToJson::to_json(self.schema_timestamp)
  }
  match self.namespace_ {
    Some(v) => json["namespace"] = ToJson::to_json(v)
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for InsertRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> InsertRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for InsertRequest"))
  }
  let message : InsertRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionName", value) =>
        message.partition_name = @json.from_json(value, path~)
      ("fieldsData", Array(value)) =>
        message.fields_data = value.map(v => @json.from_json(v, path~))
      ("hashKeys", Array(value)) =>
        message.hash_keys = value.map(v => @json.from_json(v, path~))
      ("numRows", value) => message.num_rows = @json.from_json(value, path~)
      ("schemaTimestamp", value) =>
        message.schema_timestamp = @json.from_json(value, path~)
      ("namespace", value) =>
        message.namespace_ = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for InsertRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> InsertRequest raise {
  let msg : InsertRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_name = reader |> @lib.async_read_string()
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields_data.push(
          (reader |> @lib.async_read_message() : @schema.FieldData),
        )
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.hash_keys.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint32, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.hash_keys.push(reader |> @lib.async_read_uint32())
      (7, _) => msg.num_rows = reader |> @lib.async_read_uint32()
      (8, _) => msg.schema_timestamp = reader |> @lib.async_read_uint64()
      (9, _) => msg.namespace_ = reader |> @lib.async_read_string() |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for InsertRequest with fn write(
  self : InsertRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.partition_name)
  }
  for item in self.fields_data {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(item)
  }
  if !self.hash_keys.is_empty() {
    writer |> @lib.async_write_varint(50UL)
    let size = self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.hash_keys {
      writer |> @lib.async_write_uint32(item)
    }
  }
  if self.num_rows != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_uint32(self.num_rows)
  }
  if self.schema_timestamp != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_uint64(self.schema_timestamp)
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.async_write_varint(74UL)
    writer |> @lib.async_write_string(v)
  }
}

///|
pub(all) struct UpsertRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_name : String
  mut fields_data : Array[@schema.FieldData]
  mut hash_keys : Array[UInt]
  mut num_rows : UInt
  mut schema_timestamp : UInt64
  mut partial_update : Bool
  mut namespace_ : String?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for UpsertRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.partition_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.partition_name),
    )
  }
  for s in self.fields_data {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  if !self.hash_keys.is_empty() {
    size += @lib.size_of_length_delimited_field(
      6U,
      self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if self.num_rows != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.num_rows))
  }
  if self.schema_timestamp != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.schema_timestamp))
  }
  if self.partial_update != Default::default() {
    size += @lib.size_of_field(9U, @lib.size_of(self.partial_update))
  }
  if self.namespace_ is Some(v) {
    size += @lib.size_of_length_delimited_field(10U, @lib.size_of(v))
  }
  size
}

///|
pub impl Default for UpsertRequest with fn default() -> UpsertRequest {
  UpsertRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_name: Default::default(),
    fields_data: [],
    hash_keys: [],
    num_rows: Default::default(),
    schema_timestamp: Default::default(),
    partial_update: Default::default(),
    namespace_: None,
  }
}

///|
#alias(new, deprecated)
pub fn UpsertRequest::UpsertRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_name : String,
  fields_data : Array[@schema.FieldData],
  hash_keys : Array[UInt],
  num_rows : UInt,
  schema_timestamp : UInt64,
  partial_update : Bool,
  namespace_? : String,
) -> UpsertRequest {
  UpsertRequest::{
    base,
    db_name,
    collection_name,
    partition_name,
    fields_data,
    hash_keys,
    num_rows,
    schema_timestamp,
    partial_update,
    namespace_,
  }
}

///|
pub impl @lib.Read for UpsertRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> UpsertRequest raise {
  let msg : UpsertRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_name = reader |> @lib.read_string()
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields_data.push(
          (reader |> @lib.read_message() : @schema.FieldData),
        )
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.hash_keys.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint32, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.hash_keys.push(reader |> @lib.read_uint32())
      (7, _) => msg.num_rows = reader |> @lib.read_uint32()
      (8, _) => msg.schema_timestamp = reader |> @lib.read_uint64()
      (9, _) => msg.partial_update = reader |> @lib.read_bool()
      (10, _) => msg.namespace_ = reader |> @lib.read_string() |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for UpsertRequest with fn write(
  self : UpsertRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.partition_name)
  }
  for item in self.fields_data {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(item)
  }
  if !self.hash_keys.is_empty() {
    writer |> @lib.write_varint(50UL)
    let size = self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.hash_keys {
      writer |> @lib.write_uint32(item)
    }
  }
  if self.num_rows != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_uint32(self.num_rows)
  }
  if self.schema_timestamp != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_uint64(self.schema_timestamp)
  }
  if self.partial_update != Default::default() {
    writer |> @lib.write_varint(72UL)
    writer |> @lib.write_bool(self.partial_update)
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.write_varint(82UL)
    writer |> @lib.write_string(v)
  }
}

///|
pub impl ToJson for UpsertRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_name != Default::default() {
    json["partitionName"] = ToJson::to_json(self.partition_name)
  }
  if self.fields_data != Default::default() {
    json["fieldsData"] = ToJson::to_json(self.fields_data)
  }
  if self.hash_keys != Default::default() {
    json["hashKeys"] = ToJson::to_json(self.hash_keys)
  }
  if self.num_rows != Default::default() {
    json["numRows"] = ToJson::to_json(self.num_rows)
  }
  if self.schema_timestamp != Default::default() {
    json["schemaTimestamp"] = ToJson::to_json(self.schema_timestamp)
  }
  if self.partial_update != Default::default() {
    json["partialUpdate"] = ToJson::to_json(self.partial_update)
  }
  match self.namespace_ {
    Some(v) => json["namespace"] = ToJson::to_json(v)
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for UpsertRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> UpsertRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for UpsertRequest"))
  }
  let message : UpsertRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionName", value) =>
        message.partition_name = @json.from_json(value, path~)
      ("fieldsData", Array(value)) =>
        message.fields_data = value.map(v => @json.from_json(v, path~))
      ("hashKeys", Array(value)) =>
        message.hash_keys = value.map(v => @json.from_json(v, path~))
      ("numRows", value) => message.num_rows = @json.from_json(value, path~)
      ("schemaTimestamp", value) =>
        message.schema_timestamp = @json.from_json(value, path~)
      ("partialUpdate", value) =>
        message.partial_update = @json.from_json(value, path~)
      ("namespace", value) =>
        message.namespace_ = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for UpsertRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> UpsertRequest raise {
  let msg : UpsertRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_name = reader |> @lib.async_read_string()
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields_data.push(
          (reader |> @lib.async_read_message() : @schema.FieldData),
        )
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.hash_keys.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint32, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.hash_keys.push(reader |> @lib.async_read_uint32())
      (7, _) => msg.num_rows = reader |> @lib.async_read_uint32()
      (8, _) => msg.schema_timestamp = reader |> @lib.async_read_uint64()
      (9, _) => msg.partial_update = reader |> @lib.async_read_bool()
      (10, _) => msg.namespace_ = reader |> @lib.async_read_string() |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for UpsertRequest with fn write(
  self : UpsertRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.partition_name)
  }
  for item in self.fields_data {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(item)
  }
  if !self.hash_keys.is_empty() {
    writer |> @lib.async_write_varint(50UL)
    let size = self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.hash_keys {
      writer |> @lib.async_write_uint32(item)
    }
  }
  if self.num_rows != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_uint32(self.num_rows)
  }
  if self.schema_timestamp != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_uint64(self.schema_timestamp)
  }
  if self.partial_update != Default::default() {
    writer |> @lib.async_write_varint(72UL)
    writer |> @lib.async_write_bool(self.partial_update)
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.async_write_varint(82UL)
    writer |> @lib.async_write_string(v)
  }
}

///|
pub(all) struct MutationResult {
  mut status : @common.Status?
  mut ids : @schema.IDs?
  mut succ_index : Array[UInt]
  mut err_index : Array[UInt]
  mut acknowledged : Bool
  mut insert_cnt : Int64
  mut delete_cnt : Int64
  mut upsert_cnt : Int64
  mut timestamp : UInt64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for MutationResult with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.ids is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if !self.succ_index.is_empty() {
    size += @lib.size_of_length_delimited_field(
      3U,
      self.succ_index.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if !self.err_index.is_empty() {
    size += @lib.size_of_length_delimited_field(
      4U,
      self.err_index.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if self.acknowledged != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.acknowledged))
  }
  if self.insert_cnt != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.insert_cnt))
  }
  if self.delete_cnt != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.delete_cnt))
  }
  if self.upsert_cnt != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.upsert_cnt))
  }
  if self.timestamp != Default::default() {
    size += @lib.size_of_field(9U, @lib.size_of(self.timestamp))
  }
  size
}

///|
pub impl Default for MutationResult with fn default() -> MutationResult {
  MutationResult::{
    status: None,
    ids: None,
    succ_index: [],
    err_index: [],
    acknowledged: Default::default(),
    insert_cnt: Default::default(),
    delete_cnt: Default::default(),
    upsert_cnt: Default::default(),
    timestamp: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn MutationResult::MutationResult(
  status? : @common.Status,
  ids? : @schema.IDs,
  succ_index : Array[UInt],
  err_index : Array[UInt],
  acknowledged : Bool,
  insert_cnt : Int64,
  delete_cnt : Int64,
  upsert_cnt : Int64,
  timestamp : UInt64,
) -> MutationResult {
  MutationResult::{
    status,
    ids,
    succ_index,
    err_index,
    acknowledged,
    insert_cnt,
    delete_cnt,
    upsert_cnt,
    timestamp,
  }
}

///|
pub impl @lib.Read for MutationResult with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> MutationResult raise {
  let msg : MutationResult = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.ids = (reader |> @lib.read_message() : @schema.IDs) |> Some
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.succ_index.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint32, None)).iter(),
        )
      (3, @lib.WIRE_TYPE_VARINT) =>
        msg.succ_index.push(reader |> @lib.read_uint32())
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.err_index.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint32, None)).iter(),
        )
      (4, @lib.WIRE_TYPE_VARINT) =>
        msg.err_index.push(reader |> @lib.read_uint32())
      (5, _) => msg.acknowledged = reader |> @lib.read_bool()
      (6, _) => msg.insert_cnt = reader |> @lib.read_int64()
      (7, _) => msg.delete_cnt = reader |> @lib.read_int64()
      (8, _) => msg.upsert_cnt = reader |> @lib.read_int64()
      (9, _) => msg.timestamp = reader |> @lib.read_uint64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for MutationResult with fn write(
  self : MutationResult,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.ids is Some(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(v)
  }
  if !self.succ_index.is_empty() {
    writer |> @lib.write_varint(26UL)
    let size = self.succ_index.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.succ_index {
      writer |> @lib.write_uint32(item)
    }
  }
  if !self.err_index.is_empty() {
    writer |> @lib.write_varint(34UL)
    let size = self.err_index.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.err_index {
      writer |> @lib.write_uint32(item)
    }
  }
  if self.acknowledged != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_bool(self.acknowledged)
  }
  if self.insert_cnt != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_int64(self.insert_cnt)
  }
  if self.delete_cnt != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_int64(self.delete_cnt)
  }
  if self.upsert_cnt != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_int64(self.upsert_cnt)
  }
  if self.timestamp != Default::default() {
    writer |> @lib.write_varint(72UL)
    writer |> @lib.write_uint64(self.timestamp)
  }
}

///|
pub impl ToJson for MutationResult with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  match self.ids {
    Some(v) => json["IDs"] = ToJson::to_json(v)
    _ => ()
  }
  if self.succ_index != Default::default() {
    json["succIndex"] = ToJson::to_json(self.succ_index)
  }
  if self.err_index != Default::default() {
    json["errIndex"] = ToJson::to_json(self.err_index)
  }
  if self.acknowledged != Default::default() {
    json["acknowledged"] = ToJson::to_json(self.acknowledged)
  }
  if self.insert_cnt != Default::default() {
    json["insertCnt"] = ToJson::to_json(self.insert_cnt)
  }
  if self.delete_cnt != Default::default() {
    json["deleteCnt"] = ToJson::to_json(self.delete_cnt)
  }
  if self.upsert_cnt != Default::default() {
    json["upsertCnt"] = ToJson::to_json(self.upsert_cnt)
  }
  if self.timestamp != Default::default() {
    json["timestamp"] = ToJson::to_json(self.timestamp)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for MutationResult with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> MutationResult raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for MutationResult"))
  }
  let message : MutationResult = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("IDs", value) => message.ids = Some(@json.from_json(value, path~))
      ("succIndex", Array(value)) =>
        message.succ_index = value.map(v => @json.from_json(v, path~))
      ("errIndex", Array(value)) =>
        message.err_index = value.map(v => @json.from_json(v, path~))
      ("acknowledged", value) =>
        message.acknowledged = @json.from_json(value, path~)
      ("insertCnt", value) => message.insert_cnt = @json.from_json(value, path~)
      ("deleteCnt", value) => message.delete_cnt = @json.from_json(value, path~)
      ("upsertCnt", value) => message.upsert_cnt = @json.from_json(value, path~)
      ("timestamp", value) => message.timestamp = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for MutationResult with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> MutationResult raise {
  let msg : MutationResult = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.ids = (reader |> @lib.async_read_message() : @schema.IDs) |> Some
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.succ_index.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint32, None)).iter(),
        )
      (3, @lib.WIRE_TYPE_VARINT) =>
        msg.succ_index.push(reader |> @lib.async_read_uint32())
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.err_index.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint32, None)).iter(),
        )
      (4, @lib.WIRE_TYPE_VARINT) =>
        msg.err_index.push(reader |> @lib.async_read_uint32())
      (5, _) => msg.acknowledged = reader |> @lib.async_read_bool()
      (6, _) => msg.insert_cnt = reader |> @lib.async_read_int64()
      (7, _) => msg.delete_cnt = reader |> @lib.async_read_int64()
      (8, _) => msg.upsert_cnt = reader |> @lib.async_read_int64()
      (9, _) => msg.timestamp = reader |> @lib.async_read_uint64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for MutationResult with fn write(
  self : MutationResult,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.ids is Some(v) {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(v)
  }
  if !self.succ_index.is_empty() {
    writer |> @lib.async_write_varint(26UL)
    let size = self.succ_index.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.succ_index {
      writer |> @lib.async_write_uint32(item)
    }
  }
  if !self.err_index.is_empty() {
    writer |> @lib.async_write_varint(34UL)
    let size = self.err_index.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.err_index {
      writer |> @lib.async_write_uint32(item)
    }
  }
  if self.acknowledged != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_bool(self.acknowledged)
  }
  if self.insert_cnt != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_int64(self.insert_cnt)
  }
  if self.delete_cnt != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_int64(self.delete_cnt)
  }
  if self.upsert_cnt != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_int64(self.upsert_cnt)
  }
  if self.timestamp != Default::default() {
    writer |> @lib.async_write_varint(72UL)
    writer |> @lib.async_write_uint64(self.timestamp)
  }
}

///|
pub(all) struct DeleteRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_name : String
  mut expr : String
  mut hash_keys : Array[UInt]
  mut consistency_level : @common.ConsistencyLevel
  mut namespace_ : String?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DeleteRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.partition_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.partition_name),
    )
  }
  if self.expr != Default::default() {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(self.expr))
  }
  if !self.hash_keys.is_empty() {
    size += @lib.size_of_length_delimited_field(
      6U,
      self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if self.consistency_level != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.consistency_level))
  }
  if self.namespace_ is Some(v) {
    size += @lib.size_of_length_delimited_field(9U, @lib.size_of(v))
  }
  size
}

///|
pub impl Default for DeleteRequest with fn default() -> DeleteRequest {
  DeleteRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_name: Default::default(),
    expr: Default::default(),
    hash_keys: [],
    consistency_level: Default::default(),
    namespace_: None,
  }
}

///|
#alias(new, deprecated)
pub fn DeleteRequest::DeleteRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_name : String,
  expr : String,
  hash_keys : Array[UInt],
  consistency_level : @common.ConsistencyLevel,
  namespace_? : String,
) -> DeleteRequest {
  DeleteRequest::{
    base,
    db_name,
    collection_name,
    partition_name,
    expr,
    hash_keys,
    consistency_level,
    namespace_,
  }
}

///|
pub impl @lib.Read for DeleteRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DeleteRequest raise {
  let msg : DeleteRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_name = reader |> @lib.read_string()
      (5, _) => msg.expr = reader |> @lib.read_string()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.hash_keys.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint32, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.hash_keys.push(reader |> @lib.read_uint32())
      (7, _) =>
        msg.consistency_level = reader
          |> @lib.read_enum()
          |> @common.ConsistencyLevel::from_enum
      (9, _) => msg.namespace_ = reader |> @lib.read_string() |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DeleteRequest with fn write(
  self : DeleteRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.partition_name)
  }
  if self.expr != Default::default() {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(self.expr)
  }
  if !self.hash_keys.is_empty() {
    writer |> @lib.write_varint(50UL)
    let size = self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.hash_keys {
      writer |> @lib.write_uint32(item)
    }
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_enum(self.consistency_level.to_enum())
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_string(v)
  }
}

///|
pub impl ToJson for DeleteRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_name != Default::default() {
    json["partitionName"] = ToJson::to_json(self.partition_name)
  }
  if self.expr != Default::default() {
    json["expr"] = ToJson::to_json(self.expr)
  }
  if self.hash_keys != Default::default() {
    json["hashKeys"] = ToJson::to_json(self.hash_keys)
  }
  if self.consistency_level != Default::default() {
    json["consistencyLevel"] = ToJson::to_json(self.consistency_level)
  }
  match self.namespace_ {
    Some(v) => json["namespace"] = ToJson::to_json(v)
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DeleteRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DeleteRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for DeleteRequest"))
  }
  let message : DeleteRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionName", value) =>
        message.partition_name = @json.from_json(value, path~)
      ("expr", value) => message.expr = @json.from_json(value, path~)
      ("hashKeys", Array(value)) =>
        message.hash_keys = value.map(v => @json.from_json(v, path~))
      ("consistencyLevel", value) =>
        message.consistency_level = @json.from_json(value, path~)
      ("namespace", value) =>
        message.namespace_ = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DeleteRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DeleteRequest raise {
  let msg : DeleteRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_name = reader |> @lib.async_read_string()
      (5, _) => msg.expr = reader |> @lib.async_read_string()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.hash_keys.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint32, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.hash_keys.push(reader |> @lib.async_read_uint32())
      (7, _) =>
        msg.consistency_level = reader
          |> @lib.async_read_enum()
          |> @common.ConsistencyLevel::from_enum
      (9, _) => msg.namespace_ = reader |> @lib.async_read_string() |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DeleteRequest with fn write(
  self : DeleteRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.partition_name)
  }
  if self.expr != Default::default() {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(self.expr)
  }
  if !self.hash_keys.is_empty() {
    writer |> @lib.async_write_varint(50UL)
    let size = self.hash_keys.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.hash_keys {
      writer |> @lib.async_write_uint32(item)
    }
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_enum(self.consistency_level.to_enum())
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.async_write_varint(74UL)
    writer |> @lib.async_write_string(v)
  }
}

///|
pub(all) struct SearchRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_names : Array[String]
  mut dsl : String
  mut dsl_type : @common.DslType
  mut output_fields : Array[String]
  mut search_params : Array[@common.KeyValuePair]
  mut travel_timestamp : UInt64
  mut guarantee_timestamp : UInt64
  mut nq : Int64
  mut not_return_all_meta : Bool
  mut consistency_level : @common.ConsistencyLevel
  mut use_default_consistency : Bool
  mut namespace_ : String?
  mut search_input : SearchRequest_SearchInput
} derive(Eq, Debug)

///|
pub(all) enum SearchRequest_SearchInput {
  PlaceholderGroup(Bytes)
  Ids(@schema.IDs)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for SearchRequest_SearchInput with fn default() -> SearchRequest_SearchInput {
  NotSet
}

///|
pub impl @json.FromJson for SearchRequest_SearchInput with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> SearchRequest_SearchInput raise {
  try
    SearchRequest_SearchInput::PlaceholderGroup(json |> @json.from_json(path~))
  catch {
    _ => ()
  } noraise {
    v => return v
  }
  try SearchRequest_SearchInput::Ids(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  SearchRequest_SearchInput::NotSet
}

///|
pub impl ToJson for SearchRequest_SearchInput with fn to_json(
  self : SearchRequest_SearchInput,
) -> Json {
  match self {
    SearchRequest_SearchInput::PlaceholderGroup(v) => ToJson::to_json(v)
    SearchRequest_SearchInput::Ids(v) => ToJson::to_json(v)
    SearchRequest_SearchInput::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for SearchRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  for s in self.partition_names {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  if self.dsl != Default::default() {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(self.dsl))
  }
  if self.dsl_type != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.dsl_type))
  }
  for s in self.output_fields {
    size += @lib.size_of_length_delimited_field(8U, @lib.size_of(s))
  }
  for s in self.search_params {
    size += @lib.size_of_length_delimited_field(9U, @lib.size_of(s))
  }
  if self.travel_timestamp != Default::default() {
    size += @lib.size_of_field(10U, @lib.size_of(self.travel_timestamp))
  }
  if self.guarantee_timestamp != Default::default() {
    size += @lib.size_of_field(11U, @lib.size_of(self.guarantee_timestamp))
  }
  if self.nq != Default::default() {
    size += @lib.size_of_field(12U, @lib.size_of(self.nq))
  }
  if self.not_return_all_meta != Default::default() {
    size += @lib.size_of_field(13U, @lib.size_of(self.not_return_all_meta))
  }
  if self.consistency_level != Default::default() {
    size += @lib.size_of_field(14U, @lib.size_of(self.consistency_level))
  }
  if self.use_default_consistency != Default::default() {
    size += @lib.size_of_field(15U, @lib.size_of(self.use_default_consistency))
  }
  if self.namespace_ is Some(v) {
    size += @lib.size_of_length_delimited_field(20U, @lib.size_of(v))
  }
  match self.search_input {
    PlaceholderGroup(v) =>
      size += @lib.size_of_length_delimited_field(6U, @lib.size_of(v))
    Ids(v) => size += @lib.size_of_length_delimited_field(22U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for SearchRequest with fn default() -> SearchRequest {
  SearchRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_names: [],
    dsl: Default::default(),
    dsl_type: Default::default(),
    output_fields: [],
    search_params: [],
    travel_timestamp: Default::default(),
    guarantee_timestamp: Default::default(),
    nq: Default::default(),
    not_return_all_meta: Default::default(),
    consistency_level: Default::default(),
    use_default_consistency: Default::default(),
    namespace_: None,
    search_input: SearchRequest_SearchInput::NotSet,
  }
}

///|
#alias(new, deprecated)
pub fn SearchRequest::SearchRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_names : Array[String],
  dsl : String,
  dsl_type : @common.DslType,
  output_fields : Array[String],
  search_params : Array[@common.KeyValuePair],
  travel_timestamp : UInt64,
  guarantee_timestamp : UInt64,
  nq : Int64,
  not_return_all_meta : Bool,
  consistency_level : @common.ConsistencyLevel,
  use_default_consistency : Bool,
  namespace_? : String,
  search_input? : SearchRequest_SearchInput = SearchRequest_SearchInput::NotSet,
) -> SearchRequest {
  SearchRequest::{
    base,
    db_name,
    collection_name,
    partition_names,
    dsl,
    dsl_type,
    output_fields,
    search_params,
    travel_timestamp,
    guarantee_timestamp,
    nq,
    not_return_all_meta,
    consistency_level,
    use_default_consistency,
    namespace_,
    search_input,
  }
}

///|
pub impl @lib.Read for SearchRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> SearchRequest raise {
  let msg : SearchRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_names.push(reader |> @lib.read_string())
      (5, _) => msg.dsl = reader |> @lib.read_string()
      (7, _) =>
        msg.dsl_type = reader |> @lib.read_enum() |> @common.DslType::from_enum
      (8, _) => msg.output_fields.push(reader |> @lib.read_string())
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.search_params.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (10, _) => msg.travel_timestamp = reader |> @lib.read_uint64()
      (11, _) => msg.guarantee_timestamp = reader |> @lib.read_uint64()
      (12, _) => msg.nq = reader |> @lib.read_int64()
      (13, _) => msg.not_return_all_meta = reader |> @lib.read_bool()
      (14, _) =>
        msg.consistency_level = reader
          |> @lib.read_enum()
          |> @common.ConsistencyLevel::from_enum
      (15, _) => msg.use_default_consistency = reader |> @lib.read_bool()
      (20, _) => msg.namespace_ = reader |> @lib.read_string() |> Some
      (6, _) =>
        msg.search_input = reader
          |> @lib.read_bytes()
          |> SearchRequest_SearchInput::PlaceholderGroup
      (22, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.search_input = (reader |> @lib.read_message() : @schema.IDs)
          |> SearchRequest_SearchInput::Ids
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for SearchRequest with fn write(
  self : SearchRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(item)
  }
  if self.dsl != Default::default() {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(self.dsl)
  }
  if self.dsl_type != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_enum(self.dsl_type.to_enum())
  }
  for item in self.output_fields {
    writer |> @lib.write_varint(66UL)
    writer |> @lib.write_string(item)
  }
  for item in self.search_params {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_message(item)
  }
  if self.travel_timestamp != Default::default() {
    writer |> @lib.write_varint(80UL)
    writer |> @lib.write_uint64(self.travel_timestamp)
  }
  if self.guarantee_timestamp != Default::default() {
    writer |> @lib.write_varint(88UL)
    writer |> @lib.write_uint64(self.guarantee_timestamp)
  }
  if self.nq != Default::default() {
    writer |> @lib.write_varint(96UL)
    writer |> @lib.write_int64(self.nq)
  }
  if self.not_return_all_meta != Default::default() {
    writer |> @lib.write_varint(104UL)
    writer |> @lib.write_bool(self.not_return_all_meta)
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.write_varint(112UL)
    writer |> @lib.write_enum(self.consistency_level.to_enum())
  }
  if self.use_default_consistency != Default::default() {
    writer |> @lib.write_varint(120UL)
    writer |> @lib.write_bool(self.use_default_consistency)
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.write_varint(162UL)
    writer |> @lib.write_string(v)
  }
  match self.search_input {
    SearchRequest_SearchInput::PlaceholderGroup(v) => {
      writer |> @lib.write_varint(50UL)
      writer |> @lib.write_bytes(v)
    }
    SearchRequest_SearchInput::Ids(v) => {
      writer |> @lib.write_varint(178UL)
      writer |> @lib.write_message(v)
    }
    SearchRequest_SearchInput::NotSet => ()
  }
}

///|
pub impl ToJson for SearchRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_names != Default::default() {
    json["partitionNames"] = ToJson::to_json(self.partition_names)
  }
  if self.dsl != Default::default() {
    json["dsl"] = ToJson::to_json(self.dsl)
  }
  if self.dsl_type != Default::default() {
    json["dslType"] = ToJson::to_json(self.dsl_type)
  }
  if self.output_fields != Default::default() {
    json["outputFields"] = ToJson::to_json(self.output_fields)
  }
  if self.search_params != Default::default() {
    json["searchParams"] = ToJson::to_json(self.search_params)
  }
  if self.travel_timestamp != Default::default() {
    json["travelTimestamp"] = ToJson::to_json(self.travel_timestamp)
  }
  if self.guarantee_timestamp != Default::default() {
    json["guaranteeTimestamp"] = ToJson::to_json(self.guarantee_timestamp)
  }
  if self.nq != Default::default() {
    json["nq"] = ToJson::to_json(self.nq)
  }
  if self.not_return_all_meta != Default::default() {
    json["notReturnAllMeta"] = ToJson::to_json(self.not_return_all_meta)
  }
  if self.consistency_level != Default::default() {
    json["consistencyLevel"] = ToJson::to_json(self.consistency_level)
  }
  if self.use_default_consistency != Default::default() {
    json["useDefaultConsistency"] = ToJson::to_json(
      self.use_default_consistency,
    )
  }
  match self.namespace_ {
    Some(v) => json["namespace"] = ToJson::to_json(v)
    _ => ()
  }
  match self.search_input {
    NotSet => ()
    PlaceholderGroup(v) => json["placeholderGroup"] = ToJson::to_json(v)
    Ids(v) => json["ids"] = ToJson::to_json(v)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SearchRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> SearchRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for SearchRequest"))
  }
  let message : SearchRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionNames", Array(value)) =>
        message.partition_names = value.map(v => @json.from_json(v, path~))
      ("dsl", value) => message.dsl = @json.from_json(value, path~)
      ("dslType", value) => message.dsl_type = @json.from_json(value, path~)
      ("outputFields", Array(value)) =>
        message.output_fields = value.map(v => @json.from_json(v, path~))
      ("searchParams", Array(value)) =>
        message.search_params = value.map(v => @json.from_json(v, path~))
      ("travelTimestamp", value) =>
        message.travel_timestamp = @json.from_json(value, path~)
      ("guaranteeTimestamp", value) =>
        message.guarantee_timestamp = @json.from_json(value, path~)
      ("nq", value) => message.nq = @json.from_json(value, path~)
      ("notReturnAllMeta", value) =>
        message.not_return_all_meta = @json.from_json(value, path~)
      ("consistencyLevel", value) =>
        message.consistency_level = @json.from_json(value, path~)
      ("useDefaultConsistency", value) =>
        message.use_default_consistency = @json.from_json(value, path~)
      ("namespace", value) =>
        message.namespace_ = Some(@json.from_json(value, path~))
      ("placeholderGroup", value) =>
        message.search_input = @json.from_json(value, path~)
      ("ids", value) => message.search_input = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for SearchRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> SearchRequest raise {
  let msg : SearchRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_names.push(reader |> @lib.async_read_string())
      (5, _) => msg.dsl = reader |> @lib.async_read_string()
      (7, _) =>
        msg.dsl_type = reader
          |> @lib.async_read_enum()
          |> @common.DslType::from_enum
      (8, _) => msg.output_fields.push(reader |> @lib.async_read_string())
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.search_params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (10, _) => msg.travel_timestamp = reader |> @lib.async_read_uint64()
      (11, _) => msg.guarantee_timestamp = reader |> @lib.async_read_uint64()
      (12, _) => msg.nq = reader |> @lib.async_read_int64()
      (13, _) => msg.not_return_all_meta = reader |> @lib.async_read_bool()
      (14, _) =>
        msg.consistency_level = reader
          |> @lib.async_read_enum()
          |> @common.ConsistencyLevel::from_enum
      (15, _) => msg.use_default_consistency = reader |> @lib.async_read_bool()
      (20, _) => msg.namespace_ = reader |> @lib.async_read_string() |> Some
      (6, _) =>
        msg.search_input = reader
          |> @lib.async_read_bytes()
          |> SearchRequest_SearchInput::PlaceholderGroup
      (22, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.search_input = (reader |> @lib.async_read_message() : @schema.IDs)
          |> SearchRequest_SearchInput::Ids
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for SearchRequest with fn write(
  self : SearchRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(item)
  }
  if self.dsl != Default::default() {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(self.dsl)
  }
  if self.dsl_type != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_enum(self.dsl_type.to_enum())
  }
  for item in self.output_fields {
    writer |> @lib.async_write_varint(66UL)
    writer |> @lib.async_write_string(item)
  }
  for item in self.search_params {
    writer |> @lib.async_write_varint(74UL)
    writer |> @lib.async_write_message(item)
  }
  if self.travel_timestamp != Default::default() {
    writer |> @lib.async_write_varint(80UL)
    writer |> @lib.async_write_uint64(self.travel_timestamp)
  }
  if self.guarantee_timestamp != Default::default() {
    writer |> @lib.async_write_varint(88UL)
    writer |> @lib.async_write_uint64(self.guarantee_timestamp)
  }
  if self.nq != Default::default() {
    writer |> @lib.async_write_varint(96UL)
    writer |> @lib.async_write_int64(self.nq)
  }
  if self.not_return_all_meta != Default::default() {
    writer |> @lib.async_write_varint(104UL)
    writer |> @lib.async_write_bool(self.not_return_all_meta)
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.async_write_varint(112UL)
    writer |> @lib.async_write_enum(self.consistency_level.to_enum())
  }
  if self.use_default_consistency != Default::default() {
    writer |> @lib.async_write_varint(120UL)
    writer |> @lib.async_write_bool(self.use_default_consistency)
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.async_write_varint(162UL)
    writer |> @lib.async_write_string(v)
  }
  match self.search_input {
    SearchRequest_SearchInput::PlaceholderGroup(v) => {
      writer |> @lib.async_write_varint(50UL)
      writer |> @lib.async_write_bytes(v)
    }
    SearchRequest_SearchInput::Ids(v) => {
      writer |> @lib.async_write_varint(178UL)
      writer |> @lib.async_write_message(v)
    }
    SearchRequest_SearchInput::NotSet => ()
  }
}

///|
pub(all) struct Hits {
  mut ids : Array[Int64]
  mut row_data : Array[Bytes]
  mut scores : Array[Float]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Hits with fn size_of(self) {
  let mut size = 0U
  if !self.ids.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.ids.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  for s in self.row_data {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  if !self.scores.is_empty() {
    size += @lib.size_of_length_delimited_field(
      3U,
      self.scores.length().reinterpret_as_uint() * 4,
    )
  }
  size
}

///|
pub impl Default for Hits with fn default() -> Hits {
  Hits::{ ids: [], row_data: [], scores: [], }
}

///|
#alias(new, deprecated)
pub fn Hits::Hits(
  ids : Array[Int64],
  row_data : Array[Bytes],
  scores : Array[Float],
) -> Hits {
  Hits::{ ids, row_data, scores, }
}

///|
pub impl @lib.Read for Hits with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Hits raise {
  let msg : Hits = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.ids.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) => msg.ids.push(reader |> @lib.read_int64())
      (2, _) => msg.row_data.push(reader |> @lib.read_bytes())
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.scores.push_iter(
          (reader |> @lib.read_packed(@lib.read_float, Some(4))).iter(),
        )
      (3, @lib.WIRE_TYPE_FIXED32) =>
        msg.scores.push(reader |> @lib.read_float())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Hits with fn write(self : Hits, writer : &@lib.Writer) -> Unit raise {
  if !self.ids.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.ids.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.ids {
      writer |> @lib.write_int64(item)
    }
  }
  for item in self.row_data {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_bytes(item)
  }
  if !self.scores.is_empty() {
    writer |> @lib.write_varint(26UL)
    let size = self.scores.length().reinterpret_as_uint() * 4
    writer |> @lib.write_uint32(size)
    for item in self.scores {
      writer |> @lib.write_float(item)
    }
  }
}

///|
pub impl ToJson for Hits with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.ids != Default::default() {
    json["IDs"] = ToJson::to_json(self.ids)
  }
  if self.row_data != Default::default() {
    json["rowData"] = self.row_data.map(@lib.base64_encode).to_json()
  }
  if self.scores != Default::default() {
    json["scores"] = ToJson::to_json(self.scores)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Hits with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Hits raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Hits"))
  }
  let message : Hits = Default::default()
  for key, value in obj {
    match (key, value) {
      ("IDs", Array(value)) =>
        message.ids = value.map(v => @json.from_json(v, path~))
      ("rowData", Array(value)) =>
        message.row_data = value.map(v => @json.from_json(v, path~))
      ("scores", Array(value)) =>
        message.scores = value.map(v => {
          Float::from_double(@json.from_json(v, path~))
        })
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Hits with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Hits raise {
  let msg : Hits = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.ids.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.ids.push(reader |> @lib.async_read_int64())
      (2, _) => msg.row_data.push(reader |> @lib.async_read_bytes())
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.scores.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_float, Some(4))).iter(),
        )
      (3, @lib.WIRE_TYPE_FIXED32) =>
        msg.scores.push(reader |> @lib.async_read_float())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Hits with fn write(
  self : Hits,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.ids.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.ids.iter().map(@lib.size_of).fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.ids {
      writer |> @lib.async_write_int64(item)
    }
  }
  for item in self.row_data {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_bytes(item)
  }
  if !self.scores.is_empty() {
    writer |> @lib.async_write_varint(26UL)
    let size = self.scores.length().reinterpret_as_uint() * 4
    writer |> @lib.async_write_uint32(size)
    for item in self.scores {
      writer |> @lib.async_write_float(item)
    }
  }
}

///|
pub(all) struct SearchResults {
  mut status : @common.Status?
  mut results : @schema.SearchResultData?
  mut collection_name : String
  mut session_ts : UInt64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for SearchResults with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.results is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.session_ts != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.session_ts))
  }
  size
}

///|
pub impl Default for SearchResults with fn default() -> SearchResults {
  SearchResults::{
    status: None,
    results: None,
    collection_name: Default::default(),
    session_ts: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn SearchResults::SearchResults(
  status? : @common.Status,
  results? : @schema.SearchResultData,
  collection_name : String,
  session_ts : UInt64,
) -> SearchResults {
  SearchResults::{ status, results, collection_name, session_ts, }
}

///|
pub impl @lib.Read for SearchResults with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> SearchResults raise {
  let msg : SearchResults = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.results = (reader |> @lib.read_message() : @schema.SearchResultData)
          |> Some
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.session_ts = reader |> @lib.read_uint64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for SearchResults with fn write(
  self : SearchResults,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.results is Some(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(v)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.session_ts != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_uint64(self.session_ts)
  }
}

///|
pub impl ToJson for SearchResults with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  match self.results {
    Some(v) => json["results"] = ToJson::to_json(v)
    _ => ()
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.session_ts != Default::default() {
    json["sessionTs"] = ToJson::to_json(self.session_ts)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SearchResults with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> SearchResults raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for SearchResults"))
  }
  let message : SearchResults = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("results", value) =>
        message.results = Some(@json.from_json(value, path~))
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("sessionTs", value) => message.session_ts = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for SearchResults with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> SearchResults raise {
  let msg : SearchResults = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.results = (
            reader |> @lib.async_read_message() : @schema.SearchResultData)
          |> Some
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.session_ts = reader |> @lib.async_read_uint64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for SearchResults with fn write(
  self : SearchResults,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.results is Some(v) {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(v)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.session_ts != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_uint64(self.session_ts)
  }
}

///|
pub(all) struct QueryRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut expr : String
  mut output_fields : Array[String]
  mut partition_names : Array[String]
  mut travel_timestamp : UInt64
  mut guarantee_timestamp : UInt64
  mut query_params : Array[@common.KeyValuePair]
  mut not_return_all_meta : Bool
  mut consistency_level : @common.ConsistencyLevel
  mut use_default_consistency : Bool
  mut namespace_ : String?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for QueryRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.expr != Default::default() {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(self.expr))
  }
  for s in self.output_fields {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  for s in self.partition_names {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  if self.travel_timestamp != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.travel_timestamp))
  }
  if self.guarantee_timestamp != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.guarantee_timestamp))
  }
  for s in self.query_params {
    size += @lib.size_of_length_delimited_field(9U, @lib.size_of(s))
  }
  if self.not_return_all_meta != Default::default() {
    size += @lib.size_of_field(10U, @lib.size_of(self.not_return_all_meta))
  }
  if self.consistency_level != Default::default() {
    size += @lib.size_of_field(11U, @lib.size_of(self.consistency_level))
  }
  if self.use_default_consistency != Default::default() {
    size += @lib.size_of_field(12U, @lib.size_of(self.use_default_consistency))
  }
  if self.namespace_ is Some(v) {
    size += @lib.size_of_length_delimited_field(14U, @lib.size_of(v))
  }
  size
}

///|
pub impl Default for QueryRequest with fn default() -> QueryRequest {
  QueryRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    expr: Default::default(),
    output_fields: [],
    partition_names: [],
    travel_timestamp: Default::default(),
    guarantee_timestamp: Default::default(),
    query_params: [],
    not_return_all_meta: Default::default(),
    consistency_level: Default::default(),
    use_default_consistency: Default::default(),
    namespace_: None,
  }
}

///|
#alias(new, deprecated)
pub fn QueryRequest::QueryRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  expr : String,
  output_fields : Array[String],
  partition_names : Array[String],
  travel_timestamp : UInt64,
  guarantee_timestamp : UInt64,
  query_params : Array[@common.KeyValuePair],
  not_return_all_meta : Bool,
  consistency_level : @common.ConsistencyLevel,
  use_default_consistency : Bool,
  namespace_? : String,
) -> QueryRequest {
  QueryRequest::{
    base,
    db_name,
    collection_name,
    expr,
    output_fields,
    partition_names,
    travel_timestamp,
    guarantee_timestamp,
    query_params,
    not_return_all_meta,
    consistency_level,
    use_default_consistency,
    namespace_,
  }
}

///|
pub impl @lib.Read for QueryRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> QueryRequest raise {
  let msg : QueryRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.expr = reader |> @lib.read_string()
      (5, _) => msg.output_fields.push(reader |> @lib.read_string())
      (6, _) => msg.partition_names.push(reader |> @lib.read_string())
      (7, _) => msg.travel_timestamp = reader |> @lib.read_uint64()
      (8, _) => msg.guarantee_timestamp = reader |> @lib.read_uint64()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.query_params.push(
          (reader |> @lib.read_message() : @common.KeyValuePair),
        )
      (10, _) => msg.not_return_all_meta = reader |> @lib.read_bool()
      (11, _) =>
        msg.consistency_level = reader
          |> @lib.read_enum()
          |> @common.ConsistencyLevel::from_enum
      (12, _) => msg.use_default_consistency = reader |> @lib.read_bool()
      (14, _) => msg.namespace_ = reader |> @lib.read_string() |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for QueryRequest with fn write(
  self : QueryRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.expr != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.expr)
  }
  for item in self.output_fields {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(item)
  }
  for item in self.partition_names {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_string(item)
  }
  if self.travel_timestamp != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_uint64(self.travel_timestamp)
  }
  if self.guarantee_timestamp != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_uint64(self.guarantee_timestamp)
  }
  for item in self.query_params {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_message(item)
  }
  if self.not_return_all_meta != Default::default() {
    writer |> @lib.write_varint(80UL)
    writer |> @lib.write_bool(self.not_return_all_meta)
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.write_varint(88UL)
    writer |> @lib.write_enum(self.consistency_level.to_enum())
  }
  if self.use_default_consistency != Default::default() {
    writer |> @lib.write_varint(96UL)
    writer |> @lib.write_bool(self.use_default_consistency)
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.write_varint(114UL)
    writer |> @lib.write_string(v)
  }
}

///|
pub impl ToJson for QueryRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.expr != Default::default() {
    json["expr"] = ToJson::to_json(self.expr)
  }
  if self.output_fields != Default::default() {
    json["outputFields"] = ToJson::to_json(self.output_fields)
  }
  if self.partition_names != Default::default() {
    json["partitionNames"] = ToJson::to_json(self.partition_names)
  }
  if self.travel_timestamp != Default::default() {
    json["travelTimestamp"] = ToJson::to_json(self.travel_timestamp)
  }
  if self.guarantee_timestamp != Default::default() {
    json["guaranteeTimestamp"] = ToJson::to_json(self.guarantee_timestamp)
  }
  if self.query_params != Default::default() {
    json["queryParams"] = ToJson::to_json(self.query_params)
  }
  if self.not_return_all_meta != Default::default() {
    json["notReturnAllMeta"] = ToJson::to_json(self.not_return_all_meta)
  }
  if self.consistency_level != Default::default() {
    json["consistencyLevel"] = ToJson::to_json(self.consistency_level)
  }
  if self.use_default_consistency != Default::default() {
    json["useDefaultConsistency"] = ToJson::to_json(
      self.use_default_consistency,
    )
  }
  match self.namespace_ {
    Some(v) => json["namespace"] = ToJson::to_json(v)
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for QueryRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> QueryRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for QueryRequest"))
  }
  let message : QueryRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("expr", value) => message.expr = @json.from_json(value, path~)
      ("outputFields", Array(value)) =>
        message.output_fields = value.map(v => @json.from_json(v, path~))
      ("partitionNames", Array(value)) =>
        message.partition_names = value.map(v => @json.from_json(v, path~))
      ("travelTimestamp", value) =>
        message.travel_timestamp = @json.from_json(value, path~)
      ("guaranteeTimestamp", value) =>
        message.guarantee_timestamp = @json.from_json(value, path~)
      ("queryParams", Array(value)) =>
        message.query_params = value.map(v => @json.from_json(v, path~))
      ("notReturnAllMeta", value) =>
        message.not_return_all_meta = @json.from_json(value, path~)
      ("consistencyLevel", value) =>
        message.consistency_level = @json.from_json(value, path~)
      ("useDefaultConsistency", value) =>
        message.use_default_consistency = @json.from_json(value, path~)
      ("namespace", value) =>
        message.namespace_ = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for QueryRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> QueryRequest raise {
  let msg : QueryRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.expr = reader |> @lib.async_read_string()
      (5, _) => msg.output_fields.push(reader |> @lib.async_read_string())
      (6, _) => msg.partition_names.push(reader |> @lib.async_read_string())
      (7, _) => msg.travel_timestamp = reader |> @lib.async_read_uint64()
      (8, _) => msg.guarantee_timestamp = reader |> @lib.async_read_uint64()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.query_params.push(
          (reader |> @lib.async_read_message() : @common.KeyValuePair),
        )
      (10, _) => msg.not_return_all_meta = reader |> @lib.async_read_bool()
      (11, _) =>
        msg.consistency_level = reader
          |> @lib.async_read_enum()
          |> @common.ConsistencyLevel::from_enum
      (12, _) => msg.use_default_consistency = reader |> @lib.async_read_bool()
      (14, _) => msg.namespace_ = reader |> @lib.async_read_string() |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for QueryRequest with fn write(
  self : QueryRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.expr != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.expr)
  }
  for item in self.output_fields {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(item)
  }
  for item in self.partition_names {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_string(item)
  }
  if self.travel_timestamp != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_uint64(self.travel_timestamp)
  }
  if self.guarantee_timestamp != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_uint64(self.guarantee_timestamp)
  }
  for item in self.query_params {
    writer |> @lib.async_write_varint(74UL)
    writer |> @lib.async_write_message(item)
  }
  if self.not_return_all_meta != Default::default() {
    writer |> @lib.async_write_varint(80UL)
    writer |> @lib.async_write_bool(self.not_return_all_meta)
  }
  if self.consistency_level != Default::default() {
    writer |> @lib.async_write_varint(88UL)
    writer |> @lib.async_write_enum(self.consistency_level.to_enum())
  }
  if self.use_default_consistency != Default::default() {
    writer |> @lib.async_write_varint(96UL)
    writer |> @lib.async_write_bool(self.use_default_consistency)
  }
  if self.namespace_ is Some(v) {
    writer |> @lib.async_write_varint(114UL)
    writer |> @lib.async_write_string(v)
  }
}

///|
pub(all) struct QueryResults {
  mut status : @common.Status?
  mut fields_data : Array[@schema.FieldData]
  mut collection_name : String
  mut output_fields : Array[String]
  mut session_ts : UInt64
  mut primary_field_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for QueryResults with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  for s in self.fields_data {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  for s in self.output_fields {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  if self.session_ts != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.session_ts))
  }
  if self.primary_field_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      6U,
      @lib.size_of(self.primary_field_name),
    )
  }
  size
}

///|
pub impl Default for QueryResults with fn default() -> QueryResults {
  QueryResults::{
    status: None,
    fields_data: [],
    collection_name: Default::default(),
    output_fields: [],
    session_ts: Default::default(),
    primary_field_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn QueryResults::QueryResults(
  status? : @common.Status,
  fields_data : Array[@schema.FieldData],
  collection_name : String,
  output_fields : Array[String],
  session_ts : UInt64,
  primary_field_name : String,
) -> QueryResults {
  QueryResults::{
    status,
    fields_data,
    collection_name,
    output_fields,
    session_ts,
    primary_field_name,
  }
}

///|
pub impl @lib.Read for QueryResults with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> QueryResults raise {
  let msg : QueryResults = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields_data.push(
          (reader |> @lib.read_message() : @schema.FieldData),
        )
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.output_fields.push(reader |> @lib.read_string())
      (5, _) => msg.session_ts = reader |> @lib.read_uint64()
      (6, _) => msg.primary_field_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for QueryResults with fn write(
  self : QueryResults,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  for item in self.fields_data {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(item)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  for item in self.output_fields {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(item)
  }
  if self.session_ts != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_uint64(self.session_ts)
  }
  if self.primary_field_name != Default::default() {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_string(self.primary_field_name)
  }
}

///|
pub impl ToJson for QueryResults with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.fields_data != Default::default() {
    json["fieldsData"] = ToJson::to_json(self.fields_data)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.output_fields != Default::default() {
    json["outputFields"] = ToJson::to_json(self.output_fields)
  }
  if self.session_ts != Default::default() {
    json["sessionTs"] = ToJson::to_json(self.session_ts)
  }
  if self.primary_field_name != Default::default() {
    json["primaryFieldName"] = ToJson::to_json(self.primary_field_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for QueryResults with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> QueryResults raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for QueryResults"))
  }
  let message : QueryResults = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("fieldsData", Array(value)) =>
        message.fields_data = value.map(v => @json.from_json(v, path~))
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("outputFields", Array(value)) =>
        message.output_fields = value.map(v => @json.from_json(v, path~))
      ("sessionTs", value) => message.session_ts = @json.from_json(value, path~)
      ("primaryFieldName", value) =>
        message.primary_field_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for QueryResults with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> QueryResults raise {
  let msg : QueryResults = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields_data.push(
          (reader |> @lib.async_read_message() : @schema.FieldData),
        )
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.output_fields.push(reader |> @lib.async_read_string())
      (5, _) => msg.session_ts = reader |> @lib.async_read_uint64()
      (6, _) => msg.primary_field_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for QueryResults with fn write(
  self : QueryResults,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  for item in self.fields_data {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(item)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  for item in self.output_fields {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(item)
  }
  if self.session_ts != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_uint64(self.session_ts)
  }
  if self.primary_field_name != Default::default() {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_string(self.primary_field_name)
  }
}

///|
pub(all) struct CreatePartitionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for CreatePartitionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.partition_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.partition_name),
    )
  }
  size
}

///|
pub impl Default for CreatePartitionRequest with fn default() -> CreatePartitionRequest {
  CreatePartitionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn CreatePartitionRequest::CreatePartitionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_name : String,
) -> CreatePartitionRequest {
  CreatePartitionRequest::{ base, db_name, collection_name, partition_name, }
}

///|
pub impl @lib.Read for CreatePartitionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> CreatePartitionRequest raise {
  let msg : CreatePartitionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for CreatePartitionRequest with fn write(
  self : CreatePartitionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.partition_name)
  }
}

///|
pub impl ToJson for CreatePartitionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_name != Default::default() {
    json["partitionName"] = ToJson::to_json(self.partition_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for CreatePartitionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> CreatePartitionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for CreatePartitionRequest"),
    )
  }
  let message : CreatePartitionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionName", value) =>
        message.partition_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for CreatePartitionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> CreatePartitionRequest raise {
  let msg : CreatePartitionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for CreatePartitionRequest with fn write(
  self : CreatePartitionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.partition_name)
  }
}

///|
pub(all) struct DropPartitionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DropPartitionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.partition_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.partition_name),
    )
  }
  size
}

///|
pub impl Default for DropPartitionRequest with fn default() -> DropPartitionRequest {
  DropPartitionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn DropPartitionRequest::DropPartitionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_name : String,
) -> DropPartitionRequest {
  DropPartitionRequest::{ base, db_name, collection_name, partition_name, }
}

///|
pub impl @lib.Read for DropPartitionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DropPartitionRequest raise {
  let msg : DropPartitionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DropPartitionRequest with fn write(
  self : DropPartitionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.partition_name)
  }
}

///|
pub impl ToJson for DropPartitionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_name != Default::default() {
    json["partitionName"] = ToJson::to_json(self.partition_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DropPartitionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DropPartitionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DropPartitionRequest"),
    )
  }
  let message : DropPartitionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionName", value) =>
        message.partition_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DropPartitionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DropPartitionRequest raise {
  let msg : DropPartitionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DropPartitionRequest with fn write(
  self : DropPartitionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.partition_name)
  }
}

///|
pub(all) struct HasPartitionRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for HasPartitionRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.partition_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.partition_name),
    )
  }
  size
}

///|
pub impl Default for HasPartitionRequest with fn default() -> HasPartitionRequest {
  HasPartitionRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn HasPartitionRequest::HasPartitionRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_name : String,
) -> HasPartitionRequest {
  HasPartitionRequest::{ base, db_name, collection_name, partition_name, }
}

///|
pub impl @lib.Read for HasPartitionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> HasPartitionRequest raise {
  let msg : HasPartitionRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for HasPartitionRequest with fn write(
  self : HasPartitionRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.partition_name)
  }
}

///|
pub impl ToJson for HasPartitionRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_name != Default::default() {
    json["partitionName"] = ToJson::to_json(self.partition_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for HasPartitionRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> HasPartitionRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for HasPartitionRequest"),
    )
  }
  let message : HasPartitionRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionName", value) =>
        message.partition_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for HasPartitionRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> HasPartitionRequest raise {
  let msg : HasPartitionRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for HasPartitionRequest with fn write(
  self : HasPartitionRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.partition_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.partition_name)
  }
}

///|
pub(all) struct LoadPartitionsRequest_LoadParamsEntry {
  mut key : String
  mut value : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for LoadPartitionsRequest_LoadParamsEntry with fn size_of(
  self,
) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for LoadPartitionsRequest_LoadParamsEntry with fn default() -> LoadPartitionsRequest_LoadParamsEntry {
  LoadPartitionsRequest_LoadParamsEntry::{
    key: Default::default(),
    value: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn LoadPartitionsRequest_LoadParamsEntry::LoadPartitionsRequest_LoadParamsEntry(
  key : String,
  value : String,
) -> LoadPartitionsRequest_LoadParamsEntry {
  LoadPartitionsRequest_LoadParamsEntry::{ key, value, }
}

///|
pub impl @lib.Read for LoadPartitionsRequest_LoadParamsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> LoadPartitionsRequest_LoadParamsEntry raise {
  let msg : LoadPartitionsRequest_LoadParamsEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for LoadPartitionsRequest_LoadParamsEntry with fn write(
  self : LoadPartitionsRequest_LoadParamsEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.value)
  }
}

///|
pub impl ToJson for LoadPartitionsRequest_LoadParamsEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for LoadPartitionsRequest_LoadParamsEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> LoadPartitionsRequest_LoadParamsEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for LoadPartitionsRequest_LoadParamsEntry"),
    )
  }
  let message : LoadPartitionsRequest_LoadParamsEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for LoadPartitionsRequest_LoadParamsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> LoadPartitionsRequest_LoadParamsEntry raise {
  let msg : LoadPartitionsRequest_LoadParamsEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for LoadPartitionsRequest_LoadParamsEntry with fn write(
  self : LoadPartitionsRequest_LoadParamsEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.value)
  }
}

///|
pub(all) struct LoadPartitionsRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_names : Array[String]
  mut replica_number : Int
  mut resource_groups : Array[String]
  mut refresh : Bool
  mut load_fields : Array[String]
  mut skip_load_dynamic_field : Bool
  mut load_params : Map[String, String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for LoadPartitionsRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  for s in self.partition_names {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  if self.replica_number != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.replica_number))
  }
  for s in self.resource_groups {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  if self.refresh != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.refresh))
  }
  for s in self.load_fields {
    size += @lib.size_of_length_delimited_field(8U, @lib.size_of(s))
  }
  if self.skip_load_dynamic_field != Default::default() {
    size += @lib.size_of_field(9U, @lib.size_of(self.skip_load_dynamic_field))
  }
  for k, v in self.load_params {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(10U, key_size + value_size)
  }
  size
}

///|
pub impl Default for LoadPartitionsRequest with fn default() -> LoadPartitionsRequest {
  LoadPartitionsRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_names: [],
    replica_number: Default::default(),
    resource_groups: [],
    refresh: Default::default(),
    load_fields: [],
    skip_load_dynamic_field: Default::default(),
    load_params: {},
  }
}

///|
#alias(new, deprecated)
pub fn LoadPartitionsRequest::LoadPartitionsRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_names : Array[String],
  replica_number : Int,
  resource_groups : Array[String],
  refresh : Bool,
  load_fields : Array[String],
  skip_load_dynamic_field : Bool,
  load_params : Map[String, String],
) -> LoadPartitionsRequest {
  LoadPartitionsRequest::{
    base,
    db_name,
    collection_name,
    partition_names,
    replica_number,
    resource_groups,
    refresh,
    load_fields,
    skip_load_dynamic_field,
    load_params,
  }
}

///|
pub impl @lib.Read for LoadPartitionsRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> LoadPartitionsRequest raise {
  let msg : LoadPartitionsRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_names.push(reader |> @lib.read_string())
      (5, _) => msg.replica_number = reader |> @lib.read_int32()
      (6, _) => msg.resource_groups.push(reader |> @lib.read_string())
      (7, _) => msg.refresh = reader |> @lib.read_bool()
      (8, _) => msg.load_fields.push(reader |> @lib.read_string())
      (9, _) => msg.skip_load_dynamic_field = reader |> @lib.read_bool()
      (10, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : LoadPartitionsRequest_LoadParamsEntry)
        msg.load_params[key] = value
      }
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for LoadPartitionsRequest with fn write(
  self : LoadPartitionsRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(item)
  }
  if self.replica_number != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_int32(self.replica_number)
  }
  for item in self.resource_groups {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_string(item)
  }
  if self.refresh != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_bool(self.refresh)
  }
  for item in self.load_fields {
    writer |> @lib.write_varint(66UL)
    writer |> @lib.write_string(item)
  }
  if self.skip_load_dynamic_field != Default::default() {
    writer |> @lib.write_varint(72UL)
    writer |> @lib.write_bool(self.skip_load_dynamic_field)
  }
  let keys = self.load_params.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.load_params.get(k).unwrap()
    writer |> @lib.write_varint(82UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(v)
  }
}

///|
pub impl ToJson for LoadPartitionsRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_names != Default::default() {
    json["partitionNames"] = ToJson::to_json(self.partition_names)
  }
  if self.replica_number != Default::default() {
    json["replicaNumber"] = ToJson::to_json(self.replica_number)
  }
  if self.resource_groups != Default::default() {
    json["resourceGroups"] = ToJson::to_json(self.resource_groups)
  }
  if self.refresh != Default::default() {
    json["refresh"] = ToJson::to_json(self.refresh)
  }
  if self.load_fields != Default::default() {
    json["loadFields"] = ToJson::to_json(self.load_fields)
  }
  if self.skip_load_dynamic_field != Default::default() {
    json["skipLoadDynamicField"] = ToJson::to_json(self.skip_load_dynamic_field)
  }
  if self.load_params != Default::default() {
    json["loadParams"] = ToJson::to_json(self.load_params)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for LoadPartitionsRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> LoadPartitionsRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for LoadPartitionsRequest"),
    )
  }
  let message : LoadPartitionsRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionNames", Array(value)) =>
        message.partition_names = value.map(v => @json.from_json(v, path~))
      ("replicaNumber", value) =>
        message.replica_number = @json.from_json(value, path~)
      ("resourceGroups", Array(value)) =>
        message.resource_groups = value.map(v => @json.from_json(v, path~))
      ("refresh", value) => message.refresh = @json.from_json(value, path~)
      ("loadFields", Array(value)) =>
        message.load_fields = value.map(v => @json.from_json(v, path~))
      ("skipLoadDynamicField", value) =>
        message.skip_load_dynamic_field = @json.from_json(value, path~)
      ("loadParams", _) => message.load_params = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for LoadPartitionsRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> LoadPartitionsRequest raise {
  let msg : LoadPartitionsRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_names.push(reader |> @lib.async_read_string())
      (5, _) => msg.replica_number = reader |> @lib.async_read_int32()
      (6, _) => msg.resource_groups.push(reader |> @lib.async_read_string())
      (7, _) => msg.refresh = reader |> @lib.async_read_bool()
      (8, _) => msg.load_fields.push(reader |> @lib.async_read_string())
      (9, _) => msg.skip_load_dynamic_field = reader |> @lib.async_read_bool()
      (10, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() :
          LoadPartitionsRequest_LoadParamsEntry)
        msg.load_params[key] = value
      }
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for LoadPartitionsRequest with fn write(
  self : LoadPartitionsRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(item)
  }
  if self.replica_number != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_int32(self.replica_number)
  }
  for item in self.resource_groups {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_string(item)
  }
  if self.refresh != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_bool(self.refresh)
  }
  for item in self.load_fields {
    writer |> @lib.async_write_varint(66UL)
    writer |> @lib.async_write_string(item)
  }
  if self.skip_load_dynamic_field != Default::default() {
    writer |> @lib.async_write_varint(72UL)
    writer |> @lib.async_write_bool(self.skip_load_dynamic_field)
  }
  let keys = self.load_params.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.load_params.get(k).unwrap()
    writer |> @lib.async_write_varint(82UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(v)
  }
}

///|
pub(all) struct ReleasePartitionsRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut partition_names : Array[String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ReleasePartitionsRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  for s in self.partition_names {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for ReleasePartitionsRequest with fn default() -> ReleasePartitionsRequest {
  ReleasePartitionsRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    partition_names: [],
  }
}

///|
#alias(new, deprecated)
pub fn ReleasePartitionsRequest::ReleasePartitionsRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  partition_names : Array[String],
) -> ReleasePartitionsRequest {
  ReleasePartitionsRequest::{ base, db_name, collection_name, partition_names, }
}

///|
pub impl @lib.Read for ReleasePartitionsRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ReleasePartitionsRequest raise {
  let msg : ReleasePartitionsRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.partition_names.push(reader |> @lib.read_string())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ReleasePartitionsRequest with fn write(
  self : ReleasePartitionsRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(item)
  }
}

///|
pub impl ToJson for ReleasePartitionsRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_names != Default::default() {
    json["partitionNames"] = ToJson::to_json(self.partition_names)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ReleasePartitionsRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ReleasePartitionsRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ReleasePartitionsRequest"),
    )
  }
  let message : ReleasePartitionsRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionNames", Array(value)) =>
        message.partition_names = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ReleasePartitionsRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ReleasePartitionsRequest raise {
  let msg : ReleasePartitionsRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.partition_names.push(reader |> @lib.async_read_string())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ReleasePartitionsRequest with fn write(
  self : ReleasePartitionsRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(item)
  }
}

///|
pub(all) struct ShowPartitionsRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_name : String
  mut collection_id : Int64
  mut partition_names : Array[String]
  mut type_ : ShowType
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ShowPartitionsRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.collection_name),
    )
  }
  if self.collection_id != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.collection_id))
  }
  for s in self.partition_names {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  if self.type_ != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.type_))
  }
  size
}

///|
pub impl Default for ShowPartitionsRequest with fn default() -> ShowPartitionsRequest {
  ShowPartitionsRequest::{
    base: None,
    db_name: Default::default(),
    collection_name: Default::default(),
    collection_id: Default::default(),
    partition_names: [],
    type_: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn ShowPartitionsRequest::ShowPartitionsRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_name : String,
  collection_id : Int64,
  partition_names : Array[String],
  type_ : ShowType,
) -> ShowPartitionsRequest {
  ShowPartitionsRequest::{
    base,
    db_name,
    collection_name,
    collection_id,
    partition_names,
    type_,
  }
}

///|
pub impl @lib.Read for ShowPartitionsRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ShowPartitionsRequest raise {
  let msg : ShowPartitionsRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_name = reader |> @lib.read_string()
      (4, _) => msg.collection_id = reader |> @lib.read_int64()
      (5, _) => msg.partition_names.push(reader |> @lib.read_string())
      (6, _) => msg.type_ = reader |> @lib.read_enum() |> ShowType::from_enum
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ShowPartitionsRequest with fn write(
  self : ShowPartitionsRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.collection_name)
  }
  if self.collection_id != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_int64(self.collection_id)
  }
  for item in self.partition_names {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(item)
  }
  if self.type_ != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_enum(self.type_.to_enum())
  }
}

///|
pub impl ToJson for ShowPartitionsRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.collection_id != Default::default() {
    json["collectionID"] = ToJson::to_json(self.collection_id)
  }
  if self.partition_names != Default::default() {
    json["partitionNames"] = ToJson::to_json(self.partition_names)
  }
  if self.type_ != Default::default() {
    json["type"] = ToJson::to_json(self.type_)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ShowPartitionsRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ShowPartitionsRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ShowPartitionsRequest"),
    )
  }
  let message : ShowPartitionsRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("collectionID", value) =>
        message.collection_id = @json.from_json(value, path~)
      ("partitionNames", Array(value)) =>
        message.partition_names = value.map(v => @json.from_json(v, path~))
      ("type", value) => message.type_ = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ShowPartitionsRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ShowPartitionsRequest raise {
  let msg : ShowPartitionsRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_name = reader |> @lib.async_read_string()
      (4, _) => msg.collection_id = reader |> @lib.async_read_int64()
      (5, _) => msg.partition_names.push(reader |> @lib.async_read_string())
      (6, _) =>
        msg.type_ = reader |> @lib.async_read_enum() |> ShowType::from_enum
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ShowPartitionsRequest with fn write(
  self : ShowPartitionsRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  if self.collection_id != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_int64(self.collection_id)
  }
  for item in self.partition_names {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(item)
  }
  if self.type_ != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_enum(self.type_.to_enum())
  }
}

///|
pub(all) struct ShowPartitionsResponse {
  mut status : @common.Status?
  mut partition_names : Array[String]
  mut partition_ids : Array[Int64]
  mut created_timestamps : Array[UInt64]
  mut created_utc_timestamps : Array[UInt64]
  mut in_memory_percentages : Array[Int64]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ShowPartitionsResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  for s in self.partition_names {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  if !self.partition_ids.is_empty() {
    size += @lib.size_of_length_delimited_field(
      3U,
      self.partition_ids.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if !self.created_timestamps.is_empty() {
    size += @lib.size_of_length_delimited_field(
      4U,
      self.created_timestamps.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if !self.created_utc_timestamps.is_empty() {
    size += @lib.size_of_length_delimited_field(
      5U,
      self.created_utc_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add),
    )
  }
  if !self.in_memory_percentages.is_empty() {
    size += @lib.size_of_length_delimited_field(
      6U,
      self.in_memory_percentages
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add),
    )
  }
  size
}

///|
pub impl Default for ShowPartitionsResponse with fn default() -> ShowPartitionsResponse {
  ShowPartitionsResponse::{
    status: None,
    partition_names: [],
    partition_ids: [],
    created_timestamps: [],
    created_utc_timestamps: [],
    in_memory_percentages: [],
  }
}

///|
#alias(new, deprecated)
pub fn ShowPartitionsResponse::ShowPartitionsResponse(
  status? : @common.Status,
  partition_names : Array[String],
  partition_ids : Array[Int64],
  created_timestamps : Array[UInt64],
  created_utc_timestamps : Array[UInt64],
  in_memory_percentages : Array[Int64],
) -> ShowPartitionsResponse {
  ShowPartitionsResponse::{
    status,
    partition_names,
    partition_ids,
    created_timestamps,
    created_utc_timestamps,
    in_memory_percentages,
  }
}

///|
pub impl @lib.Read for ShowPartitionsResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ShowPartitionsResponse raise {
  let msg : ShowPartitionsResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, _) => msg.partition_names.push(reader |> @lib.read_string())
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.partition_ids.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (3, @lib.WIRE_TYPE_VARINT) =>
        msg.partition_ids.push(reader |> @lib.read_int64())
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.created_timestamps.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint64, None)).iter(),
        )
      (4, @lib.WIRE_TYPE_VARINT) =>
        msg.created_timestamps.push(reader |> @lib.read_uint64())
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.created_utc_timestamps.push_iter(
          (reader |> @lib.read_packed(@lib.read_uint64, None)).iter(),
        )
      (5, @lib.WIRE_TYPE_VARINT) =>
        msg.created_utc_timestamps.push(reader |> @lib.read_uint64())
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.in_memory_percentages.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.in_memory_percentages.push(reader |> @lib.read_int64())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ShowPartitionsResponse with fn write(
  self : ShowPartitionsResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  for item in self.partition_names {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(item)
  }
  if !self.partition_ids.is_empty() {
    writer |> @lib.write_varint(26UL)
    let size = self.partition_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.partition_ids {
      writer |> @lib.write_int64(item)
    }
  }
  if !self.created_timestamps.is_empty() {
    writer |> @lib.write_varint(34UL)
    let size = self.created_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.created_timestamps {
      writer |> @lib.write_uint64(item)
    }
  }
  if !self.created_utc_timestamps.is_empty() {
    writer |> @lib.write_varint(42UL)
    let size = self.created_utc_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.created_utc_timestamps {
      writer |> @lib.write_uint64(item)
    }
  }
  if !self.in_memory_percentages.is_empty() {
    writer |> @lib.write_varint(50UL)
    let size = self.in_memory_percentages
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.in_memory_percentages {
      writer |> @lib.write_int64(item)
    }
  }
}

///|
pub impl ToJson for ShowPartitionsResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.partition_names != Default::default() {
    json["partitionNames"] = ToJson::to_json(self.partition_names)
  }
  if self.partition_ids != Default::default() {
    json["partitionIDs"] = ToJson::to_json(self.partition_ids)
  }
  if self.created_timestamps != Default::default() {
    json["createdTimestamps"] = ToJson::to_json(self.created_timestamps)
  }
  if self.created_utc_timestamps != Default::default() {
    json["createdUtcTimestamps"] = ToJson::to_json(self.created_utc_timestamps)
  }
  if self.in_memory_percentages != Default::default() {
    json["inMemoryPercentages"] = ToJson::to_json(self.in_memory_percentages)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ShowPartitionsResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ShowPartitionsResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ShowPartitionsResponse"),
    )
  }
  let message : ShowPartitionsResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("partitionNames", Array(value)) =>
        message.partition_names = value.map(v => @json.from_json(v, path~))
      ("partitionIDs", Array(value)) =>
        message.partition_ids = value.map(v => @json.from_json(v, path~))
      ("createdTimestamps", Array(value)) =>
        message.created_timestamps = value.map(v => @json.from_json(v, path~))
      ("createdUtcTimestamps", Array(value)) =>
        message.created_utc_timestamps = value.map(v => {
          @json.from_json(v, path~)
        })
      ("inMemoryPercentages", Array(value)) =>
        message.in_memory_percentages = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ShowPartitionsResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ShowPartitionsResponse raise {
  let msg : ShowPartitionsResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, _) => msg.partition_names.push(reader |> @lib.async_read_string())
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.partition_ids.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (3, @lib.WIRE_TYPE_VARINT) =>
        msg.partition_ids.push(reader |> @lib.async_read_int64())
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.created_timestamps.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint64, None)).iter(),
        )
      (4, @lib.WIRE_TYPE_VARINT) =>
        msg.created_timestamps.push(reader |> @lib.async_read_uint64())
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.created_utc_timestamps.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_uint64, None)).iter(),
        )
      (5, @lib.WIRE_TYPE_VARINT) =>
        msg.created_utc_timestamps.push(reader |> @lib.async_read_uint64())
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.in_memory_percentages.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (6, @lib.WIRE_TYPE_VARINT) =>
        msg.in_memory_percentages.push(reader |> @lib.async_read_int64())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ShowPartitionsResponse with fn write(
  self : ShowPartitionsResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  for item in self.partition_names {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(item)
  }
  if !self.partition_ids.is_empty() {
    writer |> @lib.async_write_varint(26UL)
    let size = self.partition_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.partition_ids {
      writer |> @lib.async_write_int64(item)
    }
  }
  if !self.created_timestamps.is_empty() {
    writer |> @lib.async_write_varint(34UL)
    let size = self.created_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.created_timestamps {
      writer |> @lib.async_write_uint64(item)
    }
  }
  if !self.created_utc_timestamps.is_empty() {
    writer |> @lib.async_write_varint(42UL)
    let size = self.created_utc_timestamps
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.created_utc_timestamps {
      writer |> @lib.async_write_uint64(item)
    }
  }
  if !self.in_memory_percentages.is_empty() {
    writer |> @lib.async_write_varint(50UL)
    let size = self.in_memory_percentages
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.in_memory_percentages {
      writer |> @lib.async_write_int64(item)
    }
  }
}

///|
pub(all) struct GetLoadingProgressRequest {
  mut base : @common.MsgBase?
  mut collection_name : String
  mut partition_names : Array[String]
  mut db_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for GetLoadingProgressRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      2U,
      @lib.size_of(self.collection_name),
    )
  }
  for s in self.partition_names {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(self.db_name))
  }
  size
}

///|
pub impl Default for GetLoadingProgressRequest with fn default() -> GetLoadingProgressRequest {
  GetLoadingProgressRequest::{
    base: None,
    collection_name: Default::default(),
    partition_names: [],
    db_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn GetLoadingProgressRequest::GetLoadingProgressRequest(
  base? : @common.MsgBase,
  collection_name : String,
  partition_names : Array[String],
  db_name : String,
) -> GetLoadingProgressRequest {
  GetLoadingProgressRequest::{
    base,
    collection_name,
    partition_names,
    db_name,
  }
}

///|
pub impl @lib.Read for GetLoadingProgressRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> GetLoadingProgressRequest raise {
  let msg : GetLoadingProgressRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.collection_name = reader |> @lib.read_string()
      (3, _) => msg.partition_names.push(reader |> @lib.read_string())
      (4, _) => msg.db_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GetLoadingProgressRequest with fn write(
  self : GetLoadingProgressRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(item)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.db_name)
  }
}

///|
pub impl ToJson for GetLoadingProgressRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  if self.partition_names != Default::default() {
    json["partitionNames"] = ToJson::to_json(self.partition_names)
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GetLoadingProgressRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> GetLoadingProgressRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GetLoadingProgressRequest"),
    )
  }
  let message : GetLoadingProgressRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      ("partitionNames", Array(value)) =>
        message.partition_names = value.map(v => @json.from_json(v, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for GetLoadingProgressRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> GetLoadingProgressRequest raise {
  let msg : GetLoadingProgressRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.collection_name = reader |> @lib.async_read_string()
      (3, _) => msg.partition_names.push(reader |> @lib.async_read_string())
      (4, _) => msg.db_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for GetLoadingProgressRequest with fn write(
  self : GetLoadingProgressRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
  for item in self.partition_names {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(item)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.db_name)
  }
}

///|
pub(all) struct GetLoadingProgressResponse {
  mut status : @common.Status?
  mut progress : Int64
  mut refresh_progress : Int64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for GetLoadingProgressResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.progress != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.progress))
  }
  if self.refresh_progress != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.refresh_progress))
  }
  size
}

///|
pub impl Default for GetLoadingProgressResponse with fn default() -> GetLoadingProgressResponse {
  GetLoadingProgressResponse::{
    status: None,
    progress: Default::default(),
    refresh_progress: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn GetLoadingProgressResponse::GetLoadingProgressResponse(
  status? : @common.Status,
  progress : Int64,
  refresh_progress : Int64,
) -> GetLoadingProgressResponse {
  GetLoadingProgressResponse::{ status, progress, refresh_progress, }
}

///|
pub impl @lib.Read for GetLoadingProgressResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> GetLoadingProgressResponse raise {
  let msg : GetLoadingProgressResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, _) => msg.progress = reader |> @lib.read_int64()
      (3, _) => msg.refresh_progress = reader |> @lib.read_int64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GetLoadingProgressResponse with fn write(
  self : GetLoadingProgressResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.progress != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.progress)
  }
  if self.refresh_progress != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_int64(self.refresh_progress)
  }
}

///|
pub impl ToJson for GetLoadingProgressResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.progress != Default::default() {
    json["progress"] = ToJson::to_json(self.progress)
  }
  if self.refresh_progress != Default::default() {
    json["refreshProgress"] = ToJson::to_json(self.refresh_progress)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GetLoadingProgressResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> GetLoadingProgressResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GetLoadingProgressResponse"),
    )
  }
  let message : GetLoadingProgressResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("progress", value) => message.progress = @json.from_json(value, path~)
      ("refreshProgress", value) =>
        message.refresh_progress = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for GetLoadingProgressResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> GetLoadingProgressResponse raise {
  let msg : GetLoadingProgressResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, _) => msg.progress = reader |> @lib.async_read_int64()
      (3, _) => msg.refresh_progress = reader |> @lib.async_read_int64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for GetLoadingProgressResponse with fn write(
  self : GetLoadingProgressResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.progress != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.progress)
  }
  if self.refresh_progress != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_int64(self.refresh_progress)
  }
}

///|
pub(all) struct FlushRequest {
  mut base : @common.MsgBase?
  mut db_name : String
  mut collection_names : Array[String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FlushRequest with fn size_of(self) {
  let mut size = 0U
  if self.base is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  for s in self.collection_names {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for FlushRequest with fn default() -> FlushRequest {
  FlushRequest::{
    base: None,
    db_name: Default::default(),
    collection_names: [],
  }
}

///|
#alias(new, deprecated)
pub fn FlushRequest::FlushRequest(
  base? : @common.MsgBase,
  db_name : String,
  collection_names : Array[String],
) -> FlushRequest {
  FlushRequest::{ base, db_name, collection_names, }
}

///|
pub impl @lib.Read for FlushRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FlushRequest raise {
  let msg : FlushRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.read_message() : @common.MsgBase) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, _) => msg.collection_names.push(reader |> @lib.read_string())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FlushRequest with fn write(
  self : FlushRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  for item in self.collection_names {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(item)
  }
}

///|
pub impl ToJson for FlushRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.base {
    Some(v) => json["base"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_names != Default::default() {
    json["collectionNames"] = ToJson::to_json(self.collection_names)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FlushRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FlushRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FlushRequest"))
  }
  let message : FlushRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("base", value) => message.base = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionNames", Array(value)) =>
        message.collection_names = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FlushRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FlushRequest raise {
  let msg : FlushRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.base = (reader |> @lib.async_read_message() : @common.MsgBase)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, _) => msg.collection_names.push(reader |> @lib.async_read_string())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FlushRequest with fn write(
  self : FlushRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.base is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  for item in self.collection_names {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(item)
  }
}

///|
pub(all) struct FlushResponse_CollSegIDsEntry {
  mut key : String
  mut value : @schema.LongArray
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FlushResponse_CollSegIDsEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  size
}

///|
pub impl Default for FlushResponse_CollSegIDsEntry with fn default() -> FlushResponse_CollSegIDsEntry {
  FlushResponse_CollSegIDsEntry::{
    key: Default::default(),
    value: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn FlushResponse_CollSegIDsEntry::FlushResponse_CollSegIDsEntry(
  key : String,
  value : @schema.LongArray,
) -> FlushResponse_CollSegIDsEntry {
  FlushResponse_CollSegIDsEntry::{ key, value, }
}

///|
pub impl @lib.Read for FlushResponse_CollSegIDsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FlushResponse_CollSegIDsEntry raise {
  let msg : FlushResponse_CollSegIDsEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.value = (reader |> @lib.read_message() : @schema.LongArray)
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FlushResponse_CollSegIDsEntry with fn write(
  self : FlushResponse_CollSegIDsEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  writer |> @lib.write_varint(18UL)
  writer |> @lib.write_message(self.value)
}

///|
pub impl ToJson for FlushResponse_CollSegIDsEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FlushResponse_CollSegIDsEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FlushResponse_CollSegIDsEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FlushResponse_CollSegIDsEntry"),
    )
  }
  let message : FlushResponse_CollSegIDsEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FlushResponse_CollSegIDsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FlushResponse_CollSegIDsEntry raise {
  let msg : FlushResponse_CollSegIDsEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.value = (reader |> @lib.async_read_message() : @schema.LongArray)
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FlushResponse_CollSegIDsEntry with fn write(
  self : FlushResponse_CollSegIDsEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  writer |> @lib.async_write_varint(18UL)
  writer |> @lib.async_write_message(self.value)
}

///|
pub(all) struct FlushResponse_FlushCollSegIDsEntry {
  mut key : String
  mut value : @schema.LongArray
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FlushResponse_FlushCollSegIDsEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  size
}

///|
pub impl Default for FlushResponse_FlushCollSegIDsEntry with fn default() -> FlushResponse_FlushCollSegIDsEntry {
  FlushResponse_FlushCollSegIDsEntry::{
    key: Default::default(),
    value: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn FlushResponse_FlushCollSegIDsEntry::FlushResponse_FlushCollSegIDsEntry(
  key : String,
  value : @schema.LongArray,
) -> FlushResponse_FlushCollSegIDsEntry {
  FlushResponse_FlushCollSegIDsEntry::{ key, value, }
}

///|
pub impl @lib.Read for FlushResponse_FlushCollSegIDsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FlushResponse_FlushCollSegIDsEntry raise {
  let msg : FlushResponse_FlushCollSegIDsEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.value = (reader |> @lib.read_message() : @schema.LongArray)
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FlushResponse_FlushCollSegIDsEntry with fn write(
  self : FlushResponse_FlushCollSegIDsEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  writer |> @lib.write_varint(18UL)
  writer |> @lib.write_message(self.value)
}

///|
pub impl ToJson for FlushResponse_FlushCollSegIDsEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FlushResponse_FlushCollSegIDsEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FlushResponse_FlushCollSegIDsEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FlushResponse_FlushCollSegIDsEntry"),
    )
  }
  let message : FlushResponse_FlushCollSegIDsEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FlushResponse_FlushCollSegIDsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FlushResponse_FlushCollSegIDsEntry raise {
  let msg : FlushResponse_FlushCollSegIDsEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.value = (reader |> @lib.async_read_message() : @schema.LongArray)
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FlushResponse_FlushCollSegIDsEntry with fn write(
  self : FlushResponse_FlushCollSegIDsEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  writer |> @lib.async_write_varint(18UL)
  writer |> @lib.async_write_message(self.value)
}

///|
pub(all) struct FlushResponse_CollSealTimesEntry {
  mut key : String
  mut value : Int64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FlushResponse_CollSealTimesEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for FlushResponse_CollSealTimesEntry with fn default() -> FlushResponse_CollSealTimesEntry {
  FlushResponse_CollSealTimesEntry::{
    key: Default::default(),
    value: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn FlushResponse_CollSealTimesEntry::FlushResponse_CollSealTimesEntry(
  key : String,
  value : Int64,
) -> FlushResponse_CollSealTimesEntry {
  FlushResponse_CollSealTimesEntry::{ key, value, }
}

///|
pub impl @lib.Read for FlushResponse_CollSealTimesEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FlushResponse_CollSealTimesEntry raise {
  let msg : FlushResponse_CollSealTimesEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_int64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FlushResponse_CollSealTimesEntry with fn write(
  self : FlushResponse_CollSealTimesEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.value)
  }
}

///|
pub impl ToJson for FlushResponse_CollSealTimesEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FlushResponse_CollSealTimesEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FlushResponse_CollSealTimesEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FlushResponse_CollSealTimesEntry"),
    )
  }
  let message : FlushResponse_CollSealTimesEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FlushResponse_CollSealTimesEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FlushResponse_CollSealTimesEntry raise {
  let msg : FlushResponse_CollSealTimesEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_int64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FlushResponse_CollSealTimesEntry with fn write(
  self : FlushResponse_CollSealTimesEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.value)
  }
}

///|
pub(all) struct FlushResponse_CollFlushTsEntry {
  mut key : String
  mut value : UInt64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FlushResponse_CollFlushTsEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for FlushResponse_CollFlushTsEntry with fn default() -> FlushResponse_CollFlushTsEntry {
  FlushResponse_CollFlushTsEntry::{
    key: Default::default(),
    value: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn FlushResponse_CollFlushTsEntry::FlushResponse_CollFlushTsEntry(
  key : String,
  value : UInt64,
) -> FlushResponse_CollFlushTsEntry {
  FlushResponse_CollFlushTsEntry::{ key, value, }
}

///|
pub impl @lib.Read for FlushResponse_CollFlushTsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FlushResponse_CollFlushTsEntry raise {
  let msg : FlushResponse_CollFlushTsEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_uint64()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FlushResponse_CollFlushTsEntry with fn write(
  self : FlushResponse_CollFlushTsEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_uint64(self.value)
  }
}

///|
pub impl ToJson for FlushResponse_CollFlushTsEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FlushResponse_CollFlushTsEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FlushResponse_CollFlushTsEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FlushResponse_CollFlushTsEntry"),
    )
  }
  let message : FlushResponse_CollFlushTsEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FlushResponse_CollFlushTsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FlushResponse_CollFlushTsEntry raise {
  let msg : FlushResponse_CollFlushTsEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_uint64()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FlushResponse_CollFlushTsEntry with fn write(
  self : FlushResponse_CollFlushTsEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_uint64(self.value)
  }
}

///|
pub(all) struct FlushResponse_ChannelCpsEntry {
  mut key : String
  mut value : @msg.MsgPosition
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FlushResponse_ChannelCpsEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  size
}

///|
pub impl Default for FlushResponse_ChannelCpsEntry with fn default() -> FlushResponse_ChannelCpsEntry {
  FlushResponse_ChannelCpsEntry::{
    key: Default::default(),
    value: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn FlushResponse_ChannelCpsEntry::FlushResponse_ChannelCpsEntry(
  key : String,
  value : @msg.MsgPosition,
) -> FlushResponse_ChannelCpsEntry {
  FlushResponse_ChannelCpsEntry::{ key, value, }
}

///|
pub impl @lib.Read for FlushResponse_ChannelCpsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FlushResponse_ChannelCpsEntry raise {
  let msg : FlushResponse_ChannelCpsEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.value = (reader |> @lib.read_message() : @msg.MsgPosition)
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FlushResponse_ChannelCpsEntry with fn write(
  self : FlushResponse_ChannelCpsEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  writer |> @lib.write_varint(18UL)
  writer |> @lib.write_message(self.value)
}

///|
pub impl ToJson for FlushResponse_ChannelCpsEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FlushResponse_ChannelCpsEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FlushResponse_ChannelCpsEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FlushResponse_ChannelCpsEntry"),
    )
  }
  let message : FlushResponse_ChannelCpsEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FlushResponse_ChannelCpsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FlushResponse_ChannelCpsEntry raise {
  let msg : FlushResponse_ChannelCpsEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.value = (reader |> @lib.async_read_message() : @msg.MsgPosition)
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FlushResponse_ChannelCpsEntry with fn write(
  self : FlushResponse_ChannelCpsEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  writer |> @lib.async_write_varint(18UL)
  writer |> @lib.async_write_message(self.value)
}

///|
pub(all) struct FlushResponse {
  mut status : @common.Status?
  mut db_name : String
  mut coll_seg_ids : Map[String, @schema.LongArray]
  mut flush_coll_seg_ids : Map[String, @schema.LongArray]
  mut coll_seal_times : Map[String, Int64]
  mut coll_flush_ts : Map[String, UInt64]
  mut channel_cps : Map[String, @msg.MsgPosition]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FlushResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.db_name))
  }
  for k, v in self.coll_seg_ids {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(3U, key_size + value_size)
  }
  for k, v in self.flush_coll_seg_ids {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(4U, key_size + value_size)
  }
  for k, v in self.coll_seal_times {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(5U, key_size + value_size)
  }
  for k, v in self.coll_flush_ts {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(6U, key_size + value_size)
  }
  for k, v in self.channel_cps {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(7U, key_size + value_size)
  }
  size
}

///|
pub impl Default for FlushResponse with fn default() -> FlushResponse {
  FlushResponse::{
    status: None,
    db_name: Default::default(),
    coll_seg_ids: {},
    flush_coll_seg_ids: {},
    coll_seal_times: {},
    coll_flush_ts: {},
    channel_cps: {},
  }
}

///|
#alias(new, deprecated)
pub fn FlushResponse::FlushResponse(
  status? : @common.Status,
  db_name : String,
  coll_seg_ids : Map[String, @schema.LongArray],
  flush_coll_seg_ids : Map[String, @schema.LongArray],
  coll_seal_times : Map[String, Int64],
  coll_flush_ts : Map[String, UInt64],
  channel_cps : Map[String, @msg.MsgPosition],
) -> FlushResponse {
  FlushResponse::{
    status,
    db_name,
    coll_seg_ids,
    flush_coll_seg_ids,
    coll_seal_times,
    coll_flush_ts,
    channel_cps,
  }
}

///|
pub impl @lib.Read for FlushResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FlushResponse raise {
  let msg : FlushResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, _) => msg.db_name = reader |> @lib.read_string()
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : FlushResponse_CollSegIDsEntry)
        msg.coll_seg_ids[key] = value
      }
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : FlushResponse_FlushCollSegIDsEntry)
        msg.flush_coll_seg_ids[key] = value
      }
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : FlushResponse_CollSealTimesEntry)
        msg.coll_seal_times[key] = value
      }
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : FlushResponse_CollFlushTsEntry)
        msg.coll_flush_ts[key] = value
      }
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : FlushResponse_ChannelCpsEntry)
        msg.channel_cps[key] = value
      }
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FlushResponse with fn write(
  self : FlushResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.db_name)
  }
  let keys = self.coll_seg_ids.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.coll_seg_ids.get(k).unwrap()
    writer |> @lib.write_varint(26UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(v)
  }
  let keys = self.flush_coll_seg_ids.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.flush_coll_seg_ids.get(k).unwrap()
    writer |> @lib.write_varint(34UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(v)
  }
  let keys = self.coll_seal_times.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.coll_seal_times.get(k).unwrap()
    writer |> @lib.write_varint(42UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(v)
  }
  let keys = self.coll_flush_ts.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.coll_flush_ts.get(k).unwrap()
    writer |> @lib.write_varint(50UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_uint64(v)
  }
  let keys = self.channel_cps.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.channel_cps.get(k).unwrap()
    writer |> @lib.write_varint(58UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(v)
  }
}

///|
pub impl ToJson for FlushResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.coll_seg_ids != Default::default() {
    json["collSegIDs"] = ToJson::to_json(self.coll_seg_ids)
  }
  if self.flush_coll_seg_ids != Default::default() {
    json["flushCollSegIDs"] = ToJson::to_json(self.flush_coll_seg_ids)
  }
  if self.coll_seal_times != Default::default() {
    json["collSealTimes"] = ToJson::to_json(self.coll_seal_times)
  }
  if self.coll_flush_ts != Default::default() {
    json["collFlushTs"] = ToJson::to_json(self.coll_flush_ts)
  }
  if self.channel_cps != Default::default() {
    json["channelCps"] = ToJson::to_json(self.channel_cps)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FlushResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FlushResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FlushResponse"))
  }
  let message : FlushResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collSegIDs", _) => message.coll_seg_ids = @json.from_json(value, path~)
      ("flushCollSegIDs", _) =>
        message.flush_coll_seg_ids = @json.from_json(value, path~)
      ("collSealTimes", _) =>
        message.coll_seal_times = @json.from_json(value, path~)
      ("collFlushTs", _) =>
        message.coll_flush_ts = @json.from_json(value, path~)
      ("channelCps", _) => message.channel_cps = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FlushResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FlushResponse raise {
  let msg : FlushResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, _) => msg.db_name = reader |> @lib.async_read_string()
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() : FlushResponse_CollSegIDsEntry)
        msg.coll_seg_ids[key] = value
      }
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() :
          FlushResponse_FlushCollSegIDsEntry)
        msg.flush_coll_seg_ids[key] = value
      }
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() : FlushResponse_CollSealTimesEntry)
        msg.coll_seal_times[key] = value
      }
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() : FlushResponse_CollFlushTsEntry)
        msg.coll_flush_ts[key] = value
      }
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() : FlushResponse_ChannelCpsEntry)
        msg.channel_cps[key] = value
      }
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FlushResponse with fn write(
  self : FlushResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  let keys = self.coll_seg_ids.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.coll_seg_ids.get(k).unwrap()
    writer |> @lib.async_write_varint(26UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(v)
  }
  let keys = self.flush_coll_seg_ids.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.flush_coll_seg_ids.get(k).unwrap()
    writer |> @lib.async_write_varint(34UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(v)
  }
  let keys = self.coll_seal_times.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.coll_seal_times.get(k).unwrap()
    writer |> @lib.async_write_varint(42UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(v)
  }
  let keys = self.coll_flush_ts.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.coll_flush_ts.get(k).unwrap()
    writer |> @lib.async_write_varint(50UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_uint64(v)
  }
  let keys = self.channel_cps.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.channel_cps.get(k).unwrap()
    writer |> @lib.async_write_varint(58UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(v)
  }
}

///|
pub(all) struct GetFlushStateRequest {
  mut segment_ids : Array[Int64]
  mut flush_ts : UInt64
  mut db_name : String
  mut collection_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for GetFlushStateRequest with fn size_of(self) {
  let mut size = 0U
  if !self.segment_ids.is_empty() {
    size += @lib.size_of_length_delimited_field(
      1U,
      self.segment_ids.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if self.flush_ts != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.flush_ts))
  }
  if self.db_name != Default::default() {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(self.db_name))
  }
  if self.collection_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.collection_name),
    )
  }
  size
}

///|
pub impl Default for GetFlushStateRequest with fn default() -> GetFlushStateRequest {
  GetFlushStateRequest::{
    segment_ids: [],
    flush_ts: Default::default(),
    db_name: Default::default(),
    collection_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn GetFlushStateRequest::GetFlushStateRequest(
  segment_ids : Array[Int64],
  flush_ts : UInt64,
  db_name : String,
  collection_name : String,
) -> GetFlushStateRequest {
  GetFlushStateRequest::{ segment_ids, flush_ts, db_name, collection_name, }
}

///|
pub impl @lib.Read for GetFlushStateRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> GetFlushStateRequest raise {
  let msg : GetFlushStateRequest = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.segment_ids.push_iter(
          (reader |> @lib.read_packed(@lib.read_int64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.segment_ids.push(reader |> @lib.read_int64())
      (2, _) => msg.flush_ts = reader |> @lib.read_uint64()
      (3, _) => msg.db_name = reader |> @lib.read_string()
      (4, _) => msg.collection_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GetFlushStateRequest with fn write(
  self : GetFlushStateRequest,
  writer : &@lib.Writer,
) -> Unit raise {
  if !self.segment_ids.is_empty() {
    writer |> @lib.write_varint(10UL)
    let size = self.segment_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.segment_ids {
      writer |> @lib.write_int64(item)
    }
  }
  if self.flush_ts != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_uint64(self.flush_ts)
  }
  if self.db_name != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.collection_name)
  }
}

///|
pub impl ToJson for GetFlushStateRequest with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.segment_ids != Default::default() {
    json["segmentIDs"] = ToJson::to_json(self.segment_ids)
  }
  if self.flush_ts != Default::default() {
    json["flushTs"] = ToJson::to_json(self.flush_ts)
  }
  if self.db_name != Default::default() {
    json["dbName"] = ToJson::to_json(self.db_name)
  }
  if self.collection_name != Default::default() {
    json["collectionName"] = ToJson::to_json(self.collection_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GetFlushStateRequest with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> GetFlushStateRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GetFlushStateRequest"),
    )
  }
  let message : GetFlushStateRequest = Default::default()
  for key, value in obj {
    match (key, value) {
      ("segmentIDs", Array(value)) =>
        message.segment_ids = value.map(v => @json.from_json(v, path~))
      ("flushTs", value) => message.flush_ts = @json.from_json(value, path~)
      ("dbName", value) => message.db_name = @json.from_json(value, path~)
      ("collectionName", value) =>
        message.collection_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for GetFlushStateRequest with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> GetFlushStateRequest raise {
  let msg : GetFlushStateRequest = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.segment_ids.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int64, None)).iter(),
        )
      (1, @lib.WIRE_TYPE_VARINT) =>
        msg.segment_ids.push(reader |> @lib.async_read_int64())
      (2, _) => msg.flush_ts = reader |> @lib.async_read_uint64()
      (3, _) => msg.db_name = reader |> @lib.async_read_string()
      (4, _) => msg.collection_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for GetFlushStateRequest with fn write(
  self : GetFlushStateRequest,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if !self.segment_ids.is_empty() {
    writer |> @lib.async_write_varint(10UL)
    let size = self.segment_ids
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.segment_ids {
      writer |> @lib.async_write_int64(item)
    }
  }
  if self.flush_ts != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_uint64(self.flush_ts)
  }
  if self.db_name != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.db_name)
  }
  if self.collection_name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.collection_name)
  }
}

///|
pub(all) struct GetFlushStateResponse {
  mut status : @common.Status?
  mut flushed : Bool
} derive(Eq, Debug)

///|
pub impl @lib.Sized for GetFlushStateResponse with fn size_of(self) {
  let mut size = 0U
  if self.status is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.flushed != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.flushed))
  }
  size
}

///|
pub impl Default for GetFlushStateResponse with fn default() -> GetFlushStateResponse {
  GetFlushStateResponse::{ status: None, flushed: Default::default(), }
}

///|
#alias(new, deprecated)
pub fn GetFlushStateResponse::GetFlushStateResponse(
  status? : @common.Status,
  flushed : Bool,
) -> GetFlushStateResponse {
  GetFlushStateResponse::{ status, flushed, }
}

///|
pub impl @lib.Read for GetFlushStateResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> GetFlushStateResponse raise {
  let msg : GetFlushStateResponse = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.read_message() : @common.Status) |> Some
      (2, _) => msg.flushed = reader |> @lib.read_bool()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GetFlushStateResponse with fn write(
  self : GetFlushStateResponse,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.flushed != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_bool(self.flushed)
  }
}

///|
pub impl ToJson for GetFlushStateResponse with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  match self.status {
    Some(v) => json["status"] = ToJson::to_json(v)
    _ => ()
  }
  if self.flushed != Default::default() {
    json["flushed"] = ToJson::to_json(self.flushed)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GetFlushStateResponse with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> GetFlushStateResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GetFlushStateResponse"),
    )
  }
  let message : GetFlushStateResponse = Default::default()
  for key, value in obj {
    match (key, value) {
      ("status", value) => message.status = Some(@json.from_json(value, path~))
      ("flushed", value) => message.flushed = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for GetFlushStateResponse with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> GetFlushStateResponse raise {
  let msg : GetFlushStateResponse = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.status = (reader |> @lib.async_read_message() : @common.Status)
          |> Some
      (2, _) => msg.flushed = reader |> @lib.async_read_bool()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for GetFlushStateResponse with fn write(
  self : GetFlushStateResponse,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.status is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.flushed != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_bool(self.flushed)
  }
}
