#!/usr/bin/env python3
import argparse
import csv
import json
import os
import re
import sys
from pathlib import Path
from typing import List, Dict, Any

# ---------- Defaults ----------
DEFAULT_AGG_NAME = os.getenv("ADERYN_SMARTBUGS_CSV", "smartbugs_summary.csv")
_REENTR_RE = re.compile(r"re-?entr", re.IGNORECASE)


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


def load_run_log(results_dir: Path) -> List[Dict[str, Any]]:
    """Reads the analysis_run_log.csv generated by the runner script."""
    log_file = results_dir / "analysis_run_log.csv"
    results = []

    if not log_file.exists():
        print(f"WARNING: Run log not found at {log_file}. SmartBugs CSV will lack duration/exit codes.")
        return results

    try:
        with open(log_file, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                results.append(row)
    except Exception as e:
        print(f"ERROR reading run log: {e}")

    return results


def write_smartbugs_summary(run_data: List[Dict[str, Any]], outdir: Path, name: str, only_reentrancy: bool) -> Path:
    """
    SmartBugs-style CSV (one row per Solidity file).
    Uses the data from analysis_run_log.csv to map projects to their reports.
    """
    out_csv = outdir / name
    with open(out_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow([
            "filename", "basename", "toolid", "toolmode", "parser_version", "runid",
            "start", "duration", "exit_code", "findings", "infos", "errors", "fails"
        ])

        # Sort by project name
        for r in sorted(run_data, key=lambda x: x.get("project_name", "").lower()):
            proj_dir_str = r.get("project_dir", "")
            if not proj_dir_str: continue

            proj_dir = Path(proj_dir_str)
            report_path_str = r.get("report_path", "")
            report = Path(report_path_str)

            elapsed_s = r.get("elapsed_s", "0")
            return_code = r.get("return_code", "0")

            findings_map: Dict[str, List[Dict[str, Any]]] = {}
            if report.exists():
                findings_map = _findings_by_file(report, proj_dir, only_reentrancy)
            else:
                # If path in CSV is absolute but we are running elsewhere, check relative to outdir
                alt_report = outdir / "reports" / report.name
                if alt_report.exists():
                    findings_map = _findings_by_file(alt_report, proj_dir, only_reentrancy)

            try:
                # We need to find the solidity files to map findings to them.
                # If the project dir moved, this might fail, but we assume
                # the parser runs in the same environment as the runner.
                sol_files = sorted(proj_dir.rglob("*.sol"))
            except Exception:
                sol_files = []

            if not sol_files:
                # Fallback: emit one row (project-level) with empty findings
                w.writerow([
                    str(proj_dir), proj_dir.name, "aderyn", "", "", "", "",
                    elapsed_s, return_code, "[]", "", "", ""
                ])
                continue

            for sol in sol_files:
                # Lower-cased keys for lookup
                abs_key = sol.resolve().as_posix().lower()
                try:
                    rel_key = sol.relative_to(proj_dir).as_posix().lower()
                except ValueError:
                    # In case sol file is not strictly inside proj_dir (symlinks etc)
                    rel_key = sol.name.lower()

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
                    elapsed_s,  # duration
                    return_code,  # exit_code
                    findings_json,  # findings
                    "", "", ""  # infos, errors, fails
                ])
    return out_csv


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Parse Aderyn results into SmartBugs-style CSV."
    )
    ap.add_argument("--results-dir", "-d", type=Path, default=Path("./results"),
                    help="Directory containing the 'reports' folder and 'analysis_run_log.csv'.")
    ap.add_argument("--smartbugs-csv", default=DEFAULT_AGG_NAME,
                    help=f"Output filename (default: {DEFAULT_AGG_NAME}).")
    ap.add_argument("--only-reentrancy", action="store_true",
                    help="Include only reentrancy-related findings.")

    args = ap.parse_args()

    results_dir = args.results_dir.resolve()
    if not results_dir.exists():
        print(f"Error: Results directory {results_dir} does not exist.")
        return 1

    # Load run metadata
    run_data = load_run_log(results_dir)
    if not run_data:
        print("No run data loaded. Ensure 'analysis_run_log.csv' exists in results dir.")
        return 1

    print(f"Parsing {len(run_data)} entries from {results_dir}...")

    # Write SmartBugs summary
    sb_csv = write_smartbugs_summary(run_data, results_dir, args.smartbugs_csv, args.only_reentrancy)
    print(f"Wrote SmartBugs summary to: {sb_csv}")

    return 0


if __name__ == "__main__":
    sys.exit(main())