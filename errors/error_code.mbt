// 移植自 github.com/milvus-io/milvus client/internal/merr (Apache-2.0)
// Copyright (c) LF AI & Data Foundation

///|
/// Milvus 客户端错误码常量。
///
/// `code` 是 modern 数值码（`Status.code`），`canceled` / `timeout` 是上游
/// `merr` 为 Go context 错误保留的本地码，不属于 Milvus 服务端。
pub let canceled_code : Int = 10000

///|
pub let timeout_code : Int = 10001

///|
/// 上游 `unexpectedCode`：`(1 << 16) - 1`，未知错误统一落到这里。
pub let unexpected_code : Int = 65535

///|
/// `Status.extra_info` 中标记「输入错误」的键，与上游 `inputErrorFlagKey` 一致。
pub let input_error_flag_key : String = "is_input_error"
