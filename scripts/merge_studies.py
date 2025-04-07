import os
import shutil
import time
from pathlib import Path


def merge_solidity_files(input_dirs, log_dir="../logs", label=""):
    timestamp = int(time.time())
    merged_dir = os.path.join(log_dir, f"merged_{label}_{timestamp}")
    os.makedirs(merged_dir, exist_ok=True)

    for input_dir in input_dirs:
        input_dir_path = Path(input_dir)
        if not input_dir_path.is_dir():
            print(f"Skipping non-directory: {input_dir}")
            continue

        suffix = str(input_dir_path).split(os.sep)[-2]

        for sol_file in input_dir_path.rglob("*.sol"):
            if not sol_file.is_file():
                continue

            contract_address = str(sol_file).split(os.sep)[-1].split(".")[0].split("_")[0]

            new_name = f"{contract_address}_{suffix}.sol"
            destination = Path(merged_dir) / new_name

            try:
                shutil.copy(sol_file, destination)
                print(f"Copied {sol_file} to {destination}")
            except Exception as e:
                print(f"Error copying {sol_file}: {e}")

    print(f"Merged files saved to: {merged_dir}")


if __name__ == "__main__":
    merge_solidity_files(
        input_dirs=[
            "../dataset/raw/studies/cgt/reentrant",
            "../dataset/raw/studies/hg/reentrant",
            "../dataset/raw/studies/rs/reentrant",
        ],
        label="reentrant"
    )

    merge_solidity_files(
        input_dirs=[
            "../dataset/raw/studies/rs/safe"
        ],
        label="safe"
    )
