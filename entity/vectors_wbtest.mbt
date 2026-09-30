///|
test "sparse vector keeps indices and values in step" {
  let row = SparseFloatVector::new([1U, 5U, 9U], [0.5F, 1.5F, 2.5F])
  row.validate()
  assert_eq(row.indices, [1U, 5U, 9U])
  assert_eq(row.values, [0.5F, 1.5F, 2.5F])
  assert_eq(row.inferred_dim(), 10)
}

///|
test "sparse vector validates lengths, index bound and NaN" {
  let mismatched = SparseFloatVector::{ indices: [1U, 2U], values: [0.5F], }
  try mismatched.validate() catch {
    SchemaError(message) =>
      assert_eq(
        message, "length of indices and values must be the same, got 2 and 1",
      )
  } noraise {
    _ => fail("mismatched lengths should be rejected")
  }
  let too_large = SparseFloatVector::{ indices: [0xFFFFFFFEU], values: [1.0F], }
  try too_large.validate() catch {
    SchemaError(message) =>
      assert_eq(
        message, "sparse vector index must be positive and less than 2^32-1: 4294967294",
      )
  } noraise {
    _ => fail("an index at 2^32-1 should be rejected")
  }
  let nan = SparseFloatVector::{ indices: [1U], values: [0.0F / 0.0F], }
  try nan.validate() catch {
    SchemaError(message) =>
      assert_eq(message, "sparse vector value must not be NaN")
  } noraise {
    _ => fail("a NaN value should be rejected")
  }
}

///|
test "sparse vector encodes sorted little-endian pairs" {
  let row = SparseFloatVector::new([5U, 1U], [2.0F, 1.0F])
  let bytes = row.to_bytes()
  assert_eq(bytes.length(), 16)
  let expected : Array[Int] = [
    1, 0, 0, 0, // index 1
     0, 0, 128, 63, // 1.0f
     5, 0, 0, 0, // index 5
     0, 0, 0, 64, // 2.0f
  ]
  for i = 0; i < expected.length(); i = i + 1 {
    assert_eq(bytes[i].to_int(), expected[i])
  }
}

///|
test "empty sparse row" {
  let row = SparseFloatVector::new([], [])
  row.validate()
  assert_eq(row.to_bytes().length(), 0)
  assert_eq(row.inferred_dim(), 0)
}

///|
test "sparse row from a single entry" {
  let row = SparseFloatVector::from_entry(3U, 0.25F)
  assert_eq(row.indices, [3U])
  assert_eq(row.values, [0.25F])
  assert_eq(row.inferred_dim(), 4)
}
