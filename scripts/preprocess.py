import re
import os
import sys

def remove_stuff(solidity_code):
    # Rimuove library
    solidity_code = re.sub(r'library\s+\w+\s*{[^}]*}', '', solidity_code, flags=re.DOTALL)
    
    # Rimuove interfacce
    solidity_code = re.sub(r'interface\s+\w+\s*{[^}]*}', '', solidity_code, flags=re.DOTALL)
    
    # Rimuove contratti chiamati Owned
    solidity_code = re.sub(r'contract\s+Owned\s*{[^}]*}', '', solidity_code, flags=re.DOTALL)
    
    return solidity_code

def remove_stuff2(code):
    pattern = r'(library|interface)\s+\w+\s*{'
    match = re.search(pattern, code)
    
    if not match:
        return code
    
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
    print(f'start={start}, end={end}')
    return (r, code != r)



def process_file(file_path, output_dir):
    with open(file_path, 'r', encoding='utf-8') as f:
        solidity_code = f.read()
    
    while True: 
        (cleaned_code, touched) = remove_stuff2(cleaned_code)
        if not touched:
            break
    
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, os.path.basename(file_path))
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(cleaned_code)
    
    print(f"Processed: {file_path} -> {output_path}")

def process_directory(directory, output_dir):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".sol"):
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(root, directory)
                output_subdir = os.path.join(output_dir, rel_path)
                process_file(file_path, output_subdir)

def main():
    if len(sys.argv) < 2:
        print("Usage: python preprocess.py <file_or_directory> [-out <output_directory>]")
        sys.exit(1)
    
    path = sys.argv[1]
    output_dir = "pruned"
    
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