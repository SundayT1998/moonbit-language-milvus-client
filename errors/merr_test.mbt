// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

// 对照测试：逐条复刻上游 `client/internal/merr/merr_test.go` 的用例语义。
// 上游基线：`milvus-io/milvus` commit `1bcc8cb1`，Apache-2.0。

///|
/// 上游 `TestModernStatusConversion`：
/// modern 码路径 —— code 优先，legacy 反推，retriable 透传，detail 保留。
test "modern status conversion (upstream TestModernStatusConversion)" {
  let status : @common.Status = {
    code: 100,
    reason: "collection missing",
    detail: "collection missing from database",
    retriable: true,
    error_code: @common.ErrorCode::Success,
    extra_info: {},
  }
  let err = @errors.from_status(status)
  assert_true(err is Some(_))
  // 同一个 code 即同一个错误（对应 errors.Is(err, ErrCollectionNotFound)）
  assert_true(err.unwrap().same_code(@errors.err_collection_not_found()))
  assert_eq(@errors.error_code(err), 100)
  assert_true(@errors.is_retryable_err(err))
  assert_eq(@errors.error_detail(err), "collection missing from database")
  // 回写 Status 时 legacy 由 modern 反推
  assert_eq(
    @errors.to_status(err).error_code,
    @common.ErrorCode::CollectionNotExists,
  )
  assert_eq(@errors.to_status(err).code, 100)
}

///|
/// 上游 `TestStatusMetadataConversion`：
/// `extra_info["is_input_error"]` 决定 input 位，不污染 code。
test "status metadata conversion (upstream TestStatusMetadataConversion)" {
  let status : @common.Status = {
    code: 1100,
    reason: "bad parameter",
    detail: "dimension must be positive",
    retriable: false,
    error_code: @common.ErrorCode::Success,
    extra_info: Map::from_array([("is_input_error", "true")]),
  }
  let err = @errors.from_status(status)
  assert_true(err.unwrap().same_code(@errors.err_parameter_invalid()))
  assert_true(@errors.is_input_error(err))
  assert_eq(@errors.error_detail(err), "dimension must be positive")
  assert_eq(
    @errors.to_status(err).extra_info.get("is_input_error"),
    Some("true"),
  )
}

///|
/// 上游 `TestUnknownModernCodeIsPreserved`：
/// 映射表之外的 modern 码按原值保留，不归一到 65535。
test "unknown modern code is preserved (upstream TestUnknownModernCodeIsPreserved)" {
  let status : @common.Status = {
    code: 2400,
    reason: "function pipeline failed",
    detail: "embedding provider timed out",
    retriable: true,
    error_code: @common.ErrorCode::Success,
    extra_info: Map::from_array([("is_input_error", "true")]),
  }
  let err = @errors.from_status(status)
  assert_eq(@errors.error_code(err), 2400)
  assert_true(@errors.is_retryable_err(err))
  assert_true(@errors.is_input_error(err))
  assert_eq(@errors.error_detail(err), "embedding provider timed out")
}

///|
/// 上游 `TestLegacyStatusConversion` 的表格：legacy 码 → modern 码逐条对齐。
test "legacy status conversion (upstream TestLegacyStatusConversion)" {
  let cases : Array[(@common.ErrorCode, Int)] = [
    (@common.ErrorCode::NotReadyServe, 1),
    (@common.ErrorCode::CollectionNotExists, 100),
    (@common.ErrorCode::IllegalArgument, 1100),
    (@common.ErrorCode::MemoryQuotaExhausted, 3),
    (@common.ErrorCode::DiskQuotaExhausted, 7),
    (@common.ErrorCode::RateLimit, 8),
    (@common.ErrorCode::ForceDeny, 9),
    (@common.ErrorCode::TimeTickLongDelay, 11),
    (@common.ErrorCode::MetaFailed, 500),
    (@common.ErrorCode::IndexNotExist, 700),
  ]
  for case in cases {
    let (legacy, expected) = case
    let status : @common.Status = {
      error_code: legacy,
      reason: "legacy failure",
      code: 0,
      retriable: false,
      detail: "",
      extra_info: {},
    }
    let err = @errors.from_status(status)
    assert_eq(@errors.error_code(err), expected)
    // 未参与现代码映射的 legacy 码在回写时仍保留原值
    assert_eq(@errors.to_status(err).error_code, legacy)
  }
}

///|
/// 上游 `TestLegacyStatusConversion` 中带 target 的三条：
/// NotReadyServe / CollectionNotExists / IllegalArgument / IndexNotExist 可被识别成同一错误。
test "legacy codes keep error identity (upstream targets)" {
  let cases : Array[(@common.ErrorCode, @errors.MerError)] = [
    (@common.ErrorCode::NotReadyServe, @errors.err_service_not_ready()),
    (@common.ErrorCode::CollectionNotExists, @errors.err_collection_not_found()),
    (@common.ErrorCode::IllegalArgument, @errors.err_parameter_invalid()),
    (@common.ErrorCode::IndexNotExist, @errors.err_index_not_found()),
  ]
  for case in cases {
    let (legacy, target) = case
    let status : @common.Status = {
      error_code: legacy,
      reason: "legacy failure",
      code: 0,
      retriable: false,
      detail: "",
      extra_info: {},
    }
    let err = @errors.from_status(status)
    assert_true(err.unwrap().same_code(target))
  }
}

///|
/// 上游 `TestStatusRoundTrip`：
/// wrap → Status → Error 后身份不丢，code / legacy / input 位都在。
test "status round trip (upstream TestStatusRoundTrip)" {
  let original = @errors.wrap_err_collection_schema_mismatch("demo")
  let status = @errors.to_status(Some(original))
  assert_eq(status.code, 109)
  assert_eq(status.error_code, @common.ErrorCode::SchemaMismatch)
  assert_eq(status.extra_info.get("is_input_error"), Some("true"))
  let round_trip = @errors.from_status(status)
  assert_true(
    @errors.MerError::same_code(
      round_trip.unwrap(),
      @errors.err_collection_schema_mismatch(),
    ),
  )
}

///|
/// 上游 `TestParameterMissing`。
test "parameter missing (upstream TestParameterMissing)" {
  let err = @errors.wrap_err_parameter_missing_msg(
    "collection name is required",
  )
  assert_true(err.same_code(@errors.err_parameter_missing()))
  assert_eq(@errors.error_code(Some(err)), 1101)
  assert_eq(
    @errors.to_status(Some(err)).error_code,
    @common.ErrorCode::IllegalArgument,
  )
}

///|
/// 上游 `TestParameterInvalidWrappers`。
test "parameter invalid wrappers (upstream TestParameterInvalidWrappers)" {
  let by_message = @errors.wrap_err_parameter_invalid_msg(
    "invalid field \"vector\"",
  )
  assert_true(by_message.same_code(@errors.err_parameter_invalid()))
  assert_eq(@errors.error_code(Some(by_message)), 1100)
  assert_true(by_message.to_string().contains("invalid field"))

  let by_cause = @errors.wrap_err_parameter_invalid_err(
    "invalid character", "invalid legacy params",
  )
  assert_true(by_cause.same_code(@errors.err_parameter_invalid()))
  assert_true(
    by_cause.to_string().contains("invalid legacy params: invalid character"),
  )
}

///|
/// `is_ok` / `success`，上游 `Ok` 与 `Success` 的语义：
/// `error_code` 与 `code` 必须同时为成功值。
test "ok and success (upstream Ok/Success)" {
  assert_true(@errors.is_ok(None))
  assert_true(@errors.is_ok(Some(@errors.success())))
  assert_true(@errors.is_ok(Some(@errors.success(reason="all good"))))
  // 只有 legacy 说成功、modern 码非零 → 不是成功
  let partial : @common.Status = {
    error_code: @common.ErrorCode::Success,
    reason: "",
    code: 1,
    retriable: false,
    detail: "",
    extra_info: {},
  }
  assert_false(@errors.is_ok(Some(partial)))
  assert_true(@errors.from_status(partial) is Some(_))
  assert_eq(@errors.error_code(@errors.from_status(@errors.success())), 0)
}

///|
/// 上游 `merr.Code` 的 nil 约定：无错时码为 0。
test "code of no error is zero (upstream merr.Code)" {
  let none : @errors.MerError? = None
  assert_eq(@errors.error_code(none), 0)
  assert_false(@errors.is_retryable_err(none))
  assert_eq(@errors.error_detail(none), "")
  assert_eq(@errors.error_legacy_code(none), @common.ErrorCode::Success)
}

///|
/// `IsRetryableErr` 只认服务端下发的 retriable 位，不做本地猜测。
/// 覆盖限流 / 内存 / 磁盘 / 连接类这些上游标记为可重试的码。
test "retriable follows server bit only (upstream IsRetryableErr)" {
  let retriable_codes : Array[Int] = [1, 3, 7, 8, 11, 2400]
  for code in retriable_codes {
    let status : @common.Status = {
      code,
      reason: "boom",
      detail: "",
      retriable: true,
      error_code: @common.ErrorCode::Success,
      extra_info: {},
    }
    assert_true(@errors.is_retryable_err(@errors.from_status(status)))
  }
  let non_retriable_codes : Array[Int] = [5, 100, 700, 1100, 1101, 600, 500]
  for code in non_retriable_codes {
    let status : @common.Status = {
      code,
      reason: "boom",
      detail: "",
      retriable: false,
      error_code: @common.ErrorCode::Success,
      extra_info: {},
    }
    assert_false(@errors.is_retryable_err(@errors.from_status(status)))
  }
}
