///|
/// The BFloat16 bit pattern of each float, in the same order as the input.
///
/// BFloat16 is the top 16 bits of an IEEE-754 float32, so the conversion is a
/// truncation plus a round-to-nearest-even step. The rounding constant is
/// `0x7FFF + lsb`: adding the low bit of the target makes an exact tie round
/// up only when that bit is already odd, which is round-half-to-even without a
/// branch. Carrying into the exponent is intended — it is how the mantissa
/// overflows into the next binade (`0x3F7FFFFF` -> `0x3F80`, i.e. `1.0`), and
/// the same carry turns a float32 infinity into a bfloat16 infinity.
///
/// The result is compared against upstream `ml_dtypes.bfloat16` over the whole
/// 32-bit space in the report that accompanies this module; see
/// `proto/REPORT.md` for the tooling it was checked with.
pub fn bfloat16_from_float(value : Float) -> UInt {
  let bits = value.reinterpret_as_uint()
  let low_bit = (bits >> 16) & 1U
  (bits + 0x7FFFU + low_bit) >> 16
}

///|
/// The BFloat16 bit pattern of each float, in input order.
pub fn bfloat16_from_floats(values : Array[Float]) -> Array[UInt] {
  values.map(bfloat16_from_float)
}

///|
/// The float that a BFloat16 bit pattern stands for. Exact: every bfloat16
/// value is a float32 value, so the widening is a shift with no rounding.
pub fn bfloat16_to_float(bits : UInt) -> Float {
  Float::reinterpret_from_uint(bits << 16)
}

///|
/// The little-endian, two-bytes-per-value encoding of floats as BFloat16,
/// which is what `VectorField.bfloat16_vector` carries on the wire.
pub fn bfloat16_vector_bytes(values : Array[Float]) -> Bytes {
  let buf = Buffer()
  for value in values {
    let bits = bfloat16_from_float(value)
    buf.write_byte((bits & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((bits >> 8) & 0xFFU).reinterpret_as_int().to_byte())
  }
  buf.to_bytes()
}

///|
/// Decodes little-endian BFloat16 bytes back into floats. An odd byte count
/// is a malformed payload and is rejected rather than silently truncated.
pub fn bfloat16_vector_from_bytes(
  bytes : Bytes,
) -> Array[Float] raise SchemaError {
  if bytes.length() % 2 != 0 {
    raise SchemaError(
      "bfloat16 vector payload must have an even byte count, got \{bytes.length()}",
    )
  }
  let values = []
  for i = 0; i < bytes.length(); i = i + 2 {
    let low = bytes[i].to_uint()
    let high = bytes[i + 1].to_uint()
    values.push(bfloat16_to_float(low | (high << 8)))
  }
  values
}
