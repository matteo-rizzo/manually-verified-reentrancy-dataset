import os
import re

src_root = "handcrafted/0_8"
dst_root = "handcrafted/0_5"

for dirpath, dirnames, filenames in os.walk(src_root):
    rel_path = os.path.relpath(dirpath, src_root)
    dst_dir = os.path.join(dst_root, rel_path)
    os.makedirs(dst_dir, exist_ok=True)

    for file in filenames:
        if file.endswith(".sol"):
            src_file = os.path.join(dirpath, file)
            dst_file = os.path.join(dst_dir, file)

            with open(src_file, "r") as f:
                content = f.read()

            # Modifica minima: pragma
            content = re.sub(r"pragma solidity \^0\.8\.0;", "pragma solidity ^0.5.0;", content)
                        # 2. Rewrite call syntax: target.call{value:amt}("") -> target.call.value(amt)("")
            content = re.sub(
                r'(\.call)\{value:\s*([^\}]+)\}',
                r'\1.value(\2)',
                content
            )
            content = re.sub(r"payable", "", content)

            with open(dst_file, "w") as f:
                f.write(content)
