// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

///|
/// 预定义错误值，与上游 `merr` 的命名变量一一对应。
///
/// 这些值用于 `same_code` 比对与包装（`wrap_*`），
/// 语义与 Go 版的 `ErrCollectionNotFound` 等完全一致。
pub fn err_service_not_ready() -> MerError {
  RpcError(
    code=1,
    legacy_code=@common.ErrorCode::NotReadyServe,
    message="service not ready",
    detail="service not ready",
    retriable=true,
    input=false,
  )
}

///|
pub fn err_service_internal() -> MerError {
  RpcError(
    code=5,
    legacy_code=@common.ErrorCode::UnexpectedError,
    message="service internal error",
    detail="service internal error",
    retriable=false,
    input=false,
  )
}

///|
pub fn err_service_unimplemented() -> MerError {
  RpcError(
    code=10,
    legacy_code=@common.ErrorCode::UnexpectedError,
    message="service unimplemented",
    detail="service unimplemented",
    retriable=false,
    input=false,
  )
}

///|
pub fn err_collection_not_found() -> MerError {
  RpcError(
    code=100,
    legacy_code=@common.ErrorCode::CollectionNotExists,
    message="collection not found",
    detail="collection not found",
    retriable=false,
    input=false,
  )
}

///|
pub fn err_collection_schema_mismatch() -> MerError {
  RpcError(
    code=109,
    legacy_code=@common.ErrorCode::SchemaMismatch,
    message="collection schema mismatch",
    detail="collection schema mismatch",
    retriable=false,
    input=true,
  )
}

///|
pub fn err_index_not_found() -> MerError {
  RpcError(
    code=700,
    legacy_code=@common.ErrorCode::IndexNotExist,
    message="index not found",
    detail="index not found",
    retriable=false,
    input=false,
  )
}

///|
pub fn err_parameter_invalid() -> MerError {
  RpcError(
    code=1100,
    legacy_code=@common.ErrorCode::IllegalArgument,
    message="invalid parameter",
    detail="invalid parameter",
    retriable=false,
    input=true,
  )
}

///|
pub fn err_parameter_missing() -> MerError {
  RpcError(
    code=1101,
    legacy_code=@common.ErrorCode::IllegalArgument,
    message="missing required parameters",
    detail="missing required parameters",
    retriable=false,
    input=true,
  )
}

///|
/// 未知错误的兜底值，对应上游 `errUnexpected`（码 `65535`）。
pub fn err_unexpected() -> MerError {
  RpcError(
    code=unexpected_code,
    legacy_code=@common.ErrorCode::UnexpectedError,
    message="unexpected error",
    detail="unexpected error",
    retriable=false,
    input=false,
  )
}
