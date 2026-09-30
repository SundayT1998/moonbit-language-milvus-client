// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

///|
/// Milvus RPC 错误的客户端模型。
///
/// 与上游 `merr.RPCError` 一一对应：同一个 Milvus `code` 视为同一个错误，
/// 双轨错误码（modern `code` + legacy `ErrorCode`）整体保留，不简化。
///
/// 构造用带标签的语法；典型路径是 `from_status`，需要手工造错时用
/// 预定义值加 `wrap_*`：
///
/// ```moonbit nocheck
/// let err = @errors.wrap_err_collection_not_found("demo")
/// raise err
/// ```
///
/// 也可以直接构造：
///
/// ```moonbit nocheck
/// raise RpcError(
///   code=100,
///   legacy_code=@common.ErrorCode::CollectionNotExists,
///   message="collection not found",
///   detail="collection not found",
///   retriable=false,
///   input=false,
/// )
/// ```
pub suberror MerError {
  /// Milvus modern 数值错误码（`Status.code`），未知码按原值保留。
  RpcError(
    code~ : Int,
    /// 已废弃的 legacy 错误码（`Status.error_code`）。
    legacy_code~ : @common.ErrorCode,
    /// 面向用户的错误摘要，等价于上游 `RPCError.Error()`。
    message~ : String,
    /// 服务端返回的详细错误信息（`Status.detail`）。
    detail~ : String,
    /// 服务端标记的可重试位（`Status.retriable`）。
    retriable~ : Bool,
    /// 服务端是否把该错误归类为输入错误（`extra_info["is_input_error"] == "true"`）。
    input~ : Bool
  )
}

///|
/// 错误摘要，与上游 `RPCError.Error()` 一致。
pub impl Show for MerError with fn to_string(self) {
  match self {
    RpcError(message~, ..) => message
  }
}

///|
/// 取错误码。与上游 `merr.Code` 一致；`None` 等价于上游的 `err == nil`。
pub fn MerError::code(self : MerError?) -> Int {
  match self {
    None => 0
    Some(RpcError(code~, ..)) => code
  }
}

///|
/// 取 legacy 错误码。`None` 视为 `Success`。
pub fn MerError::legacy_code(self : MerError?) -> @common.ErrorCode {
  match self {
    None => @common.ErrorCode::Success
    Some(RpcError(legacy_code~, ..)) => legacy_code
  }
}

///|
/// 取服务端下发的详细错误信息。
pub fn MerError::detail(self : MerError?) -> String {
  match self {
    None => ""
    Some(RpcError(detail~, ..)) => detail
  }
}

///|
/// 服务端是否标记该错误可重试。这正是上游 `IsRetryableErr` 的语义：
/// 只看 `Status.retriable`，不做本地猜测。
pub fn MerError::is_retryable(self : MerError?) -> Bool {
  match self {
    None => false
    Some(RpcError(retriable~, ..)) => retriable
  }
}

///|
/// 服务端是否把该错误归类为输入错误。
pub fn MerError::is_input_error(self : MerError?) -> Bool {
  match self {
    None => false
    Some(RpcError(input~, ..)) => input
  }
}

///|
/// 依据 Milvus `code` 判断两个错误是否同类，对应上游 `RPCError.Is`
/// （`errors.Is` 靠 code 匹配，而不是靠错误文本）。
pub fn MerError::same_code(self : MerError, other : MerError) -> Bool {
  match (self, other) {
    (RpcError(code~, ..), RpcError(code=other_code, ..)) => code == other_code
  }
}

///|
/// 取错误码。与上游 `merr.Code` 一致；`None` 等价于上游的 `err == nil`。
pub fn error_code(err : MerError?) -> Int {
  MerError::code(err)
}

///|
/// 取 legacy 错误码。`None` 视为 `Success`。
pub fn error_legacy_code(err : MerError?) -> @common.ErrorCode {
  MerError::legacy_code(err)
}

///|
/// 取服务端下发的详细错误信息。
pub fn error_detail(err : MerError?) -> String {
  MerError::detail(err)
}

///|
/// 服务端是否标记该错误可重试。这正是上游 `IsRetryableErr` 的语义：
/// 只看 `Status.retriable`，不做本地猜测。
///
/// 这是给 retry 中间件看的唯一判据，等价于上游 `merr.IsRetryableErr`。
pub fn is_retryable_err(err : MerError?) -> Bool {
  MerError::is_retryable(err)
}

///|
/// 服务端是否把该错误归类为输入错误。
pub fn is_input_error(err : MerError?) -> Bool {
  MerError::is_input_error(err)
}
