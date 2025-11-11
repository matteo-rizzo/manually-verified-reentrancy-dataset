#!/usr/bin/env python3
import argparse
import os
import re
import shlex
import shutil
import subprocess
import sys
import textwrap
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional, Tuple

# ---------- Optional Rich UI ----------
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
# NOTE: The Sailfish image is very old. Modern solc versions (0.8+)
# will likely NOT work. This script just calls the tool as-is.
DEFAULT_IMAGE = os.getenv("SAILFISH_IMAGE", "holmessherlock/sailfish:latest")
DEFAULT_TIMEOUT = int(os.getenv("SAILFISH_TIMEOUT", "1800"))
DEFAULT_WORKERS = min(int(os.getenv("SAILFISH_WORKERS", os.cpu_count() or 2)), 4)
DEFAULT_OUTDIR = Path(os.getenv("SAILFISH_OUTDIR", "./results"))
DEFAULT_MODE = os.getenv("SAILFISH_MODE", "range")  # range | havoc
DEFAULT_POLICIES = os.getenv("SAILFISH_POLICIES", "DAO,TOD")
DEFAULT_SOLVER = os.getenv("SAILFISH_SOLVER", "cvc4")
DEFAULT_PLATFORM = os.getenv("SAILFISH_PLATFORM", "linux/amd64")  # Force amd64 for the image
DEFAULT_TOOLID = os.getenv("SAILFISH_TOOLID", "sailfish")
DEFAULT_TOOLMODE = os.getenv("SAILFISH_TOOLMODE", "range-DAO,TOD")
DEFAULT_RUNID = os.getenv("SAILFISH_RUNID", "")
DEFAULT_PARSER_VERSION = os.getenv("SAILFISH_PARSER_VERSION", "1")

# Pragma extraction is kept for logging/metadata, but not for solc selection
PRAGMA_RE = re.compile(r"^\s*pragma\s+solidity\s+([^;]+);", re.IGNORECASE | re.MULTILINE)


@dataclass
class RunResult:
    project_dir: Path
    contract_path: Path
    status: str
    out_subdir: Path
    log_path: Path
    return_code: int
    elapsed_s: float
    findings: str
    started_at_iso: str
    pragma_specs: str


def flatten_directory(input_dir):
    """
    Creates a "flattened" clone of a directory.

    It walks through the input_dir, finds all files, and copies them
    to a new directory named '{input_dir}_flat'.

    To avoid name collisions, files are renamed based on their
    relative path. For example, 'subdir/image.jpg' becomes
    'subdir_image.jpg'.

    Args:
        input_dir (str): The path to the directory you want to flatten.
    """

    # --- 1. Validate Input ---
    if not os.path.isdir(input_dir):
        print(f"Error: Path '{input_dir}' is not a valid directory.")
        return

    # Normalize paths to remove any trailing slashes
    input_dir = os.path.normpath(input_dir)

    # --- 2. Define Output Directory ---
    # Create the output directory path (e.g., 'my_files' becomes 'my_files_flat')
    output_dir = f"{input_dir}_flat"

    try:
        # Create the output directory, including any necessary parent dirs.
        # 'exist_ok=True' means it won't raise an error if it already exists.
        os.makedirs(output_dir, exist_ok=True)
        print(f"Created temp flat directory: {output_dir}")

        # --- 3. Walk and Copy ---
        file_count = 0

        # os.walk is a generator that recursively walks the directory tree
        # root: The current directory path
        # dirs: A list of subdirectory names in 'root'
        # files: A list of file names in 'root'
        for root, dirs, files in os.walk(input_dir):

            # Don't try to walk the output directory if it's inside the input dir
            if root.startswith(output_dir):
                continue

            for filename in files:
                # Get the full path to the original file
                original_path = os.path.join(root, filename)

                # Get the file's path relative to the input_dir
                # e.g., 'subdir/another/file.txt'
                relative_path = os.path.relpath(original_path, input_dir)

                # Get just the relative directory path
                # e.g., 'subdir/another' or '' if file is in root
                relative_dir = os.path.dirname(relative_path)

                # Create the new "flat" filename based on user's request:
                # "original name with prefix = the original path"

                if relative_dir:
                    # Create the prefix from the path, e.g., 'subdir/another' -> 'subdir_another_'
                    prefix = relative_dir.replace(os.sep, '__') + '__'
                else:
                    # File is in the root of input_dir, so no prefix
                    prefix = ''

                # Combine the prefix and the original filename
                flat_name = f"{prefix}{filename}"

                # Define the full path for the new, copied file
                dest_path = os.path.join(output_dir, flat_name)

                try:
                    # Copy the file, preserving metadata (like creation time)
                    shutil.copy2(original_path, dest_path)
                    file_count += 1

                except shutil.Error as e:
                    print(f"Warning: Could not copy '{original_path}'. Error: {e}")
                except IOError as e:
                    print(f"Warning: IO Error copying '{original_path}'. Error: {e}")

        print(f"Done. Successfully copied {file_count} files to '{output_dir}'.")

    except OSError as e:
        print(f"Error: Could not create output directory '{output_dir}'. Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def require_docker() -> None:
    try:
        subprocess.run(["docker", "--version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except Exception:
        print("ERROR: Docker CLI not found or not runnable. Install Docker and ensure `docker` is on PATH.",
              file=sys.stderr)
        sys.exit(3)


def find_contracts(root: Path, include_hidden: bool = False) -> List[Path]:
    items: List[Path] = []
    for dirpath, _, filenames in os.walk(root):
        if not include_hidden and any(part.startswith(".") for part in Path(dirpath).parts):
            continue
        for f in filenames:
            if f.lower().endswith(".sol"):
                items.append((Path(dirpath) / f).resolve())
    return sorted(items)


def extract_pragmas_from_file(file_path: Path) -> List[str]:
    try:
        text = file_path.read_text(encoding="utf-8", errors="ignore")
        return [m.group(1).strip() for m in PRAGMA_RE.finditer(text)]
    except Exception:
        return []


def build_docker_cmd(
        image: str,
        contract_path: Path,
        outdir: Path,
        mode: str,
        policies: str,
        solver: str,
        platform: str,
) -> Tuple[List[str], Path]:
    project_dir = contract_path.parent
    rel_out_subdir = f"{project_dir.name}/{contract_path.stem}"
    out_subdir = outdir / rel_out_subdir
    out_subdir.mkdir(parents=True, exist_ok=True)

    # Mounts: Project dir and the specific output subdir
    # We mount the output subdir directly to /out
    mounts = [
        "-v", f"{project_dir}:/workspace",
        "-v", f"{out_subdir}:/out",
    ]

    cmd = ["docker", "run", "--rm"]
    if platform:
        cmd += ["--platform", platform]

    cmd += mounts

    # Pre-quote all shell args so we can drop them into the template safely
    q_contract = shlex.quote(f'/workspace/{contract_path.name}')
    q_outdir = shlex.quote('/out')
    q_mode = shlex.quote(mode)
    q_policies = shlex.quote(policies)
    q_solver = shlex.quote(solver)

    # Use a simple wrapper script to find and execute contractlint.py
    # This avoids the CMD/ENTRYPOINT ambiguity.
    entry_tpl = r"""\
set -Eeuo pipefail

# 1) Locate Sailfish
SCRIPT=""
for p in /sailfish/code/static_analysis/analysis/contractlint.py \
         /root/sailfish/code/static_analysis/analysis/contractlint.py \
         /opt/sailfish/code/static_analysis/analysis/contractlint.py; do
  [ -f "$p" ] && SCRIPT="$p" && break
done
[ -z "$SCRIPT" ] && echo "ERROR: contractlint.py not found" >&2 && exit 2

# 2) Find python
PYBIN="python3"; command -v python3 >/dev/null 2>&1 || PYBIN="python"

# 3) Run Sailfish from its directory
SRCDIR="$(dirname "$SCRIPT")"
cd "$SRCDIR"
export PYTHONPATH="${SRCDIR}:${PYTHONPATH-}"

# 4) Execute analysis
set +e
$PYBIN contractlint.py \
  -c «Q_CONTRACT» \
  -o «Q_OUTDIR» \
  -r «Q_MODE» \
  -p «Q_POLICIES» \
  -sv «Q_SOLVER» \
  -oo 2>&1 | tee /tmp/sf.out
RC=${PIPESTATUS[0]}
set -e
exit $RC
"""
    # Dedent and substitute markers
    entry_script = textwrap.dedent(entry_tpl) \
        .replace("«Q_CONTRACT»", q_contract) \
        .replace("«Q_OUTDIR»", q_outdir) \
        .replace("«Q_MODE»", q_mode) \
        .replace("«Q_POLICIES»", q_policies) \
        .replace("«Q_SOLVER»", q_solver)

    # Set the entrypoint to /bin/bash, which will execute our script
    cmd += [
        "-w", "/",
        "--entrypoint", "/bin/bash",
        image,
        "-lc", entry_script
    ]

    return cmd, out_subdir


def write_log(log_path: Path, meta: dict, output: str) -> None:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, "w", encoding="utf-8") as lf:
        for k, v in meta.items():
            lf.write(f"{k.upper()}: {v}\n")
        lf.write("\n=== CONTAINER OUTPUT ===\n")
        lf.write(output)


def _unique_log_path(outdir: Path, contract_path: Path) -> Path:
    folder = contract_path.parent.name
    base = contract_path.stem
    cand = outdir / f"{folder}_{base}.log"
    if not cand.exists():
        return cand.resolve()
    import hashlib
    h = hashlib.sha1(str(contract_path).encode("utf-8")).hexdigest()[:8]
    return (outdir / f"{folder}_{base}_{h}.log").resolve()


def run_one(
        image: str,
        contract_path: Path,
        outdir: Path,
        mode: str,
        policies: str,
        solver: str,
        timeout: int,
        platform: str,
) -> RunResult:
    specs = extract_pragmas_from_file(contract_path)
    cmd, out_subdir = build_docker_cmd(
        image, contract_path, outdir, mode, policies, solver, platform
    )

    start = time.time()
    status, rc, output = "success", 0, ""
    started_iso = time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(start))
    try:
        p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           text=True, encoding="utf-8", errors="replace", timeout=timeout)
        rc = p.returncode
        output = p.stdout or ""
        # The tool's default entrypoint (contractlint.py) unfortunately
        # seems to exit 1 even on some 'successful' analysis runs.
        # We'll consider it a script 'success' if rc is 0 or 1.
        # Real errors (docker missing, crash) will have other codes.
        if rc in [0, 1]:
            status = "success"
        else:
            status = "error"

    except subprocess.TimeoutExpired as te:
        status, rc, output = "timeout", -1, f"TIMEOUT after {timeout}s\n{te}\n"
    except FileNotFoundError:
        status, rc, output = "docker_missing", -2, "Docker CLI not found on PATH.\n"
    except Exception as e:
        status, rc, output = "exception", -3, f"Unhandled exception: {e}\n{traceback.format_exc()}\n"

    elapsed = time.time() - start
    log_path = _unique_log_path(outdir, contract_path)

    pragma_str = "; ".join(specs) or "(none found)"

    write_log(
        log_path,
        {
            "project_dir": contract_path.parent,
            "contract": contract_path,
            "image": image,
            "command": " ".join(shlex.quote(c) for c in cmd),
            "mode": mode,
            "policies": policies,
            "solver": solver,
            "out_subdir": out_subdir,
            "status": status,
            "return_code": rc,
            "elapsed_seconds": f"{elapsed:.2f}",
            "pragma_specs": pragma_str,
        },
        output,
    )

    findings = ""
    try:
        # Check if any .csv file was created in the output subdir
        if any(p.suffix.lower() == ".csv" for p in out_subdir.glob("*.csv")):
            findings = "1"
        else:
            findings = "0"
    except Exception:
        findings = ""  # Error (e.g. permission)

    return RunResult(
        project_dir=contract_path.parent,
        contract_path=contract_path,
        status=status,
        out_subdir=out_subdir,
        log_path=log_path,
        return_code=rc,
        elapsed_s=elapsed,
        findings=findings,
        started_at_iso=started_iso,
        pragma_specs=pragma_str,
    )


def present_table(results: List[RunResult], outdir: Path) -> None:
    ok = sum(1 for r in results if r.status == "success")
    if RICH:
        table = Table(title="Sailfish Batch Summary (Docker)")
        table.add_column("Contract")
        table.add_column("Pragmas")
        table.add_column("Status")
        table.add_column("Findings", justify="center")
        table.add_column("RC", justify="right")
        table.add_column("Sec", justify="right")
        for r in sorted(results, key=lambda x: str(x.contract_path).lower()):
            prag_str = r.pragma_specs[:30] + '...' if len(r.pragma_specs) > 30 else r.pragma_specs
            status_color = "green" if r.status == "success" else "red"
            findings_str = "[green]✔[/green]" if r.findings == "1" else "[grey50]✘[/grey50]" if r.findings == "0" else "?"

            # Try to get relative path for cleaner display
            try:
                contract_display_path = str(r.contract_path.relative_to(r.project_dir.parent.parent))
            except ValueError:
                contract_display_path = str(r.contract_path)

            table.add_row(
                contract_display_path,
                prag_str,
                f"[{status_color}]{r.status}[/{status_color}]",
                findings_str,
                str(r.return_code),
                f"{r.elapsed_s:.1f}"
            )
        CON.print(table)
        CON.print(f"[bold green]{ok}[/bold green]/{len(results)} succeeded • Results: {outdir}")
    else:
        print(f"\nSummary: {ok}/{len(results)} succeeded • Results: {outdir}")
        for r in sorted(results, key=lambda x: str(x.contract_path).lower()):
            print(f"- {r.contract_path}  {r.status} findings={r.findings} rc={r.return_code} {r.elapsed_s:.1f}s")
            print(f"  pragmas: {r.pragma_specs}")
            print(f"  log: {r.log_path}")


def run_parallel(func, items: List[Path], workers: int):
    # This function is now more complex as it's used by both rich/non-rich
    from concurrent.futures import ThreadPoolExecutor, as_completed

    results: List[RunResult] = []

    if RICH:
        with Progress(SpinnerColumn(), "[progress.description]{task.description}", BarColumn(),
                      TaskProgressColumn(), TimeElapsedColumn(), transient=False) as progress:
            task = progress.add_task("Running Sailfish in Docker…", total=len(items))
            with ThreadPoolExecutor(max_workers=max(1, workers)) as ex:
                futs = {ex.submit(func, c): c for c in items}
                for fut in as_completed(futs):
                    contract_path = futs[fut]
                    try:
                        res = fut.result()
                        results.append(res)
                        status = "OK" if res.status == "success" else "FAIL"
                        progress.update(task, advance=1, description=f"({status}) {contract_path.name}")
                    except Exception as e:
                        progress.update(task, advance=1, description=f"(CRASH) {contract_path.name}")
                        print(f"CRITICAL ERROR running {contract_path}: {e}", file=sys.stderr)
    else:
        print(f"Running {len(items)} contracts with {workers} workers...")
        with ThreadPoolExecutor(max_workers=max(1, workers)) as ex:
            futs = [ex.submit(func, it) for it in items]
            for i, fut in enumerate(as_completed(futs), 1):
                try:
                    res = fut.result()
                    results.append(res)
                    print(f"({i}/{len(items)}) [{res.status.upper()}] {res.contract_path.name} ({res.elapsed_s:.1f}s)")
                except Exception as e:
                    print(f"({i}/{len(items)}) [CRASH] {e}", file=sys.stderr)

    return results


def main(argv: Optional[Iterable[str]] = None) -> int:
    ap = argparse.ArgumentParser(description="Batch-run Sailfish (Docker) over a dataset of Solidity contracts.")
    ap.add_argument("root", type=Path, help="Dataset root.")
    ap.add_argument("--image", default=DEFAULT_IMAGE)
    ap.add_argument("--outdir", "-o", type=Path, default=DEFAULT_OUTDIR)
    ap.add_argument("--mode", default=DEFAULT_MODE)
    ap.add_argument("--policies", default=DEFAULT_POLICIES)
    ap.add_argument("--solver", default=DEFAULT_SOLVER)
    ap.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT)
    ap.add_argument("--workers", type=int, default=DEFAULT_WORKERS)
    ap.add_argument("--include-hidden", action="store_true")
    ap.add_argument("--platform", default=DEFAULT_PLATFORM,
                    help="Force a docker platform, e.g. 'linux/amd64'. Recommended.")
    ap.add_argument("--toolid", default=DEFAULT_TOOLID)
    ap.add_argument("--toolmode", default=DEFAULT_TOOLMODE)
    ap.add_argument("--parser-version", default=DEFAULT_PARSER_VERSION)
    ap.add_argument("--runid", default=DEFAULT_RUNID)
    ap.add_argument("--keep-flat-dir", action="store_true")
    args = ap.parse_args(argv)

    require_docker()
    root = args.root.resolve()
    if not root.is_dir():
        print(f"ERROR: Root does not exist or is not a directory: {root}", file=sys.stderr)
        return 2

    flatten_directory(root)

    root = str(root) + "_flat"

    outdir = args.outdir.resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    contracts = find_contracts(root, include_hidden=args.include_hidden)
    if not contracts:
        print(f"WARNING: No Solidity files found under {root}. Nothing to do.")
        return 0

    if CON:
        CON.print(f"Found {len(contracts)} Solidity files under [bold]{root}[/bold]")
        CON.print(f"Using image: [bold]{args.image}[/bold] (Platform: [bold]{args.platform}[/bold])")

    def _runner(contract: Path) -> RunResult:
        return run_one(args.image, contract, outdir, args.mode, args.policies, args.solver,
                       args.timeout, args.platform)

    results = run_parallel(_runner, contracts, args.workers)

    present_table(results, outdir)
    if any(r.status != "success" for r in results):
        print(f"One or more runs failed. See logs in {outdir}", file=sys.stderr)
        return 1

    print("Deleting temp flat directory...")
    if not args.keep_flat_dir:
        shutil.rmtree(root)

    print("Done!")
    return 0


if __name__ == "__main__":
    # Add traceback for unhandled exceptions
    import traceback

    sys.exit(main())
