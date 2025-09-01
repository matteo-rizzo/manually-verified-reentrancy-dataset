import os
import re

src_root = "0_8"
dst_root = "0_5"

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
                r'(\.call)\{value:\s*([A-Za-z0-9]+)\,\s*gas:\s*([A-Za-z0-9]+)\}',
                r'\1.value(\2).gas(\3)',
                content
            )
            content = re.sub(
                r'(\.call)\{value:\s*([^A-Za-z0-9]+)\}',
                r'\1.value(\2)',
                content
            )
            content = re.sub(r"payable\(", "(", content)
            content = re.sub(r"receive", "function", content)

            content = re.sub(r"virtual", "", content)
            content = re.sub(r"override", "", content)

            content = re.sub(r'(\bconstructor\s*\([^)]*\))\s*(?={)', r'\1 public ',content)
            #content = re.sub(r'\bunchecked\s*\{([^}]*)\s*\}', r'\1', content)



            with open(dst_file, "w") as f:
                f.write(content)
