#!/usr/bin/env python3
"""修 protoc-gen-mbt 对 `repeated bytes` 字段 JSON 编码的漏判。

生成器把

    repeated bytes data = 1;

编成

    json["data"] = @lib.base64_encode(self.data).to_json()

而 `base64_encode(Bytes) -> String` 收不下 `Array[Bytes]`，编译不过。
（见 proto/REPORT.md 第 4 节 Bug #1。）这里在生成后按*字段声明*判定：
结构体里该字段写成 `Array[Bytes]` 才补 `map(@lib.base64_encode)`，
`Bytes` 字段保持原样。是文本补丁，不是语义重写，所以宁可漏判题：
只在“`pub(all) struct X { ... mut f : Array[Bytes] ... }` 且文件里出现
`@lib.base64_encode(self.f).to_json()`”两条同时成立时改。
"""

import re
import sys
from pathlib import Path

STRUCT = re.compile(r"pub\(all\) struct\s+(\w+)\s*\{(.*?)\n\}", re.S)
FIELD = re.compile(r"mut\s+(\w+)\s*:\s*Array\[Bytes\]")
CALL = "@lib.base64_encode(self.{field}).to_json()"


def patch_file(path: Path) -> int:
    text = path.read_text()
    changed = 0
    for struct in STRUCT.finditer(text):
        for field in FIELD.finditer(struct.group(2)):
            name = field.group(1)
            call = CALL.format(field=name)
            if call in text:
                text = text.replace(
                    call, f"self.{name}.map(@lib.base64_encode).to_json()"
                )
                changed += 1
    if changed:
        path.write_text(text)
    return changed


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    total = 0
    for path in sorted(root.rglob("*.mbt")):
        total += patch_file(path)
    print(f"patched {total} repeated-bytes JSON site(s) under {root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
