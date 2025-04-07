import os
import shutil
from pathlib import Path
from rich.console import Console

console = Console()

def copy_solidity_files(src_folder, dst_folder):
    src_folder = Path(src_folder).resolve()
    dst_folder = Path(dst_folder).resolve()

    if not src_folder.exists():
        console.print(f"[red]Input folder does not exist: {src_folder}[/red]")
        return

    sol_count = 0
    for root, _, files in os.walk(src_folder):
        rel_path = os.path.relpath(root, src_folder)
        dest_dir = dst_folder / rel_path
        dest_dir.mkdir(parents=True, exist_ok=True)

        for file in files:
            if file.endswith(".sol"):
                src_file = Path(root) / file
                dst_file = dest_dir / file
                shutil.copy2(src_file, dst_file)
                console.print(f"[green]Copied[/green] {src_file} -> {dst_file}")
                sol_count += 1

    console.print(f"\n[bold green]Done! Copied {sol_count} Solidity files.[/bold green]")

def main():
    input_folder = "dump"
    output_folder = "reentrant"

    copy_solidity_files(input_folder, output_folder)

if __name__ == "__main__":
    main()
