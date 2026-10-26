"""Measured-box and real tool-corridor validation, including failure controls."""
import json
from pathlib import Path
import shutil
import subprocess
import sys

import pytest

pytest.importorskip("trimesh")
pytest.importorskip("manifold3d")
pytestmark = pytest.mark.skipif(not shutil.which("openscad"), reason="OpenSCAD CLI is required")
ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT/"tools"/"validate_measured_fit.py"
MODEL = ROOT/"hafele_control_box.scad"


def run_fit(tmp_path, source, *extra):
    output = tmp_path/"fit.json"
    run = subprocess.run([sys.executable, str(TOOL), "--scad", str(source),
                          "--out", str(output), *extra], capture_output=True, text=True)
    return run, json.loads(output.read_text())


def source_fixture(tmp_path, *, driver_collision=False, board_contact=False,
                   missing_connectors=False, single_connector=False,
                   board_driver_collision=False):
    source = tmp_path/"hardware.scad"
    source.write_text(f"""
show_part="none";
longitud=20; proto_width=1; proto_length=1; proto_total_height=1;
supply_length=1; supply_width=1; supply_total_height=1;
function board_left_x()=100;
function proto_y0()=200;
function supply_y0()=210;
function board_lowest_z()=0;
function source_tower_edge()=5;
function lid_tower_xs()=[500,510];
function closure_head_z()=2;
module case_body() {{ translate([{100 if board_contact else 0},{200 if board_contact else 0},0]) cube(1); }}
module case_lid_installed() {{ translate([10,0,0]) cube(1); }}
module controls_bracket() {{ translate([20,0,0]) cube(1); }}
module board_clamp(board=0) {{ translate([30+10*board,0,0]) cube(1); }}
module enclosure_shell() {{ translate([50,0,0]) cube(1); }}
module end_closures() {{ translate([50.5,0,0]) cube(1); }}
module controls_tool_access(iron=false) {{
    for(i=[0:2]) translate([(!iron && i==0 && {str(driver_collision).lower()}) ? 0 : 400+i*10, iron ? 10 : 0,0]) cube(1);
}}
module board_tool_access(iron=false) {{
    for(i=[0:1]) translate([(!iron && i==0 && {str(board_driver_collision).lower()}) ? 0 : 600+i*10, iron ? 10 : 0,0]) cube(1);
}}
""" + ("" if missing_connectors else f"""
module control_connector_envelopes(wire_allowance=true) {{
    translate([300,0,0]) cube(1);
    {'' if single_connector else 'translate([310,0,0]) cube(1);'}
}}
"""))
    return source


def test_default_measured_boxes_connectors_and_tool_corridors(tmp_path):
    run, report = run_fit(tmp_path, MODEL)
    assert run.returncode == 0, run.stdout+run.stderr
    assert report["passed"] and not report["physical_fit_certified"]
    result = report["configurations"][0]
    assert len(result["parts"]) == report["expected_part_count"]
    assert len(result["checks"]) == report["expected_check_count"]
    assert len(result["excluded_contacts"]) == 4
    assert result["parts"]["control_connectors_and_bends"]["positive_components"] == 2
    assert result["parts"]["controls_driver_approach"]["positive_components"] == 3
    assert result["parts"]["board_driver_approach"]["positive_components"] == 2
    assert result["parts"]["board_insert_iron_approach"]["positive_components"] == 2
    assert result["parts"]["closure_quarter_inch_bit_approach"]["positive_components"] == 4
    board_driver_checks = {check["second"] for check in result["checks"]
                           if check["first"] == "board_driver_approach"}
    assert board_driver_checks == {"case", "controls_bracket", "proto_clamp", "supply_clamp",
                                   "proto_envelope", "supply_envelope", "control_connectors_and_bends"}
    assert "physically absent" in report["assembly_stages"]["internal_drivers"]["excluded_part"]
    assert report["assembly_stages"]["insert_installation"]["case"] == "empty case only"


@pytest.mark.parametrize("defect,corridor", [
    ("driver_collision", "controls_driver_approach"),
    ("board_driver_collision", "board_driver_approach"),
])
def test_tool_corridor_collision_fails_with_real_volume(tmp_path, defect, corridor):
    run, report = run_fit(tmp_path, source_fixture(tmp_path, **{defect:True}))
    assert run.returncode == 1 and not report["passed"]
    result = report["configurations"][0]
    collision = next(check for check in result["checks"] if not check["passed"])
    assert (collision["first"],collision["second"]) == (corridor,"case")
    assert collision["intersection_volume_mm3"] == pytest.approx(1)


def test_declared_board_support_contact_is_reported_as_overlap_not_zero(tmp_path):
    run, report = run_fit(tmp_path, source_fixture(tmp_path, board_contact=True))
    assert run.returncode == 0, run.stdout+run.stderr
    assert report["passed"] and not report["physical_fit_certified"]
    excluded = report["configurations"][0]["excluded_contacts"]
    contact = next(item for item in excluded if item["first"] == "proto_envelope"
                   and item["second"] == "case")
    assert contact["intersection_volume_mm3"] == pytest.approx(1)
    assert contact["excluded_from_clearance_verdict"]
    assert "unverified" in contact["contact_band_and_limitations"]


@pytest.mark.parametrize("defect", ["missing_connectors", "single_connector"])
def test_missing_hardware_envelope_cannot_pass(tmp_path, defect):
    run, report = run_fit(tmp_path, source_fixture(tmp_path, **{defect:True}))
    assert run.returncode == 1 and not report["passed"]
    assert "error" in report["configurations"][0]
