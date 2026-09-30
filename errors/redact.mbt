// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

///|
/// 错误信息脱敏。
///
/// 验收要求「错误信息中不泄露 token 等敏感 metadata」。Milvus 的 `Status.detail`
/// 与 `reason` 由服务端拼装，可能回显请求侧的认证头或连接串。上游 Go 版没有这层，
/// 这里补上，且是**纯函数**，不影响任何判定语义。
///
/// 规则：
/// - `Authorization: Bearer xxx` / 裸 `Bearer xxx` → `Bearer ***`
/// - `token=xxx` / `password=xxx` / `api_key=xxx` 等 `key<分隔符>value` → 值打码
/// - URL userinfo（`scheme://user:pass@host`）里的口令段 → `***`
///
/// 非敏感内容（主机名、端口、库名、字段名）原样保留，保证可调试。
pub fn redact(input : String) -> String {
  // 顺序有讲究：先处理 `Authorization:` 这个键，再处理它后面的 `Bearer <token>`。
  // 反过来会把 `Bearer` 当成 `authorization` 的值打码掉。
  let out = redact_scheme_credentials(input)
  let out = redact_key_value_secrets(out)
  redact_authorization(out)
}

///|
/// 需要打码的关键词，大小写不敏感。
let secret_keys : Array[String] = [
  "authorization", "token", "password", "passwd", "secret", "api_key", "apikey",
  "access_key", "private_key",
]

///|
fn redact_key_value_secrets(input : String) -> String {
  let mut out = input
  for key in secret_keys {
    out = redact_all_occurrences(out, key)
  }
  out
}

///|
/// 找 `key` 的所有出现（大小写不敏感），把紧随其后的值替换成 `***`。
fn redact_all_occurrences(input : String, key : String) -> String {
  let lower = input.to_lower()
  let key_lower = key.to_lower()
  let key_len = key_lower.length()
  let out = StringBuilder()
  let mut cursor = 0
  let input_len = input.length()
  while cursor <= input_len {
    let found = find_from(lower, key_lower, cursor)
    if found == -1 {
      out.write_string(slice(input, cursor, input_len))
      break
    }
    out.write_string(slice(input, cursor, found + key_len))
    cursor = found + key_len
    // 跳过 key 与值之间的分隔与空白：`token=abc`、`token: abc`、`token "abc"`
    let mut i = cursor
    while i < input_len && is_separator_or_space(input.at(i)) {
      i = i + 1
    }
    if i > cursor {
      out.write_string(slice(input, cursor, i))
      cursor = i
    }
    // 打码到值的结束（空白、`,`、`;`、`&`、`}`、引号、行尾）
    let mut j = cursor
    while j < input_len && !is_value_terminator(input.at(j)) {
      j = j + 1
    }
    // `Authorization: Bearer xxx` 交给 redact_authorization 处理，
    // 否则这里会把 `Bearer` 本身当成值打码，丢掉 scheme 名。
    if j > cursor && !slice(input, cursor, j).to_lower().has_prefix("bearer") {
      out.write_string("***")
      cursor = j
    }
  }
  out.to_string()
}

///|
/// 取 `[start, end)` 子串，规避已废弃的 `String::substring`。
fn slice(s : String, start : Int, end : Int) -> String {
  s.view(start_offset=start, end_offset=end).to_owned()
}

///|
/// 从 `from` 起找 `needle`（要求 `haystack` 与 `needle` 同为小写），返回下标或 `-1`。
fn find_from(haystack : String, needle : String, from : Int) -> Int {
  let h_len = haystack.length()
  let n_len = needle.length()
  if n_len == 0 || from >= h_len {
    return -1
  }
  let mut i = from
  while i + n_len <= h_len {
    if slice(haystack, i, i + n_len) == needle {
      return i
    }
    i = i + 1
  }
  -1
}

///|
/// 该 UTF-16 码元是否属于「key 与值之间的分隔」。
fn is_separator_or_space(c : UInt16) -> Bool {
  c == 0x3D || c == 0x3A || c == 0x20 || c == 0x09 || c == 0x22 || c == 0x27
}

///|
/// 该 UTF-16 码元是否终止一个值。
fn is_value_terminator(c : UInt16) -> Bool {
  c == 0x20 ||
  c == 0x09 ||
  c == 0x0A ||
  c == 0x0D ||
  c == 0x2C ||
  c == 0x3B ||
  c == 0x26 ||
  c == 0x7D ||
  c == 0x29 ||
  c == 0x22 ||
  c == 0x27
}

///|
/// 打码 `Bearer xxx`（含 `Authorization: Bearer xxx`）。
fn redact_authorization(input : String) -> String {
  let lower = input.to_lower()
  let out = StringBuilder()
  let mut cursor = 0
  let input_len = input.length()
  while cursor <= input_len {
    let found = find_from(lower, "bearer", cursor)
    if found == -1 {
      out.write_string(slice(input, cursor, input_len))
      break
    }
    out.write_string(slice(input, cursor, found + 6))
    cursor = found + 6
    let mut i = cursor
    while i < input_len && (input.at(i) == 0x20 || input.at(i) == 0x09) {
      i = i + 1
    }
    out.write_string(slice(input, cursor, i))
    cursor = i
    let mut j = cursor
    while j < input_len && !is_value_terminator(input.at(j)) {
      j = j + 1
    }
    if j > cursor {
      out.write_string("***")
      cursor = j
    }
  }
  out.to_string()
}

///|
/// 打码 URL userinfo 中的口令：`scheme://user:pass@host` → `scheme://user:***@host`。
fn redact_scheme_credentials(input : String) -> String {
  let lower = input.to_lower()
  let out = StringBuilder()
  let mut cursor = 0
  let input_len = input.length()
  while cursor <= input_len {
    let found = find_from(lower, "://", cursor)
    if found == -1 {
      out.write_string(slice(input, cursor, input_len))
      break
    }
    let user_start = found + 3
    // 在 authority 段内找 userinfo 与 host 的分界 '@'
    let mut at = -1
    let mut i = user_start
    while i < input_len && !is_authority_end(input.at(i)) {
      if input.at(i) == 0x40 {
        at = i
        break
      }
      i = i + 1
    }
    if at == -1 {
      out.write_string(slice(input, cursor, user_start))
      cursor = user_start
      continue
    }
    let userinfo = slice(input, user_start, at)
    out.write_string(slice(input, cursor, user_start))
    match find_from(userinfo, ":", 0) {
      -1 =>
        // 只有用户名、没有口令，原样保留
        out.write_string(userinfo)
      colon => {
        out.write_string(slice(userinfo, 0, colon + 1))
        out.write_string("***")
      }
    }
    out.write_string("@")
    cursor = at + 1
  }
  out.to_string()
}

///|
fn is_authority_end(c : UInt16) -> Bool {
  c == 0x2F || c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D || c == 0x22
}
