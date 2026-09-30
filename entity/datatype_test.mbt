///|
/// Every `DataType` constant as `(name, proto value)`, checked against
/// `milvus.proto.schema.DataType`. The values are wire protocol: a server
/// reads them, so a reordering of the enum is a breaking change and this table
/// is where it shows up.
let data_type_values : Array[(String, Int)] = [
  ("None", 0),
  ("Bool", 1),
  ("Int8", 2),
  ("Int16", 3),
  ("Int32", 4),
  ("Int64", 5),
  ("Float", 10),
  ("Double", 11),
  ("String", 20),
  ("VarChar", 21),
  ("Array", 22),
  ("JSON", 23),
  ("Geometry", 24),
  ("Text", 25),
  ("Timestamptz", 26),
  ("Mol", 27),
  ("Date", 28),
  ("Time", 29),
  ("Decimal", 30),
  ("UUID", 31),
  ("BinaryVector", 100),
  ("FloatVector", 101),
  ("Float16Vector", 102),
  ("BFloat16Vector", 103),
  ("SparseFloatVector", 104),
  ("Int8Vector", 105),
  ("ArrayOfVector", 106),
  ("ArrayOfStruct", 200),
  ("Struct", 201),
]

///|
test "DataType values match schema.proto" {
  for entry in data_type_values {
    let data_type = match @entity.DataType::from_int(entry.1) {
      Some(data_type) => data_type
      None => fail("no DataType for proto value \{entry.1}")
    }
    assert_eq(data_type.name(), entry.0)
    assert_eq(data_type.to_int(), entry.1)
  }
}

///|
test "DataType::to_int / from_int round-trip" {
  let data_types = data_type_values.map(entry => {
    match @entity.DataType::from_int(entry.1) {
      Some(data_type) => data_type
      None => fail("no DataType for proto value \{entry.1}")
    }
  })
  assert_eq(data_types.length(), 29)
  for data_type in data_types {
    assert_eq(@entity.DataType::from_int(data_type.to_int()), Some(data_type))
  }
}

///|
test "DataType::from_int rejects unknown values" {
  assert_eq(@entity.DataType::from_int(6), None)
  assert_eq(@entity.DataType::from_int(99), None)
  assert_eq(@entity.DataType::from_int(-1), None)
  assert_eq(@entity.DataType::from_int(999), None)
}

///|
test "DataType::name is unambiguous" {
  let names = []
  for entry in data_type_values {
    names.push(entry.0)
  }
  let unique = Map([])
  for name in names {
    assert_false(unique.contains(name))
    unique[name] = ()
  }
}

///|
test "vector type predicates" {
  let vectors = [
    @entity.DataType::BinaryVector,
    @entity.DataType::FloatVector,
    @entity.DataType::Float16Vector,
    @entity.DataType::BFloat16Vector,
    @entity.DataType::SparseFloatVector,
    @entity.DataType::Int8Vector,
    @entity.DataType::ArrayOfVector,
  ]
  let scalars = [
    @entity.DataType::None,
    @entity.DataType::Bool,
    @entity.DataType::Int64,
    @entity.DataType::Float,
    @entity.DataType::VarChar,
    @entity.DataType::Json,
    @entity.DataType::Array,
    @entity.DataType::ArrayOfStruct,
    @entity.DataType::Struct,
  ]
  for data_type in vectors {
    assert_true(data_type.is_vector_type())
  }
  for data_type in scalars {
    assert_false(data_type.is_vector_type())
  }
  for data_type in vectors {
    let dense = data_type.is_dense_vector_type()
    assert_eq(
      dense,
      data_type != @entity.DataType::SparseFloatVector &&
      data_type != @entity.DataType::ArrayOfVector,
    )
  }
}

///|
test "vector_bytes_per_dim matches the storage widths" {
  assert_eq(@entity.DataType::FloatVector.vector_bytes_per_dim(), Some(4))
  assert_eq(@entity.DataType::Float16Vector.vector_bytes_per_dim(), Some(2))
  assert_eq(@entity.DataType::BFloat16Vector.vector_bytes_per_dim(), Some(2))
  assert_eq(@entity.DataType::Int8Vector.vector_bytes_per_dim(), Some(1))
  assert_eq(@entity.DataType::BinaryVector.vector_bytes_per_dim(), None)
  assert_eq(@entity.DataType::SparseFloatVector.vector_bytes_per_dim(), None)
  assert_eq(@entity.DataType::Int64.vector_bytes_per_dim(), None)
}
