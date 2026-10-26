"""Lightweight structural checks; full CAD comparison is tools/validate_geometry.py."""
import json
from pathlib import Path
import shutil
import subprocess
import pytest
ROOT=Path(__file__).resolve().parents[1]
def test_inventory_has_all_objects_and_parameters():
    d=json.loads((ROOT/'freecad_model_inventory.json').read_text())
    assert len(d['objects'])==45
    sheet=next(o for o in d['objects'] if o['type']=='Spreadsheet::Sheet')
    aliases={c['alias'] for c in sheet['cells'] if c['alias']}
    assert {'longitud','alto','profundidad','ancho_pared','dia_botones','dia_interno_torres_tornillos'} <= aliases
    tower_sketch=next(o for o in d['objects'] if o['name']=='Sketch003')
    assert {g['construction'] for g in tower_sketch['geometry']} == {True,False}
    assert 'dependencies' in tower_sketch and 'dependents' in tower_sketch
def test_model_has_case_lid_and_assembly_selector():
    s=(ROOT/'hafele_control_box.scad').read_text()
    for module in ('case_body','case_lid','assembly','screw_tower','lid_fastener_holes'):
        assert f'module {module}(' in s
    assert 'show_part' in s and 'linear_extrude' in s
    assert 'design_revision = "rework"' in s
    assert 'translate([case_top_center_x(),-longitud/2,' in s
    assert 'module rework_panel_pockets(' in s
    assert 'module external_access_cutouts(' in s
    assert 'include <lib/combined_controls.scad>' in s
    assert 'module button_cap(' in s
    assert 'module external_access_cutouts(' in s
    assert 'rework_display_window_width = 27;' in s
    assert 'wood_mount_spacing = 166;' in s

def test_hardware_evidence_and_cable_clamp_are_documented():
    assert (ROOT/'HARDWARE_EVIDENCE.md').is_file()
    clamp=(ROOT/'tests'/'motor_cable_clamp.scad').read_text()
    assert 'module saddle(' in clamp and 'module cap(' in clamp
    assert 'mount_grid_pitch' in clamp and 'cable_od' in clamp

def test_fit_coupons_cover_reported_hardware_interfaces():
    s=(ROOT/'tests'/'fit_test_coupons.scad').read_text()
    selectors=('oled','encoder','button','usb','motor_cable','dupont','m3_insert',
               'm3_screw','board_edge','board_outline')
    selector_line=next(line for line in s.splitlines() if line.startswith('test_set ='))
    assert all(f',{name}' in selector_line or f'[{name}' in selector_line for name in selectors)
    for parameter in ('oled_pcb_width_default','encoder_body_x','m3_insert_length',
                      'usb_plug_width','board_outline_target'):
        assert parameter in s

def test_rework_plan_marks_unverified_board_and_component_dimensions():
    s=(ROOT/'REWORK_PLAN.md').read_text()
    assert 'CP2102' in s
    assert 'does not identify the PCB' in s
    assert 'still unknown' in s.lower() or 'unknown' in s.lower()
    assert 'two' in s.lower() or 'two' in (ROOT/'HARDWARE_MEASUREMENTS.md').read_text().lower()

@pytest.mark.parametrize('definitions', [
    ['-D', 'show_part="case"'],
    ['-D', 'show_part="lid"'],
    ['-D', 'show_part="case"', '-D', 'enable_usb_access=true',
     '-D', 'enable_motor_cable_exit=true', '-D', 'motor_cable_end="far"',
     '-D', 'usb_access_end="near"'],
    ['-D', 'show_part="case"', '-D', 'm3_insert_pilot_diameter=3.8',
     '-D', 'm3_insert_length=4.0'],
    ['-D', 'show_part="controls_bracket"'],
    ['-D', 'show_part="proto_clamp"'],
    ['-D', 'show_part="supply_clamp"'],
    ['-D', 'design_revision="baseline"', '-D', 'show_part="case"'],
])
def test_case_revision_and_hardware_retainer_meshes_are_manifold(tmp_path,definitions):
    openscad=shutil.which('openscad')
    if not openscad:
        pytest.skip('OpenSCAD CLI is required for native mesh smoke checks')
    output=tmp_path/'part.stl'
    command=[openscad,'-o',str(output),*definitions,str(ROOT/'hafele_control_box.scad')]
    result=subprocess.run(command,capture_output=True,text=True,check=True)
    log=result.stdout+result.stderr
    assert 'Top level object is a 3D object (manifold)' in log
    assert 'Status:     NoError' in log
    assert output.is_file() and output.stat().st_size>0
    import trimesh
    mesh=trimesh.load(output,force='mesh')
    assert mesh.is_watertight and mesh.is_winding_consistent
    shells=mesh.split(only_watertight=False)
    # Blind M3 insert bores are enclosed voids and appear as inward-wound STL
    # shells. Count positive-volume solids separately from those cavity shells.
    assert sum(part.volume>0 for part in shells)==1

def test_assembled_preview_renders_with_registered_rework_lid(tmp_path):
    openscad=shutil.which('openscad')
    if not openscad:
        pytest.skip('OpenSCAD CLI is required for the assembly preview')
    output=tmp_path/'assembly.png'
    command=[openscad,'--render','--autocenter','--viewall','--projection=o',
             '--imgsize=640,640','-o',str(output),'-D','show_part="assembly"',
             str(ROOT/'hafele_control_box.scad')]
    result=subprocess.run(command,capture_output=True,text=True,check=True)
    assert 'Status:     NoError' in result.stdout+result.stderr
    assert output.is_file() and output.stat().st_size>0
