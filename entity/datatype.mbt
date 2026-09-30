///|
/// Milvus field data types.
///
/// The enum members mirror `milvus.proto.schema.DataType` one to one, and the
/// numeric values are pinned by `DataType::to_int` (see `entity_wbtest.mbt`).
/// They are part of the wire protocol, so neither the spelling nor the value
/// may drift from the upstream `.proto`.
pub(all) enum DataType {
  None
  Bool
  Int8
  Int16
  Int32
  Int64
  Float
  Double
  String
  VarChar
  Array
  Json
  Geometry
  Text
  Timestamptz
  Mol
  Date
  Time
  Decimal
  Uuid
  BinaryVector
  FloatVector
  Float16Vector
  BFloat16Vector
  SparseFloatVector
  Int8Vector
  ArrayOfVector
  ArrayOfStruct
  Struct
} derive(Eq, Debug)

///|
/// The `DataType` enum value from `schema.proto`.
pub fn DataType::to_int(self : DataType) -> Int {
  match self {
    None => 0
    Bool => 1
    Int8 => 2
    Int16 => 3
    Int32 => 4
    Int64 => 5
    Float => 10
    Double => 11
    String => 20
    VarChar => 21
    Array => 22
    Json => 23
    Geometry => 24
    Text => 25
    Timestamptz => 26
    Mol => 27
    Date => 28
    Time => 29
    Decimal => 30
    Uuid => 31
    BinaryVector => 100
    FloatVector => 101
    Float16Vector => 102
    BFloat16Vector => 103
    SparseFloatVector => 104
    Int8Vector => 105
    ArrayOfVector => 106
    ArrayOfStruct => 200
    Struct => 201
  }
}

///|
/// Inverse of `DataType::to_int`; `None` for values this client does not know.
pub fn DataType::from_int(value : Int) -> DataType? {
  match value {
    0 => Some(None)
    1 => Some(Bool)
    2 => Some(Int8)
    3 => Some(Int16)
    4 => Some(Int32)
    5 => Some(Int64)
    10 => Some(Float)
    11 => Some(Double)
    20 => Some(String)
    21 => Some(VarChar)
    22 => Some(Array)
    23 => Some(Json)
    24 => Some(Geometry)
    25 => Some(Text)
    26 => Some(Timestamptz)
    27 => Some(Mol)
    28 => Some(Date)
    29 => Some(Time)
    30 => Some(Decimal)
    31 => Some(Uuid)
    100 => Some(BinaryVector)
    101 => Some(FloatVector)
    102 => Some(Float16Vector)
    103 => Some(BFloat16Vector)
    104 => Some(SparseFloatVector)
    105 => Some(Int8Vector)
    106 => Some(ArrayOfVector)
    200 => Some(ArrayOfStruct)
    201 => Some(Struct)
    _ => None
  }
}

///|
/// The enum constant name, as spelled in `schema.proto`.
pub fn DataType::name(self : DataType) -> String {
  match self {
    None => "None"
    Bool => "Bool"
    Int8 => "Int8"
    Int16 => "Int16"
    Int32 => "Int32"
    Int64 => "Int64"
    Float => "Float"
    Double => "Double"
    String => "String"
    VarChar => "VarChar"
    Array => "Array"
    Json => "JSON"
    Geometry => "Geometry"
    Text => "Text"
    Timestamptz => "Timestamptz"
    Mol => "Mol"
    Date => "Date"
    Time => "Time"
    Decimal => "Decimal"
    Uuid => "UUID"
    BinaryVector => "BinaryVector"
    FloatVector => "FloatVector"
    Float16Vector => "Float16Vector"
    BFloat16Vector => "BFloat16Vector"
    SparseFloatVector => "SparseFloatVector"
    Int8Vector => "Int8Vector"
    ArrayOfVector => "ArrayOfVector"
    ArrayOfStruct => "ArrayOfStruct"
    Struct => "Struct"
  }
}

///|
/// Whether the type is any vector kind, dense or sparse.
pub fn DataType::is_vector_type(self : DataType) -> Bool {
  match self {
    BinaryVector
    | FloatVector
    | Float16Vector
    | BFloat16Vector
    | SparseFloatVector
    | Int8Vector
    | ArrayOfVector => true
    _ => false
  }
}

///|
/// Whether rows of the type have a fixed byte width derived from `dim`.
/// Sparse vectors do not: they store only the non-zero entries of each row.
pub fn DataType::is_dense_vector_type(self : DataType) -> Bool {
  match self {
    BinaryVector | FloatVector | Float16Vector | BFloat16Vector | Int8Vector =>
      true
    _ => false
  }
}

///|
/// Bytes each dimension takes for dense, non-packed vector types.
/// `None` for binary vectors (packed, 8 dimensions per byte) and for every
/// non-vector type.
pub fn DataType::vector_bytes_per_dim(self : DataType) -> Int? {
  match self {
    FloatVector => Some(4)
    Float16Vector | BFloat16Vector => Some(2)
    Int8Vector => Some(1)
    _ => None
  }
}

// `derive(Debug)` (and `derive(Eq)`) promote their trait methods to plain
// methods, which MoonBit deprecates. Pinning the promotions here keeps the
// module warning-free without dropping the derives themselves.

///|
#deprecated
pub extend DataType with Eq::{not_equal, equal}

///|
#deprecated
pub extend DataType with @debug.Debug::{to_repr}
