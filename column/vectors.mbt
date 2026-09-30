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
// 向量列的取数。上游 `columns.go` 里每种向量各写一段几乎一样的循环
// （`data[i*dim:(i+1)*dim]` 那套），这里先收成两个公共函数：
// 按固定行宽切、按紧凑/行满布局圈范围，再让每种向量各出一个薄包装。

///|
/// 一圈范围：给定行宽 `width` 和扁平 payload，返回 `[begin, end)` 逻辑行
/// 对应的、每行 `width` 个元素的数组。
///
/// 上游对可空向量一律按**紧凑**布局处理（`sparseMode = true`：`valid_data`
/// 一行一个，payload 只放有效行）。这里两种情况都认：
/// - `payload_len == logical_len * width`：行满，直接切。
/// - `payload_len == valid_count * width`：紧凑，null 行不占位。
/// 两种都对得上时以行满为准，因为那样逻辑下标就是物理下标，没有歧义。
fn[T] split_rows(
  field_name : String,
  payload : Array[T],
  width : Int,
  valid : Array[Bool],
  begin : Int,
  end : Int,
) -> Array[Array[T]] raise ColumnError {
  if width <= 0 {
    raise MalformedPayload(
      "vector field \{field_name} has invalid row width \{width}",
    )
  }
  if payload.length() % width != 0 {
    raise MalformedPayload(
      "vector field \{field_name} payload has \{payload.length()} values, not a multiple of row width \{width}",
    )
  }
  let rows_in_payload = payload.length() / width
  // 非空列：行数就是 payload 能切出多少行，与 valid 无关。
  // 可空列：逻辑行数以 valid 为准（行满）或等于有效数（紧凑）。
  let logical = if valid.is_empty() { rows_in_payload } else { valid.length() }
  check_range(field_name, begin, end, logical)
  let e = normalize_end(end, logical)
  let b = clamp_begin(begin, logical)
  if valid.is_empty() || rows_in_payload == logical {
    let out : Array[Array[T]] = []
    for i = b; i < e; i = i + 1 {
      out.push(payload[i * width:(i + 1) * width].to_owned())
    }
    return out
  }
  let (_, _, valid_count) = count_valid_bounds(valid, begin, e)
  if rows_in_payload != valid_count {
    raise MalformedPayload(
      "vector field \{field_name} compact payload has \{rows_in_payload} rows but \{valid_count} valid rows",
    )
  }
  // 紧凑：把逻辑行映射到物理行。null 行给一个空数组占位，长度在
  // `Column::get` 里由 valid 挡住，不会读到。
  let physical : Array[Int] = []
  let mut next = 0
  for is_valid in valid {
    if is_valid {
      physical.push(next)
      next = next + 1
    } else {
      physical.push(-1)
    }
  }
  let out : Array[Array[T]] = []
  for i = b; i < e; i = i + 1 {
    let p = physical[i]
    if p < 0 {
      out.push([])
    } else {
      out.push(payload[p * width:(p + 1) * width].to_owned())
    }
  }
  out
}

///|
/// `FloatVector`：`float32` 数组，行宽就是 `dim`。
fn vector_float_rows(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> (Int, Array[Array[Float]]) raise ColumnError {
  let v = vector_payload(field, "float_vector")
  let dim = v.dim.to_int()
  match v.data {
    @schema.VectorField_Data::FloatVector(a) =>
      (dim, split_rows(field.field_name, a.data, dim, valid, begin, end))
    _ => raise missing_vector(field, "not float_vector")
  }
}

///|
/// `Float16Vector`：线上是每维 2 字节的小端半精度，按 IEEE-754 binary16
/// 解回 `Float`。行宽是 `dim * 2` 字节。
fn vector_float16_rows(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> (Int, Array[Array[Float]]) raise ColumnError {
  let v = vector_payload(field, "float16_vector")
  let dim = v.dim.to_int()
  match v.data {
    @schema.VectorField_Data::Float16Vector(bytes) => {
      let values = float16_bytes_to_floats(field.field_name, bytes)
      (dim, split_rows(field.field_name, values, dim, valid, begin, end))
    }
    _ => raise missing_vector(field, "not float16_vector")
  }
}

///|
/// `BFloat16Vector`：每维 2 字节小端。
fn vector_bfloat16_rows(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> (Int, Array[Array[Float]]) raise ColumnError {
  let v = vector_payload(field, "bfloat16_vector")
  let dim = v.dim.to_int()
  match v.data {
    @schema.VectorField_Data::Bfloat16Vector(bytes) => {
      let values = bfloat16_bytes_to_floats(field.field_name, bytes)
      (dim, split_rows(field.field_name, values, dim, valid, begin, end))
    }
    _ => raise missing_vector(field, "not bfloat16_vector")
  }
}

///|
/// `BinaryVector`：`dim` 位打包，行宽 `dim / 8` 字节。`dim` 必为 8 的
/// 倍数，不是就是坏负载——上游 `parseVectorArrayData` 同样检查。
fn vector_binary_rows(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> (Int, Array[Bytes]) raise ColumnError {
  let v = vector_payload(field, "binary_vector")
  let dim = v.dim.to_int()
  if dim % 8 != 0 {
    raise MalformedPayload(
      "binary vector field \{field.field_name} requires dim a multiple of 8, got \{dim}",
    )
  }
  match v.data {
    @schema.VectorField_Data::BinaryVector(bytes) =>
      (dim, split_bytes(field.field_name, bytes, dim / 8, valid, begin, end))
    _ => raise missing_vector(field, "not binary_vector")
  }
}

///|
/// `Int8Vector`：有符号字节，行宽就是 `dim`。
fn vector_int8_rows(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> (Int, Array[Bytes]) raise ColumnError {
  let v = vector_payload(field, "int8_vector")
  let dim = v.dim.to_int()
  match v.data {
    @schema.VectorField_Data::Int8Vector(bytes) =>
      (dim, split_bytes(field.field_name, bytes, dim, valid, begin, end))
    _ => raise missing_vector(field, "not int8_vector")
  }
}

///|
/// 字节 payload 的按行切分。`Bytes` 没有 `map`/切片成 `Array` 那么顺手，
/// 先展开成 `Array[Int]` 再走 `split_rows`，最后每行收成 `Bytes`。
///
/// 这条路多一次拷贝，但字节向量列的行宽固定且不大，换来与数值向量共用
/// 一套范围/布局逻辑，值得。
fn split_bytes(
  field_name : String,
  bytes : Bytes,
  width : Int,
  valid : Array[Bool],
  begin : Int,
  end : Int,
) -> Array[Bytes] raise ColumnError {
  let flat : Array[Int] = []
  for i = 0; i < bytes.length(); i = i + 1 {
    flat.push(bytes[i].to_int())
  }
  let rows = split_rows(field_name, flat, width, valid, begin, end)
  rows.map(row => Bytes::from_array(row.map(v => v.to_byte())))
}

///|
/// `SparseFloatVector`：每个有效行是一段 `(uint32 index, float32 value)` 对
/// 的小端字节。解回 `@entity.SparseFloatVector` 后交给列。
fn sparse_rows(
  field : @schema.FieldData,
  begin : Int,
  end : Int,
  valid : Array[Bool],
) -> Array[@entity.SparseFloatVector] raise ColumnError {
  let v = vector_payload(field, "sparse_float_vector")
  match v.data {
    @schema.VectorField_Data::SparseFloatVector(s) => {
      let rows : Array[@entity.SparseFloatVector] = []
      for content in s.contents {
        let row = @entity.SparseFloatVector::from_bytes(content) catch {
          @entity.SchemaError(message) =>
            raise MalformedPayload(
              "sparse vector field \{field.field_name}: \{message}",
            )
        }
        rows.push(row)
      }
      let logical = logical_len(rows.length(), valid)
      check_range(field.field_name, begin, end, logical)
      let e = normalize_end(end, logical)
      let b = clamp_begin(begin, logical)
      rows[b:e].to_owned()
    }
    _ => raise missing_vector(field, "not sparse_float_vector")
  }
}
