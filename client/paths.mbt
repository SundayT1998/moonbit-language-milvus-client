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
// gRPC 方法路径。服务名与上游 `milvuspb.MilvusService` 的
// `_MilvusService_serviceDesc.ServiceName` 一致，方法名大小写照搬
// `client/milvusclient` 各调用点的 `MilvusServiceClient.<Method>`。

///|
/// Milvus 的 gRPC 服务全名。
pub let service_name : String = "milvus.proto.milvus.MilvusService"

///|
fn method_path(rpc : String) -> String {
  "/" + service_name + "/" + rpc
}

///|
pub let create_collection_path : String = method_path("CreateCollection")

///|
pub let drop_collection_path : String = method_path("DropCollection")

///|
pub let has_collection_path : String = method_path("HasCollection")

///|
pub let describe_collection_path : String = method_path("DescribeCollection")

///|
pub let load_collection_path : String = method_path("LoadCollection")

///|
pub let release_collection_path : String = method_path("ReleaseCollection")

///|
pub let get_load_state_path : String = method_path("GetLoadState")

///|
pub let create_index_path : String = method_path("CreateIndex")

///|
pub let describe_index_path : String = method_path("DescribeIndex")

///|
pub let drop_index_path : String = method_path("DropIndex")

///|
pub let show_collections_path : String = method_path("ShowCollections")

///|
pub let insert_path : String = method_path("Insert")

///|
pub let upsert_path : String = method_path("Upsert")

///|
pub let delete_path : String = method_path("Delete")

///|
pub let search_path : String = method_path("Search")

///|
pub let query_path : String = method_path("Query")
