"""Regression checks for real pairwise validation and missing-geometry failures."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import trimesh
import numpy as np

import pytest

pytest.importorskip("trimesh")
pytest.importorskip("manifold3d")
pytestmark = pytest.mark.skipif(not shutil.which("openscad"), reason="OpenSCAD CLI is required")
ROOT = Path(__file__).resolve().parents[1]
VALIDATOR = ROOT / "tools" / "validate_clearance.py"
MODEL = ROOT / "hafele_control_box.scad"


def source_fixture(tmp_path, *, collision=False, omit_controls=False, bad_include=False,
                   split_controls=False):
    source = tmp_path / "fixture.scad"
    text = """
show_part="none";
module case_body() { cube([1,1,1]); }
module case_lid_installed() { translate([10,0,0]) cube([1,1,1]); }
module board_clamp(board=0) { translate([30+10*board,0,0]) cube([1,1,1]); }
"""
    if not omit_controls:
        extra = "translate([22,0,0]) cube([1,1,1]);" if split_controls else ""
        text += f"module controls_bracket() {{ translate([{0 if collision else 20},0,0]) cube([1,1,1]); {extra} }}\n"
    if bad_include:
        text = "include <nonexistent-clearance-fixture.scad>;\n" + text
    source.write_text(text)
    return source


def run_validator(tmp_path, source, *extra):
    report = tmp_path / "report.json"
    run = subprocess.run(
        [sys.executable, str(VALIDATOR), "--scad", str(source), "--out", str(report), *extra],
        capture_output=True, text=True,
    )
    return run, json.loads(report.read_text())


def test_default_assembly_has_five_controls_and_ten_clear_pairs(tmp_path):
    run, report = run_validator(tmp_path, MODEL)
    assert run.returncode == 0, run.stdout + run.stderr
    assert report["passed"]
    result = report["configurations"][0]
    assert len(result["parts"]) == 5 and len(result["pairs"]) == 10
    assert all(pair["intersection_volume_mm3"] <= report["tolerance_mm3"]
               for pair in result["pairs"])


def test_common_controls_screw_heads_clear_case_and_bracket(tmp_path):
    meshes = {}
    for name, expression in {
        'heads':'for (p=controls_mounts()) translate([p[0],p[1],controls_head_z()-(m3_screw_head_diameter-m3_lid_clearance_diameter)/2]) cylinder(d1=m3_lid_clearance_diameter,d2=m3_screw_head_diameter,h=(m3_screw_head_diameter-m3_lid_clearance_diameter)/2,$fn=64);',
        'case':'case_body();', 'bracket':'controls_bracket();',
    }.items():
        wrapper = tmp_path/f'{name}.scad'
        wrapper.write_text(f'include <{MODEL}>;\n{expression}\n')
        output = wrapper.with_suffix('.stl')
        run = subprocess.run(['openscad','-o',str(output),'-D','show_part="none"',str(wrapper)],
                             capture_output=True,text=True)
        assert run.returncode == 0 and 'WARNING:' not in run.stderr, run.stderr
        meshes[name] = trimesh.load_mesh(output)
        assert meshes[name].is_volume and meshes[name].volume > 0
    for name in ('case','bracket'):
        overlap = trimesh.boolean.intersection([meshes['heads'],meshes[name]],engine='manifold')
        with np.errstate(divide='ignore',invalid='ignore'):
            volume = abs(float(overlap.volume))
        assert np.isfinite(volume) and volume <= 1e-4, f'Screw heads collide with {name}: {volume}'


def test_common_bracket_clears_both_connected_control_envelopes(tmp_path):
    meshes = {}
    for name, expression in {'connectors':'control_connector_envelopes(wire_allowance=true);',
                             'bracket':'controls_bracket();'}.items():
        wrapper = tmp_path/f'{name}.scad'
        wrapper.write_text(f'include <{MODEL}>;\n{expression}\n')
        output = wrapper.with_suffix('.stl')
        run = subprocess.run(['openscad','-o',str(output),'-D','show_part="none"',str(wrapper)],
                             capture_output=True,text=True)
        assert run.returncode == 0 and 'WARNING:' not in run.stderr, run.stderr
        meshes[name] = trimesh.load_mesh(output)
        assert meshes[name].is_volume and meshes[name].volume > 0
    overlap = trimesh.boolean.intersection([meshes['connectors'],meshes['bracket']],engine='manifold')
    with np.errstate(divide='ignore',invalid='ignore'):
        volume = abs(float(overlap.volume))
    assert np.isfinite(volume) and volume <= 1e-4, f'Connector passage is blocked: {volume}'


@pytest.mark.parametrize("defect", ["omit_controls", "bad_include"])
def test_missing_geometry_or_include_cannot_pass_as_clearance(tmp_path, defect):
    source = source_fixture(tmp_path, **{defect: True})
    run, report = run_validator(tmp_path, source)
    assert run.returncode != 0
    assert not report["passed"]
    assert "OpenSCAD export failed" in report["configurations"][0]["error"]


def test_real_overlap_fails_and_configured_volume_tolerance_is_used(tmp_path):
    source = source_fixture(tmp_path, collision=True)
    run, report = run_validator(tmp_path, source)
    assert run.returncode == 1 and not report["passed"]
    pairs = report["configurations"][0]["pairs"]
    assert len(pairs) == 10
    collision = next(pair for pair in pairs if not pair["passed"])
    assert {collision["first"], collision["second"]} == {"case", "controls_bracket"}
    assert collision["intersection_volume_mm3"] == pytest.approx(1)
    run, report = run_validator(tmp_path, source, "--tolerance-mm3", "1.1")
    assert run.returncode == 0 and report["passed"]


def test_disconnected_print_part_fails_even_when_all_shells_are_watertight(tmp_path):
    source = source_fixture(tmp_path, split_controls=True)
    run, report = run_validator(tmp_path, source)
    assert run.returncode == 1 and not report["passed"]
    error = report["configurations"][0]["error"]
    assert "not one positive watertight solid" in error
    assert "'positive_components': 2" in error


def test_each_config_is_checked_and_recorded(tmp_path):
    source = source_fixture(tmp_path)
    configs = tmp_path / "configs.json"
    configs.write_text(json.dumps([
        {"name": "first", "parameters": {}},
        {"name": "second", "parameters": {"unused_fixture_parameter": 3}},
    ]))
    run, report = run_validator(tmp_path, source, "--configs", str(configs))
    assert run.returncode == 0, run.stdout + run.stderr
    assert [item["configuration"] for item in report["configurations"]] == ["first", "second"]
    assert all(len(item["pairs"]) == 10 for item in report["configurations"])
