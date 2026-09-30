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
// 移植自 milvus-io/milvus client/milvusclient/{partition.go,
// partition_options.go}（Apache-2.0）。
//
// 上游 `ListPartitions` 走的是 `ShowPartitions`（Show 系列），`HasPartition`
// 返回 `BoolResponse` 而不是 old-style 的 `common.Status`——两处都照抄，
// 不为了「统一」去换 RPC，换了就与服务端的鉴权对象对不上。

///|
/// 建分区的入参。对应上游 `createPartitionOpt`。
pub(all) struct CreatePartitionOption {
  collection_name : String
  partition_name : String
}

///|
pub fn new_create_partition_option(
  collection_name : String,
  partition_name : String,
) -> CreatePartitionOption {
  { collection_name, partition_name, }
}

///|
/// 建一个分区。分区是集合内的写入分组，检索时可按 `partition_names` 收窄。
pub async fn Client::create_partition(
  self : Client,
  option : CreatePartitionOption,
) -> Unit raise ClientError {
  let request = @milvus.CreatePartitionRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_name: option.partition_name,
  }
  let response : @common.Status = self.call_service(
    create_partition_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 删分区的入参。
pub(all) struct DropPartitionOption {
  collection_name : String
  partition_name : String
}

///|
pub fn new_drop_partition_option(
  collection_name : String,
  partition_name : String,
) -> DropPartitionOption {
  { collection_name, partition_name, }
}

///|
/// 删分区，连带里面的数据一起删。这是不可逆的。
pub async fn Client::drop_partition(
  self : Client,
  option : DropPartitionOption,
) -> Unit raise ClientError {
  let request = @milvus.DropPartitionRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_name: option.partition_name,
  }
  let response : @common.Status = self.call_service(
    drop_partition_path, request,
  )
  match check_status(Some(response)) {
    Some(err) => raise err
    None => ()
  }
}

///|
/// 查分区是否存在的入参。
pub(all) struct HasPartitionOption {
  collection_name : String
  partition_name : String
}

///|
pub fn new_has_partition_option(
  collection_name : String,
  partition_name : String,
) -> HasPartitionOption {
  { collection_name, partition_name, }
}

///|
/// 分区是否存在。
///
/// 与 `HasCollection` 不同，上游这里用的是真 `HasPartition` RPC
/// （返回 `BoolResponse`），不是「Describe 然后接 not-found」。
pub async fn Client::has_partition(
  self : Client,
  option : HasPartitionOption,
) -> Bool raise ClientError {
  let request = @milvus.HasPartitionRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    partition_name: option.partition_name,
  }
  let response : @milvus.BoolResponse = self.call_service(
    has_partition_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => response.value
  }
}

///|
/// 列分区的入参。上游就一个集合名，`type` 固定 `All`。
pub(all) struct ListPartitionsOption {
  collection_name : String
}

///|
pub fn new_list_partitions_option(
  collection_name : String,
) -> ListPartitionsOption {
  { collection_name, }
}

///|
/// 列出集合的全部分区名，含默认分区 `_default`。
pub async fn Client::list_partitions(
  self : Client,
  option : ListPartitionsOption,
) -> Array[String] raise ClientError {
  let request = @milvus.ShowPartitionsRequest::{
    base: None,
    db_name: "",
    collection_name: option.collection_name,
    collection_id: 0L,
    partition_names: [],
    type_: @milvus.ShowType::All,
  }
  let response : @milvus.ShowPartitionsResponse = self.call_service(
    show_partitions_path, request,
  )
  match check_status(response.status) {
    Some(err) => raise err
    None => response.partition_names
  }
}
