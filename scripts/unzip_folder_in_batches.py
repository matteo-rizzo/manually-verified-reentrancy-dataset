import argparse
import logging
import os
import shutil
import tarfile
import time
import zipfile

# --- Configuration ---
# Setup logging for informative output
# You can change the level to logging.DEBUG for more detailed output
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

# Supported TAR extensions (add more if needed)
TAR_EXTENSIONS = ('.tar', '.tar.gz', '.tgz', '.tar.bz2', '.tbz', '.tbz2', '.tar.xz', '.txz')


# --- Core Function ---

def extract_and_flatten(source_dir, dest_dir):
    """
    Scans the source directory for archives, extracts them into a destination
    directory, placing all extracted files directly into the destination,
    regardless of their original path within the archive.

    Args:
        source_dir (str): Path to the directory containing archive files.
        dest_dir (str): Path to the directory where files will be extracted.
                        This directory will be created if it doesn't exist.
    """
    # --- Validate Source Directory ---
    if not os.path.isdir(source_dir):
        logging.error(f"Source directory not found or is not a directory: {source_dir}")
        return False  # Indicate failure

    # --- Create Destination Directory ---
    try:
        # exist_ok=True prevents an error if the directory already exists
        os.makedirs(dest_dir, exist_ok=True)
        logging.info(f"Ensured destination directory exists: {dest_dir}")
    except OSError as e:
        logging.error(f"Could not create destination directory {dest_dir}: {e}")
        return False  # Indicate failure

    logging.info(f"Scanning source directory: {source_dir}")
    processed_files = 0
    skipped_files = 0
    error_files = 0

    # --- Iterate Through Source Directory Items ---
    for item_name in os.listdir(source_dir):
        source_item_path = os.path.join(source_dir, item_name)

        # Skip if it's a directory or not a file
        if not os.path.isfile(source_item_path):
            continue

        archive_type = None
        open_mode = ""
        file_processed = False

        # Convert item name to lowercase for case-insensitive extension check
        item_name_lower = item_name.lower()

        # --- Check for ZIP files ---
        if item_name_lower.endswith('.zip'):
            try:
                if zipfile.is_zipfile(source_item_path):
                    archive_type = 'zip'
                    logging.info(f"Found ZIP archive: {item_name}")
                else:
                    logging.debug(f"Skipping non-ZIP file ending with .zip: {item_name}")
            except Exception as e:
                logging.warning(f"Could not check if {item_name} is zip: {e}")


        # --- Check for TAR files (including compressed variants) ---
        elif item_name_lower.endswith(TAR_EXTENSIONS):
            try:
                # TarFile.is_tarfile doesn't exist, so we try opening it.
                # 'r:*' attempts to automatically detect the compression method (gz, bz2, xz).
                with tarfile.open(source_item_path, 'r:*') as temp_tf:
                    # Simple check: does it contain any members?
                    if temp_tf.getmembers():
                        archive_type = 'tar'
                        open_mode = 'r:*'  # Use auto-detection mode
                        logging.info(f"Found TAR archive: {item_name} (type detected)")
                    else:
                        logging.warning(f"Detected TAR file seems empty: {item_name}")
            except tarfile.TarError as e:
                # This is expected for non-tar files or corrupted ones
                logging.debug(f"File {item_name} not a readable TAR archive: {e}")
            except FileNotFoundError:
                logging.warning(f"File not found during TAR check (might be a broken link?): {source_item_path}")
            except Exception as e:  # Catch other potential errors during open
                logging.warning(f"Error checking potential TAR file {item_name}: {e}")

        # --- Process if it's a recognized archive ---
        if archive_type:
            # Create a unique temporary directory *inside* the destination directory
            # This helps keep intermediate files organized and avoids polluting other locations.
            # Adding timestamp/random element to avoid potential clashes if script runs fast
            timestamp = str(int(time.time() * 1000))
            temp_extract_base = f"__temp_extract_{os.path.splitext(item_name)[0]}_{timestamp}"
            temp_extract_dir = os.path.join(dest_dir, temp_extract_base)

            try:
                os.makedirs(temp_extract_dir)
                logging.info(f"Extracting '{item_name}' to temporary location: {temp_extract_dir}")

                # --- Extraction Logic ---
                if archive_type == 'zip':
                    with zipfile.ZipFile(source_item_path, 'r') as zf:
                        # Extract all contents into the temporary directory
                        zf.extractall(path=temp_extract_dir)
                elif archive_type == 'tar':
                    with tarfile.open(source_item_path, open_mode) as tf:
                        # Extract all contents into the temporary directory
                        # Note: tarfile.extractall can be vulnerable to path traversal attacks
                        # if the archive contains malicious paths like "../".
                        # For controlled environments this is often acceptable.
                        # For untrusted archives, more careful member filtering is needed.
                        tf.extractall(path=temp_extract_dir)

                logging.info(f"Extraction complete for '{item_name}'. Moving files to flatten structure...")

                # --- Flattening Logic: Walk the temporary directory ---
                files_moved = 0
                for root, dirs, files in os.walk(temp_extract_dir):
                    for filename in files:
                        # Path of the file in the temporary structure
                        source_file_path = os.path.join(root, filename)
                        # Target path directly in the final destination directory
                        dest_file_path = os.path.join(dest_dir, filename)

                        # --- Handle Name Collisions ---
                        # Option 1: Overwrite (current implementation)
                        if os.path.exists(dest_file_path):
                            # Check if it's the exact same file (e.g., from temp dir itself)
                            # This can happen if the archive had no subfolders
                            try:
                                if os.path.samefile(source_file_path, dest_file_path):
                                    continue  # Skip moving if it's the same file
                            except FileNotFoundError:
                                pass  # If dest doesn't exist, we definitely need to move

                            logging.warning(
                                f"Overwriting existing file: '{filename}' in {dest_dir} "
                                f"with file from archive '{item_name}'"
                            )
                            # Remove the existing file before moving
                            try:
                                if os.path.isdir(dest_file_path):  # Should not happen if source is file, but check
                                    logging.warning(f"Cannot overwrite directory '{dest_file_path}' with a file.")
                                    continue
                                os.remove(dest_file_path)
                            except OSError as rm_err:
                                logging.error(
                                    f"Could not remove existing file '{dest_file_path}' to overwrite: {rm_err}")
                                continue  # Skip moving this file

                        # Option 2: Rename (example - uncomment and adapt if needed)
                        # counter = 1
                        # original_dest_path = dest_file_path
                        # while os.path.exists(dest_file_path):
                        #     base, ext = os.path.splitext(original_dest_path)
                        #     dest_file_path = f"{base}_{counter}{ext}"
                        #     counter += 1
                        # if dest_file_path != original_dest_path:
                        #     logging.info(f"Renaming colliding file to: {os.path.basename(dest_file_path)}")

                        # --- Move the file ---
                        try:
                            shutil.move(source_file_path, dest_file_path)
                            files_moved += 1
                        except Exception as move_err:
                            logging.error(f"Could not move file '{filename}' from temp dir to {dest_dir}: {move_err}")
                            error_files += 1  # Count error even if one file fails

                logging.info(f"Moved {files_moved} file(s) from '{item_name}'.")
                processed_files += 1
                file_processed = True

            # --- Handle Extraction/Move Errors ---
            except zipfile.BadZipFile:
                logging.error(f"Error: Bad or corrupted ZIP file - '{item_name}'")
                error_files += 1
            except tarfile.TarError as e:
                logging.error(f"Error extracting TAR file '{item_name}': {e}")
                error_files += 1
            except OSError as e:
                logging.error(f"OS Error during processing of '{item_name}': {e}")
                error_files += 1
            except Exception as e:  # Catch-all for unexpected errors during processing
                logging.error(f"An unexpected error occurred processing '{item_name}': {e}")
                error_files += 1
            finally:
                # --- Cleanup Temporary Directory ---
                # This block executes whether the try block succeeded or failed
                if os.path.exists(temp_extract_dir):
                    logging.info(f"Cleaning up temporary directory: {temp_extract_dir}")
                    try:
                        shutil.rmtree(temp_extract_dir)
                    except Exception as cleanup_e:
                        # Log error but continue processing other archives
                        logging.error(f"Failed to cleanup temporary directory '{temp_extract_dir}': {cleanup_e}")

        # --- Update Skip Counter ---
        if archive_type and not file_processed and error_files == 0:  # If detected but failed before move
            error_files += 1  # Count as error if processing started but failed
        elif not archive_type:
            logging.debug(f"Skipping non-archive file: {item_name}")
            skipped_files += 1

    # --- Final Summary ---
    logging.info("=" * 20 + " Processing Summary " + "=" * 20)
    logging.info(f"Scan of '{source_dir}' complete.")
    logging.info(f"Successfully processed archives: {processed_files}")
    logging.info(f"Skipped non-archive files:    {skipped_files}")
    logging.info(f"Archives with errors:         {error_files}")
    logging.info(f"Flattened files are located in: '{dest_dir}'")
    if any(msg.startswith("Overwriting existing file") for msg in
           [rec.getMessage() for rec in logging.getLogger().handlers[0].records]):
        logging.warning(
            "Note: Files with the same name from different archives/subfolders may have overwritten each other.")

    return error_files == 0  # Return True if successful (no errors), False otherwise


# --- Command Line Interface ---

def main():
    """Parses command line arguments and runs the extraction function."""
    parser = argparse.ArgumentParser(
        description="Extract archives from a source folder to a destination folder, "
                    "flattening the directory structure. All files from within the "
                    "archives will be placed directly into the destination folder.",
        epilog="Example: python unzip_folder_in_batches.py /path/to/archives /path/to/output"
    )

    # Required arguments
    parser.add_argument(
        "--source_folder", default="../dataset/raw/studies/rs/safe",
        help="The path to the folder containing the archive files (.zip, .tar, .tar.gz, etc.)."
    )
    parser.add_argument(
        "--destination_folder", default="../dataset/raw/studies/rs/safe_full",
        help="The path to the folder where extracted files will be placed. "
             "It will be created if it doesn't exist."
    )

    args = parser.parse_args()

    # Run the main function
    success = extract_and_flatten(args.source_folder, args.destination_folder)

    if success:
        logging.info("Script finished successfully.")
        exit(0)  # Standard success exit code
    else:
        logging.error("Script finished with errors.")
        exit(1)  # Standard error exit code


# --- Script Execution Guard ---
if __name__ == "__main__":
    main()
