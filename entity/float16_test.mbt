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
// 期望值由 Python `struct.pack('<e', v)` 生成，逐位比对。

///|
test "@entity.float16_from_float: exact binary16 values" {
  // 这些数在 binary16 里可精确表示，编码不该有任何舍入。
  assert_eq(@entity.float16_from_float(0.0), 0x0000U)
  assert_eq(@entity.float16_from_float(-0.0), 0x8000U)
  assert_eq(@entity.float16_from_float(1.0), 0x3C00U)
  assert_eq(@entity.float16_from_float(-1.0), 0xBC00U)
  assert_eq(@entity.float16_from_float(-2.0), 0xC000U)
  assert_eq(@entity.float16_from_float(0.5), 0x3800U)
  assert_eq(@entity.float16_from_float(2.0), 0x4000U)
  assert_eq(@entity.float16_from_float(65504.0), 0x7BFFU)
}

///|
test "@entity.float16_from_float: round half to even" {
  // struct.pack('<e', 1.0009765625) -> 0x3C01（恰好是半格，尾数末位为奇，进）
  assert_eq(@entity.float16_from_float(1.0009765625), 0x3C01U)
  // 比半格少一点 -> 舍
  assert_eq(@entity.float16_from_float(1.00048828125), 0x3C00U)
  // 1 + 2^-11 恰好是半格且末位为偶 -> 舍
  assert_eq(@entity.float16_from_float(1.00048828125), 0x3C00U)
}

///|
test "@entity.float16_from_float: overflow and subnormal" {
  assert_eq(@entity.float16_from_float(65520.0), 0x7C00U) // 上溢 -> inf
  assert_eq(@entity.float16_from_float(-70000.0), 0xFC00U) // 负上溢 -> -inf
  assert_eq(@entity.float16_from_float(1.0e-8), 0x0000U) // 太小 -> 0
  assert_eq(@entity.float16_from_float(-1.0e-8), 0x8000U) // 太小 -> -0
  // 最小次正规数 2^-24 恰好可表示
  assert_eq(@entity.float16_from_float(5.960464477539063e-8), 0x0001U)
}

///|
test "@entity.float16_from_float: inf and nan keep their identity" {
  let inf = Float::reinterpret_from_uint(0x7F800000U)
  let ninf = Float::reinterpret_from_uint(0xFF800000U)
  let nan = Float::reinterpret_from_uint(0x7FC00000U)
  assert_eq(@entity.float16_from_float(inf), 0x7C00U)
  assert_eq(@entity.float16_from_float(ninf), 0xFC00U)
  assert_eq(@entity.float16_from_float(nan), 0x7E00U)
}

///|
test "@entity.float16_vector_bytes: little-endian, two bytes per value" {
  let bytes = @entity.float16_vector_bytes([1.0, -2.0])
  assert_eq(bytes.length(), 4)
  assert_eq(bytes[0].to_uint(), 0x00U)
  assert_eq(bytes[1].to_uint(), 0x3CU)
  assert_eq(bytes[2].to_uint(), 0x00U)
  assert_eq(bytes[3].to_uint(), 0xC0U)
}
