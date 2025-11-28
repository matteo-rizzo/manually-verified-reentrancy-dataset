#!/usr/bin/env python3
import argparse
import csv
import json
import os
from pathlib import Path
from typing import List, Dict, Any

HEADERS = [
    "filename",
    "basename",
    "toolid",
    "toolmode",
    "parser_version",
    "runid",
    "start",
    "duration",
    "exit_code",
    "findings",
    "infos",
    "errors",
    "fails",
]

INFO_FILES = ["dao_path_info.json", "tod_path_info.json"]

def is_leaf_dir(p: Path) -> bool:
    """Leaf dir = has no subdirectories."""
    try:
        for e in p.iterdir():
            if e.is_dir():
                return False
    except PermissionError:
        return False
    return True

def extract_bug_types_from_info_file(info_path: Path) -> List[str]:
    """
    Read a *_path_info.json file whose top-level is a dict of entries.
    Each entry is a dict that may contain `bug_type`. Collect them.
    """
    bug_types: List[str] = []
    seen = set()
    try:
        with open(info_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, dict):
            for _, entry in data.items():
                if isinstance(entry, dict):
                    bt = entry.get("bug_type")
                    if isinstance(bt, str) and bt:
                        if bt not in seen:
                            bug_types.append(bt)
                            seen.add(bt)
    except Exception:
        # Ignore unreadable/malformed files
        pass
    return bug_types

def collect_bug_types(dirpath: Path) -> List[str]:
    """Aggregate unique bug_types across dao_path_info.json and tod_path_info.json."""
    all_bts: List[str] = []
    seen = set()
    for name in INFO_FILES:
        p = dirpath / name
        if p.is_file():
            for bt in extract_bug_types_from_info_file(p):
                if bt not in seen:
                    all_bts.append(bt)
                    seen.add(bt)
    return all_bts

def main():
    ap = argparse.ArgumentParser(description="Summarize bug_types from *_path_info.json in leaf result dirs.")
    ap.add_argument("--root", default="results", help="Root results directory (default: results)")
    ap.add_argument("--out", default="summary.csv", help="Output CSV (default: summary.csv)")
    args = ap.parse_args()

    root = Path(args.root).resolve()
    out_path = Path(args.out).resolve()
    out_path.parent.mkdir(parents=True, exist_ok=True)

    rows: List[Dict[str, Any]] = []

    if root.exists() and root.is_dir():
        for dirpath, subdirs, files in os.walk(root):
            p = Path(dirpath)
            if subdirs:  # not a leaf
                continue

            bug_types = collect_bug_types(p)

            tmp_path = p.name.replace("__", "/")

            row = {
                "filename": p.parts[-3].removesuffix("_flat") + "/" + tmp_path + ".sol",
                "basename": tmp_path.split("/")[-1] + ".sol",
                "toolid": "sailfish",
                "toolmode": "",
                "parser_version": "",
                "runid": "",
                "start": "",
                "duration": "",
                "exit_code": "",
                # findings is a JSON array of bug_type strings (or blank if none)
                "findings": json.dumps(bug_types, ensure_ascii=False) if bug_types else "",
                "infos": "",
                "errors": "",
                "fails": "",
            }
            rows.append(row)
    else:
        print(f"[WARN] Root directory '{root}' not found or not a directory. Writing header only.")

    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=HEADERS)
        w.writeheader()
        w.writerows(rows)

    print(f"Wrote {len(rows)} rows to {out_path}")

if __name__ == "__main__":
    main()
