#!/usr/bin/env python3
import argparse
import csv
import json
import os
import re
import shlex
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional, Dict, Any

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
DEFAULT_IMAGE = os.getenv("ADERYN_IMAGE", "aderyn:latest")
DEFAULT_EXT = os.getenv("ADERYN_EXT", ".json")
DEFAULT_TIMEOUT = int(os.getenv("ADERYN_TIMEOUT", "900"))
DEFAULT_WORKERS = min(int(os.getenv("ADERYN_WORKERS", os.cpu_count() or 2)), 4)
DEFAULT_OUTDIR = Path(os.getenv("ADERYN_OUTDIR", "./results"))
DEFAULT_FALLBACK_SOLC = os.getenv("ADERYN_FALLBACK_SOLC", "0.5.17")
DEFAULT_EVM_VERSION = os.getenv("ADERYN_EVM_VERSION", "")  # override; else auto-pick
DEFAULT_SVM_CACHE = os.getenv("ADERYN_SVM_CACHE", str(Path.home() / ".svm"))
DEFAULT_AGG_NAME = os.getenv("ADERYN_SMARTBUGS_CSV", "smartbugs_summary.csv")
# --------------------------------

# Known, good solc patch versions to choose from when pragma gives a range.
KNOWN_SOLC = [
    "0.4.24",
    "0.4.26",
    "0.5.17",
    "0.6.12",
    "0.7.6",
    "0.8.19", "0.8.20", "0.8.21", "0.8.22", "0.8.23", "0.8.24", "0.8.25", "0.8.26", "0.8.27", "0.8.28", "0.8.29",
    "0.8.30", "0.8.31",
]

PRAGMA_RE = re.compile(r"^\s*pragma\s+solidity\s+([^;]+);", re.IGNORECASE | re.MULTILINE)
_REENTR_RE = re.compile(r"re-?entr", re.IGNORECASE)


@dataclass
class RunResult:
    project_name: str
    project_dir: str  # absolute path to the analyzed folder
    status: str  # success | error | timeout | docker_missing | exception | no_report
    report_path: str
    log_path: str
    return_code: int
    elapsed_s: float


# --- helpers ---------------------------------------------------------------

def require_docker() -> None:
    try:
        subprocess.run(["docker", "--version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except Exception:
        print("ERROR: Docker CLI not found or not runnable. Install Docker and ensure `docker` is on PATH.",
              file=sys.stderr)
        sys.exit(3)


def find_solidity_dirs(root: Path, include_hidden: bool = False) -> List[Path]:
    dirs = set()
    for dirpath, _, filenames in os.walk(root):
        if not include_hidden and any(part.startswith(".") for part in Path(dirpath).parts):
            continue
        if any(name.lower().endswith(".sol") for name in filenames):
            dirs.add(Path(dirpath))
    return sorted(dirs)


def extract_all_pragmas(folder: Path) -> List[str]:
    specs = []
    for p in folder.glob("**/*.sol"):
        try:
            text = p.read_text(encoding="utf-8", errors="ignore")
            m = PRAGMA_RE.search(text)
            if m:
                specs.append(m.group(1).strip())
        except Exception:
            pass
    return specs


def _vtuple(v: str) -> tuple:
    return tuple(int(x) for x in v.split("."))


def pick_solc_from_pragmas(specs: List[str], fallback: str) -> str:
    """Pick a concrete patch version that satisfies all pragma specs; else fallback."""
    if not specs:
        return fallback

    def satisfies(ver: str, spec: str) -> bool:
        v = _vtuple(ver)
        nums = [tuple(map(int, s.split("."))) for s in re.findall(r"\d+\.\d+\.\d+", spec)]
        s = spec.replace(" ", "")
        if s.startswith("^") and nums:
            base = nums[0]
            ceiling = (base[0], base[1] + 1, 0)
            return v >= base and v < ceiling
        if s.startswith("=") and nums:
            return v == nums[0]
        ge = re.search(r">=\s*(\d+\.\d+\.\d+)", spec)
        lt = re.search(r"<\s*(\d+\.\d+\.\d+)", spec)
        le = re.search(r"<=\s*(\d+\.\d+\.\d+)", spec)
        ok = True
        if ge: ok &= v >= _vtuple(ge.group(1))
        if lt: ok &= v < _vtuple(lt.group(1))
        if le: ok &= v <= _vtuple(le.group(1))
        if ge or lt or le:
            return ok
        plain = re.match(r"^\s*(\d+\.\d+\.\d+)\s*$", spec)
        return v == _vtuple(plain.group(1)) if plain else True

    # for ver in reversed(KNOWN_SOLC):  # prefer newest that satisfies all specs
    #     if all(satisfies(ver, s) for s in specs):
    #         return ver
    return fallback


def pick_evm_for_solc(solc_version: str, user_override: str) -> str:
    """Conservative EVM picks if user didn't override."""
    if user_override:
        return user_override
    v = _vtuple(solc_version)
    if v >= (0, 8, 24):
        return "cancun"
    if v >= (0, 8, 0):
        return "shanghai"
    return "istanbul"


def build_docker_cmd(
        image: str,
        project_dir: Path,
        outdir: Path,
        report_name: str,
        solc_version: str,
        evm_version: str,
        extra_args: List[str],
        svm_cache: Optional[str] = None,
) -> List[str]:
    envs = [
        "-e", f"FOUNDRY_SOLC_VERSION={solc_version}",
        "-e", f"FOUNDRY_EVM_VERSION={evm_version}",
    ]

    mounts = [
        "-v", f"{project_dir}:/workspace",
        "-v", f"{outdir}:/out",
    ]
    if svm_cache:
        mounts += ["-v", f"{svm_cache}:/root/.svm"]

    aderyn_args = " ".join(shlex.quote(a) for a in extra_args) if extra_args else ""

    inner = f"""#!/usr/bin/env bash
set -euo pipefail

mkdir -p /out/reports
export PATH="/usr/local/bin:/root/.svm/bin:$PATH"

want="{solc_version}"

# 1) Best effort: install with svm (no-op if present)
svm install "$want" >/dev/null 2>&1 || true

# 2) If svm can tell us the exact binary, prefer that and expose it at /usr/local/bin/solc
if SOLC_BIN="$(svm which "$want" 2>/dev/null)"; then
  if [ -n "$SOLC_BIN" ] && [ -x "$SOLC_BIN" ]; then
    ln -sf "$SOLC_BIN" /usr/local/bin/solc
  fi
fi

# 3) If version still mismatches (or solc missing), fetch static binary from Solidity releases
have="$(solc --version 2>/dev/null | sed -n 's/^Version: \\([0-9.]*\\).*/\\1/p' | head -n1 || true)"
if [ "${{have:-}}" != "$want" ]; then
  echo "[setup] Installing solc $want …"

  # Ensure we have a downloader in this base image
  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    (apt-get update -y && apt-get install -y curl) >/dev/null 2>&1 || \
    (apk add --no-cache curl) >/dev/null 2>&1 || \
    (microdnf install -y curl) >/dev/null 2>&1 || \
    (yum install -y curl) >/dev/null 2>&1 || true
  fi

  url="https://github.com/ethereum/solidity/releases/download/v$want/solc-static-linux"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o /usr/local/bin/solc
  elif command -v wget >/dev/null 2>&1; then
    wget -qO /usr/local/bin/solc "$url"
  else
    echo "ERROR: neither curl nor wget available to download solc $want" >&2
    exit 12
  fi
  chmod +x /usr/local/bin/solc
fi

echo "[env] solc full version:"
solc --version || true
echo "[env] aderyn: $(aderyn --version 2>/dev/null || echo unknown)"

cd /workspace
aderyn . -o /out/reports/{shlex.quote(report_name)} {aderyn_args}
"""

    return [
        "docker", "run", "--rm",
        *mounts,
        "-w", "/workspace",
        *envs,
        "--entrypoint", "/bin/bash",
        image, "-lc", inner,
    ]


def write_log(log_path: Path, meta: dict, output: str) -> None:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, "w", encoding="utf-8") as lf:
        for k, v in meta.items():
            lf.write(f"{k.upper()}: {v}\n")
        lf.write("\n=== CONTAINER OUTPUT ===\n")
        lf.write(output or "")


# --- findings collection ----------------------------------------------------

def _collect_findings_from_report(path: Path, only_reentrancy: bool = False) -> List[Dict[str, Any]]:
    """
    Collect findings (one item per *instance*) from an Aderyn JSON report.
    Returns a list of dicts: severity, title, detector, description, contract_path, line_no, hint.
    If only_reentrancy=True, keeps only items whose title/detector/description mention reentrancy.
    """
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        return []

    def want(title: str, detector: str, description: str) -> bool:
        if not only_reentrancy:
            return True
        text = f"{title} {detector} {description or ''}"
        return _REENTR_RE.search(text) is not None

    def pull(section: dict, severity: str) -> list:
        out = []
        if not isinstance(section, dict):
            return out
        issues = section.get("issues") or []
        if not isinstance(issues, list):
            return out
        for issue in issues:
            title = (issue or {}).get("title") or ""
            detector = (issue or {}).get("detector_name") or ""
            description = (issue or {}).get("description") or ""
            if not want(title, detector, description):
                continue
            instances = (issue or {}).get("instances") or []
            if not isinstance(instances, list):
                continue
            for inst in instances:
                out.append({
                    "severity": severity,
                    "title": title,
                    "detector": detector,
                    "description": description,
                    "contract_path": (inst or {}).get("contract_path") or "",
                    "line_no": (inst or {}).get("line_no"),
                    "hint": (inst or {}).get("hint"),
                })
        return out

    findings: List[Dict[str, Any]] = []
    if isinstance(data, dict):
        findings += pull(data.get("high_issues"), "high")
        findings += pull(data.get("low_issues"), "low")

    # Optional SARIF fallback
    if not findings and isinstance(data, dict) and "runs" in data:
        for run in data.get("runs", []) or []:
            for res in (run or {}).get("results", []) or []:
                rule_id = res.get("ruleId") or ""
                level = (res.get("level") or "").lower() or "info"
                msg = res.get("message")
                if isinstance(msg, dict):
                    msg = msg.get("text")
                msg = msg or ""
                if only_reentrancy and not _REENTR_RE.search(f"{rule_id} {msg}"):
                    continue
                locs = res.get("locations") or []
                if not locs:
                    findings.append({
                        "severity": level,
                        "title": rule_id,
                        "detector": rule_id,
                        "description": msg,
                        "contract_path": "",
                        "line_no": None,
                        "hint": msg,
                    })
                else:
                    for loc in locs:
                        phys = (loc or {}).get("physicalLocation") or {}
                        art = phys.get("artifactLocation") or {}
                        region = phys.get("region") or {}
                        findings.append({
                            "severity": level,
                            "title": rule_id,
                            "detector": rule_id,
                            "description": msg,
                            "contract_path": art.get("uri") or "",
                            "line_no": region.get("startLine"),
                            "hint": msg,
                        })
    return findings


def _findings_by_file(report_path: Path, project_dir: Path, only_reentrancy: bool) -> Dict[str, List[Dict[str, Any]]]:
    """
    Build a map from multiple path keys -> findings list for robust file matching:
      - absolute: <project_dir>/<contract_path>
      - relative: as given in contract_path (normalized)
      - basename: file name only
    Keys are lowercase for matching.
    """
    items = _collect_findings_from_report(report_path, only_reentrancy)
    by: Dict[str, List[Dict[str, Any]]] = {}

    proj = project_dir.resolve()
    for it in items:
        cp = (it.get("contract_path") or "").strip()
        keys = set()
        if cp:
            # Normalize slash
            rel_norm = cp.replace("\\", "/").lstrip("./")
            abs_norm = (proj / rel_norm).resolve()
            keys.add(rel_norm.lower())  # relative form
            keys.add(abs_norm.as_posix().lower())  # absolute form
            keys.add(Path(rel_norm).name.lower())  # basename form
        else:
            keys.add("")  # unknown path bucket

        for k in keys:
            by.setdefault(k, []).append(it)
    return by


# --- core run --------------------------------------------------------------

def run_one(
        image: str,
        project_dir: Path,
        outdir: Path,
        ext: str,
        timeout: int,
        extra_args: List[str],
        fallback_solc: str,
        user_evm_override: str,
        svm_cache: Optional[str],
) -> RunResult:
    name_safe = project_dir.name.replace(" ", "_")
    if not ext.startswith("."):
        ext = "." + ext
    report_name = f"{name_safe}{ext}"
    report_path = (outdir / "reports" / report_name).resolve()
    log_path = (outdir / "logs" / f"{name_safe}.log").resolve()

    specs = extract_all_pragmas(project_dir)
    solc = pick_solc_from_pragmas(specs, fallback=fallback_solc)
    evm_version = pick_evm_for_solc(solc, user_evm_override)

    cmd = build_docker_cmd(image, project_dir, outdir, report_name, solc, evm_version, extra_args, svm_cache)

    start = time.time()
    status, rc, output = "success", 0, ""
    try:
        p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           text=True, encoding="utf-8", errors="replace", timeout=timeout)
        rc = p.returncode
        output = p.stdout or ""
        status = "success" if rc == 0 else "error"
    except subprocess.TimeoutExpired as te:
        status, rc, output = "timeout", -1, f"TIMEOUT after {timeout}s\n{te}\n"
    except FileNotFoundError:
        status, rc, output = "docker_missing", -2, "Docker CLI not found on PATH.\n"
    except Exception as e:
        status, rc, output = "exception", -3, f"Unhandled exception: {e}\n"
    elapsed = time.time() - start

    # Verify the report actually exists
    if status == "success" and not report_path.exists():
        status = "no_report"
        try:
            ls_cmd = [
                "docker", "run", "--rm",
                "-v", f"{outdir}:/out",
                "--entrypoint", "/bin/sh",
                image, "-lc", "ls -lah /out || true"
            ]
            ls_out = subprocess.run(ls_cmd, capture_output=True, text=True).stdout
            output = (output or "") + "\n[post-check] report file missing; /out contents:\n" + (ls_out or "(empty)")
        except Exception:
            pass

    write_log(
        log_path,
        {
            "project_dir": project_dir,
            "image": image,
            "solc_version": solc,
            "evm_version": evm_version or "(default)",
            "command": " ".join(shlex.quote(c) for c in cmd),
            "report_path": report_path,
            "status": status,
            "return_code": rc,
            "elapsed_seconds": f"{elapsed:.2f}",
            "pragma_specs": "; ".join(specs) or "(none found)",
        },
        output,
    )
    return RunResult(project_dir.name, str(project_dir.resolve()), status, str(report_path), str(log_path), rc, elapsed)


def run_parallel(func, items: List[Path], workers: int):
    from concurrent.futures import ThreadPoolExecutor, as_completed
    results = []
    with ThreadPoolExecutor(max_workers=max(1, workers)) as ex:
        futs = [ex.submit(func, it) for it in items]
        for fut in as_completed(futs):
            results.append(fut.result())
    return results


def present_table(results: List[RunResult], outdir: Path) -> None:
    ok = sum(1 for r in results if r.status == "success")
    if RICH:
        table = Table(title="Aderyn Batch Summary (Docker)")
        table.add_column("Project")
        table.add_column("Status")
        table.add_column("Report")
        table.add_column("Log")
        table.add_column("RC", justify="right")
        table.add_column("Sec", justify="right")
        for r in sorted(results, key=lambda x: x.project_name.lower()):
            table.add_row(r.project_name, r.status, r.report_path, r.log_path, str(r.return_code), f"{r.elapsed_s:.1f}")
        CON.print(table)
        CON.print(f"[bold green]{ok}[/bold green]/{len(results)} succeeded • Results: {outdir}")
    else:
        print(f"\nSummary: {ok}/{len(results)} succeeded • Results: {outdir}")
        for r in sorted(results, key=lambda x: x.project_name.lower()):
            print(f"- {r.project_name:30} {r.status:10} rc={r.return_code:3} {r.elapsed_s:6.1f}s")
            print(f"  report: {r.report_path}")
            print(f"  log   : {r.log_path}")


def write_summary_csv(results: List[RunResult], outdir: Path) -> Path:
    summary_csv = outdir / "analysis_run_log.csv"
    with open(summary_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["project_name", "status", "project_dir", "report_path", "log_path", "return_code", "elapsed_s"])
        for r in results:
            w.writerow([r.project_name, r.status, r.project_dir, r.report_path, r.log_path, r.return_code,
                        f"{r.elapsed_s:.2f}"])
    return summary_csv


# --- SmartBugs writer ------------------------------------------------------

def write_smartbugs_summary(results: List[RunResult], outdir: Path, name: str, only_reentrancy: bool) -> Path:
    """
    SmartBugs-style CSV (one row per Solidity file):
      filename,basename,toolid,toolmode,parser_version,runid,start,duration,exit_code,findings,infos,errors,fails

    - filename  → absolute path to the .sol file
    - basename  → file name (e.g., Send_safe1.sol)
    - findings  → JSON array of findings for that file (filtered by --only-reentrancy if set)
    """
    out_csv = outdir / name
    with open(out_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow([
            "filename", "basename", "toolid", "toolmode", "parser_version", "runid",
            "start", "duration", "exit_code", "findings", "infos", "errors", "fails"
        ])

        for r in sorted(results, key=lambda x: x.project_name.lower()):
            proj_dir = Path(r.project_dir)
            report = Path(r.report_path)
            findings_map: Dict[str, List[Dict[str, Any]]] = {}
            if report.exists():
                findings_map = _findings_by_file(report, proj_dir, only_reentrancy)

            try:
                sol_files = sorted(proj_dir.rglob("*.sol"))
            except Exception:
                sol_files = []

            if not sol_files:
                # Fallback: emit one row (project-level) with empty findings
                w.writerow([
                    str(proj_dir), proj_dir.name, "aderyn", "", "", "", "",
                    f"{r.elapsed_s:.2f}", r.return_code, "[]", "", "", ""
                ])
                continue

            for sol in sol_files:
                # Lower-cased keys for lookup
                abs_key = sol.resolve().as_posix().lower()
                rel_key = sol.relative_to(proj_dir).as_posix().lower()
                name_key = sol.name.lower()

                # Merge findings matched by absolute, relative or basename
                matched = []
                matched += findings_map.get(abs_key, [])
                matched += findings_map.get(rel_key, [])
                matched += findings_map.get(name_key, [])

                # De-duplicate by a simple tuple of (title, detector, line_no, contract_path)
                seen = set()
                uniq = []
                for it in matched:
                    t = (it.get("title"), it.get("detector"), it.get("line_no"), it.get("contract_path"))
                    if t not in seen:
                        seen.add(t)
                        uniq.append(it)

                findings_json = json.dumps(uniq, ensure_ascii=False, separators=(",", ":"))
                w.writerow([
                    str(sol.resolve()),  # filename (full path)
                    sol.name,  # basename
                    "aderyn",  # toolid
                    "", "", "", "",  # toolmode, parser_version, runid, start
                    f"{r.elapsed_s:.2f}",  # duration
                    r.return_code,  # exit_code
                    findings_json,  # findings
                    "", "", ""  # infos, errors, fails
                ])
    return out_csv


# --- main ------------------------------------------------------------------

def main(argv: Optional[Iterable[str]] = None) -> int:
    ap = argparse.ArgumentParser(
        description="Batch-run Aderyn (Docker) on Solidity folders — detects pragma → installs solc → picks EVM → runs analysis → SmartBugs CSV."
    )
    ap.add_argument("root", type=Path, help="Dataset root.")
    ap.add_argument("--image", default=DEFAULT_IMAGE, help=f"Docker image (default: {DEFAULT_IMAGE}).")
    ap.add_argument("--outdir", "-o", type=Path, default=DEFAULT_OUTDIR,
                    help=f"Output dir (default: {DEFAULT_OUTDIR}).")
    ap.add_argument("--ext", default=DEFAULT_EXT,
                    help=f"Report extension (.json | .md | .sarif). Default: {DEFAULT_EXT}")
    ap.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT,
                    help=f"Timeout seconds (default: {DEFAULT_TIMEOUT}).")
    ap.add_argument("--workers", type=int, default=DEFAULT_WORKERS,
                    help=f"Parallel containers (default: {DEFAULT_WORKERS}).")
    ap.add_argument("--include-hidden", action="store_true", help="Scan hidden folders too.")
    ap.add_argument("--extra-args", default="", help='Extra args passed to Aderyn, e.g. "--no-snippets".')
    ap.add_argument("--fallback-solc", default=DEFAULT_FALLBACK_SOLC,
                    help=f"Fallback solc patch if pragma missing (default: {DEFAULT_FALLBACK_SOLC}).")
    ap.add_argument("--evm-version", default=DEFAULT_EVM_VERSION,
                    help='Override EVM target (e.g., "shanghai"). If omitted, it is picked from solc.')
    ap.add_argument("--svm-cache", default=DEFAULT_SVM_CACHE,
                    help=f"Host path to mount as the container's ~/.svm cache (default: {DEFAULT_SVM_CACHE}). "
                         "Set to '' to disable mounting a cache.")
    ap.add_argument("--smartbugs-csv", default=DEFAULT_AGG_NAME,
                    help=f"Output CSV filename for SmartBugs-style summary (default: {DEFAULT_AGG_NAME}).")
    ap.add_argument("--only-reentrancy", action="store_true",
                    help="Include only reentrancy-related findings in the SmartBugs CSV 'findings' column.")

    args = ap.parse_args(argv)

    require_docker()
    root = args.root.resolve()
    if not root.is_dir():
        print(f"ERROR: Root does not exist or is not a directory: {root}", file=sys.stderr)
        return 2

    outdir = args.outdir.resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    targets = find_solidity_dirs(root, include_hidden=args.include_hidden)
    if not targets:
        print(f"WARNING: No Solidity files found under {root}. Nothing to do.")
        return 0

    extra_args = shlex.split(args.extra_args) if args.extra_args.strip() else []

    # Cap workers to the number of targets (prevents useless threads)
    workers = max(1, min(args.workers, len(targets)))

    def _runner(p: Path) -> RunResult:
        return run_one(args.image, p, outdir, args.ext, args.timeout, extra_args,
                       args.fallback_solc, args.evm_version, args.svm_cache or None)

    if RICH:
        with Progress(SpinnerColumn(), "[progress.description]{task.description}", BarColumn(),
                      TaskProgressColumn(), TimeElapsedColumn(), transient=True) as progress:
            task = progress.add_task("Running Aderyn in Docker…", total=len(targets))
            from concurrent.futures import ThreadPoolExecutor, as_completed
            results: List[RunResult] = []
            with ThreadPoolExecutor(max_workers=workers) as ex:
                futs = {ex.submit(_runner, t): t for t in targets}
                for fut in as_completed(futs):
                    results.append(fut.result())
                    progress.advance(task)
    else:
        print(f"Found {len(targets)} folders. Running with workers={workers}, timeout={args.timeout}s")
        results = run_parallel(_runner, targets, workers)

    summary_csv = write_summary_csv(results, outdir)
    if RICH:
        CON.print(f"[bold]Wrote:[/bold] {summary_csv}")

    # --- SmartBugs per-file summary ---
    sb_csv = write_smartbugs_summary(results, outdir, args.smartbugs_csv, args.only_reentrancy)
    if RICH:
        CON.print(f"[bold]Wrote:[/bold] {sb_csv}")
    else:
        print(f"Wrote: {sb_csv}")

    # Non-zero exit if any failures
    if any(r.status != "success" for r in results):
        print(f"One or more runs failed. See logs and {summary_csv}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
