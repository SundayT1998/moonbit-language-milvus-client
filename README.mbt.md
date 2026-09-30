# Tangbuting/milvus-client

MoonBit client for [Milvus](https://milvus.io/) vector database.

## 当前状态

传输层（Issue #11）已打通：能对真实 Milvus 建立 gRPC channel、
注入认证与 dbName、按超时控制调用。业务 RPC（collection / search / insert 等）
尚未实现，见 #5 的规划。

## 分层

```
transport/          配置、metadata 组装、gRPC status —— 跨 target（wasm / wasm-gc / js / native）
transport/native/   真连 socket 的 Channel 实现 —— native 专属
```

为什么要拆开：传输实现依赖 `moonbitstack/moonrpc/net`，
而它自己声明了 `supported_targets = "native"`。
模块的 `preferred_target = "wasm"` 与之冲突，
混在一个包里会让 wasm / js 直接编不过。
拆开后，wasm 下拿到的是可用的配置与错误类型，缺的只是「谁来发字节」。

详见下面「已知限制」一节。

## 用法

```moonbit nocheck
// 配置（跨 target）

///|
let cfg = @milvus_client.with_address("127.0.0.1:19530")
  |> @milvus_client.with_token("root:Milvus")
  |> @milvus_client.with_db_name("default")
  |> @milvus_client.with_timeout_millis(5000)
```

native 下发起调用：

```moonbit nocheck
///|
async fn demo() -> Unit raise @transport.RpcError {
  let cfg = @transport.Config::new("127.0.0.1:19530")
    .with_token("root:Milvus")
    .with_db_name("default")
    .with_timeout_millis(5000)
  let client = @native.Client::connect(cfg)
  let reply = client.unary(
    "/milvus.proto.milvus.MilvusService/DescribeCollection", body,
  )
  client.close()
  ignore(reply)
}
```

判断失败是不是超时：

```moonbit nocheck
match ... {
  // ...
} catch {
  err => if err.is_deadline_exceeded() { /* 超时 */ }
}
```

自检程序（连上后发一次 Health/Check）：

```sh
moon run cmd/main -- 127.0.0.1:19530 root:Milvus default
```

## 已知限制

### 1. `moonrpc/net` 只支持 native

`moonbitstack/moonrpc@0.19.3` 的 `net` 包声明了
`supported_targets = "native"`，而它的其他包（pure 的 HTTP/2 / HPACK /
protobuf 线段）是跨 target 的。

本项目的 `preferred_target = "wasm"` 因此和「用 moonrpc 发请求」直接冲突。

当前选择：**保留 `preferred_target = "wasm"`，把 native 实现隔离到
`transport/native/`**。理由是本仓库已花力气做了 proto 生成与裁剪（见
`proto/REPORT.md`），而生成物本身是跨 target 的；直接改成
`preferred_target = "native"` 会丢掉 wasm 侧的可能性，代价大于收益。

若将来 moonrpc 补齐 wasm 的 socket 后端，删掉 `transport/native/` 的
`supported_targets` 声明即可，上层 API 不用动。

### 2. `grpc-encoding` 请求侧不支持

`moonrpc` 的请求侧不会压缩 body（`encode_message` 只处理响应侧的解压），
且它在收集响应头时会把 `grpc-encoding` 当保留头过滤掉。
所以 `Config::with_gzip` **只声明 `grpc-accept-encoding: gzip`**，
声明自己不做请求压缩 —— 这样服务端可以压响应，而不会期待一个
不存在的请求压缩。

### 3. 超时是「客户端本地计时 + `grpc-timeout` 头」双保险

客户端在本地超时后会发 `RST_STREAM(CANCEL)` 并合成一个
`DEADLINE_EXCEEDED` 的回复，不等服务端回应。
服务端侧看到的 `grpc-timeout` 也真实带上了（见测试）。
