import os
import re
import sys

import chardet

verbose = False


def remove_stuff(code):
    pattern = r'(((library|interface)\s+\w+)|(contract\s+(Owned|Ownable)))\s*{'
    match = re.search(pattern, code)

    if not match:
        return code, False

    start = match.start()
    count = 0
    end = start

    for i in range(start, len(code)):
        if code[i] == '{':
            count += 1
        elif code[i] == '}':
            count -= 1
            if count == 0:
                end = i + 1
                break

    r = code[:start] + code[end:]
    return r, code != r


def process_file(file_path, output_dir):
    with open(file_path, 'rb') as f:
        solidity_code = f.read()
        enc = chardet.detect(solidity_code)

    with open(file_path, 'r', encoding=enc['encoding']) as f:
        solidity_code = f.read()

    cleaned_code = solidity_code
    while True:
        cleaned_code, touched = remove_stuff(cleaned_code)
        if not touched:
            break

    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, os.path.basename(file_path))
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(cleaned_code)

    if verbose: print(f"Processed [{enc['encoding']}]: {file_path} -> {output_path}")


def process_directory(directory, output_dir):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".sol"):
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(root, directory)
                output_subdir = os.path.join(output_dir, rel_path)
                try:
                    process_file(file_path, output_subdir)
                except KeyboardInterrupt:
                    exit()
                except BaseException as e:
                    print(f'Error processing file: {file_path}\nException caught: {e}\n')


def main():
    if len(sys.argv) < 2:
        print("Usage: python prune.py <file_or_directory> [-out <output_directory>]")
        sys.exit(1)

    path = sys.argv[1]
    output_dir = "./pruned"

    if "-v" in sys.argv:
        global verbose
        verbose = True

    if "-out" in sys.argv:
        out_index = sys.argv.index("-out")
        if out_index + 1 < len(sys.argv):
            output_dir = sys.argv[out_index + 1]
        else:
            print("Error: Missing output directory after -out")
            sys.exit(1)

    if os.path.isfile(path):
        process_file(path, output_dir)
    elif os.path.isdir(path):
        process_directory(path, output_dir)
    else:
        print(f"Error: {path} is not a valid file or directory.")
        sys.exit(1)


if __name__ == "__main__":
    main()
