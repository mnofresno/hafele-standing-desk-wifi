#!/usr/bin/env python3
"""Validate five installed rework parts and all ten pairwise clearances.

Each part is exported and checked independently before Boolean intersections
are measured with manifold3d. An empty OpenSCAD result is an error for a part:
a missing include/module must never masquerade as a clear assembly.
Zero-volume surface contact is allowed; positive overlap is compared to the
configured tolerance in cubic millimetres. This checks printed geometry, not
unmodeled electronics or a physical assembly/insertion path.
"""
import argparse
import hashlib
import itertools
import json
import math
from pathlib import Path
import re
import subprocess
import tempfile

import numpy as np
import trimesh


PARTS = {
    "case": "case_body();",
    "lid": "case_lid_installed();",
    "controls_bracket": "controls_bracket();",
    "proto_clamp": "board_clamp(0);",
    "supply_clamp": "board_clamp(1);",
}
DIAGNOSTIC = re.compile(r"^\s*(?:WARNING|ERROR|Parser error|Fatal error)\s*:", re.M | re.I)


class ValidationError(RuntimeError):
    """The exported geometry or clearance does not meet the requested check."""


def export_part(source, expression, target, openscad, parameters, expected_components=1):
    """Export a positive control; reject empty output and all CLI diagnostics."""
    wrapper = target.with_suffix(".scad")
    if any(character in str(source) for character in (">", "\n", "\r")):
        raise ValidationError("The OpenSCAD include path contains an unsupported character")
    wrapper.write_text(f"include <{source.as_posix()}>;\n{expression}\n")
    definitions = []
    for name, value in parameters.items():
        if not re.fullmatch(r"[A-Za-z_$][A-Za-z0-9_$]*", name):
            raise ValidationError(f"Invalid OpenSCAD parameter name: {name!r}")
        definitions.extend(["-D", f"{name}={json.dumps(value, allow_nan=False)}"])
    # Override the model selector to prevent duplicate top-level assembly output.
    definitions.extend(["-D", 'show_part="none"', "-D", "show_exploded=false"])
    process = subprocess.run(
        [openscad, "-o", str(target), *definitions, str(wrapper)],
        capture_output=True, text=True,
    )
    log = process.stdout + process.stderr
    if process.returncode or DIAGNOSTIC.search(log):
        raise ValidationError(f"OpenSCAD export failed for {target.stem}:\n{log.strip()}")
    if not target.is_file() or target.stat().st_size == 0:
        raise ValidationError(f"OpenSCAD produced no mesh for {target.stem}:\n{log.strip()}")
    try:
        mesh = trimesh.load_mesh(target, process=True)
    except Exception as error:
        raise ValidationError(f"Cannot read {target.stem}: {error}") from error
    if not isinstance(mesh, trimesh.Trimesh) or len(mesh.faces) == 0:
        raise ValidationError(f"{target.stem} is an empty/non-mesh part")
    if not (np.isfinite(mesh.vertices).all() and math.isfinite(float(mesh.volume))):
        raise ValidationError(f"{target.stem} has non-finite geometry")
    shells = mesh.split(only_watertight=False)
    positive_components = sum(float(shell.volume) > 0 for shell in shells)
    metrics = {
        "volume_mm3": float(mesh.volume),
        "bounds_mm": mesh.bounds.tolist(),
        "watertight": bool(mesh.is_watertight),
        "winding_consistent": bool(mesh.is_winding_consistent),
        "positive_components": positive_components,
        "shells": len(shells),
    }
    if (metrics["volume_mm3"] <= 0 or not metrics["watertight"]
            or not metrics["winding_consistent"] or positive_components != expected_components):
        expected = "one positive watertight solid" if expected_components == 1 else f"{expected_components} positive watertight solids"
        raise ValidationError(f"{target.stem} is not {expected}: {metrics}")
    return mesh, metrics


def intersection_volume(first, second):
    intersection = trimesh.boolean.intersection(
        [first, second], engine="manifold", check_volume=True)
    if not isinstance(intersection, trimesh.Trimesh):
        raise ValidationError("Boolean engine returned no intersection mesh")
    # A permitted zero-volume contact has no finite centre of mass.
    with np.errstate(divide="ignore", invalid="ignore"):
        volume = abs(float(intersection.volume))
    if not math.isfinite(volume):
        raise ValidationError("Non-finite intersection volume")
    return volume


def validate_configuration(source, config, openscad, tolerance):
    result = {"configuration": config["name"], "parameters": config["parameters"],
              "parts": {}, "pairs": [], "passed": False}
    try:
        with tempfile.TemporaryDirectory(prefix="hafele-assembly-") as directory:
            meshes = {}
            for name, expression in PARTS.items():
                meshes[name], result["parts"][name] = export_part(
                    source, expression, Path(directory) / f"{name}.stl", openscad,
                    config["parameters"],
                )
            for first, second in itertools.combinations(PARTS, 2):
                volume = intersection_volume(meshes[first], meshes[second])
                result["pairs"].append({
                    "first": first, "second": second,
                    "intersection_volume_mm3": volume,
                    "passed": volume <= tolerance,
                })
            result["passed"] = all(pair["passed"] for pair in result["pairs"])
    except (ValidationError, OSError, ValueError, ImportError, RuntimeError) as error:
        result["error"] = str(error)
    return result


def load_configs(path):
    if path is None:
        return [{"name": "default", "parameters": {}}]
    configs = json.loads(path.read_text())
    if not isinstance(configs, list) or not configs:
        raise ValueError("--configs must contain a non-empty JSON list")
    for config in configs:
        if (not isinstance(config, dict) or not isinstance(config.get("name"), str)
                or not isinstance(config.get("parameters"), dict)):
            raise ValueError("Each configuration requires a string name and parameters object")
    return configs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--openscad", default="openscad")
    parser.add_argument("--scad", type=Path, default=Path("plastic_case/hafele_control_box.scad"))
    parser.add_argument("--configs", type=Path,
                        help="JSON list of {name, parameters} rework configurations")
    parser.add_argument("--tolerance-mm3", type=float, default=1e-4)
    parser.add_argument("--out", type=Path, default=Path("/tmp/hafele-assembly-clearance.json"))
    args = parser.parse_args()
    if not math.isfinite(args.tolerance_mm3) or args.tolerance_mm3 < 0:
        parser.error("--tolerance-mm3 must be finite and nonnegative")
    source = args.scad.resolve()
    if not source.is_file():
        parser.error(f"OpenSCAD source does not exist: {source}")
    try:
        configs = load_configs(args.configs)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    results = [validate_configuration(source, config, args.openscad, args.tolerance_mm3)
               for config in configs]
    report = {"source": str(source), "source_sha256":hashlib.sha256(source.read_bytes()).hexdigest(),
              "tolerance_mm3": args.tolerance_mm3,
              "boolean_engine": "manifold", "passed": all(item["passed"] for item in results),
              "configurations": results}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, indent=2, allow_nan=False) + "\n")
    for result in results:
        largest = max((pair["intersection_volume_mm3"] for pair in result["pairs"]), default=0)
        print(f"{result['configuration']}: {'PASS' if result['passed'] else 'FAIL'}; "
              f"{len(result['parts'])}/5 valid parts, {len(result['pairs'])}/10 pairs; "
              f"maximum overlap {largest:.9g} mm^3 (tolerance {args.tolerance_mm3:g} mm^3)")
        if "error" in result:
            print(result["error"])
        for pair in result["pairs"]:
            if not pair["passed"]:
                print(f"Collision: {pair['first']}/{pair['second']}: "
                      f"{pair['intersection_volume_mm3']:.9g} mm^3")
    print(f"Report: {args.out}")
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
