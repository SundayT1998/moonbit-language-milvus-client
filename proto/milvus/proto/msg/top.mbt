///|
pub(all) struct MsgPosition {
  mut channel_name : String
  mut msg_id : Bytes
  mut msg_group : String
  mut timestamp : UInt64
  mut wal_name : @common.WALName
} derive(Eq, Debug)

///|
pub impl @lib.Sized for MsgPosition with fn size_of(self) {
  let mut size = 0U
  if self.channel_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      1U,
      @lib.size_of(self.channel_name),
    )
  }
  if self.msg_id != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.msg_id))
  }
  if self.msg_group != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.msg_group),
    )
  }
  if self.timestamp != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.timestamp))
  }
  if self.wal_name != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.wal_name))
  }
  size
}

///|
pub impl Default for MsgPosition with fn default() -> MsgPosition {
  MsgPosition::{
    channel_name: Default::default(),
    msg_id: Default::default(),
    msg_group: Default::default(),
    timestamp: Default::default(),
    wal_name: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn MsgPosition::MsgPosition(
  channel_name : String,
  msg_id : Bytes,
  msg_group : String,
  timestamp : UInt64,
  wal_name : @common.WALName,
) -> MsgPosition {
  MsgPosition::{ channel_name, msg_id, msg_group, timestamp, wal_name, }
}

///|
pub impl @lib.Read for MsgPosition with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> MsgPosition raise {
  let msg : MsgPosition = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.channel_name = reader |> @lib.read_string()
      (2, _) => msg.msg_id = reader |> @lib.read_bytes()
      (3, _) => msg.msg_group = reader |> @lib.read_string()
      (4, _) => msg.timestamp = reader |> @lib.read_uint64()
      (5, _) =>
        msg.wal_name = reader |> @lib.read_enum() |> @common.WALName::from_enum
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for MsgPosition with fn write(
  self : MsgPosition,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.channel_name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.channel_name)
  }
  if self.msg_id != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_bytes(self.msg_id)
  }
  if self.msg_group != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.msg_group)
  }
  if self.timestamp != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_uint64(self.timestamp)
  }
  if self.wal_name != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_enum(self.wal_name.to_enum())
  }
}

///|
pub impl ToJson for MsgPosition with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.channel_name != Default::default() {
    json["channelName"] = ToJson::to_json(self.channel_name)
  }
  if self.msg_id != Default::default() {
    json["msgID"] = @lib.base64_encode(self.msg_id).to_json()
  }
  if self.msg_group != Default::default() {
    json["msgGroup"] = ToJson::to_json(self.msg_group)
  }
  if self.timestamp != Default::default() {
    json["timestamp"] = ToJson::to_json(self.timestamp)
  }
  if self.wal_name != Default::default() {
    json["WALName"] = ToJson::to_json(self.wal_name)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for MsgPosition with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> MsgPosition raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for MsgPosition"))
  }
  let message : MsgPosition = Default::default()
  for key, value in obj {
    match (key, value) {
      ("channelName", value) =>
        message.channel_name = @json.from_json(value, path~)
      ("msgID", String(value)) =>
        message.msg_id = @lib.base64_decode(value) catch {
          _ => raise @json.JsonDecodeError((path, "Invalid base64 encoding"))
        }
      ("msgGroup", value) => message.msg_group = @json.from_json(value, path~)
      ("timestamp", value) => message.timestamp = @json.from_json(value, path~)
      ("WALName", value) => message.wal_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for MsgPosition with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> MsgPosition raise {
  let msg : MsgPosition = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.channel_name = reader |> @lib.async_read_string()
      (2, _) => msg.msg_id = reader |> @lib.async_read_bytes()
      (3, _) => msg.msg_group = reader |> @lib.async_read_string()
      (4, _) => msg.timestamp = reader |> @lib.async_read_uint64()
      (5, _) =>
        msg.wal_name = reader
          |> @lib.async_read_enum()
          |> @common.WALName::from_enum
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for MsgPosition with fn write(
  self : MsgPosition,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.channel_name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.channel_name)
  }
  if self.msg_id != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_bytes(self.msg_id)
  }
  if self.msg_group != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.msg_group)
  }
  if self.timestamp != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_uint64(self.timestamp)
  }
  if self.wal_name != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_enum(self.wal_name.to_enum())
  }
}
