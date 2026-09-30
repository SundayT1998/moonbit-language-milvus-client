// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

// 上游 `WrapErr*` 包装族的对照测试：包装只应改写文本，不得改变 code 身份。

///|
test "wrap keeps code identity for every sentinel" {
  let wrapped : Array[@errors.MerError] = [
    @errors.wrap_err_service_not_ready("rootcoord", 42L, "active"),
    @errors.wrap_err_service_internal("disk full"),
    @errors.wrap_err_collection_not_found("demo"),
    @errors.wrap_err_collection_schema_mismatch("demo"),
    @errors.wrap_err_index_not_found("idx_1"),
    @errors.wrap_err_parameter_invalid("dim", "0"),
    @errors.wrap_err_parameter_invalid_msg("bad thing"),
    @errors.wrap_err_parameter_missing_msg("name required"),
  ]
  let expected_codes : Array[Int] = [1, 5, 100, 109, 700, 1100, 1100, 1101]
  assert_eq(wrapped.length(), expected_codes.length())
  for i in 0..<wrapped.length() {
    assert_eq(@errors.error_code(Some(wrapped[i])), expected_codes[i])
  }
}

///|
test "wrap service not ready renders role session and state" {
  let err = @errors.wrap_err_service_not_ready("querynode", 7L, "standby")
  let text = @errors.MerError::to_string(err)
  assert_true(text.contains("querynode"))
  assert_true(text.contains("7"))
  assert_true(text.contains("standby"))
}

///|
/// 上游 `messages` 上下文链：多段用 `->` 拼接，最后才是本层描述。
test "wrap context messages chain with arrow" {
  let err = @errors.wrap_err_collection_not_found("demo", messages=[
    "LoadCollection", "validate",
  ])
  let text = @errors.MerError::to_string(err)
  assert_true(text.has_prefix("LoadCollection->validate: "))
  assert_true(text.contains("demo"))
}

///|
test "wrap parameter invalid renders expected and actual" {
  let err = @errors.wrap_err_parameter_invalid("4", "3")
  let text = @errors.MerError::to_string(err)
  assert_true(text.contains("[expected=4]"))
  assert_true(text.contains("[actual=3]"))
}

///|
/// `to_status(None)` 必须是成功状态。
test "to_status of no error is success" {
  let none : @errors.MerError? = None
  let status = @errors.to_status(none)
  assert_eq(status.code, 0)
  assert_eq(status.error_code, @common.ErrorCode::Success)
  assert_false(status.retriable)
  assert_true(@errors.is_ok(Some(status)))
}

///|
/// 预定义错误值自身与上游常量对齐。
test "sentinel values match upstream constants" {
  assert_eq(@errors.error_code(Some(@errors.err_service_not_ready())), 1)
  assert_eq(@errors.error_code(Some(@errors.err_service_internal())), 5)
  assert_eq(@errors.error_code(Some(@errors.err_service_unimplemented())), 10)
  assert_eq(@errors.error_code(Some(@errors.err_collection_not_found())), 100)
  assert_eq(
    @errors.error_code(Some(@errors.err_collection_schema_mismatch())),
    109,
  )
  assert_eq(@errors.error_code(Some(@errors.err_index_not_found())), 700)
  assert_eq(@errors.error_code(Some(@errors.err_parameter_invalid())), 1100)
  assert_eq(@errors.error_code(Some(@errors.err_parameter_missing())), 1101)
  assert_eq(
    @errors.error_code(Some(@errors.err_unexpected())),
    @errors.unexpected_code,
  )
  // 上游标记为可重试的只有 service not ready
  assert_true(@errors.is_retryable_err(Some(@errors.err_service_not_ready())))
  assert_false(
    @errors.is_retryable_err(Some(@errors.err_collection_not_found())),
  )
  // 上游标记为输入错误的两个参数类错误
  assert_true(@errors.is_input_error(Some(@errors.err_parameter_invalid())))
  assert_true(@errors.is_input_error(Some(@errors.err_parameter_missing())))
  assert_true(
    @errors.is_input_error(Some(@errors.err_collection_schema_mismatch())),
  )
  assert_false(@errors.is_input_error(Some(@errors.err_collection_not_found())))
  // 码常量
  assert_eq(@errors.canceled_code, 10000)
  assert_eq(@errors.timeout_code, 10001)
  assert_eq(@errors.unexpected_code, 65535)
}

///|
/// `same_code` 是 `errors.Is` 的等价物：同码即同错，文本不影响判定。
test "same_code ignores text" {
  let a = @errors.wrap_err_collection_not_found("demo")
  let b = @errors.wrap_err_collection_not_found("other_collection")
  assert_true(a.same_code(b))
  assert_false(a.same_code(@errors.err_index_not_found()))
}

///|
/// `is_input_error` / `is_retryable_err` 对无错误统一返回 false。
test "predicates of no error are false" {
  let none : @errors.MerError? = None
  assert_false(@errors.is_input_error(none))
  assert_false(@errors.is_retryable_err(none))
}
