import zipfile
from pathlib import Path


def zip_in_batches(input_folder, output_folder, batch_size=1000):
    input_folder = Path(input_folder)
    output_folder = Path(output_folder)
    output_folder.mkdir(parents=True, exist_ok=True)

    # Get all file paths in the input folder (non-recursive)
    all_files = sorted([f for f in input_folder.iterdir() if f.is_file()])

    total_files = len(all_files)
    print(f"Total files to process: {total_files}")

    for i in range(0, total_files, batch_size):
        batch_files = all_files[i:i + batch_size]
        zip_index = i // batch_size + 1
        zip_name = output_folder / f"archive_{zip_index:04}.zip"

        with zipfile.ZipFile(zip_name, 'w', compression=zipfile.ZIP_DEFLATED) as zipf:
            for file_path in batch_files:
                arcname = file_path.name  # You could keep folder structure by using .relative_to(input_folder)
                zipf.write(file_path, arcname=arcname)

        print(f"Created: {zip_name} with {len(batch_files)} files")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Zip files in batches")
    parser.add_argument("input_folder", help="Path to folder containing files")
    parser.add_argument("output_folder", help="Path to output ZIPs")
    parser.add_argument("--batch-size", type=int, default=1000, help="Max files per ZIP")

    args = parser.parse_args()
    zip_in_batches(args.input_folder, args.output_folder, args.batch_size)
