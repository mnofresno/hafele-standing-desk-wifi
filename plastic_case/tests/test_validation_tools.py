"""Regression checks for validation gates and retained FreeCAD source geometry."""
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace

import pytest
import trimesh


TOOLS = Path(__file__).resolve().parents[1]/'tools'
sys.path.insert(0,str(TOOLS))
SPEC = importlib.util.spec_from_file_location('geometry_validator', TOOLS/'validate_geometry.py')
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


def source_inventory(invalid=False):
    state = ['Invalid'] if invalid else ['Up-to-date']
    return {
        'objects':[{'name':'Sketch007','type':'Sketcher::SketchObject','state':state,
                    'solver':{'state':state,'degrees_of_freedom':1 if invalid else 0}}],
        'final_solids':[{'object':'Body','is_valid':True,'is_watertight_brep':True}],
        'recompute':{'errors':[]},
    }


def test_invalid_saved_source_is_snapshot_only_not_parameter_equivalence():
    inventory = source_inventory(invalid=True)
    snapshot = validator.source_validation(inventory, parameterized=False)
    assert snapshot['classification'] == 'source_snapshot_only'
    assert snapshot['comparison_allowed']
    assert not snapshot['parameter_equivalence_eligible']
    variant = validator.source_validation(inventory, parameterized=True)
    assert variant['classification'] == 'invalid_parameter_recompute'
    assert not variant['comparison_allowed']
    assert not variant['parameter_equivalence_eligible']


def test_recompute_exception_blocks_variant_even_if_tip_shape_is_valid():
    inventory = source_inventory()
    inventory['recompute']['errors'] = [{'phase':'initial','error':'Recompute failed'}]
    assert not validator.source_validation(inventory, parameterized=True)['comparison_allowed']


def test_invalid_variant_never_compares_retained_solids(tmp_path, monkeypatch):
    config = tmp_path/'config.json'
    config.write_text(json.dumps([{'name':'invalid-short','parameters':{'ancho_pared':2}}]))
    calls = []

    def fake_export(command, **kwargs):
        calls.append(command)
        destination = Path(command[3])
        (destination/'freecad_model_inventory.json').write_text(json.dumps(source_inventory(invalid=True)))
        # A valid saved shape could exist here; the source state must reject it
        # before OpenSCAD export or mesh comparison is attempted.
        return subprocess.CompletedProcess(command, 0, '', '')

    monkeypatch.setattr(validator.subprocess, 'run', fake_export)
    args = SimpleNamespace(configs=str(config), source='source.FCStd',
                           scad='model.scad', freecad_python='freecad-python')
    result = validator.validate_configurations(args)
    assert len(calls) == 1
    assert not result[0]['passed']
    assert result[0]['parts'] == []
    assert 'retained geometry was not compared' in result[0]['validation_error']


@pytest.mark.parametrize('topology,distance', [(False,0), (True,0.051), (True,float('nan'))])
def test_failed_topology_or_distance_cannot_pass(topology, distance):
    comparison = {
        'topology_passed':topology, 'bbox_max_abs_delta_mm':0,
        'surface_distance_a_to_b_mm':{'max_sampled':distance},
        'surface_distance_b_to_a_mm':{'max_sampled':0},
    }
    assert not validator.comparison_passed(comparison, 0.05)


def test_identical_open_meshes_fail_even_with_zero_surface_distance(tmp_path):
    mesh = trimesh.creation.box(extents=[1,1,1])
    mesh.update_faces(list(range(len(mesh.faces)-1)))
    path = tmp_path/'open.stl'
    mesh.export(path)
    measured = validator.metrics(path)
    comparison = validator.compare(measured, measured, n=64)
    assert not measured['watertight']
    assert not comparison['topology_passed']
    assert comparison['symmetric_difference_method'] == 'unavailable_invalid_topology'
    assert not validator.comparison_passed(comparison, 0.05)


@pytest.mark.parametrize('passed,expected_exit', [(False,1), (True,0)])
def test_cli_exit_code_matches_report(tmp_path, monkeypatch, passed, expected_exit):
    report = [{'configuration':'probe','parts':[], 'passed':passed}]
    monkeypatch.setattr(validator, 'validate_configurations', lambda args: report)
    output = tmp_path/'report.json'
    result = validator.main(['--source','source.FCStd','--scad','model.scad',
                             '--configs','configs.json','--freecad-python','python',
                             '--out',str(output)])
    assert result == expected_exit
    assert json.loads(output.read_text()) == report


def test_mesh_boolean_detects_difference_smaller_than_old_voxel_grid():
    pytest.importorskip('manifold3d')
    a = trimesh.creation.box(extents=[1,1,1])
    b = a.copy()
    b.apply_translation([0.2,0,0])
    result = validator.symmetric_difference(a,b,pitch=1)
    assert result['symmetric_difference_method'] == 'manifold3d_tessellated_mesh_boolean'
    assert result['symmetric_difference_mesh_mm3'] == pytest.approx(0.4, abs=1e-6)
    assert result['a_minus_b_mesh_mm3'] == pytest.approx(0.2, abs=1e-6)
    assert result['b_minus_a_mesh_mm3'] == pytest.approx(0.2, abs=1e-6)


def test_caller_freecad_environment_is_preserved(monkeypatch):
    monkeypatch.setenv('PYTHONPATH','/custom/freecad/lib')
    monkeypatch.setenv('LD_LIBRARY_PATH','/custom/linked/libs')
    environment = validator.freecad_environment()
    assert environment['PYTHONPATH'] == '/custom/freecad/lib'
    assert environment['LD_LIBRARY_PATH'] == '/custom/linked/libs'
