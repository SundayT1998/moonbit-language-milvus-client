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

///|
/// 插入序保持：测试快照稳定依赖这一点。
test "set preserves insertion order" {
  let p = @index.IndexParams::new()
  p.set("b", "2")
  p.set("a", "1")
  p.set("c", "3")
  assert_eq(p.to_pairs(), [("b", "2"), ("a", "1"), ("c", "3")])
}

///|
/// 覆盖写入原地替换，不改变位置。
test "set overwrites in place" {
  let p = @index.IndexParams::new()
  p.set("a", "1")
  p.set("b", "2")
  p.set("a", "9")
  assert_eq(p.to_pairs(), [("a", "9"), ("b", "2")])
}

///|
/// `set_default` 不覆盖已存在的键。
test "set_default does not overwrite" {
  let p = @index.IndexParams::new()
  p.set("M", "64")
  p.set_default("M", "16")
  p.set_default("efConstruction", "200")
  assert_eq(p.get("M"), Some("64"))
  assert_eq(p.get("efConstruction"), Some("200"))
}

///|
/// 整数写入走十进制，不带符号或填充。
test "set_int writes decimal" {
  let p = @index.IndexParams::new()
  p.set_int("nlist", 128)
  assert_eq(p.get("nlist"), Some("128"))
}

///|
/// JSON 是紧凑格式，与上游 `encoding/json` 的 `Marshal` 一致（无空格）。
test "to_json is compact and ordered" {
  let p = @index.IndexParams::new()
  p.set("index_type", "HNSW")
  p.set("metric_type", "L2")
  p.set("M", "16")
  p.set("efConstruction", "200")
  assert_eq(
    p.to_json(),
    "{\"index_type\":\"HNSW\",\"metric_type\":\"L2\",\"M\":\"16\",\"efConstruction\":\"200\"}",
  )
}

///|
/// 空参数集的 JSON 是 `{}`。
test "empty params to_json" {
  assert_eq(@index.IndexParams::new().to_json(), "{}")
}

///|
/// 引号与反斜杠必须转义，否则查表键名里的 `"` 会截断 JSON。
test "to_json escapes special characters" {
  let p = @index.IndexParams::new()
  p.set("we\"ird", "back\\slash")
  p.set("newline", "a\nb")
  assert_eq(
    p.to_json(),
    "{\"we\\\"ird\":\"back\\\\slash\",\"newline\":\"a\\nb\"}",
  )
}

///|
/// 从上游返回的键值对重建后，键名与取值原样保留。
test "from_pairs round-trips" {
  let pairs : Array[(String, String)] = [
    ("index_type", "IVF_FLAT"),
    ("nlist", "128"),
  ]
  let p = @index.IndexParams::from_pairs(pairs)
  assert_eq(p.size(), 2)
  assert_eq(p.get("nlist"), Some("128"))
  assert_eq(p.to_pairs(), pairs)
}

///|
/// `Show` 输出即 JSON，便于调试时直接读到参数内容。
test "show renders json" {
  let p = @index.IndexParams::new()
  p.set("nlist", "128")
  assert_eq(p.to_string(), "{\"nlist\":\"128\"}")
}
