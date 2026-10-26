#!/usr/bin/env python3
"""Check measured board boxes, connected-control routing and assembly tools.

Printed parts and each hardware/approach envelope are independently exported as
positive controls. The board boxes include measured maximum component/solder
height. They are deliberately conservative, not component-level PCB scans.
Board-support and own-clamp contact is measured and explicitly excluded; the
component-free PCB edge bands still require physical confirmation.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import tempfile

from validate_clearance import (
    PARTS, ValidationError, export_part, intersection_volume, load_configs,
)


ENVELOPES = {
    "enclosure_walls": ("union() { enclosure_shell(); end_closures(); }", 1),
    "proto_envelope": (
        "translate([board_left_x(),proto_y0(),board_lowest_z()]) "
        "cube([proto_width,proto_length,proto_total_height]);", 1),
    "supply_envelope": (
        "translate([board_left_x(),supply_y0(),board_lowest_z()]) "
        "cube([supply_length,supply_width,supply_total_height]);", 1),
    "control_connectors_and_bends": (
        "control_connector_envelopes(wire_allowance=true);", 2),
    "controls_driver_approach": ("controls_tool_access(false);", 3),
    "controls_insert_iron_approach": ("controls_tool_access(true);", 3),
    "board_driver_approach": ("board_tool_access(false);", 2),
    "board_insert_iron_approach": ("board_tool_access(true);", 2),
    "closure_quarter_inch_bit_approach": (
        "for (x=lid_tower_xs(),y=[-source_tower_edge(),-longitud+source_tower_edge()]) "
        "translate([x,y,-1]) cylinder(d=6.35,h=closure_head_z()+1,$fn=64);", 4),
}

BOARDS = ("proto_envelope", "supply_envelope")


def required_pairs():
    pairs = [(board, other) for board in BOARDS
             for other in ("enclosure_walls", "lid", "controls_bracket")]
    pairs += [("proto_envelope", "supply_envelope"),
              ("proto_envelope", "supply_clamp"),
              ("supply_envelope", "proto_clamp")]
    pairs += [("control_connectors_and_bends", other) for other in (*PARTS, *BOARDS)]
    pairs += [("controls_driver_approach", other)
              for other in ("case", "controls_bracket", *BOARDS,
                            "control_connectors_and_bends")]
    pairs += [("controls_insert_iron_approach", "case")]
    pairs += [("board_driver_approach", other)
              for other in ("case", "controls_bracket", "proto_clamp", "supply_clamp",
                            *BOARDS, "control_connectors_and_bends")]
    pairs += [("board_insert_iron_approach", "case")]
    pairs += [("closure_quarter_inch_bit_approach", other) for other in ("case", "lid")]
    return pairs


EXCLUDED_CONTACTS = [
    ("proto_envelope", "case",
     "Four corner support pads: radius 1.25 mm, centres 1 mm from board edges. "
     "The maximum-height solid box includes these intended supports. Bare PCB "
     "edge/component-free underside at the pads is an unverified assumption."),
    ("supply_envelope", "case",
     "Four corner support pads: radius 1.25 mm, centres 1 mm from board edges. "
     "Solder-free support locations must be confirmed on the actual supply."),
    ("proto_envelope", "proto_clamp",
     "Own clamp contacts the bare PCB edge: up to 2.5 mm into the outline, "
     "8 mm along the edge, at board_top_z() through +2 mm. Component-free edge "
     "width and underside solder clearance are not measured."),
    ("supply_envelope", "supply_clamp",
     "Own clamp contacts the bare PCB edge: up to 2.5 mm into the outline, "
     "8 mm along the edge, at board_top_z() through +2 mm. Component-free edge "
     "width and underside solder clearance are not measured."),
]


def validate_configuration(source, config, openscad, tolerance):
    result = {"configuration": config["name"], "parameters": config["parameters"],
              "parts": {}, "checks": [], "excluded_contacts": [], "passed": False,
              "physical_fit_certified": False}
    try:
        with tempfile.TemporaryDirectory(prefix="hafele-measured-fit-") as directory:
            meshes = {}
            assets = {name: (expression, 1) for name, expression in PARTS.items()}
            assets.update(ENVELOPES)
            for name, (expression, components) in assets.items():
                meshes[name], result["parts"][name] = export_part(
                    source, expression, Path(directory)/(name+".stl"), openscad,
                    config["parameters"], expected_components=components)
            for first, second in required_pairs():
                volume = intersection_volume(meshes[first], meshes[second])
                result["checks"].append({"first": first, "second": second,
                                         "intersection_volume_mm3": volume,
                                         "passed": volume <= tolerance})
            for first, second, reason in EXCLUDED_CONTACTS:
                volume = intersection_volume(meshes[first], meshes[second])
                result["excluded_contacts"].append({
                    "first": first, "second": second,
                    "intersection_volume_mm3": volume,
                    "excluded_from_clearance_verdict": True,
                    "contact_band_and_limitations": reason})
            result["passed"] = all(check["passed"] for check in result["checks"])
    except (ValidationError, OSError, ValueError, ImportError, RuntimeError) as error:
        result["error"] = str(error)
    return result


def source_hashes(source):
    files = [source, *sorted((source.parent/"lib").glob("*.scad"))]
    measurements = source.parent/"hardware_measurements.json"
    if measurements.is_file():
        files.append(measurements)
    return {str(path.relative_to(source.parent)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in files}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scad", type=Path, default=Path("plastic_case/hafele_control_box.scad"))
    parser.add_argument("--openscad", default="openscad")
    parser.add_argument("--configs", type=Path)
    parser.add_argument("--tolerance-mm3", type=float, default=1e-4)
    parser.add_argument("--out", type=Path, default=Path("/tmp/hafele-measured-fit.json"))
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
    report = {
        "source": str(source), "source_files_sha256": source_hashes(source),
        "tolerance_mm3": args.tolerance_mm3, "boolean_engine": "manifold",
        "passed": all(result["passed"] for result in results),
        "physical_fit_certified": False,
        "expected_part_count": len(PARTS)+len(ENVELOPES),
        "expected_check_count": len(required_pairs()),
        "scope": "Conservative two-board maximum boxes, connected-control plastic plus "
                 "configured wire-bend allowance, upright controls/board driver and insert-iron "
                 "access and bottom closure access for a 6.35 mm stock bit. "
                 "Internal driver/iron access requires the body detached from its desk-fixed "
                 "lid. Insert-iron access assumes an empty case with electronics and removable "
                 "brackets/clamps absent. Board iron uses a 6 mm tip for the first 12 mm, "
                 "then the configured barrel diameter (12 mm default) for 48 mm. Vertical corridors "
                 "end/start at their seating/head planes and permit surface-only contact. "
                 "Excluded PCB edge contacts are reported with real overlap volume, "
                 "not interpreted as empty clearance. No actuator or board insertion "
                 "trajectory is certified.",
        "assembly_stages": {
            "internal_drivers": {
                "corridors": ["controls_driver_approach", "board_driver_approach"],
                "lid": "removed; case body detached from desk-fixed lid before service",
                "electronics": "installed; measured maximum envelopes and connectors checked",
                "own_screw_head_contact": "Surface-only contact at the head plane is allowed",
                "excluded_part": "lid; it is physically absent at this assembly stage"},
            "insert_installation": {
                "corridors": ["controls_insert_iron_approach", "board_insert_iron_approach"],
                "case": "empty case only",
                "absent": ["lid", "controls_bracket", "proto_clamp", "supply_clamp",
                           "both electronics assemblies", "connected control wiring"]},
            "closure_screw_release": {
                "corridor": "closure_quarter_inch_bit_approach",
                "lid": "installed and desk-fixed",
                "direction": "from below case bottom up to closure screw head face",
                "bit_diameter_mm": 6.35,
                "limit": "Stops at head face below the wood/lid; releases body before internal service"}},
        "configurations": results,
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, indent=2, allow_nan=False)+"\n")
    for result in results:
        largest = max((check["intersection_volume_mm3"] for check in result["checks"]), default=0)
        print(f"{result['configuration']}: {'PASS' if result['passed'] else 'FAIL'}; "
              f"{len(result['parts'])} positive envelope exports, "
              f"{len(result['checks'])}/{len(required_pairs())} checks; "
              f"maximum enforced overlap {largest:.9g} mm^3")
        for check in result["checks"]:
            if not check["passed"]:
                print(f"Collision: {check['first']}/{check['second']}: "
                      f"{check['intersection_volume_mm3']:.9g} mm^3")
        if "error" in result:
            print(result["error"])
    print(f"Report: {args.out}")
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
