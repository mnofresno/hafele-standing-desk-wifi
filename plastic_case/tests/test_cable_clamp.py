"""Verify that the cap's M3 head recesses are open from the outside face."""
import json
from pathlib import Path
import shutil
import subprocess

import pytest


CLAMP = Path(__file__).with_name("motor_cable_clamp.scad")


@pytest.mark.parametrize("cable_od,bolt_y,cap_top", [(6, 7, 5), (8, 8, 6), (12, 10, 8)])
def test_cap_screw_heads_have_clear_entry_corridors(tmp_path, cable_od, bolt_y, cap_top):
    openscad = shutil.which("openscad")
    if not openscad:
        pytest.skip("OpenSCAD CLI is required for the cap screw access check")

    cap = tmp_path / "cap.stl"
    subprocess.run(
        [openscad, "-o", str(cap), "-D", 'show_part="cap"',
         "-D", f"cable_od={cable_od}", "-D", "cap_screw_head_d=5.8",
         "-D", "cap_screw_head_h=2.4", str(CLAMP)],
        check=True, capture_output=True, text=True,
    )
    assert cap.is_file() and cap.stat().st_size > 0

    # Intersect the exported mesh with the entire head-entry cylinder. Stay
    # 0.1 mm inside the intended recess to avoid touching tessellated boundaries.
    # An enclosed counterbore or a ceiling above it leaves material here.
    diagnostic = tmp_path / "head_corridors.scad"
    diagnostic.write_text(
        "intersection() {\n"
        f"  import({json.dumps(str(cap))});\n"
        "  union() {\n"
        f"    for (y=[-{bolt_y},{bolt_y}])\n"
        f"      translate([0,y,{cap_top - 2.3}]) cylinder(r=2.8,h=2.2,$fn=96);\n"
        "  }\n"
        "}\n"
    )
    result = subprocess.run(
        [openscad, "-o", str(tmp_path / "blocked_head_corridor.stl"), str(diagnostic)],
        capture_output=True, text=True,
    )
    assert result.returncode in (0, 1)
    assert "Current top level object is empty." in result.stdout + result.stderr
