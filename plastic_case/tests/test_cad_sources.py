"""A changed included SCAD file must invalidate the print-set provenance."""
import importlib.util
from pathlib import Path

SOURCE=Path(__file__).resolve().parents[1]/'tools/cad_sources.py'
spec=importlib.util.spec_from_file_location('cad_sources_test',SOURCE)
module=importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def test_nested_includes_and_use_are_hashed_and_comments_are_ignored(tmp_path):
    (tmp_path/'lib').mkdir()
    main=tmp_path/'case.scad'
    main.write_text('include <lib/frame.scad>;\n// use <missing.scad>;\n/*\ninclude <also-missing.scad>;\n*/\n')
    (tmp_path/'lib/frame.scad').write_text('use <lip.scad>;\nmodule frame() {}')
    lip=tmp_path/'lib/lip.scad'
    lip.write_text('module lip() { cube(1); }')
    original=module.source_hashes([main],tmp_path)
    assert set(original)=={'case.scad','lib/frame.scad','lib/lip.scad'}
    lip.write_text('module lip() { cube(2); }')
    changed=module.source_hashes([main],tmp_path)
    assert changed['case.scad']==original['case.scad']
    assert changed['lib/lip.scad']!=original['lib/lip.scad']
