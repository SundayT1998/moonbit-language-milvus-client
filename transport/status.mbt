// gRPC status：上层判断「这次失败是不是超时」的入口。
// MoonBit 侧没有 Go 的 `codes` 包，这里把 P0 用得到的码定出来。
// 数值与 gRPC 规范一致，也与 `moonrpc` 的 `Status` 对齐。

///|
/// gRPC 状态码。
pub(all) enum Code {
  Ok
  Cancelled
  Unknown
  InvalidArgument
  DeadlineExceeded
  NotFound
  AlreadyExists
  PermissionDenied
  ResourceExhausted
  FailedPrecondition
  Aborted
  OutOfRange
  Unimplemented
  Internal
  Unavailable
  DataLoss
  Unauthenticated
}

///|
impl Eq for Code with fn equal(self, other) {
  self.to_int() == other.to_int()
}

///|
impl @debug.Debug for Code with fn to_repr(self) {
  @debug.Repr::string(self.name())
}

///|
/// `Code` 的调试形态。`assert_eq` 的失败 diff 会用它，
/// 这里也开出来，便于别处打日志时拿到和断言一致的表示。
pub fn Code::debug_repr(self : Code) -> String {
  @debug.to_string(self)
}

///|
pub fn Code::name(self : Code) -> String {
  match self {
    Ok => "OK"
    Cancelled => "CANCELLED"
    Unknown => "UNKNOWN"
    InvalidArgument => "INVALID_ARGUMENT"
    DeadlineExceeded => "DEADLINE_EXCEEDED"
    NotFound => "NOT_FOUND"
    AlreadyExists => "ALREADY_EXISTS"
    PermissionDenied => "PERMISSION_DENIED"
    ResourceExhausted => "RESOURCE_EXHAUSTED"
    FailedPrecondition => "FAILED_PRECONDITION"
    Aborted => "ABORTED"
    OutOfRange => "OUT_OF_RANGE"
    Unimplemented => "UNIMPLEMENTED"
    Internal => "INTERNAL"
    Unavailable => "UNAVAILABLE"
    DataLoss => "DATA_LOSS"
    Unauthenticated => "UNAUTHENTICATED"
  }
}

///|
pub fn Code::to_int(self : Code) -> Int {
  match self {
    Ok => 0
    Cancelled => 1
    Unknown => 2
    InvalidArgument => 3
    DeadlineExceeded => 4
    NotFound => 5
    AlreadyExists => 6
    PermissionDenied => 7
    ResourceExhausted => 8
    FailedPrecondition => 9
    Aborted => 10
    OutOfRange => 11
    Unimplemented => 12
    Internal => 13
    Unavailable => 14
    DataLoss => 15
    Unauthenticated => 16
  }
}

///|
/// 规范数值还原成枚举。未知数值归 `Unknown`；
/// 原始数值不丢，`RpcError::raw_code` 留着。
pub fn Code::from_int(n : Int) -> Code {
  match n {
    0 => Ok
    1 => Cancelled
    2 => Unknown
    3 => InvalidArgument
    4 => DeadlineExceeded
    5 => NotFound
    6 => AlreadyExists
    7 => PermissionDenied
    8 => ResourceExhausted
    9 => FailedPrecondition
    10 => Aborted
    11 => OutOfRange
    12 => Unimplemented
    13 => Internal
    14 => Unavailable
    15 => DataLoss
    16 => Unauthenticated
    _ => Unknown
  }
}

///|
/// 一次调用失败的全部信息。`raw_code` 保留线上原值，`code` 是归类后的结果。
///
/// 用 `suberror` 而不是 `struct`：调用侧要能 `raise` 它，
/// 否则「超时错误可被上层识别」就只剩比较返回值一条路。
pub suberror RpcError {
  RpcError(Code, Int, String)
}

///|
/// 失败归类后的 gRPC 码。
pub fn RpcError::code(self : RpcError) -> Code {
  let RpcError(code, _, _) = self
  code
}

///|
/// 线上原始 `grpc-status` 数值。未知码也不丢。
pub fn RpcError::raw_code(self : RpcError) -> Int {
  let RpcError(_, raw_code, _) = self
  raw_code
}

///|
/// 服务端给的 `grpc-message`。
pub fn RpcError::message(self : RpcError) -> String {
  let RpcError(_, _, message) = self
  message
}

///|
/// 调用方看的一句话描述。
pub fn RpcError::to_string(self : RpcError) -> String {
  let RpcError(code, _, message) = self
  if message == "" {
    code.name()
  } else {
    code.name() + ": " + message
  }
}

///|
impl @debug.Debug for RpcError with fn to_repr(self) {
  @debug.Repr::string(self.to_string())
}

///|
impl Show for RpcError with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
impl Eq for RpcError with fn equal(self, other) {
  let RpcError(_, a_raw, a_msg) = self
  let RpcError(_, b_raw, b_msg) = other
  a_raw == b_raw && a_msg == b_msg
}

///|
/// 多个失败是否「同一类」。重试判断用得到：同一码、同一条消息即视为同类。
pub fn RpcError::same_kind(self : RpcError, other : RpcError) -> Bool {
  self == other
}

///|
/// 把 gRPC 层的 (status, message) 包成上层能判别的错误。
pub fn RpcError::new(raw_code : Int, message : String) -> RpcError {
  RpcError(Code::from_int(raw_code), raw_code, message)
}

///|
/// 是否可由调用方重试。读路径上 `Unavailable` 是典型可重试项；
/// 超时与参数错不盲目重试。
pub fn RpcError::is_retryable(self : RpcError) -> Bool {
  match self.code() {
    Unavailable | ResourceExhausted | Aborted => true
    _ => false
  }
}

///|
/// Issue 验收项「超时错误可被上层识别」落在这里：
/// 上层拿 `RpcError` 调它，而不是去比对魔法数字 4。
pub fn RpcError::is_deadline_exceeded(self : RpcError) -> Bool {
  self.code() == DeadlineExceeded
}
