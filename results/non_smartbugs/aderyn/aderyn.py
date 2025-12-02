#!/usr/bin/env python3
import argparse
import csv
import os
import shutil
import shlex
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional

# Optional Rich UI
try:
    from rich.console import Console
    from rich.progress import Progress, SpinnerColumn, TimeElapsedColumn, BarColumn, TaskProgressColumn
    from rich.table import Table

    RICH = True
    CON = Console()
except Exception:
    RICH = False
    CON = None

# ---------- Defaults ----------
DEFAULT_EXT = os.getenv("ADERYN_EXT", ".json")
DEFAULT_TIMEOUT = int(os.getenv("ADERYN_TIMEOUT", "900"))
DEFAULT_WORKERS = min(int(os.getenv("ADERYN_WORKERS", os.cpu_count() or 2)), 8)
DEFAULT_OUTDIR = Path(os.getenv("ADERYN_OUTDIR", "./results"))


@dataclass
class RunResult:
    project_name: str
    project_dir: str  # absolute path to the analyzed folder
    status: str  # success | error | timeout | missing_cli | exception | no_report
    report_path: str
    log_path: str
    return_code: int
    elapsed_s: float


# --- helpers ---------------------------------------------------------------

def require_aderyn() -> None:
    """Checks if 'aderyn' is installed and executable locally."""
    if not shutil.which("aderyn"):
        print("ERROR: 'aderyn' executable not found in PATH.\n"
              "Please install it (e.g., `cargo install aderyn` or `foundryup`) before running this script.",
              file=sys.stderr)
        sys.exit(3)


def find_solidity_dirs(root: Path, include_hidden: bool = False) -> List[Path]:
    """Scans for directories containing .sol files."""
    dirs = set()
    for dirpath, _, filenames in os.walk(root):
        if not include_hidden and any(part.startswith(".") for part in Path(dirpath).parts):
            continue
        if any(name.lower().endswith(".sol") for name in filenames):
            dirs.add(Path(dirpath))
    return sorted(dirs)


def write_log(log_path: Path, meta: dict, output: str) -> None:
    """Writes metadata and stdout/stderr to a log file."""
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, "w", encoding="utf-8") as lf:
        for k, v in meta.items():
            lf.write(f"{k.upper()}: {v}\n")
        lf.write("\n=== ADERYN OUTPUT ===\n")
        lf.write(output or "")


# --- core run --------------------------------------------------------------

def run_one(
        project_dir: Path,
        outdir: Path,
        ext: str,
        timeout: int,
        extra_args: List[str]
) -> RunResult:
    name_safe = project_dir.name.replace(" ", "_")
    if not ext.startswith("."):
        ext = "." + ext

    report_name = f"{name_safe}{ext}"
    report_path = (outdir / "reports" / report_name).resolve()
    log_path = (outdir / "logs" / f"{name_safe}.log").resolve()

    # Ensure reports dir exists so aderyn can write to it
    report_path.parent.mkdir(parents=True, exist_ok=True)

    # Build local command
    # Structure: aderyn . -o /absolute/path/to/report.json [extra args]
    cmd = ["aderyn", ".", "-o", str(report_path)] + extra_args

    start = time.time()
    status, rc, output = "success", 0, ""

    try:
        # Run aderyn inside the project directory
        p = subprocess.run(
            cmd,
            cwd=str(project_dir),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout
        )
        rc = p.returncode
        output = p.stdout or ""
        status = "success" if rc == 0 else "error"

    except subprocess.TimeoutExpired as te:
        status, rc, output = "timeout", -1, f"TIMEOUT after {timeout}s\n{te}\n" + (str(te.stdout) if te.stdout else "")
    except FileNotFoundError:
        status, rc, output = "missing_cli", -2, "Aderyn executable not found during execution.\n"
    except Exception as e:
        status, rc, output = "exception", -3, f"Unhandled exception: {e}\n"

    elapsed = time.time() - start

    # Verify report existence
    if status == "success" and not report_path.exists():
        status = "no_report"
        output += f"\n[post-check] File expected at {report_path} but not found."

    write_log(
        log_path,
        {
            "project_dir": str(project_dir),
            "command": " ".join(shlex.quote(c) for c in cmd),
            "report_path": str(report_path),
            "status": status,
            "return_code": rc,
            "elapsed_seconds": f"{elapsed:.2f}",
        },
        output,
    )

    return RunResult(
        project_name=project_dir.name,
        project_dir=str(project_dir.resolve()),
        status=status,
        report_path=str(report_path),
        log_path=str(log_path),
        return_code=rc,
        elapsed_s=elapsed
    )


def run_parallel(func, items: List[Path], workers: int):
    from concurrent.futures import ThreadPoolExecutor, as_completed
    results = []
    with ThreadPoolExecutor(max_workers=max(1, workers)) as ex:
        futs = [ex.submit(func, it) for it in items]
        for fut in as_completed(futs):
            results.append(fut.result())
    return results


def write_summary_csv(results: List[RunResult], outdir: Path) -> Path:
    summary_csv = outdir / "analysis_run_log.csv"
    with open(summary_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["project_name", "status", "project_dir", "report_path", "log_path", "return_code", "elapsed_s"])
        for r in results:
            w.writerow([
                r.project_name,
                r.status,
                r.project_dir,
                r.report_path,
                r.log_path,
                r.return_code,
                f"{r.elapsed_s:.2f}"
            ])
    return summary_csv


def main(argv: Optional[Iterable[str]] = None) -> int:
    ap = argparse.ArgumentParser(
        description="Batch-run Aderyn locally on Solidity folders."
    )
    ap.add_argument("root", type=Path, help="Dataset root directory.")
    ap.add_argument("--outdir", "-o", type=Path, default=DEFAULT_OUTDIR,
                    help=f"Output dir (default: {DEFAULT_OUTDIR}).")
    ap.add_argument("--ext", default=DEFAULT_EXT,
                    help=f"Report extension (.json | .md | .sarif). Default: {DEFAULT_EXT}")
    ap.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT,
                    help=f"Timeout seconds (default: {DEFAULT_TIMEOUT}).")
    ap.add_argument("--workers", type=int, default=DEFAULT_WORKERS,
                    help=f"Parallel processes (default: {DEFAULT_WORKERS}).")
    ap.add_argument("--include-hidden", action="store_true", help="Scan hidden folders too.")
    ap.add_argument("--extra-args", default="", help='Extra args passed to Aderyn, e.g. "--no-snippets".')

    args = ap.parse_args(argv)

    # 1. Check prerequisites
    require_aderyn()

    root = args.root.resolve()
    if not root.is_dir():
        print(f"ERROR: Root does not exist or is not a directory: {root}", file=sys.stderr)
        return 2

    outdir = args.outdir.resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    # 2. Find targets
    targets = find_solidity_dirs(root, include_hidden=args.include_hidden)
    if not targets:
        print(f"WARNING: No Solidity files found under {root}. Nothing to do.")
        return 0

    extra_args = shlex.split(args.extra_args) if args.extra_args.strip() else []
    workers = max(1, min(args.workers, len(targets)))

    def _runner(p: Path) -> RunResult:
        return run_one(p, outdir, args.ext, args.timeout, extra_args)

    # 3. Execute
    results: List[RunResult] = []

    if RICH:
        with Progress(
                SpinnerColumn(),
                "[progress.description]{task.description}",
                BarColumn(),
                TaskProgressColumn(),
                TimeElapsedColumn(),
                transient=True
        ) as progress:
            task = progress.add_task(f"Running Aderyn locally ({workers} workers)…", total=len(targets))
            from concurrent.futures import ThreadPoolExecutor, as_completed

            with ThreadPoolExecutor(max_workers=workers) as ex:
                futs = {ex.submit(_runner, t): t for t in targets}
                for fut in as_completed(futs):
                    results.append(fut.result())
                    progress.advance(task)
    else:
        print(f"Found {len(targets)} folders. Running locally with workers={workers}, timeout={args.timeout}s")
        results = run_parallel(_runner, targets, workers)

    # 4. Report
    summary_csv = write_summary_csv(results, outdir)

    if RICH:
        table = Table(title="Aderyn Batch Summary (Local)")
        table.add_column("Project")
        table.add_column("Status")
        table.add_column("Report")

        # Sort by status (errors first), then name
        sorted_results = sorted(results, key=lambda x: (0 if x.status == "success" else 1, x.project_name.lower()))

        for r in sorted_results:
            style = "green" if r.status == "success" else "red"
            table.add_row(r.project_name, f"[{style}]{r.status}[/{style}]", os.path.basename(r.report_path))

        CON.print(table)
        CON.print(f"[bold]Completed.[/bold] Log saved to: {summary_csv}")
    else:
        print(f"Completed. Log saved to: {summary_csv}")

    # Non-zero exit if any failures
    if any(r.status != "success" for r in results):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())