// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

///|
/// 包装函数族，对应上游 `merr` 的 `WrapErr*` 与 `withDetails`。
///
/// 共同语义：**保留 base 的 code / legacy_code / retriable / input，
/// 只改写 message 与 detail**。一旦携带了 code 身份，就能用 `same_code`
/// 或 `code()` 重新识别出来 —— 这就是 Go 版 `errors.Is` 在本项目里的等价物。
///
/// `messages` 为上下文链，按 `a->b: <message>` 拼接，与上游一致。
fn with_context(
  base : MerError,
  message : String,
  messages : Array[String],
) -> MerError {
  let composed = if messages.length() == 0 {
    message
  } else {
    messages.join("->") + ": " + message
  }
  match base {
    RpcError(code~, legacy_code~, retriable~, input~, ..) =>
      RpcError(
        code~,
        legacy_code~,
        message=redact(composed),
        detail=redact(composed),
        retriable~,
        input~,
      )
  }
}

///|
/// 取 base 的 message，用于拼 `xxx[field=value]` 形式的细节。
fn base_message(base : MerError) -> String {
  match base {
    RpcError(message~, ..) => message
  }
}

///|
fn with_details(base : MerError, field : String, value : String) -> MerError {
  with_context(base, base_message(base) + "[" + field + "=" + value + "]", [])
}

///|
/// `ErrServiceNotReady` 带 role / sessionID / state 的包装。
pub fn wrap_err_service_not_ready(
  role : String,
  session_id : Int64,
  state : String,
  messages? : Array[String] = [],
) -> MerError {
  let base = err_service_not_ready()
  let detail = base_message(base) +
    "[" +
    role +
    "=" +
    session_id.to_string() +
    "]: " +
    state
  with_context(base, detail, messages)
}

///|
/// `ErrServiceInternal` 带 reason 的包装。
pub fn wrap_err_service_internal(
  reason : String,
  messages? : Array[String] = [],
) -> MerError {
  let base = err_service_internal()
  with_context(base, base_message(base) + ": " + reason, messages)
}

///|
pub fn wrap_err_collection_not_found(
  collection : String,
  messages? : Array[String] = [],
) -> MerError {
  let base = err_collection_not_found()
  let out = with_details(base, "collection", collection)
  with_context(out, base_message(out), messages)
}

///|
pub fn wrap_err_collection_schema_mismatch(
  collection : String,
  messages? : Array[String] = [],
) -> MerError {
  let base = err_collection_schema_mismatch()
  let out = with_details(base, "collection", collection)
  with_context(out, base_message(out), messages)
}

///|
pub fn wrap_err_index_not_found(
  index_name : String,
  messages? : Array[String] = [],
) -> MerError {
  let base = err_index_not_found()
  let out = with_details(base, "indexName", index_name)
  with_context(out, base_message(out), messages)
}

///|
/// `ErrParameterInvalid` 带 expected / actual 的包装。
pub fn wrap_err_parameter_invalid(
  expected : String,
  actual : String,
  messages? : Array[String] = [],
) -> MerError {
  let base = err_parameter_invalid()
  let detail = base_message(base) +
    "[expected=" +
    expected +
    "][actual=" +
    actual +
    "]"
  with_context(base, detail, messages)
}

///|
/// `ErrParameterInvalid` 的自由文本包装（上游 `WrapErrParameterInvalidMsg`）。
pub fn wrap_err_parameter_invalid_msg(message : String) -> MerError {
  with_context(err_parameter_invalid(), message, [])
}

///|
/// 把任意错误文本重新归为 `ErrParameterInvalid`，只保留文本、不保留原 code
/// （上游 `WrapErrParameterInvalidErr`）。
pub fn wrap_err_parameter_invalid_err(
  err : String,
  message : String,
) -> MerError {
  with_context(err_parameter_invalid(), message + ": " + err, [])
}

///|
pub fn wrap_err_parameter_missing_msg(message : String) -> MerError {
  with_context(err_parameter_missing(), message, [])
}
