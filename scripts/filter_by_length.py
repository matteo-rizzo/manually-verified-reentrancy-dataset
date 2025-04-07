import argparse
import os
import shutil


def filter_by_length(input_dir, output_dir, max_lines=500):
    """
    Replicates the directory structure from input_dir to output_dir and copies only Solidity files
    with line count less than or equal to max_lines.

    :param input_dir: Root directory containing Solidity contracts.
    :param output_dir: Root directory where filtered files will be saved.
    :param max_lines: Maximum number of lines allowed for a Solidity file to be copied.
    """
    for root, dirs, files in os.walk(input_dir):
        # Compute relative path and corresponding target directory
        rel_path = os.path.relpath(root, input_dir)
        target_dir = os.path.join(output_dir, rel_path)

        # Ensure the target directory exists
        os.makedirs(target_dir, exist_ok=True)

        for file in files:
            if file.endswith(".sol"):
                src_file_path = os.path.join(root, file)

                try:
                    with open(src_file_path, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                        if len(lines) <= max_lines:
                            dst_file_path = os.path.join(target_dir, file)
                            shutil.copy2(src_file_path, dst_file_path)
                            print(f"Copied: {src_file_path} -> {dst_file_path}")
                        else:
                            print(f"Skipped (too long): {src_file_path}")
                except Exception as e:
                    print(f"Error processing file {src_file_path}: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Filter Solidity files by line length.")
    parser.add_argument("input_dir", help="Path to input directory containing Solidity files")
    parser.add_argument("output_dir", help="Path to output log directory")
    parser.add_argument("--max_lines", type=int, default=250, help="Maximum allowed lines per file")

    args = parser.parse_args()

    filter_by_length(args.input_dir, args.output_dir, args.max_lines)
