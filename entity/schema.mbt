///|
/// Errors raised when a collection schema is malformed.
///
/// The message text is the observable behaviour of this module, so it is
/// phrased after the pymilvus wording where the two check the same thing.
pub(all) suberror SchemaError {
  SchemaError(String)
} derive(Eq, Debug)

///|
/// Key of the `dim` entry written into `type_params`.
pub let dim_key : String = "dim"

///|
/// Key of the `max_length` entry written into `type_params`.
pub let max_length_key : String = "max_length"

///|
/// One field of a collection schema.
///
/// `dim` and `max_length` are not `FieldSchema` fields in `schema.proto`;
/// the server reads them out of `type_params`, which is why they are kept
/// here as keys plus an escape hatch (`type_params`) for the remaining
/// entries such as `enable_analyzer`.
pub(all) struct Field {
  name : String
  data_type : DataType
  field_id : Int64
  is_primary_key : Bool
  auto_id : Bool
  description : String
  is_dynamic : Bool
  is_partition_key : Bool
  is_clustering_key : Bool
  nullable : Bool
  element_type : DataType?
  dim : Int?
  max_length : Int?
  type_params : Array[(String, String)]
} derive(Debug)

///|
/// A field with no optional attribute set: not a primary key, not auto ID,
/// not dynamic, not nullable, no dimension and no max length.
pub fn Field::new(name : String, data_type : DataType) -> Field {
  {
    name,
    data_type,
    field_id: 0L,
    is_primary_key: false,
    auto_id: false,
    description: "",
    is_dynamic: false,
    is_partition_key: false,
    is_clustering_key: false,
    nullable: false,
    element_type: None,
    dim: None,
    max_length: None,
    type_params: [],
  }
}

///|
/// Rejects a dimension the server would reject, so that a bad schema fails
/// locally instead of coming back as an opaque gRPC error.
fn check_dim(data_type : DataType, dim : Int) -> Unit raise SchemaError {
  if dim <= 0 {
    raise SchemaError("dimension must be positive, got \{dim}")
  }
  match data_type {
    FloatVector | Float16Vector | BFloat16Vector | Int8Vector =>
      if dim <= 1 || dim > 32768 {
        raise SchemaError("dimension must be in (1, 32768], got \{dim}")
      }
    BinaryVector =>
      if dim % 8 != 0 {
        raise SchemaError(
          "binary vector dimension must be a multiple of 8, got \{dim}",
        )
      }
    _ => ()
  }
}

///|
/// Sets the dimension of a vector field.
pub fn Field::with_dim(self : Field, dim : Int) -> Field raise SchemaError {
  check_dim(self.data_type, dim)
  { ..self, dim: Some(dim), }
}

///|
/// Sets the maximum length of a `VarChar` (or `Text`) field.
pub fn Field::with_max_length(
  self : Field,
  max_length : Int,
) -> Field raise SchemaError {
  if max_length <= 0 {
    raise SchemaError("max_length must be positive, got \{max_length}")
  }
  if self.data_type != VarChar &&
    self.data_type != String &&
    self.data_type != Text {
    raise SchemaError(
      "max_length is only valid for VarChar, Text and String fields, got \{self.data_type.name()}",
    )
  }
  { ..self, max_length: Some(max_length), }
}

///|
/// Adds an arbitrary `type_params` entry, e.g. `enable_analyzer=true`.
pub fn Field::with_type_param(
  self : Field,
  key : String,
  value : String,
) -> Field {
  { ..self, type_params: self.type_params + [(key, value)], }
}

///|
/// Marks the field as the collection's primary key.
pub fn Field::as_primary_key(self : Field) -> Field {
  { ..self, is_primary_key: true, }
}

///|
/// Enables server-side ID generation for a primary key field.
pub fn Field::as_auto_id(self : Field) -> Field {
  { ..self, auto_id: true, }
}

///|
/// Allows null values for the field.
pub fn Field::as_nullable(self : Field) -> Field {
  { ..self, nullable: true, }
}

///|
/// Enables logic partitions on the field.
pub fn Field::as_partition_key(self : Field) -> Field {
  { ..self, is_partition_key: true, }
}

///|
/// Sets the element type of an `Array` field.
pub fn Field::with_element_type(self : Field, element_type : DataType) -> Field {
  { ..self, element_type: Some(element_type), }
}

///|
/// The `type_params` entries `schema.proto` expects for this field: the
/// dimension for vectors, the max length for string fields.
pub fn Field::type_params_pairs(self : Field) -> Array[(String, String)] {
  let pairs = []
  match self.dim {
    Some(dim) => pairs.push((dim_key, dim.to_string()))
    None => ()
  }
  match self.max_length {
    Some(max_length) => pairs.push((max_length_key, max_length.to_string()))
    None => ()
  }
  pairs + self.type_params
}

///|
/// Whether the field is a sparse float vector field, which is the one vector
/// kind that has no dimension.
pub fn Field::is_sparse_vector(self : Field) -> Bool {
  self.data_type == SparseFloatVector
}

///|
/// Validates one field: a dimension on every dense vector field and on none
/// of the others, an auto ID only on the primary key, and a partition key
/// only on an `Int64` or `VarChar` field.
pub fn Field::validate(self : Field) -> Unit raise SchemaError {
  if self.data_type.is_dense_vector_type() {
    match self.dim {
      Some(_) => ()
      None =>
        raise SchemaError("vector field \{self.name} requires a dimension")
    }
  } else {
    match self.dim {
      Some(_) =>
        if self.data_type != SparseFloatVector &&
          self.data_type != ArrayOfVector {
          raise SchemaError(
            "dimension is only valid for vector fields, but \{self.name} is \{self.data_type.name()}",
          )
        }
      None => ()
    }
  }
  if self.auto_id && !self.is_primary_key {
    raise SchemaError(
      "auto_id is only valid on the primary key field \{self.name}",
    )
  }
  if self.is_partition_key &&
    self.data_type != Int64 &&
    self.data_type != VarChar {
    raise SchemaError(
      "partition key field \{self.name} must be Int64 or VarChar",
    )
  }
}

///|
/// A collection schema: the fields plus the collection-level description and
/// the `enable_dynamic_field` switch from `CollectionSchema` in
/// `schema.proto`.
pub(all) struct CollectionSchema {
  fields : Array[Field]
  description : String
  enable_dynamic_field : Bool
} derive(Debug)

///|
/// A schema with the given fields, no dynamic field.
pub fn CollectionSchema::new(fields : Array[Field]) -> CollectionSchema {
  { fields, description: "", enable_dynamic_field: false, }
}

///|
/// A schema with a single field, for the common one-field case.
pub fn CollectionSchema::from_field(field : Field) -> CollectionSchema {
  { fields: [field], description: "", enable_dynamic_field: false, }
}

///|
/// Sets the collection description.
pub fn CollectionSchema::with_description(
  self : CollectionSchema,
  description : String,
) -> CollectionSchema {
  { ..self, description, }
}

///|
/// Enables or disables the `$meta` dynamic field.
pub fn CollectionSchema::with_dynamic_field(
  self : CollectionSchema,
  enabled : Bool,
) -> CollectionSchema {
  { ..self, enable_dynamic_field: enabled, }
}

///|
/// Appends a field.
pub fn CollectionSchema::with_field(
  self : CollectionSchema,
  field : Field,
) -> CollectionSchema {
  { ..self, fields: self.fields + [field], }
}

///|
/// The field with the given name, if any.
pub fn CollectionSchema::field(
  self : CollectionSchema,
  name : String,
) -> Field? {
  for field in self.fields {
    if field.name == name {
      return Some(field)
    }
  }
  None
}

///|
/// The primary key field, if the schema declares one.
pub fn CollectionSchema::primary_key(self : CollectionSchema) -> Field? {
  for field in self.fields {
    if field.is_primary_key {
      return Some(field)
    }
  }
  None
}

///|
/// All vector fields, in declaration order.
pub fn CollectionSchema::vector_fields(self : CollectionSchema) -> Array[Field] {
  self.fields.filter(field => field.data_type.is_vector_type())
}

///|
/// Validates the whole schema: at least one field, exactly one primary key of
/// an auto-ID-capable type, no duplicate names, and every field individually
/// valid.
pub fn CollectionSchema::validate(
  self : CollectionSchema,
) -> Unit raise SchemaError {
  if self.fields.is_empty() {
    raise SchemaError("schema must have at least one field")
  }
  let mut primary_keys = 0
  for field in self.fields {
    if field.is_primary_key {
      primary_keys = primary_keys + 1
    }
  }
  if primary_keys != 1 {
    raise SchemaError(
      "schema must have exactly one primary key field, got \{primary_keys}",
    )
  }
  let seen : Map[String, Unit] = Map([])
  for field in self.fields {
    if seen.contains(field.name) {
      raise SchemaError("duplicate field name: \{field.name}")
    }
    seen[field.name] = ()
    field.validate()
  }
  match self.primary_key() {
    Some(pk) =>
      match pk.data_type {
        Int64 => ()
        VarChar =>
          if pk.auto_id {
            raise SchemaError(
              "auto_id is not supported for VarChar primary keys",
            )
          }
        _ =>
          raise SchemaError(
            "primary key field \{pk.name} must be Int64 or VarChar, got \{pk.data_type.name()}",
          )
      }
    None => ()
  }
}

///|
/// A schema with one auto ID `Int64` primary key named `id`, plus the given
/// fields. This is the shape most examples use.
pub fn CollectionSchema::with_auto_id_primary(
  fields : Array[Field],
) -> CollectionSchema {
  let id = Field::new("id", Int64).as_primary_key().as_auto_id()
  CollectionSchema::new([id] + fields)
}

///|

// `derive(Debug)` (and `derive(Eq)`) promote their trait methods to plain
// methods, which MoonBit deprecates. Pinning the promotions here keeps the
// module warning-free without dropping the derives themselves.

///|
#deprecated
pub extend SchemaError with Eq::{not_equal, equal}

///|
#deprecated
pub extend SchemaError with @debug.Debug::{to_repr}

///|
#deprecated
pub extend Field with @debug.Debug::{to_repr}

///|
#deprecated
pub extend CollectionSchema with @debug.Debug::{to_repr}
