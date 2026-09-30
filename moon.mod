// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "SundayT1998/milvus-client"

version = "0.1.0"

readme = "README.mbt.md"

repository = "https://github.com/SundayT1998/moonbit-language-milvus-client"

license = "Apache-2.0"

warnings = "-implicit_impl_as_method"

preferred_target = "wasm"

description = "Milvus vector database client for MoonBit"

import {
  "moonbitstack/moonrpc@0.19.3",
  "moonbitstack/moonhttp@0.12.1",
  "moonbitlang/async@0.20.3",
  "moonbitlang/protobuf@0.1.3",
}
