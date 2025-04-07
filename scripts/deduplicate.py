import argparse
import hashlib
import logging
import os
import shutil
from pathlib import Path

from rich.console import Console
from rich.logging import RichHandler

# Setup rich logging
console = Console()
logging.basicConfig(level=logging.INFO, handlers=[RichHandler(console=console)])
logger = logging.getLogger("deduplicator")


def compute_file_hash(file_path, chunk_size=65536):
    """Compute the SHA-256 hash of a file."""
    hasher = hashlib.sha256()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(chunk_size), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def deduplicate_files(input_folder, dry_run=True, move_duplicates=False, duplicate_folder=None):
    """Find and remove duplicate files in the given folder."""
    file_hashes = {}
    input_folder = Path(input_folder)

    if move_duplicates and duplicate_folder:
        duplicate_folder = Path(duplicate_folder)
        duplicate_folder.mkdir(parents=True, exist_ok=True)

    for root, _, files in os.walk(input_folder):
        for file in files:
            file_path = Path(root) / file
            file_hash = compute_file_hash(file_path)

            if file_hash in file_hashes:
                logger.warning(f"Duplicate found: {file_path} (Duplicate of {file_hashes[file_hash]})")

                if not dry_run:
                    if move_duplicates and duplicate_folder:
                        shutil.move(file_path, duplicate_folder / file_path.name)
                        logger.info(f"Moved: {file_path} to {duplicate_folder}")
                    else:
                        os.remove(file_path)
                        logger.info(f"Deleted: {file_path}")
            else:
                file_hashes[file_hash] = file_path


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Deduplicate files in a folder.")
    parser.add_argument("folder", type=str, help="Path to the folder containing files.")
    parser.add_argument("--dry-run", action="store_true", help="Run without deleting files.")
    parser.add_argument("--move-duplicates", action="store_true", help="Move duplicates instead of deleting them.")
    parser.add_argument("--duplicate-folder", type=str, help="Folder to move duplicate files into.")

    args = parser.parse_args()

    deduplicate_files(
        args.folder,
        dry_run=args.dry_run,
        move_duplicates=args.move_duplicates,
        duplicate_folder=args.duplicate_folder
    )
