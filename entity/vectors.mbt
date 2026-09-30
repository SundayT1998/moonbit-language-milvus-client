///|
/// A dense vector of `dim` float32 values.
pub(all) struct FloatVector {
  dim : Int
  values : Array[Float]
} derive(Debug)

///|
/// A dense vector of `dim` IEEE-754 half-precision values. The values are kept
/// as floats and narrowed on the wire, where each one takes two bytes.
pub(all) struct Float16Vector {
  dim : Int
  values : Array[Float]
} derive(Debug)

///|
/// A dense vector of `dim` bfloat16 values, kept widened to float32 so that
/// arithmetic on them stays exact.
pub(all) struct BFloat16Vector {
  dim : Int
  values : Array[Float]
} derive(Debug)

///|
/// A dense binary vector of `dim` bits, packed 8 bits per byte the way
/// `VectorField.binary_vector` expects. `dim` is always a multiple of 8, so
/// the byte count is `dim / 8`.
pub(all) struct BinaryVector {
  dim : Int
  data : Bytes
} derive(Debug)

///|
/// A dense vector of `dim` signed bytes.
pub(all) struct Int8Vector {
  dim : Int
  data : Bytes
} derive(Debug)

///|
/// A sparse float vector: the value of each stored coordinate, keyed by
/// coordinate. The server sizes a sparse row by its largest index, not by a
/// declared dimension, so there is no `dim` here.
///
/// Indices are `UInt` because `SparseFloatVector` coordinates are uint32 on
/// the wire. The `.proto` bounds the *row* by `uint32` and the per-entry
/// encoding by `varint`, so an index at or above `2^32 - 1` is rejected the
/// same way upstream rejects it.
pub(all) struct SparseFloatVector {
  indices : Array[UInt]
  values : Array[Float]
} derive(Eq, Debug)

///|
/// A sparse row from parallel index/value arrays. Both arrays must be the
/// same length; neither may hold a NaN value.
pub fn SparseFloatVector::new(
  indices : Array[UInt],
  values : Array[Float],
) -> SparseFloatVector raise SchemaError {
  if indices.length() != values.length() {
    raise SchemaError(
      "length of indices and values must be the same, got \{indices.length()} and \{values.length()}",
    )
  }
  SparseFloatVector::{ indices, values, }
}

///|
/// A sparse row with a single entry.
pub fn SparseFloatVector::from_entry(
  index : UInt,
  value : Float,
) -> SparseFloatVector {
  { indices: [index], values: [value], }
}

///|
/// The dimension the server will infer for this row: the largest index plus
/// one, or 0 for an empty row.
pub fn SparseFloatVector::inferred_dim(self : SparseFloatVector) -> Int {
  let mut dim = 0
  for index in self.indices {
    dim = dim.max(index.reinterpret_as_int() + 1)
  }
  dim
}

///|
/// Validates the row against the encoding the server accepts: equal lengths,
/// indices below `2^32 - 1`, and no NaN.
pub fn SparseFloatVector::validate(
  self : SparseFloatVector,
) -> Unit raise SchemaError {
  if self.indices.length() != self.values.length() {
    raise SchemaError(
      "length of indices and values must be the same, got \{self.indices.length()} and \{self.values.length()}",
    )
  }
  for index in self.indices {
    if index >= 0xFFFFFFFEU {
      raise SchemaError(
        "sparse vector index must be positive and less than 2^32-1: \{index}",
      )
    }
  }
  for value in self.values {
    if value.is_nan() {
      raise SchemaError("sparse vector value must not be NaN")
    }
  }
}

///|
/// Encodes the row as index/value pairs, each a little-endian uint32
/// followed by a little-endian float32. Entries are sorted by index, which is
/// the order upstream writes and the order Milvus persists.
pub fn SparseFloatVector::to_bytes(
  self : SparseFloatVector,
) -> Bytes raise SchemaError {
  self.validate()
  let sorted = []
  for i = 0; i < self.indices.length(); i = i + 1 {
    sorted.push((self.indices[i], self.values[i]))
  }
  sorted.sort()
  let buf = Buffer()
  for entry in sorted {
    let index = entry.0
    buf.write_byte((index & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((index >> 8) & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((index >> 16) & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((index >> 24) & 0xFFU).reinterpret_as_int().to_byte())
    let bits = entry.1.reinterpret_as_uint()
    buf.write_byte((bits & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((bits >> 8) & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((bits >> 16) & 0xFFU).reinterpret_as_int().to_byte())
    buf.write_byte(((bits >> 24) & 0xFFU).reinterpret_as_int().to_byte())
  }
  buf.to_bytes()
}

///|
// Silence the implicit trait-promotion warnings that `derive(Debug)` (and
// `derive(Eq)`) would otherwise raise for the whole module.

///|

// `derive(Debug)` (and `derive(Eq)`) promote their trait methods to plain
// methods, which MoonBit deprecates. Pinning the promotions here keeps the
// module warning-free without dropping the derives themselves.

///|
#deprecated
pub extend FloatVector with @debug.Debug::{to_repr}

///|
#deprecated
pub extend Float16Vector with @debug.Debug::{to_repr}

///|
#deprecated
pub extend BFloat16Vector with @debug.Debug::{to_repr}

///|
#deprecated
pub extend BinaryVector with @debug.Debug::{to_repr}

///|
#deprecated
pub extend Int8Vector with @debug.Debug::{to_repr}

///|
#deprecated
pub extend SparseFloatVector with @debug.Debug::{to_repr}

///|
#deprecated
pub extend SparseFloatVector with Eq::{not_equal, equal}

///|
/// The sparse row that a payload written by `SparseFloatVector::to_bytes`
/// stands for: little-endian uint32 index followed by little-endian float32
/// value, 8 bytes an entry. Named after the upstream
/// `entity.DeserializeSliceSparseEmbedding`.
///
/// A byte count that is not a multiple of 8, or a NaN value, is rejected the
/// same way the write side rejects it, so a payload round-trips or fails
/// loudly at the boundary.
pub fn SparseFloatVector::from_bytes(
  bytes : Bytes,
) -> SparseFloatVector raise SchemaError {
  if bytes.length() % 8 != 0 {
    raise SchemaError(
      "sparse vector payload must be a multiple of 8 bytes, got \{bytes.length()}",
    )
  }
  let indices : Array[UInt] = []
  let values : Array[Float] = []
  for i = 0; i * 8 < bytes.length(); i = i + 1 {
    let base = i * 8
    let index = bytes[base].to_uint() |
      (bytes[base + 1].to_uint() << 8) |
      (bytes[base + 2].to_uint() << 16) |
      (bytes[base + 3].to_uint() << 24)
    let bits = bytes[base + 4].to_uint() |
      (bytes[base + 5].to_uint() << 8) |
      (bytes[base + 6].to_uint() << 16) |
      (bytes[base + 7].to_uint() << 24)
    indices.push(index)
    values.push(Float::reinterpret_from_uint(bits))
  }
  let row = SparseFloatVector::{ indices, values, }
  row.validate()
  row
}
