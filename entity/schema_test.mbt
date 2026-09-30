///|
/// A schema covering the shapes a `CreateCollection` request needs: an auto ID
/// primary key, a scalar field with a max length, a nullable field, and one
/// field of each vector kind.
fn demo_schema() -> @entity.CollectionSchema raise {
  @entity.CollectionSchema::with_auto_id_primary([
    @entity.Field::new("title", @entity.DataType::VarChar).with_max_length(512),
    @entity.Field::new("year", @entity.DataType::Int32).as_nullable(),
    @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(768),
  ])
  .with_description("demo collection")
  .with_dynamic_field(true)
}

///|
test "field defaults" {
  let field = @entity.Field::new("vector", @entity.DataType::FloatVector)
  assert_eq(field.name, "vector")
  assert_eq(field.data_type, @entity.DataType::FloatVector)
  assert_eq(field.field_id, 0L)
  assert_false(field.is_primary_key)
  assert_false(field.auto_id)
  assert_false(field.is_dynamic)
  assert_false(field.is_partition_key)
  assert_false(field.is_clustering_key)
  assert_false(field.nullable)
  assert_eq(field.element_type, None)
  assert_eq(field.dim, None)
  assert_eq(field.max_length, None)
  assert_eq(field.type_params, [])
}

///|
test "dim and max_length are reported through type_params" {
  let vector = @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(
    768,
  )
  assert_eq(vector.type_params_pairs(), [("dim", "768")])
  let text = @entity.Field::new("title", @entity.DataType::VarChar).with_max_length(
    512,
  )
  assert_eq(text.type_params_pairs(), [("max_length", "512")])
  // the pymilvus-style key pair travels alongside the explicit attributes
  let analysed = text.with_type_param("enable_analyzer", "true")
  assert_eq(analysed.type_params_pairs(), [
    ("max_length", "512"),
    ("enable_analyzer", "true"),
  ])
}

///|
test "dimension is rejected when out of range" {
  let float_vector = @entity.Field::new("v", @entity.DataType::FloatVector)
  try float_vector.with_dim(0) catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "dimension must be positive, got 0")
  } noraise {
    _ => fail("dim 0 should be rejected")
  }
  try float_vector.with_dim(1) catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "dimension must be in (1, 32768], got 1")
  } noraise {
    _ => fail("dim 1 should be rejected")
  }
  try float_vector.with_dim(32769) catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "dimension must be in (1, 32768], got 32769")
  } noraise {
    _ => fail("dim 32769 should be rejected")
  }
  assert_eq(float_vector.with_dim(32768).dim, Some(32768))
}

///|
test "binary vector dimension must be a multiple of 8" {
  let binary = @entity.Field::new("v", @entity.DataType::BinaryVector)
  try binary.with_dim(12) catch {
    @entity.SchemaError(message) =>
      assert_eq(
        message, "binary vector dimension must be a multiple of 8, got 12",
      )
  } noraise {
    _ => fail("dim 12 should be rejected for binary vectors")
  }
  assert_eq(binary.with_dim(64).dim, Some(64))
}

///|
test "max_length is only accepted on string fields" {
  let text = @entity.Field::new("t", @entity.DataType::VarChar)
  try text.with_max_length(0) catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "max_length must be positive, got 0")
  } noraise {
    _ => fail("max_length 0 should be rejected")
  }
  try
    @entity.Field::new("n", @entity.DataType::Int64).with_max_length(8)
  catch {
    @entity.SchemaError(message) =>
      assert_eq(
        message, "max_length is only valid for VarChar, Text and String fields, got Int64",
      )
  } noraise {
    _ => fail("max_length on Int64 should be rejected")
  }
}

///|
test "field validation" {
  let float_vector = @entity.Field::new("v", @entity.DataType::FloatVector)
  try float_vector.validate() catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "vector field v requires a dimension")
  } noraise {
    _ => fail("a dense vector without dim should be rejected")
  }
  let annotated = @entity.Field::new("n", @entity.DataType::Int64).with_type_param(
    "dim", "8",
  )
  annotated.validate()
  try
    @entity.Field::new("v", @entity.DataType::FloatVector)
    .with_dim(8)
    .as_auto_id()
    .validate()
  catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "auto_id is only valid on the primary key field v")
  } noraise {
    _ => fail("auto_id outside the primary key should be rejected")
  }
  try
    @entity.Field::new("p", @entity.DataType::Float)
    .as_partition_key()
    .validate()
  catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "partition key field p must be Int64 or VarChar")
  } noraise {
    _ => fail("a float partition key should be rejected")
  }
}

///|
test "the demo schema validates and exposes its fields" {
  let schema = demo_schema()
  schema.validate()
  assert_eq(schema.description, "demo collection")
  assert_true(schema.enable_dynamic_field)
  assert_eq(schema.fields.length(), 4)
  assert_eq(schema.primary_key().unwrap().name, "id")
  assert_eq(schema.field("title").unwrap().max_length, Some(512))
  assert_true(schema.field("missing") is None)
  assert_eq(schema.vector_fields().map(field => field.name), ["vector"])
}

///|
test "schema validation rejects the shapes the server rejects" {
  // no primary key
  try
    @entity.CollectionSchema::new([
      @entity.Field::new("title", @entity.DataType::VarChar),
    ]).validate()
  catch {
    @entity.SchemaError(message) =>
      assert_eq(
        message, "schema must have exactly one primary key field, got 0",
      )
  } noraise {
    _ => fail("a schema without a primary key should be rejected")
  }
  // two primary keys
  try
    @entity.CollectionSchema::new([
      @entity.Field::new("a", @entity.DataType::Int64).as_primary_key(),
      @entity.Field::new("b", @entity.DataType::Int64).as_primary_key(),
    ]).validate()
  catch {
    @entity.SchemaError(message) =>
      assert_eq(
        message, "schema must have exactly one primary key field, got 2",
      )
  } noraise {
    _ => fail("a schema with two primary keys should be rejected")
  }
  // duplicate names
  try
    @entity.CollectionSchema::new([
      @entity.Field::new("id", @entity.DataType::Int64).as_primary_key(),
      @entity.Field::new("id", @entity.DataType::Int64),
    ]).validate()
  catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "duplicate field name: id")
  } noraise {
    _ => fail("duplicate field names should be rejected")
  }
  // string primary key with auto ID
  try
    @entity.CollectionSchema::new([
      @entity.Field::new("id", @entity.DataType::VarChar)
      .as_primary_key()
      .as_auto_id(),
    ]).validate()
  catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "auto_id is not supported for VarChar primary keys")
  } noraise {
    _ => fail("an auto ID VarChar primary key should be rejected")
  }
  // non-integer primary key
  try
    @entity.CollectionSchema::new([
      @entity.Field::new("id", @entity.DataType::Float).as_primary_key(),
    ]).validate()
  catch {
    @entity.SchemaError(message) =>
      assert_eq(
        message, "primary key field id must be Int64 or VarChar, got Float",
      )
  } noraise {
    _ => fail("a float primary key should be rejected")
  }
  // empty schema
  try @entity.CollectionSchema::new([]).validate() catch {
    @entity.SchemaError(message) =>
      assert_eq(message, "schema must have at least one field")
  } noraise {
    _ => fail("an empty schema should be rejected")
  }
}

///|
/// The acceptance criterion for this module: a schema that carries everything
/// `CreateCollection`, `Insert` and `Search` need — a primary key, an
/// explicit-dimension vector, a string field with a max length and a sparse
/// vector — is built and validated without touching the wire types.
test "schema covers CreateCollection, Insert and Search needs" {
  let schema = @entity.CollectionSchema::new([
    @entity.Field::new("id", @entity.DataType::Int64)
    .as_primary_key()
    .as_auto_id(),
    @entity.Field::new("body", @entity.DataType::VarChar).with_max_length(65535),
    @entity.Field::new("dense", @entity.DataType::FloatVector).with_dim(4),
    @entity.Field::new("half", @entity.DataType::Float16Vector).with_dim(4),
    @entity.Field::new("brain", @entity.DataType::BFloat16Vector).with_dim(4),
    @entity.Field::new("binary", @entity.DataType::BinaryVector).with_dim(32),
    @entity.Field::new("sparse", @entity.DataType::SparseFloatVector),
    @entity.Field::new("label", @entity.DataType::Array).with_element_type(
      @entity.DataType::Int64,
    ),
  ])
  schema.validate()
  assert_eq(schema.vector_fields().length(), 5)
  let sparse = schema.field("sparse").unwrap()
  assert_eq(sparse.dim, None)
  assert_true(sparse.is_sparse_vector())
  assert_eq(sparse.type_params_pairs(), [])
  assert_eq(schema.field("dense").unwrap().type_params_pairs(), [("dim", "4")])
  assert_eq(schema.field("binary").unwrap().dim, Some(32))
  assert_eq(
    @entity.CollectionSchema::from_field(schema.fields[0]).fields.length(),
    1,
  )
}
