import os
from pathlib import Path
from typing import List, Set, Union

from src.classes.utils.DebugLogger import DebugLogger


def get_missing_files(
        folder_path: Union[str, Path],
        filenames_to_check: Union[List[str], Set[str]]
) -> List[str]:
    """
    Checks for the presence of files (comparing basenames without extensions)
    within a folder and its subfolders against a provided list of filenames.

    @:param folder_path (Union[str, Path]): The path to the folder to search within.
    @:param filenames_to_check (Union[List[str], Set[str]]): A list or set of filenames (can include extensions, they will
     be ignored in comparison) to check for presence.
    @:returns List[str]: A list containing the filenames from `filenames_to_check`
                   that were NOT found (based on basename without extension)
                   in the specified folder or its subfolders. The filenames
                   in the returned list preserve their original format/extension
                   as provided in `filenames_to_check`.

    @:raises:
        FileNotFoundError: If the provided folder_path does not exist.
        NotADirectoryError: If the provided folder_path is not a directory.
    """
    logger = DebugLogger()
    logger.info("Starting check for missing files.")
    logger.debug(f"Target folder: '{folder_path}'")
    logger.debug(f"Number of filenames to check: {len(filenames_to_check)}")

    # --- Input Validation and Path Handling ---
    folder_path_obj = Path(folder_path)
    try:
        if not folder_path_obj.exists():
            logger.error(f"Folder path does not exist: '{folder_path_obj}'")
            raise FileNotFoundError(f"Folder not found: {folder_path_obj}")
        if not folder_path_obj.is_dir():
            logger.error(f"Provided path is not a directory: '{folder_path_obj}'")
            raise NotADirectoryError(f"Path is not a directory: {folder_path_obj}")
    except Exception as e:
        # Catch potential permission errors or other OS errors during checks
        logger.error(f"Error accessing folder path '{folder_path_obj}': {e}", exc_info=True)
        raise  # Re-raise the caught exception

    # --- Collect Existing File Stems ---
    present_files_stems: Set[str] = set()
    total_files_scanned = 0
    logger.debug(f"Scanning directory tree starting at '{folder_path_obj}'...")
    try:
        for root, _, files in os.walk(folder_path_obj):
            root_path = Path(root)  # Use Path object for root as well
            for file in files:
                try:
                    file_path = root_path / file
                    # Check if it's actually a file (os.walk might list other things)
                    if file_path.is_file():
                        present_files_stems.add(file_path.stem)
                        total_files_scanned += 1
                except OSError as e:
                    # Handle potential errors accessing file info (e.g., broken symlinks)
                    logger.warning(f"Could not process file info for '{file_path}': {e}")
                    continue  # Skip this file
        logger.debug(f"Scan complete. Found {total_files_scanned} files.")
        logger.debug(f"Collected {len(present_files_stems)} unique file stems.")

    except Exception as e:
        logger.error(f"Error during directory walk in '{folder_path_obj}': {e}", exc_info=True)
        # Depending on requirements, you might return [] or re-raise
        raise RuntimeError(f"Failed to scan directory {folder_path_obj}") from e

    # --- Identify Missing Files ---
    missing_files: List[str] = []
    filenames_set = set(filenames_to_check)  # Ensure uniqueness and faster processing if it's a list

    logger.debug(f"Comparing {len(filenames_set)} unique filenames to check against found stems.")
    for filename_to_check in filenames_set:  # Iterate the unique set
        # Get the stem (filename without extension) of the file we are looking for
        stem_to_check = Path(filename_to_check).stem

        # Compare the stem we are looking for with the set of stems found on disk
        if stem_to_check not in present_files_stems:
            logger.debug(f"MISSING: Stem '{stem_to_check}' (from '{filename_to_check}') not found in the directory.")
            missing_files.append(filename_to_check)  # Add original filename (with ext)

    # --- Log Summary and Return ---
    if not missing_files:
        logger.info("All requested files were found (based on stem comparison).")
    else:
        logger.info(f"Found {len(missing_files)} missing file(s) (based on stem comparison): {missing_files}")

    return missing_files
