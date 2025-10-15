"""Command line interface for the Forge SDD toolkit initializer."""

from __future__ import annotations

import argparse
import logging
import os
import shutil
from dataclasses import dataclass
from importlib.resources import as_file, files
from pathlib import Path
from typing import Iterable, Iterator

LOGGER = logging.getLogger("toolkit_forge_cli")


@dataclass(frozen=True)
class CopyPlan:
    """Represents a directory copy operation."""

    source: str
    destination: Path


def iter_files(root: Path) -> Iterator[Path]:
    """Yield all files under ``root`` recursively."""

    for current_root, _dirs, filenames in os.walk(root):
        current_path = Path(current_root)
        for filename in filenames:
            yield current_path / filename


def copy_tree(src: Path, dest: Path, *, force: bool = False) -> tuple[int, int]:
    """Copy ``src`` into ``dest``.

    Returns a tuple ``(copied, skipped)`` counting files copied versus skipped
    because they already existed and ``force`` was ``False``.
    """

    copied = 0
    skipped = 0

    for file_path in iter_files(src):
        relative_path = file_path.relative_to(src)
        target_path = dest / relative_path
        target_path.parent.mkdir(parents=True, exist_ok=True)

        if target_path.exists() and not force:
            LOGGER.info("Skipping existing file: %s", target_path)
            skipped += 1
            continue

        if target_path.exists() and force:
            if target_path.is_file():
                target_path.unlink()
            else:
                shutil.rmtree(target_path)

        shutil.copy2(file_path, target_path)
        copied += 1
        LOGGER.debug("Copied %s -> %s", file_path, target_path)

    return copied, skipped


def run_init(force: bool = False) -> None:
    """Initialize the Forge SDD toolkit structure in the current directory."""

    destination_root = Path.cwd()
    LOGGER.info("Initializing Forge SDD toolkit at %s", destination_root)

    data_root = files("toolkit_forge_cli.data")

    plans: Iterable[CopyPlan] = (
        CopyPlan(".github", destination_root / ".github"),
        CopyPlan(".toolkit-forge-sdd", destination_root / ".toolkit-forge-sdd"),
        CopyPlan("toolkit-forge-docs", destination_root / "toolkit-forge-docs"),
    )

    total_copied = 0
    total_skipped = 0

    for plan in plans:
        with as_file(data_root / plan.source) as src_path_obj:
            src_path = Path(src_path_obj)
            dest_path = plan.destination
            dest_path.mkdir(parents=True, exist_ok=True)
            copied, skipped = copy_tree(src_path, dest_path, force=force)
            total_copied += copied
            total_skipped += skipped
            LOGGER.info(
                "Seeded %s (%d copied, %d skipped)",
                dest_path.relative_to(destination_root),
                copied,
                skipped,
            )

    LOGGER.info(
        "Forge SDD toolkit ready. Files copied: %d, skipped: %d", total_copied, total_skipped
    )
    LOGGER.info(
        "Next steps: open this folder in VS Code and enable GitHub Copilot to pick up the prompts."
    )


def build_parser() -> argparse.ArgumentParser:
    """Create the CLI argument parser."""

    parser = argparse.ArgumentParser(
        prog="toolkit-forge",
        description="Initialize the Forge SDD toolkit structure in the current workspace.",
    )

    subparsers = parser.add_subparsers(dest="command")
    init_parser = subparsers.add_parser(
        "init",
        help="Create the .github, .toolkit-forge-sdd, and toolkit-forge-docs directories with seeded content.",
    )
    init_parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing files instead of skipping them.",
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    """Entry point for the console script."""

    logging.basicConfig(level=logging.INFO, format="%(message)s")

    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "init":
        run_init(force=args.force)
        return 0

    parser.print_help()
    return 1


if __name__ == "__main__":  # pragma: no cover - CLI entry point
    raise SystemExit(main())
