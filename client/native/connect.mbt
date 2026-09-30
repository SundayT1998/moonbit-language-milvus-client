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
// 把 `client` 这层的 `Unary` 接到真实 socket 上。
//
// 单独成包的唯一理由是目标平台：`moonrpc/net` 声明了
// `supported_targets = "native"`，而模块 `preferred_target = "wasm"`，
// 混进 `client/` 会让 wasm / js 直接编不过（同 Issue #11 的 R4）。
// 这里除了「建连 + 绑一下元数据」之外不做别的事。

///|
/// 建一条到 Milvus 的连接。
///
/// 失败按 `@transport.RpcError` 抛出；返回的 `Client` 可以直接拿去跑
/// `create_collection` / `insert` / `search`。
pub async fn connect(
  config : @transport.Config,
) -> (@client.Client, @channel.Client) {
  let channel = @channel.Client::connect(config)
  let call : @client.Unary = (path, body) => channel.unary(path, body)
  (@client.Client::new(config, call), channel)
}
