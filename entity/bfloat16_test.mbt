///|
/// BFloat16 bit patterns, cross-checked against upstream `ml_dtypes.bfloat16`.
/// The expected values were produced with
/// `ml_dtypes.bfloat16(np.float32(x)).view(np.uint16)`; the comment on each
/// line is the float it decodes back to.
let bfloat16_cases : Array[(Float, UInt)] = [
  // exact round-trips
  (0.0F, 0x0000U), // 0.0
  (-0.0F, 0x8000U), // -0.0
  (1.0F, 0x3F80U), // 1.0
  (-1.0F, 0xBF80U), // -1.0
  (2.0F, 0x4000U), // 2.0
  (1.5F, 0x3FC0U), // 1.5
  (-2.5F, 0xC020U), // -2.5
  (65536.0F, 0x4780U), // 65536.0
  // BFloat16 has 8 mantissa bits, so values that need more round to it
  (1.00390625F, 0x3F80U), // 1.0
  (1.002F, 0x3F80U), // 1.0
  (3.14159F, 0x4049U), // 3.140625
  (-3.14159F, 0xC049U), // -3.140625
  (0.1F, 0x3DCDU), // 0.10009765625
  (65535.0F, 0x4780U), // 65536.0
  (1.0e38F, 0x7E96U), // 1.0005146e38
  (-1.0e38F, 0xFE96U), // -1.0005146e38
  // overflow, underflow and the denormal boundary
  (1.0e-40F, 0x0001U), // 9.1835496e-41, smallest denormal
  // the largest finite float32 is above the midpoint to infinity, so it overflows
  (3.4028235e38F, 0x7F80U), // infinity
  (1.0F / 0.0F, 0x7F80U), // +infinity
  (-1.0F / 0.0F, 0xFF80U), // -infinity
]

///|
test "bfloat16_from_float matches ml_dtypes.bfloat16" {
  for entry in bfloat16_cases {
    assert_eq(@entity.bfloat16_from_float(entry.0), entry.1)
    assert_eq(
      Float::reinterpret_from_uint(entry.1 << 16),
      @entity.bfloat16_to_float(entry.1),
    )
  }
}

///|
/// Round-half-to-even, seen from the float side: the two neighbours of 1.0 are
/// 1.0 and 1 + 2^-7, their midpoint `1 + 2^-8` rounds to the even one (1.0),
/// and just above it rounds up.
test "bfloat16 rounds half to even" {
  let one = Float::reinterpret_from_uint(0x3F800000U)
  let up = Float::reinterpret_from_uint(0x3F810000U)
  let mid = Float::reinterpret_from_uint(0x3F808000U)
  assert_eq(@entity.bfloat16_from_float(one), 0x3F80U)
  assert_eq(@entity.bfloat16_from_float(up), 0x3F81U)
  assert_eq(@entity.bfloat16_from_float(mid), 0x3F80U)
  // the same midpoint behind an odd mantissa rounds up instead
  let odd = Float::reinterpret_from_uint(0x3F818000U)
  assert_eq(@entity.bfloat16_from_float(odd), 0x3F82U)
}

///|
/// The mantissa carry may bump the exponent: the float just below 1.0 (all
/// ones in the low 16 bits) rounds to 1.0, and the float just below the
/// largest finite float32 rounds to infinity.
test "bfloat16 rounding carries into the exponent" {
  let just_below_one = Float::reinterpret_from_uint(0x3F7FFFFFU)
  assert_eq(@entity.bfloat16_from_float(just_below_one), 0x3F80U)
  let just_below_max = Float::reinterpret_from_uint(0x7F7FFFFFU)
  assert_eq(@entity.bfloat16_from_float(just_below_max), 0x7F80U)
}

///|
test "bfloat16 vector bytes are little-endian pairs" {
  let bytes = @entity.bfloat16_vector_bytes([1.0F, -2.0F, 0.0F])
  assert_eq(bytes.length(), 6)
  let expected : Array[Int] = [0x80, 0x3F, 0x00, 0xC0, 0x00, 0x00]
  for i = 0; i < expected.length(); i = i + 1 {
    assert_eq(bytes[i].to_int(), expected[i])
  }
  assert_eq(@entity.bfloat16_vector_from_bytes(bytes), [1.0F, -2.0F, 0.0F])
}

///|
test "bfloat16 vector bytes round-trip arbitrary values" {
  let values : Array[Float] = [
    0.1F,
    -0.1F,
    3.14159F,
    1.0e-40F,
    1.0e38F,
    0.0F,
    -0.0F,
  ]
  let round_tripped = @entity.bfloat16_vector_from_bytes(
    @entity.bfloat16_vector_bytes(values),
  )
  assert_eq(round_tripped.length(), values.length())
  for i = 0; i < values.length(); i = i + 1 {
    assert_eq(
      round_tripped[i],
      @entity.bfloat16_to_float(@entity.bfloat16_from_float(values[i])),
    )
  }
}

///|
test "bfloat16 rejects an odd byte count" {
  let bytes : Bytes = b"\x01\x02\x03"
  try @entity.bfloat16_vector_from_bytes(bytes) catch {
    @entity.SchemaError(message) =>
      assert_eq(
        message, "bfloat16 vector payload must have an even byte count, got 3",
      )
  } noraise {
    _ => fail("odd byte count should be rejected")
  }
}
