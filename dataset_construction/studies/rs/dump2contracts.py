import os
import shutil
from pathlib import Path

import pandas as pd
from rich import print
from rich.console import Console

console = Console()


def load_reentrancy_info(csv_path):
    try:
        df = pd.read_csv(csv_path, dtype=str)
        if 'address' not in df.columns or 'true_positive' not in df.columns:
            raise ValueError("CSV must contain 'address' and 'true_positive' columns.")
        return df.set_index('address')['true_positive'].to_dict()
    except Exception as e:
        console.print(f"[red]Error loading CSV:[/red] {e}")
        raise


def process_contracts(input_folder, output_folder, info_dict):
    reentrant_dir = os.path.join(output_folder, 'reentrant')
    safe_dir = os.path.join(output_folder, 'safe')
    os.makedirs(reentrant_dir, exist_ok=True)
    os.makedirs(safe_dir, exist_ok=True)

    processed = 0
    skipped = 0

    for file in os.listdir(input_folder):
        if file.endswith(".sol"):
            src_path = os.path.join(input_folder, file)
            address = file.split('.')[0]
            label = info_dict.get(address)

            if label == '1':
                dst_path = os.path.join(reentrant_dir, file)
                shutil.copy(src_path, dst_path)
                console.print(f"[bold green]Reentrant[/bold green]: {file}")
                processed += 1
            elif label == '0':
                dst_path = os.path.join(safe_dir, file)
                shutil.copy(src_path, dst_path)
                console.print(f"[bold blue]Safe[/bold blue]: {file}")
                processed += 1
            else:
                console.print(f"[yellow]Skipping[/yellow] {file} (N/A or not found in CSV)")
                skipped += 1

    console.print(f"\n[green]Processed {processed} files[/green], [yellow]Skipped {skipped} files[/yellow]")


def main():
    input_folder = "dump"
    csv_path = "reentrancy_information.csv"
    output_folder = "logs/contract_classification"

    console.print(f"\n[bold]Starting classification...[/bold]")
    info_dict = load_reentrancy_info(csv_path)
    process_contracts(input_folder, output_folder, info_dict)


if __name__ == "__main__":
    main()
