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
// 回读侧的 float16 / bfloat16 解码头。
//
// 写侧目前只有 `@entity.bfloat16_vector_bytes`，回读侧的半边放在这里，因为
// 它只服务于「把一段 payload 变成浮点数组」这一件事；等写侧补齐 float16
// 编码时，两边应当合到 `entity` 去。解码逐位对齐 IEEE-754 binary16，
// 不是近似。

///|
/// 小端两字节一组的 float16 payload 解成浮点数组。
///
/// 奇数字节数是坏负载，直接报错——上游
/// `entity.DeserializeSliceSparseEmbedding` 对不整的字节数也是报错，不截断。
fn float16_bytes_to_floats(
  field_name : String,
  bytes : Bytes,
) -> Array[Float] raise ColumnError {
  if bytes.length() % 2 != 0 {
    raise MalformedPayload(
      "float16 vector field \{field_name} payload must have an even byte count, got \{bytes.length()}",
    )
  }
  let values : Array[Float] = []
  for i = 0; i * 2 < bytes.length(); i = i + 1 {
    let low = bytes[i * 2].to_uint()
    let high = bytes[i * 2 + 1].to_uint()
    values.push(float16_to_float(low | (high << 8)))
  }
  values
}

///|
/// 一个 IEEE-754 binary16 位模式对应的 float32 值。
///
/// 三种情形分开处理，与 binary16 的定义逐条对应：
/// - 指数全 0：0 或次正规数，尾数要按 2^-14 的标度展开；
/// - 指数全 1：正负无穷或 NaN，保留 NaN 的尾数位（不静默变成 0）；
/// - 其余：正规数，指数偏置从 15 换到 127。
fn float16_to_float(bits : UInt) -> Float {
  let sign = (bits >> 15) & 1U
  let exponent = (bits >> 10) & 0x1FU
  let mantissa = bits & 0x3FFU
  let sign_bit = sign << 31
  if exponent == 0U {
    if mantissa == 0U {
      return Float::reinterpret_from_uint(sign_bit)
    }
    // 次正规数：按尾数里最高有效位定位，归一化后是 binary32 的正规数。
    let mut shift = 10U
    let mut m = mantissa
    while (m & 0x400U) == 0U {
      m = m << 1
      shift = shift - 1U
    }
    let frac = (m & 0x3FFU) << 13
    let exp = (127 - 15 - shift.reinterpret_as_int() + 1).reinterpret_as_uint() <<
      23
    return Float::reinterpret_from_uint(sign_bit | exp | frac)
  }
  if exponent == 0x1FU {
    // 无穷或 NaN。NaN 必须有非零尾数，binary16 的尾数搬到 binary32 的高位。
    if mantissa == 0U {
      return Float::reinterpret_from_uint(sign_bit | 0x7F800000U)
    }
    return Float::reinterpret_from_uint(
      sign_bit | 0x7F800000U | (mantissa << 13),
    )
  }
  let exp = (exponent.reinterpret_as_int() - 15 + 127).reinterpret_as_uint() <<
    23
  Float::reinterpret_from_uint(sign_bit | exp | (mantissa << 13))
}

///|
/// 小端两字节一组的 bfloat16 payload 解成浮点数组。与 `entity` 里的
/// 编码侧互补：那边取 float32 的高 16 位，这边把它放回去，是精确的。
fn bfloat16_bytes_to_floats(
  field_name : String,
  bytes : Bytes,
) -> Array[Float] raise ColumnError {
  if bytes.length() % 2 != 0 {
    raise MalformedPayload(
      "bfloat16 vector field \{field_name} payload must have an even byte count, got \{bytes.length()}",
    )
  }
  let values : Array[Float] = []
  for i = 0; i * 2 < bytes.length(); i = i + 1 {
    let low = bytes[i * 2].to_uint()
    let high = bytes[i * 2 + 1].to_uint()
    values.push(@entity.bfloat16_to_float(low | (high << 8)))
  }
  values
}
