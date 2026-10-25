"""Lightweight structural checks; full CAD comparison is tools/validate_geometry.py."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def test_inventory_has_all_objects_and_parameters():
    d=json.loads((ROOT/'freecad_model_inventory.json').read_text())
    assert len(d['objects'])==45
    sheet=next(o for o in d['objects'] if o['type']=='Spreadsheet::Sheet')
    aliases={c['alias'] for c in sheet['cells'] if c['alias']}
    assert {'longitud','alto','profundidad','ancho_pared','dia_botones','dia_interno_torres_tornillos'} <= aliases
def test_model_has_case_lid_and_assembly_selector():
    s=(ROOT/'hafele_control_box.scad').read_text()
    for module in ('case_body','case_lid','assembly','screw_tower','lid_fastener_holes'):
        assert f'module {module}(' in s
    assert 'show_part' in s and 'linear_extrude' in s
