// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

///|
/// `Status` 是否代表成功，对应上游 `merr.Ok`。
///
/// 两个字段都要满足：`error_code == Success` 且 `code == 0`。
/// `None` 视为成功（上游对 `nil` Status 返回 true）。
pub fn is_ok(status : @common.Status?) -> Bool {
  match status {
    None => true
    Some(s) => s.error_code == @common.ErrorCode::Success && s.code == 0
  }
}

///|
/// 成功状态，对应上游 `merr.Success`。
pub fn success(reason? : String = "") -> @common.Status {
  @common.Status::{
    error_code: @common.ErrorCode::Success,
    reason,
    code: 0,
    retriable: false,
    detail: "",
    extra_info: {},
  }
}

///|
/// Milvus `Status` → `MerError`，对应上游 `merr.Error`。
///
/// 双轨码的补齐规则与上游完全一致：
/// - `code == 0` 时用 legacy 推导 modern 码
/// - legacy 为 `Success` 时用 modern 码反推 legacy
///
/// 成功状态返回 `None`（上游返回 `nil`）。`reason` 与 `detail` 都过一遍脱敏。
pub fn from_status(status : @common.Status) -> MerError? {
  if is_ok(Some(status)) {
    return None
  }
  let code = if status.code == 0 {
    modern_code_from_legacy(status.error_code)
  } else {
    status.code
  }
  let legacy = if status.error_code == @common.ErrorCode::Success {
    legacy_code_from_modern(code)
  } else {
    status.error_code
  }
  Some(
    RpcError(
      code~,
      legacy_code=legacy,
      message=redact(status.reason),
      detail=redact(status.detail),
      retriable=status.retriable,
      input=status.extra_info.get(input_error_flag_key) == Some("true"),
    ),
  )
}

///|
/// 把 `MerError?` 还原成 `Status`，对应上游 `merr.Status`。
///
/// 主要给 mock 与测试用；`None` 返回成功 `Status`。
pub fn to_status(err : MerError?) -> @common.Status {
  match err {
    None => success()
    Some(RpcError(code~, legacy_code~, message~, detail~, retriable~, input~)) =>
      @common.Status::{
        error_code: legacy_code,
        reason: message,
        code,
        retriable,
        detail,
        extra_info: if input {
          Map::from_array([(input_error_flag_key, "true")])
        } else {
          {}
        },
      }
  }
}
