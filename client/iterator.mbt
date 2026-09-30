// Licensed to the LF AI & Data foundation under one
// or more contributor license agreements. See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership. The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// 移植自 milvus-io/milvus client/milvusclient/{iterator.go,
// iterator_option.go}（Apache-2.0）。
//
// Milvus 服务端对单次返回有上限，大结果集靠翻页。上游给了两条路：
//
// - `SearchIterator`：服务端侧游标。`schema.SearchResultData` 里回一个
//   `search_iterator_v2_results`（token + last_bound），下一次请求带上它，
//   服务端自己知道从哪继续。依赖 V2 协议，老服务端没有。
// - `QueryIterator`：客户端侧游标。记下上一批最后一行的主键，下次拼成
//   `pk > last` 追加到表达式后面。不依赖服务端能力，但要求主键可排序。
//
// 两条路都是「一次 `next` 一批」，批大小由调用方给，整体上限可选。
// 取空时报 `IteratorError::EndOfIterator`；`close` 收尾。
//
// 三处刻意的取舍，与上游不同，写在这里备查：
//
// 1. **不切 nq**。服务端要求搜索迭代器的 nq 恒为 1。上游靠 `nq = 1` 就
//    直接取 `topks[0]`；本移植在 `nq > 1` 时报错，而不是自己挑一段假装
//    那就是答案。
// 2. **`limit` 不跨批截断**。上游在 `SearchIterator` 里会把超出上限的那
//    一批切短（而 `QueryIterator` 切的是中间结果，切了等于白切）。本移植
//    两条路统一：上限只决定「还发不发下一次请求」，已取回的批次原样返回。
// 3. **收尾会真去关服务端会话**。服务端侧游标不会自己过期，所以
//    `SearchIterator` 翻到空、以及调用方显式 `close` 时，都补一次
//    `nq = 0` 的空检索把 session 收掉，而不是只打个本地标记。这条是 #18
//    验收标准里的「不泄漏服务端资源」；上游在翻到空时是靠服务端兜底的。

///|
/// `search_params` 里与迭代器相关的键。字面量与上游逐条对齐。
///
/// `iterator` 与 `search_iter_v2` 告诉服务端「这是翻页请求」；
/// `search_iter_id` / `search_iter_last_bound` 是上一批回给我们的续页凭据，
/// 原样带回去就行；`collection_id` 是 V2 协议要求的集合 ID。
pub let iterator_key : String = "iterator"

///|
pub let iterator_search_v2_key : String = "search_iter_v2"

///|
pub let iterator_batch_size_key : String = "search_iter_batch_size"

///|
pub let iterator_search_id_key : String = "search_iter_id"

///|
pub let iterator_search_last_bound_key : String = "search_iter_last_bound"

///|
pub let iterator_collection_id_key : String = "collection_id"

///|
/// 迭代器上限的「无限」写法。上游 `Unlimited = -1`。
pub let iterator_unlimited : Int64 = -1L

///|
/// 迭代器相关的失败。
///
/// `EndOfIterator` 是正常收尾而不是故障 —— 单独一类，因为调用方的处置
/// 与其余几种完全不同：其余几种要么重试要么放弃，它只是停下来。
pub(all) suberror IteratorError {
  /// 没有下一批了。走到末尾后重复调用同样报它。
  EndOfIterator
  /// 迭代器已经 `close` 过，不能再取下一批。
  Closed
  /// 建立或推进迭代器时发现前置条件不满足：集合不存在、主键不可排序、
  /// 主键列没回、批大小非正数等。翻不动时必须报出来，不能静默给空。
  Setup(String)
  /// 翻页过程中服务端或传输层出错。文本给人看，另两样给重试逻辑分流。
  /// `ClientError` 的构造器是包私有的，所以这里把需要的那部分摊出来，
  /// 而不是嵌一个 `@ClientError`。
  Rpc(Bool, Bool, String)
} derive(Debug)

///|
/// `EndOfIterator` 是正常收尾，值得单拎出来让调用方 `while` 到它为止。
pub fn IteratorError::is_end_of_iterator(self : IteratorError) -> Bool {
  match self {
    EndOfIterator => true
    _ => false
  }
}

///|
/// 已经关掉的迭代器再取下一批。
pub fn IteratorError::is_closed(self : IteratorError) -> Bool {
  match self {
    Closed => true
    _ => false
  }
}

///|
/// 这次失败是不是传输层的（可以原样重试的那一类）。
/// 非 RPC 失败一律为 `false`。
pub fn IteratorError::is_transport_failure(self : IteratorError) -> Bool {
  match self {
    Rpc(transport, _, _) => transport
    _ => false
  }
}

///|
/// 这次失败值不值得重试。传输层失败按 `ClientError` 的口径看，
/// 服务端拒绝则只看服务端下发的 `retriable`，不做本地猜测。
pub fn IteratorError::is_retryable(self : IteratorError) -> Bool {
  match self {
    Rpc(_, retriable, _) => retriable
    _ => false
  }
}

///|
pub impl Show for IteratorError with fn to_string(self) {
  match self {
    EndOfIterator => "end of iterator"
    Closed => "iterator is closed"
    Setup(msg) => "iterator setup: " + msg
    Rpc(_, _, message) => message
  }
}

///|
/// 把 `ClientError` 抬成 `IteratorError`：文本原样搬，分流信息保留。
fn as_rpc(err : ClientError) -> IteratorError {
  Rpc(err.is_transport(), err.is_retryable(), Show::to_string(err))
}

///|
/// 解码失败。`@column` 的错误在包外只剩文本，所以这一层只搬文本。
fn decode_failure(message : String) -> IteratorError {
  Rpc(false, false, "decode: " + message)
}

///|
/// 批大小必须是正数。服务端收到 `limit = 0` 会回空，迭代器就此静默终止，
/// 比少查几行更难查，所以在本地挡下。
fn validate_batch_size(batch_size : Int) -> Unit raise IteratorError {
  if batch_size <= 0 {
    raise IteratorError::Setup(
      "batch size must be greater than 0, got " + batch_size.to_string(),
    )
  }
}

///|
/// 这一页有没有行。没有列（服务端回空）或列都是 0 行都算空。
fn page_is_empty(page : QueryResult) -> Bool {
  page.len() == 0
}

///|
/// 查询迭代器的入参。对应上游 `queryIteratorOption`。
///
/// `batch_size` 是每批行数，`limit` 是整体上限（`iterator_unlimited` 表示
/// 取到空为止）。`output_fields` 里一定会有主键 —— 翻页靠它做游标，
/// 调用方没写也会被补上，与上游一致。
pub(all) struct QueryIteratorOption {
  collection_name : String
  partition_names : Array[String]
  expr : String
  output_fields : Array[String]
  batch_size : Int
  limit : Int64
  consistency_level : ConsistencyLevel?
} derive(Debug)

///|
/// 上游 `NewQueryIteratorOption`：批大小 1000、上限无限、一致性用默认档。
pub fn new_query_iterator_option(
  collection_name : String,
) -> QueryIteratorOption {
  {
    collection_name,
    partition_names: [],
    expr: "",
    output_fields: [],
    batch_size: 1000,
    limit: iterator_unlimited,
    consistency_level: None,
  }
}

///|
pub fn QueryIteratorOption::with_batch_size(
  self : QueryIteratorOption,
  batch_size : Int,
) -> QueryIteratorOption {
  { ..self, batch_size, }
}

///|
/// 整体上限。负数按「无限」处理，与上游 `WithIteratorLimit` 一致。
pub fn QueryIteratorOption::with_limit(
  self : QueryIteratorOption,
  limit : Int64,
) -> QueryIteratorOption {
  { ..self, limit: if limit < 0 { iterator_unlimited } else { limit }, }
}

///|
pub fn QueryIteratorOption::with_filter(
  self : QueryIteratorOption,
  expr : String,
) -> QueryIteratorOption {
  { ..self, expr, }
}

///|
pub fn QueryIteratorOption::with_output_fields(
  self : QueryIteratorOption,
  output_fields : Array[String],
) -> QueryIteratorOption {
  { ..self, output_fields, }
}

///|
pub fn QueryIteratorOption::with_partitions(
  self : QueryIteratorOption,
  partition_names : Array[String],
) -> QueryIteratorOption {
  { ..self, partition_names, }
}

///|
pub fn QueryIteratorOption::with_consistency_level(
  self : QueryIteratorOption,
  level : ConsistencyLevel,
) -> QueryIteratorOption {
  { ..self, consistency_level: Some(level), }
}

///|
/// 主键游标的两种形态。整数主键与字符串主键的翻页表达式不同，
/// 类型在建立迭代器时从 schema 定下来，往后只走对应那一支。
enum QueryCursor {
  Int(Int64)
  Str(String)
} derive(Debug)

///|
/// 主键能被表达式排序的两个类型。上游只认 `Int64` 与 `VarChar`，
/// 其余的（`Uuid` 之类）在建立迭代器时就报错，而不是翻出个错序的结果。
enum QueryCursorKind {
  IntCursor
  StrCursor
} derive(Eq, Debug)

///|
/// 翻页游标的列名与类型。
struct IteratorKey {
  name : String
  kind : QueryCursorKind
} derive(Debug)

///|
/// 查询迭代器。逐批问，靠主键游标往后挪。
///
/// 字段私有：`next` / `close` / `is_closed` 之外没有别的用法，
/// 把游标暴露出去只会让调用方有办法把状态搞乱。
pub struct QueryIterator {
  priv client : Client
  priv key : IteratorKey
  priv collection_name : String
  priv partition_names : Array[String]
  priv expr : String
  priv output_fields : Array[String]
  priv batch_size : Int
  priv consistency_level : ConsistencyLevel?
  priv mut remaining : Int64
  priv mut last : QueryCursor?
  priv mut closed : Bool
  priv mut exhausted : Bool
}

///|
/// 从 schema 里挑出主键，并判断它能不能当游标。
///
/// 上游对不能排序的主键是「原样返回表达式」——那等于每批都取同一段，
/// 静默地翻不动。这里直接报错，别让调用方以为自己拿到了全部数据。
fn iterator_key_of(
  schema : @entity.CollectionSchema,
) -> IteratorKey raise IteratorError {
  let pk = match schema.primary_key() {
    Some(field) => field
    None => raise IteratorError::Setup("collection schema has no primary key")
  }
  let kind = match pk.data_type {
    @entity.DataType::Int64 => IntCursor
    @entity.DataType::VarChar => StrCursor
    other =>
      raise IteratorError::Setup(
        "query iterator needs an Int64 or VarChar primary key, but " +
        pk.name +
        " is " +
        other.name(),
      )
  }
  { name: pk.name, kind, }
}

///|
/// 把用户表达式与主键下界拼成这一批的 `expr`。
///
/// 与上游 `composeIteratorExpr` 逐字对齐：第一页没有游标时原样返回用户
/// 表达式；有游标时拼 `(用户表达式) and pk > 值`，字符串主键的值带双引号。
fn compose_iterator_expr(
  base : String,
  key : IteratorKey,
  last : QueryCursor?,
) -> String {
  let cursor = match last {
    None => return base
    Some(cursor) => cursor
  }
  let pk_filter = match (key.kind, cursor) {
    (IntCursor, Int(v)) => key.name + " > " + v.to_string()
    (StrCursor, Str(v)) => key.name + " > \"" + v + "\""
    // `key.kind` 与游标类型在建立时一起定下，随后不再变；对不上说明有 bug，
    // 但表达式这一层没有 raise 的位置，退化成不带游标比拼出个错序结果好。
    _ => return base
  }
  let trimmed = base.trim()
  if trimmed == "" {
    pk_filter
  } else {
    "(" + trimmed.to_owned() + ") and " + pk_filter
  }
}

///|
/// 建立查询迭代器。这一步会先 `DescribeCollection` 拿 schema，
/// 所以集合不存在、或主键不可排序，都在 `next` 之前就失败。
pub async fn Client::query_iterator(
  self : Client,
  option : QueryIteratorOption,
) -> QueryIterator raise IteratorError {
  validate_batch_size(option.batch_size)
  let described = self.describe_collection(
    new_describe_collection_option(option.collection_name),
  ) catch {
    err => raise as_rpc(err)
  }
  let key = iterator_key_of(described.schema)
  let mut output_fields = option.output_fields
  // 上游只在调用方明确给了 output_fields 时才补主键：空列表对服务端
  // 意味着「只回主键」，本来就有。
  if output_fields.length() > 0 && !output_fields.contains(key.name) {
    output_fields = output_fields + [key.name]
  }
  {
    client: self,
    key,
    collection_name: option.collection_name,
    partition_names: option.partition_names,
    expr: option.expr,
    output_fields,
    batch_size: option.batch_size,
    consistency_level: option.consistency_level,
    remaining: option.limit,
    last: None,
    closed: false,
    exhausted: false,
  }
}

///|
/// 迭代器还能不能取下一批。`close` 之后为假，翻完之后也为假。
pub fn QueryIterator::is_closed(self : QueryIterator) -> Bool {
  self.closed || self.exhausted
}

///|
/// 关掉迭代器：之后的 `next` 报 `EndOfIterator`/`Closed`。
///
/// 查询迭代器在服务端没有会话 —— 状态全在客户端，没有东西要释放。
/// 保留 `close` 是为了让调用方的 `defer` 对两条迭代器一视同仁，
/// 也为了把「已经翻完了」这件事显式记下来。
///
/// 不声明 `raise`：这里真的没有会失败的动作。`SearchIterator::close` 会
/// 返回 `Bool`（服务端侧关成没关成），查询迭代器没有对应物，所以这里就是
/// 一个纯净的收尾，调用方用 `defer` 挂上也不必有 `try`。
pub fn QueryIterator::close(self : QueryIterator) -> Unit {
  self.closed = true
}

///|
/// 问服务端要一批。这是「一发一收」，批次切分在 `next` 里做。
async fn QueryIterator::fetch(
  iterator : QueryIterator,
) -> QueryResult raise IteratorError {
  let query_params : Array[(String, String)] = [
    (iterator_key, "true"),
    (query_param_limit, iterator.batch_size.to_string()),
  ]
  let consistency = match iterator.consistency_level {
    Some(level) => level.to_proto()
    None => @common.ConsistencyLevel::Bounded
  }
  let request = @milvus.QueryRequest::{
    base: None,
    db_name: "",
    collection_name: iterator.collection_name,
    expr: compose_iterator_expr(iterator.expr, iterator.key, iterator.last),
    output_fields: iterator.output_fields,
    partition_names: iterator.partition_names,
    travel_timestamp: 0UL,
    guarantee_timestamp: 0UL,
    query_params: query_params.map(pair => {
      @common.KeyValuePair::KeyValuePair(pair.0, pair.1)
    }),
    not_return_all_meta: false,
    consistency_level: consistency,
    use_default_consistency: iterator.consistency_level is None,
    namespace_: None,
  }
  let response : @milvus.QueryResults = iterator.client.call_service(
    query_path, request,
  ) catch {
    err => raise as_rpc(err)
  }
  match check_status(response.status) {
    Some(err) => raise as_rpc(err)
    None => decode_query_results(response) catch { err => raise as_rpc(err) }
  }
}

///|
/// 游标往后挪：记下这一页最后一行的主键。
///
/// 主键列没回来是硬故障 —— 没有它就翻不到下一页，与其原地打转不如报出来。
fn QueryIterator::advance(
  iterator : QueryIterator,
  page : QueryResult,
) -> Unit raise IteratorError {
  if page.len() == 0 {
    return
  }
  let column = match page.column(iterator.key.name) {
    Some(column) => column
    None =>
      raise IteratorError::Setup(
        "server did not return the primary key column " + iterator.key.name,
      )
  }
  if column.len() == 0 {
    return
  }
  let last = column.len() - 1
  let is_null = column.is_null(last) catch { _ => true }
  if is_null {
    raise IteratorError::Setup(
      "primary key column " +
      iterator.key.name +
      " is null at the last row of a batch",
    )
  }
  let value = match iterator.key.kind {
    IntCursor =>
      QueryCursor::Int(
        column.get_as_int64(last) catch {
          err => raise decode_failure(column_error_message(err))
        },
      )
    StrCursor =>
      QueryCursor::Str(
        column.get_as_string(last) catch {
          err => raise decode_failure(column_error_message(err))
        },
      )
  }
  iterator.last = Some(value)
}

///|
/// 取下一批。到末尾报 `EndOfIterator`，关掉了报 `Closed`。
///
/// 每次请求都问 `batch_size` 行，服务端给多少就回多少；不做跨批截断，
/// 上限只控制「还发不发下一次请求」（见文件头第 2 条）。
pub async fn QueryIterator::next(
  iterator : QueryIterator,
) -> QueryResult raise IteratorError {
  if iterator.closed {
    raise IteratorError::Closed
  }
  // 翻完了就一直是翻完了：再问还是 `EndOfIterator`，不会退化成一个
  // 「这个迭代器坏了」的 `Closed`。
  if iterator.exhausted {
    raise IteratorError::EndOfIterator
  }
  if iterator.remaining == 0L {
    iterator.exhausted = true
    raise IteratorError::EndOfIterator
  }
  let page = iterator.fetch()
  if page_is_empty(page) {
    iterator.exhausted = true
    raise IteratorError::EndOfIterator
  }
  iterator.advance(page)
  if iterator.remaining != iterator_unlimited {
    iterator.remaining = iterator.remaining - page.len().to_int64()
  }
  page
}

///|
/// 检索迭代器的入参。上游是 `searchIteratorOption`（内嵌 `searchOption`
/// 再加批大小与上限），这里照着嵌一个 `SearchOption`。
pub(all) struct SearchIteratorOption {
  base : SearchOption
  batch_size : Int
  limit : Int64
}

///|
/// 上游 `NewSearchIteratorOption`：批大小 1000、上限无限，并把
/// `iterator=true` / `search_iter_v2=true` 一并塞进 `search_params`。
///
/// `vectors` 的写法与 `new_search_option` 同一套：每个元素是**一次查询**，
/// 所以搜索迭代器的入参必须恰好一个元素（`nq = 1`）。
///
/// 上游给的初始 `topk` 是 1000，但那在每次 `next` 里都会被批大小覆盖，
/// 这里直接不放那个数 —— 少一个会被改写的东西。
pub fn new_search_iterator_option(
  collection_name : String,
  limit : Int,
  vectors : Array[@column.ColumnValue],
) -> SearchIteratorOption {
  let base = new_search_option(collection_name, limit, vectors)
    .with_search_param(iterator_key, "true")
    .with_search_param(iterator_search_v2_key, "true")
  { base, batch_size: 1000, limit: iterator_unlimited, }
}

///|
pub fn SearchIteratorOption::with_batch_size(
  self : SearchIteratorOption,
  batch_size : Int,
) -> SearchIteratorOption {
  { ..self, batch_size, }
}

///|
/// 整体上限。负数按「无限」处理。
pub fn SearchIteratorOption::with_limit(
  self : SearchIteratorOption,
  limit : Int64,
) -> SearchIteratorOption {
  { ..self, limit: if limit < 0 { iterator_unlimited } else { limit }, }
}

///|
pub fn SearchIteratorOption::with_anns_field(
  self : SearchIteratorOption,
  anns_field : String,
) -> SearchIteratorOption {
  { ..self, base: self.base.with_anns_field(anns_field), }
}

///|
pub fn SearchIteratorOption::with_filter(
  self : SearchIteratorOption,
  expr : String,
) -> SearchIteratorOption {
  { ..self, base: self.base.with_filter(expr), }
}

///|
pub fn SearchIteratorOption::with_output_fields(
  self : SearchIteratorOption,
  output_fields : Array[String],
) -> SearchIteratorOption {
  { ..self, base: self.base.with_output_fields(output_fields), }
}

///|
pub fn SearchIteratorOption::with_partitions(
  self : SearchIteratorOption,
  partition_names : Array[String],
) -> SearchIteratorOption {
  { ..self, base: self.base.with_partitions(partition_names), }
}

///|
pub fn SearchIteratorOption::with_metric_type(
  self : SearchIteratorOption,
  metric_type : @index.MetricType,
) -> SearchIteratorOption {
  { ..self, base: self.base.with_metric_type(metric_type), }
}

///|
/// 补一条 `search_params`。迭代器自己的键（`iterator` 之类）允许被覆盖 ——
/// 上游也是这个顺序：后写的赢。
pub fn SearchIteratorOption::with_search_param(
  self : SearchIteratorOption,
  key : String,
  value : String,
) -> SearchIteratorOption {
  { ..self, base: self.base.with_search_param(key, value), }
}

///|
pub fn SearchIteratorOption::with_ignore_growing(
  self : SearchIteratorOption,
  ignore_growing? : Bool = true,
) -> SearchIteratorOption {
  { ..self, base: self.base.with_ignore_growing(ignore_growing~), }
}

///|
pub fn SearchIteratorOption::with_consistency_level(
  self : SearchIteratorOption,
  level : ConsistencyLevel,
) -> SearchIteratorOption {
  { ..self, base: self.base.with_consistency_level(level), }
}

///|
/// 服务端侧游标的状态：上一批的 token 与最后一条命中的距离下界。
/// 两者都原样带回给服务端，客户端不解释它们。
struct SearchCursor {
  token : String
  last_bound : Float
} derive(Debug)

///|
/// 检索迭代器。
///
/// 服务端侧会话，所以 `close` 不只是打个标记：会发一次空检索把游标收掉，
/// 免得服务端为没人再读的会话留着资源。
pub struct SearchIterator {
  priv client : Client
  priv option : SearchIteratorOption
  priv collection_id : Int64
  priv mut remaining : Int64
  priv mut cursor : SearchCursor?
  priv mut closed : Bool
  priv mut exhausted : Bool
}

///|
/// 从响应里取这一批的续页凭据。
///
/// 服务端没给（老版本、或不是 V2 协议）就报错 —— 迭代器建不起来比翻到
/// 一半原地打转好。这是上游 `ErrServerVersionIncompatible` 的位置。
fn search_cursor_of(
  data : @schema.SearchResultData,
) -> SearchCursor raise IteratorError {
  let incompatible = "server did not return a search iterator token; it does not support search iterator v2"
  match data.search_iterator_v2_results {
    Some(info) =>
      if info.token == "" {
        raise IteratorError::Setup(incompatible)
      } else {
        { token: info.token, last_bound: info.last_bound, }
      }
    None => raise IteratorError::Setup(incompatible)
  }
}

///|
/// 建立检索迭代器。
///
/// 先 `DescribeCollection` 拿集合 ID —— V2 协议要求翻页请求带上它；
/// 这一步也顺带把「集合存在吗」问掉了。
pub async fn Client::search_iterator(
  self : Client,
  option : SearchIteratorOption,
) -> SearchIterator raise IteratorError {
  validate_batch_size(option.batch_size)
  // nq 恒为 1：服务端对搜索迭代器就是这个要求。上游靠「nq = 1 所以取
  // topks[0]」隐式成立，这里显式挡下来 —— 一次多查的用例在迭代器里
  // 没有意义，服务端也不会替你挑一段。
  if option.base.vectors.length() != 1 {
    raise IteratorError::Setup(
      "search iterator requires exactly one query vector (nq = 1), got " +
      option.base.vectors.length().to_string(),
    )
  }
  let described = self.describe_collection(
    new_describe_collection_option(option.base.collection_name),
  ) catch {
    err => raise as_rpc(err)
  }
  {
    client: self,
    option,
    collection_id: described.id,
    remaining: option.limit,
    cursor: None,
    closed: false,
    exhausted: false,
  }
}

///|
/// 迭代器是不是已经收尾。
pub fn SearchIterator::is_closed(self : SearchIterator) -> Bool {
  self.closed || self.exhausted
}

///|
/// 这一批的 `search_params`：搜索选项自带的那份，加批大小，加集合 ID，
/// 加续页凭据（如果有）。
///
/// 键集合与上游 `searchIteratorOption.SearchOption()` 加 `Next` 的组合一致：
/// `search_iter_batch_size` 与 `collection_id` 每批都写，
/// `search_iter_id` / `search_iter_last_bound` 只有拿到游标之后才有。
fn SearchIterator::search_params(
  iterator : SearchIterator,
  batch_size : Int,
  collection_id : Int64,
  with_cursor : Bool,
) -> Array[(String, String)] {
  let mut base = iterator.option.base.with_search_param(
    iterator_batch_size_key,
    batch_size.to_string(),
  )
  base = base.with_search_param(
    iterator_collection_id_key,
    collection_id.to_string(),
  )
  if with_cursor {
    match iterator.cursor {
      Some(cursor) => {
        base = base.with_search_param(iterator_search_id_key, cursor.token)
        base = base.with_search_param(
          iterator_search_last_bound_key,
          cursor.last_bound.to_string(),
        )
      }
      None => ()
    }
  }
  base.search_params
}

///|
/// 发一次检索。`limit` 覆盖成批大小，`search_params` 换成迭代器那一份，
/// 并在收到响应后把续页凭据记下来。
///
/// 响应里的续页凭据与命中是一起回来的，所以「取数」和「挪游标」在这里
/// 一趟做完 —— 分两步的话中间那段窗口里凭据是旧的，再发一发就重复了。
async fn SearchIterator::fetch(
  iterator : SearchIterator,
) -> SearchResult raise IteratorError {
  let with_cursor = iterator.cursor is Some(_)
  let batch_size = iterator.option.batch_size
  let collection_id = iterator.collection_id
  let option : SearchOption = {
    ..iterator.option.base,
    limit: batch_size,
    search_params: iterator.search_params(
      batch_size, collection_id, with_cursor,
    ),
  }
  // 借用 `search` 的入参编码，但响应里的 `SearchResultData` 要留着 ——
  // 续页凭据在它上面，而 `SearchResult` 只装了命中。
  let raw = iterator.client.search_raw(option) catch {
    err => raise as_rpc(err)
  }
  iterator.cursor = Some(search_cursor_of(raw.data))
  raw.result
}

///|
/// 取下一批。到末尾报 `EndOfIterator`，关掉了报 `Closed`。
///
/// 末尾的判定是「服务端回了零条命中」—— 搜索是距离序，取空即到底。
pub async fn SearchIterator::next(
  iterator : SearchIterator,
) -> SearchResult raise IteratorError {
  if iterator.closed {
    raise IteratorError::Closed
  }
  if iterator.exhausted {
    raise IteratorError::EndOfIterator
  }
  if iterator.remaining == 0L {
    iterator.exhausted = true
    // 收尾失败不盖掉 `EndOfIterator`：调用方要的是「没有下一批了」，
    // 而不是「服务端会话没关掉」。
    ignore(iterator.stop_server_session()) catch {
      _ => ()
    }
    raise IteratorError::EndOfIterator
  }
  let result = iterator.fetch()
  if result.hits.length() == 0 {
    iterator.exhausted = true
    // 收尾失败不盖掉 `EndOfIterator`：调用方要的是「没有下一批了」，
    // 而不是「服务端会话没关掉」。
    ignore(iterator.stop_server_session()) catch {
      _ => ()
    }
    raise IteratorError::EndOfIterator
  }
  if iterator.remaining != iterator_unlimited {
    iterator.remaining = iterator.remaining - result.hits.length().to_int64()
  }
  result
}

///|
/// 补一次空检索把服务端那个游标会话收掉。
///
/// 服务端侧的游标不会自己过期，所以走到末尾、或者调用方显式 `close` 的
/// 时候，都得主动告诉服务端一声，否则它会为一个没人再读的会话留着资源。
/// 上游在 `SearchIterator` 翻到空时**不**收尾，靠服务端兜底；这里两处都收，
/// 理由就是上面这条（验收标准里的「不泄漏服务端资源」）。
///
/// 失败往上抛，由调用方决定怎么处置：翻到末尾时那个失败只说明「服务端
/// 会话收尾没成功」，不该盖掉 `EndOfIterator`；显式 `close` 时调用方拿
/// `false` 也就够用了。两处都不想让一个收尾动作变成主流程的错误来源。
async fn SearchIterator::stop_server_session(
  iterator : SearchIterator,
) -> Unit raise IteratorError {
  // 从没取过一批：服务端那边没有任何会话可关。
  if iterator.cursor is None {
    return
  }
  let option : SearchOption = {
    ..iterator.option.base,
    vectors: [],
    search_params: iterator.search_params(0, iterator.collection_id, true),
  }
  // 收尾失败抬给调用方 —— 只有它知道这时候该不该在乎。走到末尾时不在乎
  // （`EndOfIterator` 才是重点），显式 `close` 时在乎（返回 `false`）。
  iterator.client.cancel_search(option) catch {
    err => raise as_rpc(err)
  }
}

///|
/// 关掉迭代器。
///
/// 服务端侧的游标不会自己过期，所以这里补一次空检索让服务端把那个
/// session 收掉，顺便把本地状态钉成「已关」。
///
/// 空检索失败不往上抛：调用方多半是在 `defer` 里关的，这时候再报一个
/// 「关不掉」也救不回来，反倒会把原本的错误盖掉。返回值告诉调用方这次
/// 关闭是干净收尾（`true`）还是服务端侧没关成（`false`）。
pub async fn SearchIterator::close(iterator : SearchIterator) -> Bool {
  // 已经关过、或已经翻完了：服务端那边早在翻到空时收掉了，别再发一发。
  if iterator.closed || iterator.exhausted {
    return true
  }
  iterator.closed = true
  ignore(iterator.stop_server_session()) catch {
    _ => return false
  }
  true
}
