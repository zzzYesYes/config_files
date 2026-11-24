#!/usr/bin/env python3
"""Check Markdown files recursively for lines longer than the configured limit."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable

DEFAULT_LIMIT = 100
EXCLUDED_DIRECTORIES = {
    ".git",
    ".hg",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    ".svn",
    ".tox",
    ".venv",
    "build",
    "dist",
    "node_modules",
    "target",
    "vendor",
}


def markdown_files(root: Path) -> Iterable[Path]:
    """Yield Markdown files below root while skipping generated dependency trees."""

    if root.is_file():
        if root.suffix.lower() in {".md", ".markdown"}:
            yield root
        return

    for path in root.rglob("*"):
        if any(part in EXCLUDED_DIRECTORIES for part in path.parts):
            continue
        if path.is_file() and path.suffix.lower() in {".md", ".markdown"}:
            yield path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fail when Markdown lines exceed the configured character limit."
    )
    parser.add_argument(
        "paths",
        nargs="*",
        type=Path,
        default=[Path.cwd()],
        help="Files or directories to check; defaults to the current directory.",
    )
    parser.add_argument(
        "--max-length",
        type=int,
        default=DEFAULT_LIMIT,
        help=f"Maximum characters per line; defaults to {DEFAULT_LIMIT}.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    violations: list[tuple[Path, int, int]] = []
    checked: set[Path] = set()

    for requested_path in args.paths:
        root = requested_path.expanduser().resolve()
        for path in markdown_files(root):
            resolved = path.resolve()
            if resolved in checked:
                continue
            checked.add(resolved)
            for line_number, line in enumerate(
                path.read_text(encoding="utf-8").splitlines(),
                start=1,
            ):
                if len(line) > args.max_length:
                    violations.append((path, line_number, len(line)))

    if violations:
        for path, line_number, length in violations:
            print(f"{path}:{line_number}: {length} characters")
        return 1

    print(
        f"Checked {len(checked)} Markdown files; "
        f"all lines are at most {args.max_length} characters."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
