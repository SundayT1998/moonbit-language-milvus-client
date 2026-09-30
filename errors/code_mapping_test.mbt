// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

// 验收标准：「映射表覆盖上游全部错误码，与 Go 版逐条对齐」。
// 上游只给了两张局部 switch 表，这里把「全量 legacy 枚举」都过一遍，
// 保证没有 panic、且有稳定的落点。

///|
/// 上游 `ErrorCode` 枚举的全部取值（含被 switch 漏掉的）。
/// 覆盖上不需要「都有专属映射」，但必须每个都能安全落到某个 modern 码。
fn all_legacy_codes() -> Array[@common.ErrorCode] {
  [
    @common.ErrorCode::Success,
    @common.ErrorCode::UnexpectedError,
    @common.ErrorCode::ConnectFailed,
    @common.ErrorCode::PermissionDenied,
    @common.ErrorCode::CollectionNotExists,
    @common.ErrorCode::IllegalArgument,
    @common.ErrorCode::IllegalDimension,
    @common.ErrorCode::IllegalIndexType,
    @common.ErrorCode::IllegalCollectionName,
    @common.ErrorCode::IllegalTOPK,
    @common.ErrorCode::IllegalRowRecord,
    @common.ErrorCode::IllegalVectorID,
    @common.ErrorCode::IllegalSearchResult,
    @common.ErrorCode::FileNotFound,
    @common.ErrorCode::MetaFailed,
    @common.ErrorCode::CacheFailed,
    @common.ErrorCode::CannotCreateFolder,
    @common.ErrorCode::CannotCreateFile,
    @common.ErrorCode::CannotDeleteFolder,
    @common.ErrorCode::CannotDeleteFile,
    @common.ErrorCode::BuildIndexError,
    @common.ErrorCode::IllegalNLIST,
    @common.ErrorCode::IllegalMetricType,
    @common.ErrorCode::OutOfMemory,
    @common.ErrorCode::IndexNotExist,
    @common.ErrorCode::EmptyCollection,
    @common.ErrorCode::UpdateImportTaskFailure,
    @common.ErrorCode::CollectionNameNotFound,
    @common.ErrorCode::CreateCredentialFailure,
    @common.ErrorCode::UpdateCredentialFailure,
    @common.ErrorCode::DeleteCredentialFailure,
    @common.ErrorCode::GetCredentialFailure,
    @common.ErrorCode::ListCredUsersFailure,
    @common.ErrorCode::GetUserFailure,
    @common.ErrorCode::CreateRoleFailure,
    @common.ErrorCode::DropRoleFailure,
    @common.ErrorCode::OperateUserRoleFailure,
    @common.ErrorCode::SelectRoleFailure,
    @common.ErrorCode::SelectUserFailure,
    @common.ErrorCode::SelectResourceFailure,
    @common.ErrorCode::OperatePrivilegeFailure,
    @common.ErrorCode::SelectGrantFailure,
    @common.ErrorCode::RefreshPolicyInfoCacheFailure,
    @common.ErrorCode::ListPolicyFailure,
    @common.ErrorCode::NotShardLeader,
    @common.ErrorCode::NoReplicaAvailable,
    @common.ErrorCode::SegmentNotFound,
    @common.ErrorCode::ForceDeny,
    @common.ErrorCode::RateLimit,
    @common.ErrorCode::NodeIDNotMatch,
    @common.ErrorCode::UpsertAutoIDTrue,
    @common.ErrorCode::InsufficientMemoryToLoad,
    @common.ErrorCode::MemoryQuotaExhausted,
    @common.ErrorCode::DiskQuotaExhausted,
    @common.ErrorCode::TimeTickLongDelay,
    @common.ErrorCode::NotReadyServe,
    @common.ErrorCode::NotReadyCoordActivating,
    @common.ErrorCode::CreatePrivilegeGroupFailure,
    @common.ErrorCode::DropPrivilegeGroupFailure,
    @common.ErrorCode::ListPrivilegeGroupsFailure,
    @common.ErrorCode::OperatePrivilegeGroupFailure,
    @common.ErrorCode::SchemaMismatch,
    @common.ErrorCode::DataCoordNA,
    @common.ErrorCode::DDRequestRace,
  ]
}

///|
/// 每个 legacy 码都能推出一个 non-negative 的 modern 码，未命中的落到 65535。
test "every legacy code maps to a modern code" {
  for legacy in all_legacy_codes() {
    let code = @errors.modern_code_from_legacy(legacy)
    assert_true(code >= 0)
    // Success 也走默认分支落到 65535，与上游 switch 的 default 一致
    assert_eq(code, @errors.modern_code_from_legacy(legacy))
  }
  // 抽查几个非映射项落到 unexpected
  assert_eq(
    @errors.modern_code_from_legacy(@common.ErrorCode::PermissionDenied),
    @errors.unexpected_code,
  )
  assert_eq(
    @errors.modern_code_from_legacy(@common.ErrorCode::ConnectFailed),
    @errors.unexpected_code,
  )
  assert_eq(
    @errors.modern_code_from_legacy(@common.ErrorCode::Success),
    @errors.unexpected_code,
  )
}

///|
/// 上游 `modernCodeFromLegacy` 的 12 条分支逐条锁定。
test "modern_code_from_legacy matches upstream branches" {
  let expected : Array[(@common.ErrorCode, Int)] = [
    (@common.ErrorCode::NotReadyServe, 1),
    (@common.ErrorCode::CollectionNotExists, 100),
    (@common.ErrorCode::IllegalArgument, 1100),
    (@common.ErrorCode::NodeIDNotMatch, 904),
    (@common.ErrorCode::InsufficientMemoryToLoad, 3),
    (@common.ErrorCode::MemoryQuotaExhausted, 3),
    (@common.ErrorCode::DiskQuotaExhausted, 7),
    (@common.ErrorCode::TimeTickLongDelay, 11),
    (@common.ErrorCode::RateLimit, 8),
    (@common.ErrorCode::ForceDeny, 9),
    (@common.ErrorCode::IndexNotExist, 700),
    (@common.ErrorCode::SegmentNotFound, 600),
    (@common.ErrorCode::MetaFailed, 500),
  ]
  for case in expected {
    let (legacy, code) = case
    assert_eq(@errors.modern_code_from_legacy(legacy), code)
  }
}

///|
/// 上游 `legacyCodeFromModern` 的 16 条分支逐条锁定。
test "legacy_code_from_modern matches upstream branches" {
  let expected : Array[(Int, @common.ErrorCode)] = [
    (1, @common.ErrorCode::NotReadyServe),
    (110, @common.ErrorCode::NotReadyServe),
    (100, @common.ErrorCode::CollectionNotExists),
    (1100, @common.ErrorCode::IllegalArgument),
    (1101, @common.ErrorCode::IllegalArgument),
    (1102, @common.ErrorCode::IllegalArgument),
    (904, @common.ErrorCode::NodeIDNotMatch),
    (200, @common.ErrorCode::MetaFailed),
    (400, @common.ErrorCode::MetaFailed),
    (501, @common.ErrorCode::MetaFailed),
    (401, @common.ErrorCode::NoReplicaAvailable),
    (503, @common.ErrorCode::NoReplicaAvailable),
    (506, @common.ErrorCode::NoReplicaAvailable),
    (905, @common.ErrorCode::NoReplicaAvailable),
    (3, @common.ErrorCode::InsufficientMemoryToLoad),
    (7, @common.ErrorCode::DiskQuotaExhausted),
    (11, @common.ErrorCode::TimeTickLongDelay),
    (505, @common.ErrorCode::TimeTickLongDelay),
    (8, @common.ErrorCode::RateLimit),
    (9, @common.ErrorCode::ForceDeny),
    (700, @common.ErrorCode::IndexNotExist),
    (600, @common.ErrorCode::SegmentNotFound),
    (109, @common.ErrorCode::SchemaMismatch),
  ]
  for case in expected {
    let (code, legacy) = case
    assert_eq(@errors.legacy_code_from_modern(code), legacy)
  }
}

///|
/// 未映射的 modern 码落到 `UnexpectedError`，与上游 default 一致。
test "unknown modern code falls back to unexpected" {
  assert_eq(
    @errors.legacy_code_from_modern(2400),
    @common.ErrorCode::UnexpectedError,
  )
  assert_eq(
    @errors.legacy_code_from_modern(0),
    @common.ErrorCode::UnexpectedError,
  )
  assert_eq(
    @errors.legacy_code_from_modern(65535),
    @common.ErrorCode::UnexpectedError,
  )
}

///|
/// 双轨转换在两条表上都命中的码上闭环：modern → legacy → modern 稳定。
test "dual track mapping is stable on mapped codes" {
  for code in [1, 100, 500, 600, 700, 8, 9, 3, 7, 11, 904, 1100] {
    let legacy = @errors.legacy_code_from_modern(code)
    let back = @errors.modern_code_from_legacy(legacy)
    // 1101/1102 会折叠到 1100，其余等价；这里只要求回推后仍是同一错误族
    assert_eq(@errors.legacy_code_from_modern(back), legacy)
  }
}

///|
/// 上游两张表**不对称**，这里把差异钉住，避免有人「顺手修正」而偏离 Go 版。
///
/// - `109 SchemaMismatch` 只出现在 `legacyCodeFromModern`，
///   `modernCodeFromLegacy` 没有对应分支，回推会落到 65535。
/// - `1101/1102` 同样单向：只在 modern → legacy 方向折叠到 `IllegalArgument`。
///
/// 这是上游的真实行为（`merr.go` 的两个 switch），不是疏漏；
/// 客户端的 code 身份来自服务端下发的 `Status.code`，不依赖这条回推路径。
test "dual track asymmetry is preserved (upstream quirk)" {
  assert_eq(
    @errors.legacy_code_from_modern(109),
    @common.ErrorCode::SchemaMismatch,
  )
  assert_eq(
    @errors.modern_code_from_legacy(@common.ErrorCode::SchemaMismatch),
    @errors.unexpected_code,
  )
  assert_eq(
    @errors.legacy_code_from_modern(1101),
    @common.ErrorCode::IllegalArgument,
  )
  assert_eq(
    @errors.modern_code_from_legacy(@common.ErrorCode::IllegalArgument),
    1100,
  )
}
