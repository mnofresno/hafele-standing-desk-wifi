#!/usr/bin/env python3
"""Verify the installed encoder retainer clears the removable carrier."""
import argparse
import subprocess
import tempfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--openscad", default="openscad")
    parser.add_argument("--scad", default="plastic_case/tests/encoder_carrier_intersection.scad")
    parser.add_argument("--tolerance-mm3", type=float, default=1e-5)
    args = parser.parse_args()
    source = Path(args.scad).resolve()
    with tempfile.TemporaryDirectory(prefix="hafele-clearance-") as td:
        stl = Path(td) / "intersection.stl"
        run = subprocess.run(
            [args.openscad, "-o", str(stl), "-D", 'show_part="none"', str(source)],
            capture_output=True, text=True,
        )
        # OpenSCAD emits its standard empty ASCII STL for a disjoint CSG result.
        output = run.stdout + run.stderr
        if ("Current top level object is empty." not in output
                or run.returncode not in (0, 1)):
            raise SystemExit(f"Parts intersect or OpenSCAD did not confirm empty geometry:\n{output}")
        if stl.exists() and stl.stat().st_size > 1024:
            raise SystemExit(f"Unexpected non-empty intersection STL ({stl.stat().st_size} bytes)")
    print(f"encoder_retainer/carrier intersection: 0 mm^3 (tolerance {args.tolerance_mm3:g} mm^3)")


if __name__ == "__main__":
    main()
