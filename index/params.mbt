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
// 移植自 milvus-io/milvus client/index/*.go（Apache-2.0）。
// 上游 `index_type` / `metric_type` 的键名与字面量在这里是协议的一部分，
// 键名大小写敏感：`M`（图度数）与 `m`（PQ 子量化器数）是两个参数。

///|
/// 非法参数组合。上游把这类错误留给服务端，客户端要一次 RPC 往返才知道；
/// 这里在构造期就拦下，错误信息带上参数名与取值范围。
pub suberror IndexParamError {
  /// 参数越界：参数名、给定值、期望范围
  OutOfRange(key~ : String, value~ : Int, expected~ : String)
  /// 参数组合在该索引类型上不被接受：索引类型、说明
  InvalidCombination(index_type~ : String, reason~ : String)
  /// 空集合等前置条件不满足
  InvalidArgument(reason~ : String)
} derive(Debug)

///|
/// `index_type` 的键名。
pub let index_type_key : String = "index_type"

///|
/// `metric_type` 的键名。
pub let metric_type_key : String = "metric_type"

///|
/// 索引构建参数集合。键名即线上协议键名，原样透传。
///
/// 上游每个具体索引类型一个 struct 类型；这里统一成一个 map 承载，
/// 因为最终产物都是 `map<string,string>`，分成十几个类型只会把
/// 「哪些键对哪种索引有效」这一信息藏进类型名里，而校验仍要手写。
pub(all) struct IndexParams {
  /// 有序键值对。Milvus 的 `ExtraParams` 是 repeated，顺序不进协议语义，
  /// 但保持插入序能让测试与调试输出稳定。
  entries : Array[(String, String)]
} derive(Eq)

///|
/// 空参数集。
pub fn IndexParams::new() -> IndexParams {
  { entries: [], }
}

///|
/// 覆盖写入一个键：已存在则原地替换（保持位置），否则追加。
pub fn IndexParams::set(
  self : IndexParams,
  key : String,
  value : String,
) -> Unit {
  for i, entry in self.entries {
    if entry.0 == key {
      self.entries[i] = (key, value)
      return
    }
  }
  self.entries.push((key, value))
}

///|
/// 只在该键未出现时写入。用于「默认值不该覆盖显式设置」的场景。
pub fn IndexParams::set_default(
  self : IndexParams,
  key : String,
  value : String,
) -> Unit {
  for entry in self.entries {
    if entry.0 == key {
      return
    }
  }
  self.entries.push((key, value))
}

///|
/// 读取一个键。
pub fn IndexParams::get(self : IndexParams, key : String) -> String? {
  for entry in self.entries {
    if entry.0 == key {
      return Some(entry.1)
    }
  }
  None
}

///|
/// 键数量。
pub fn IndexParams::size(self : IndexParams) -> Int {
  self.entries.length()
}

///|
/// 转为 Milvus `ExtraParams` 需要的键值对序列。
pub fn IndexParams::to_pairs(self : IndexParams) -> Array[(String, String)] {
  self.entries.copy()
}

///|
/// 从上游返回的键值对重建。
pub fn IndexParams::from_pairs(pairs : Array[(String, String)]) -> IndexParams {
  { entries: pairs.copy(), }
}

///|
/// 把整数值写入，便于调用方在能拿到类型的地方少写一次 `to_string`。
pub fn IndexParams::set_int(
  self : IndexParams,
  key : String,
  value : Int,
) -> Unit {
  self.set(key, value.to_string())
}

///|
/// 转成 JSON 对象字符串。Milvus 的 `params` 字段在某些入口接受 JSON 串，
/// 这里保持上游 `encoding/json` 的紧凑格式（无空格），键保持插入序。
///
/// 只处理字符串值：上游 builder 产出的值全是字符串形式的数字或枚举名。
pub fn IndexParams::to_json(self : IndexParams) -> String {
  let buf = StringBuilder()
  buf.write_char('{')
  for i, entry in self.entries {
    if i > 0 {
      buf.write_char(',')
    }
    write_json_string(buf, entry.0)
    buf.write_char(':')
    write_json_string(buf, entry.1)
  }
  buf.write_char('}')
  buf.to_string()
}

///|
/// 写一个 JSON 字符串字面量。Milvus 的参数键名与取值都是 ASCII 标识符或数字，
/// 但 `refine_type` 之类是用户可传的，转义不能省，否则 `"` 会截断 JSON。
fn write_json_string(buf : StringBuilder, s : String) -> Unit {
  buf.write_char('"')
  for c in s {
    match c {
      '"' => buf.write_string("\\\"")
      '\\' => buf.write_string("\\\\")
      '\n' => buf.write_string("\\n")
      '\r' => buf.write_string("\\r")
      '\t' => buf.write_string("\\t")
      _ => buf.write_char(c)
    }
  }
  buf.write_char('"')
}

///|
/// `Show` 用 JSON 形态，调试时直接可读。
pub impl Show for IndexParams with fn output(self, logger) {
  logger.write_string(self.to_json())
}
