// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

// 验收标准：「错误信息中不泄露 token 等敏感 metadata」。
// 脱敏是上游 Go 版没有的增量，因此这里用独立用例固定行为。

///|
test "redact authorization bearer" {
  assert_eq(
    @errors.redact("Authorization: Bearer abc.def.ghi"),
    "Authorization: Bearer ***",
  )
  assert_eq(@errors.redact("bearer TOKEN123"), "bearer ***")
  assert_eq(
    @errors.redact("failed with Bearer abc, retry later"),
    "failed with Bearer ***, retry later",
  )
}

///|
test "redact key value secrets" {
  assert_eq(@errors.redact("token=abc123"), "token=***")
  assert_eq(@errors.redact("password: hunter2"), "password: ***")
  assert_eq(
    @errors.redact("api_key=sk-xxxx&db=default"),
    "api_key=***&db=default",
  )
  assert_eq(@errors.redact("Token=abc"), "Token=***")
}

///|
test "redact url userinfo keeps host" {
  assert_eq(
    @errors.redact("dial tcp milvus://root:secretpw@127.0.0.1:19530 failed"),
    "dial tcp milvus://root:***@127.0.0.1:19530 failed",
  )
}

///|
test "redact preserves non sensitive text" {
  assert_eq(
    @errors.redact("collection demo not found in database default"),
    "collection demo not found in database default",
  )
  assert_eq(@errors.redact("127.0.0.1:19530"), "127.0.0.1:19530")
  assert_eq(@errors.redact(""), "")
}

///|
/// 端到端：服务端把 token 回显在 reason / detail 里时，经 `from_status`
/// 后必须已打码。
test "from_status redacts credential echo" {
  let status : @common.Status = {
    code: 1100,
    reason: "auth failed: token=super-secret-value",
    detail: "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.payload.sig",
    retriable: false,
    error_code: @common.ErrorCode::Success,
    extra_info: {},
  }
  let err = @errors.from_status(status)
  let shown = @errors.MerError::to_string(err.unwrap())
  assert_true(shown.contains("token=***"))
  assert_false(shown.contains("super-secret-value"))
  assert_false(@errors.error_detail(err).contains("eyJhbGciOiJIUzI1NiJ9"))
  assert_true(@errors.error_detail(err).contains("Bearer ***"))
}

///|
/// 脱敏不得改变判定语义：code / legacy / retriable 不受影响。
test "redaction does not alter error identity" {
  let status : @common.Status = {
    code: 8,
    reason: "rate limited, token=abc",
    detail: "",
    retriable: true,
    error_code: @common.ErrorCode::Success,
    extra_info: {},
  }
  let err = @errors.from_status(status)
  assert_eq(@errors.error_code(err), 8)
  assert_true(@errors.is_retryable_err(err))
  assert_true(@errors.MerError::to_string(err.unwrap()).contains("token=***"))
}

///|
/// URL 无 userinfo 时必须原样穿过，不当成敏感信息误伤。
test "redact passes through url without userinfo" {
  assert_eq(
    @errors.redact("dial http://127.0.0.1:19530/v1 failed"),
    "dial http://127.0.0.1:19530/v1 failed",
  )
  assert_eq(
    @errors.redact("https://milvus.example.com"),
    "https://milvus.example.com",
  )
}

///|
/// userinfo 只有用户名、没有口令时保留用户名。
test "redact keeps username when password absent" {
  assert_eq(
    @errors.redact("mitm://milvus@127.0.0.1:19530"),
    "mitm://milvus@127.0.0.1:19530",
  )
}

///|
/// `legacy_code` 对 None 返回 Success。
test "legacy_code of no error is success" {
  let none : @errors.MerError? = None
  assert_eq(@errors.error_legacy_code(none), @common.ErrorCode::Success)
  assert_eq(
    @errors.error_legacy_code(Some(@errors.err_collection_not_found())),
    @common.ErrorCode::CollectionNotExists,
  )
}
