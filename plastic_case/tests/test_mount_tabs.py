"""Native-mesh checks for the rounded wood-mount tab library."""
import json
from pathlib import Path
import shutil
import subprocess

import numpy as np
import pytest
import trimesh


LIBRARY = Path(__file__).resolve().parents[1] / "lib" / "rounded_mount_tabs.scad"


def render_scad(tmp_path, name, source):
    openscad = shutil.which("openscad")
    if not openscad:
        pytest.skip("OpenSCAD CLI is required for the mount-tab checks")
    scad = tmp_path / f"{name}.scad"
    stl = tmp_path / f"{name}.stl"
    scad.write_text(source)
    result = subprocess.run([openscad, "-o", str(stl), str(scad)],
                            capture_output=True, text=True)
    return stl, result


def render_tabs(tmp_path, length=150):
    stl, result = render_scad(
        tmp_path, "tabs",
        f"use <{LIBRARY}>;\n"
        "difference() {\n"
        f"  rounded_mount_tabs(length={length});\n"
        "  wood_mount_hole_cutouts();\n"
        "}\n",
    )
    assert result.returncode == 0, result.stdout + result.stderr
    mesh = trimesh.load(stl, force="mesh")
    assert mesh.is_watertight and mesh.is_winding_consistent
    assert len(mesh.split()) == 2
    return stl, mesh


def assert_empty(result):
    assert result.returncode in (0, 1), result.stdout + result.stderr
    assert "Current top level object is empty." in result.stdout + result.stderr


@pytest.mark.parametrize("length", [140, 150, 160])
def test_mount_hole_centers_stay_166_mm_apart_when_lid_length_changes(tmp_path, length):
    _, mesh = render_tabs(tmp_path, length)
    # Below the countersink the exported mesh must contain two circular Ø4
    # through-holes. Measure the actual section, not a source parameter string.
    section = mesh.section(plane_origin=[0, 0, 0.3], plane_normal=[0, 0, 1])
    assert section is not None
    hole_bounds = []
    for loop in section.discrete:
        bounds = np.array([loop.min(axis=0), loop.max(axis=0)])
        if bounds[1, 0] - bounds[0, 0] < 5:
            hole_bounds.append(bounds)
    assert len(hole_bounds) == 2
    centers = sorted([(b[0]+b[1])/2 for b in hole_bounds], key=lambda point: point[1])
    np.testing.assert_allclose(centers, [[0, -83, 0.3], [0, 83, 0.3]], atol=0.005)
    for bounds in hole_bounds:
        np.testing.assert_allclose(bounds[1, :2]-bounds[0, :2], [4, 4], atol=0.005)
    assert mesh.bounds[0, 2] == pytest.approx(0)
    assert mesh.bounds[1, 2] == pytest.approx(5)


def test_countersunk_heads_and_screwdriver_have_clear_access_from_inside(tmp_path):
    stl, _ = render_tabs(tmp_path)
    _, result = render_scad(
        tmp_path, "screw_access",
        "intersection() {\n"
        f"  import({json.dumps(str(stl))});\n"
        "  union() {\n"
        "    for (y=[-83,83]) {\n"
        "      translate([0,y,0.61]) cylinder(d1=4.0,d2=6.96,h=1.48,$fn=96);\n"
        "      translate([0,y,2.11]) cylinder(d=8.8,h=3.0,$fn=96);\n"
        "    }\n"
        "  }\n"
        "}\n",
    )
    assert_empty(result)


def test_exported_seat_has_90_degree_cone_and_nine_mm_tool_well(tmp_path):
    _, mesh = render_tabs(tmp_path)
    # A 90-degree cone grows 2 mm in diameter per millimetre of height.
    # The 7 mm head plane is z=2.1, leaving a 0.6 mm web below the Ø4 end.
    for z, diameter in [(0.3, 4), (0.9, 4.6), (1.8, 6.4), (2.2, 9)]:
        section = mesh.section(plane_origin=[0, 0, z], plane_normal=[0, 0, 1])
        assert section is not None
        holes = []
        for loop in section.discrete:
            widths = loop.max(axis=0)-loop.min(axis=0)
            if widths[0] < 10:
                holes.append(widths[:2])
        assert len(holes) == 2
        np.testing.assert_allclose(holes, [[diameter, diameter]]*2, atol=0.005)


def test_countersink_preserves_bearing_web_above_wood_plane(tmp_path):
    stl, _ = render_tabs(tmp_path)
    # This annular volume lies beneath the narrow end of the 90-degree cone;
    # material must remain here to carry the countersunk head's clamping load.
    _, result = render_scad(
        tmp_path, "bearing_web",
        "difference() {\n"
        "  union() {\n"
        "    for (y=[-83,83]) translate([0,y,0.1]) difference() {\n"
        "      cylinder(d=6.8,h=0.4,$fn=96);\n"
        "      translate([0,0,-0.01]) cylinder(d=4.2,h=0.42,$fn=96);\n"
        "    }\n"
        "  }\n"
        f"  import({json.dumps(str(stl))});\n"
        "}\n",
    )
    assert_empty(result)


def test_case_relief_contains_entire_reinforced_root_with_assembly_clearance(tmp_path):
    _, result = render_scad(
        tmp_path, "root_relief",
        f"use <{LIBRARY}>;\n"
        "difference() { rounded_mount_tabs(); tab_root_relief(); }\n",
    )
    assert_empty(result)
