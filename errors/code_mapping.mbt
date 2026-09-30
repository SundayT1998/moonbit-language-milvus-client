// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

///|
/// legacy `ErrorCode` → modern 数值码，逐条照搬上游 `modernCodeFromLegacy`。
///
/// 未命中的 legacy 码落到 `unexpected_code`。
pub fn modern_code_from_legacy(legacy : @common.ErrorCode) -> Int {
  match legacy {
    @common.ErrorCode::NotReadyServe => 1
    @common.ErrorCode::CollectionNotExists => 100
    @common.ErrorCode::IllegalArgument => 1100
    @common.ErrorCode::NodeIDNotMatch => 904
    @common.ErrorCode::InsufficientMemoryToLoad
    | @common.ErrorCode::MemoryQuotaExhausted => 3
    @common.ErrorCode::DiskQuotaExhausted => 7
    @common.ErrorCode::TimeTickLongDelay => 11
    @common.ErrorCode::RateLimit => 8
    @common.ErrorCode::ForceDeny => 9
    @common.ErrorCode::IndexNotExist => 700
    @common.ErrorCode::SegmentNotFound => 600
    @common.ErrorCode::MetaFailed => 500
    _ => unexpected_code
  }
}

///|
/// modern 数值码 → legacy `ErrorCode`，逐条照搬上游 `legacyCodeFromModern`。
///
/// 未命中的数值码落到 `UnexpectedError`。
pub fn legacy_code_from_modern(code : Int) -> @common.ErrorCode {
  match code {
    1 | 110 => @common.ErrorCode::NotReadyServe
    100 => @common.ErrorCode::CollectionNotExists
    1100 | 1101 | 1102 => @common.ErrorCode::IllegalArgument
    904 => @common.ErrorCode::NodeIDNotMatch
    200 | 400 | 501 => @common.ErrorCode::MetaFailed
    401 | 503 | 506 | 905 => @common.ErrorCode::NoReplicaAvailable
    3 => @common.ErrorCode::InsufficientMemoryToLoad
    7 => @common.ErrorCode::DiskQuotaExhausted
    11 | 505 => @common.ErrorCode::TimeTickLongDelay
    8 => @common.ErrorCode::RateLimit
    9 => @common.ErrorCode::ForceDeny
    700 => @common.ErrorCode::IndexNotExist
    600 => @common.ErrorCode::SegmentNotFound
    109 => @common.ErrorCode::SchemaMismatch
    _ => @common.ErrorCode::UnexpectedError
  }
}
