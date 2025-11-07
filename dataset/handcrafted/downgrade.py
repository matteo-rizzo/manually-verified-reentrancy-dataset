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
            content = re.sub(r"pragma solidity \^0\.8\.20;", "pragma solidity ^0.5.0;", content)
                        # 2. Rewrite call syntax: target.call{value:amt}("") -> target.call.value(amt)("")
            content = re.sub(
                r'(\.call)\{value:\s*([A-Za-z0-9]+)\,\s*gas:\s*([A-Za-z0-9]+)\}',
                r'\1.value(\2).gas(\3)',
                content
            )
            content = re.sub(
                r'(\.call)\{value:\s*([A-Za-z0-9]+)\}',
                r'\1.value(\2)',
                content
            )
            content = re.sub(r"payable\(", "(", content)
            content = re.sub(r"receive", "function", content)

            content = re.sub(r"virtual", "", content)
            content = re.sub(r"override", "", content)
            content = re.sub(r"immutable", "", content)

            content = re.sub(r'(\bconstructor\s*\([^)]*\)\s*(payable)?)', r'\1 public ', content)
            #content = re.sub(r'\bunchecked\s*\{([^}]*)\s*\}', r'\1', content)



            with open(dst_file, "w") as f:
                f.write(content)




import shutil

underflow_dir = os.path.join(dst_root, "always-safe", "underflow")

if os.path.exists(underflow_dir):
    for file in os.listdir(underflow_dir):
        file_path = os.path.join(underflow_dir, file)

        if file in ["Underflow_ree1.sol", "CrossUnderflow_ree1.sol"]:
            print(f"Removing {file_path}")
            os.remove(file_path)

        elif file == "Underflow_safe1.sol":
            dst = os.path.join(
                dst_root,
                "single-function",
                "low-level-call",
                "to-sender",
                "baseline",
                file
            )
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            print(f"Moving {file_path} -> {dst}")
            shutil.move(file_path, dst)

        elif file == "CrossUnderflow_safe1.sol":
            dst = os.path.join(dst_root, "cross-function", "baseline", file)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            print(f"Moving {file_path} -> {dst}")
            shutil.move(file_path, dst)

        elif file == "Underflow_safe2.sol":
            new_name = file.replace("safe2", "ree1")
            dst = os.path.join(
                dst_root,
                "single-function",
                "low-level-call",
                "to-sender",
                "baseline",
                new_name
            )
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            print(f"Renaming and moving {file_path} -> {dst}")
            shutil.move(file_path, dst)

        elif file == "CrossUnderflow_safe2.sol":
            new_name = file.replace("safe2", "ree1")
            dst = os.path.join(dst_root, "cross-function", "baseline", new_name)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            print(f"Renaming and moving {file_path} -> {dst}")
            shutil.move(file_path, dst)

    print(f"Removing folder {underflow_dir}")
    shutil.rmtree(underflow_dir)
