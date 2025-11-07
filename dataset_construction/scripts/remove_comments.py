import os
import re
import sys


def remove_comments_from_code(code: str) -> str:
    """
    Remove all single-line (// ...) and multi-line (/* ... */) comments from Solidity code,
    while preserving string literals (single, double, and backtick quoted).
    """
    pattern = re.compile(
        r"""
        (                           # capture entire match
          (?P<string>               # group 'string': match string literals
              "([^"\\]*(\\.[^"\\]*)*)"        |   # double-quoted strings
              '([^'\\]*(\\.[^'\\]*)*)'        |   # single-quoted strings
              `([^`\\]*(\\.[^`\\]*)*)`            # backtick-quoted strings
          )
          |
          (?P<comment>              # group 'comment': match comments
              //.*?$                       |   # single-line comments
              /\*.*?\*/                        # multi-line comments
          )
        )
        """, re.VERBOSE | re.DOTALL | re.MULTILINE
    )

    def replacer(match: re.Match) -> str:
        if match.group('comment'):
            return ''  # remove the comment
        return match.group('string')  # leave the string literal intact

    return pattern.sub(replacer, code)


def process_directory(input_dir: str, output_dir: str):
    """
    Process all Solidity files in the input_dir by removing comments and saving the
    modified contents into output_dir.
    """
    if not os.path.isdir(input_dir):
        print(f"Error: Input directory '{input_dir}' does not exist or is not a directory.")
        sys.exit(1)

    # Create the output directory if it doesn't already exist.
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Iterate over files in the input directory.
    for filename in os.listdir(input_dir):
        if filename.lower().endswith('.sol'):
            input_path = os.path.join(input_dir, filename)
            output_filename = filename
            if "_" in output_filename:
                output_filename = output_filename.split("_")[0] + ".sol"
            output_path = os.path.join(output_dir, output_filename)
            try:
                with open(input_path, 'r', encoding='utf-8') as infile:
                    solidity_code = infile.read()

                uncommented_code = remove_comments_from_code(solidity_code)

                with open(output_path, 'w', encoding='utf-8') as outfile:
                    outfile.write(uncommented_code)

                print(f"Processed: {filename} -> {output_path}")
            except Exception as e:
                print(f"Error processing file '{input_path}': {e}")


def main():
    if len(sys.argv) != 3:
        print("Usage: python remove_comments.py <input_directory> <output_directory>")
        sys.exit(1)

    input_directory = sys.argv[1]
    output_directory = sys.argv[2]

    process_directory(input_directory, output_directory)


if __name__ == "__main__":
    main()
