#!/usr/bin/env python3
"""Export candidate hardware-rework configurations and report mesh metrics.

This checks parametric rework outputs for valid, single-component, watertight
meshes. It does not compare the new mechanical interfaces against FreeCAD,
which contains none of those features.
"""
import argparse
import json
import subprocess
import tempfile
from pathlib import Path

import trimesh


def mesh_metrics(path):
    mesh = trimesh.load(path, force="mesh")
    components = mesh.split(only_watertight=False)
    # A blind insert bore creates an enclosed cavity. STL stores that cavity as
    # a separate, inward-wound shell, so shell count is not the same as the
    # number of disconnected printable solids.
    solid_components = [part for part in components if part.volume > 0]
    cavity_shells = [part for part in components if part.volume < 0]
    return {
        "bounds_mm": mesh.bounds.tolist(),
        "volume_mm3": float(mesh.volume),
        "area_mm2": float(mesh.area),
        "shells": len(components),
        "solid_components": len(solid_components),
        "enclosed_cavity_shells": len(cavity_shells),
        "watertight": bool(mesh.is_watertight),
        "winding_consistent": bool(mesh.is_winding_consistent),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--scad", default="plastic_case/hafele_control_box.scad")
    parser.add_argument("--configs", default="plastic_case/tests/rework_configurations.json")
    parser.add_argument("--openscad", default="openscad")
    parser.add_argument("--out", default="/tmp/hafele-rework-validation.json")
    args = parser.parse_args()

    scad = Path(args.scad).resolve()
    configs = json.loads(Path(args.configs).read_text())
    results = []
    for config in configs:
        with tempfile.TemporaryDirectory(prefix="hafele-rework-") as td:
            stl = Path(td) / "part.stl"
            definitions = []
            for name, value in config["parameters"].items():
                definitions.extend(["-D", f"{name}={json.dumps(value)}"])
            process = subprocess.run(
                [args.openscad, "-o", str(stl), *definitions, str(scad)],
                check=True, capture_output=True, text=True,
            )
            metrics = mesh_metrics(stl)
            valid = (metrics["watertight"] and metrics["winding_consistent"]
                     and metrics["solid_components"] == 1)
            if not valid:
                raise RuntimeError(f"{config['name']} produced an invalid mesh: {metrics}")
            status = process.stdout+process.stderr
            if "Status:     NoError" not in status:
                raise RuntimeError(f"{config['name']} OpenSCAD reported a geometry warning:\n{status}")
            results.append({
                "configuration": config["name"],
                "parameters": config["parameters"],
                "metrics": metrics,
                "openscad_status": "NoError",
            })

    output = Path(args.out)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(results, indent=2)+"\n")
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
