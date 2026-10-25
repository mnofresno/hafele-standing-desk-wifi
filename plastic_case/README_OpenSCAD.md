# Häfele control box: OpenSCAD reconstruction

This folder contains an editable OpenSCAD CSG reconstruction of the FreeCAD case and lid. The FreeCAD document remains the geometric reference. The reconstruction is **not yet equivalent**: the current case misses the required 0.05 mm tolerance, and some parameter changes do not reproduce the FreeCAD feature behavior. Use the existing FreeCAD models/STLs for fabrication until that gap is resolved.

## Source selection

I compared `plastic_case/hafele_control_box_with_lid.FCStd` with the workspace source `Gabinete Hafele Standing Desk.FCStd` after opening and recomputing both in FreeCAD 1.0.2. Both have 45 objects, 9 sketches, the same feature order, spreadsheet values and aliases, and matching final geometry (case BRep volume 42,071.6025 mm³; lid 31,103.0044 mm³). The target copy was incorporated by commit `7fd1ede32fd79ccc4e8f1e2d872f4374dcdf2647` on 2024-07-30 with the corresponding STL/render files. The latest local CAD-specific commit is `91452eb` on 2022-07-03. The target repo copy is the most recently incorporated complete design; no geometry difference was found between the two documents.

## Parameter mapping

All spreadsheet aliases are exposed in OpenSCAD Customizer. The source labels are in Spanish and retained. Values are millimetres except `angulo_del_panel`, in degrees. The source formula for `long_torres_tornillos` is `alto - ancho_pared`.

| FreeCAD cell | Alias / label | Default | OpenSCAD variable | Observed source effect |
|---|---|---:|---|---|
| B1 | `longitud` / ancho_gabinete | 150 | `longitud` | Case extrusion and lid length |
| B2 | `alto` / alto_gabinete | 35 | `alto` | Side profile height, support height, tower length formula |
| B3 | `profundidad` / profundidad_gabinete | 70 | `profundidad` | Side profile top span and lid width |
| B4 | `ancho_display` | 26.64 | `ancho_display` | Rectangular display opening |
| B5 | `alto_display` | 14.46 | `alto_display` | Rectangular display opening |
| B6 | `radio_curvaturas` | 5 | `radio_curvaturas` | Two tangent profile corners |
| B7 | `angulo_del_panel` | 75° | `angulo_del_panel` | Sloped panel and derived profile points |
| B8 | `ancho_pared` | 1.5 | `ancho_pared` | Shell offset and pad depths |
| B9 | `pos_display_x` | 20 | `pos_display_x` | Display sketch position; placement not yet faithfully reproduced |
| B10 | `pos_display_y` | 15 | `pos_display_y` | Display sketch position; placement not yet faithfully reproduced |
| B11 | `distancia_botones` | 40 | `distancia_botones` | Button spacing |
| B12 | `altura_botones` / source label pos_y_botones | 3 | `altura_botones` | Button sketch position; placement not yet faithfully reproduced |
| B13 | `pos_x_botones` | 75 | `pos_x_botones` | Button sketch location; not yet faithfully reproduced |
| B14 | `dia_botones` | 8.68 | `dia_botones` | Button opening diameter |
| B15 | `espesor_tapa` | 1.5 | `espesor_tapa` | No final feature expression references this cell; retained but source geometry follows `ancho_pared` |
| B16 | `dia_torres_tornillos` | 7 | `dia_torres_tornillos` | Tower outer diameter |
| B17 | `long_torres_tornillos` | `=B2-B8` | `long_torres_tornillos` | Tower height |
| B18 | `separacion_torres_tornillos` | 6 | `separacion_torres_tornillos` | Tower/support sketch spacing; not fully reproduced |
| B19 | `dia_interno_torres_tornillos` | 4.25 | `dia_interno_torres_tornillos` | Tower bore diameter |

The complete 45-object inventory, sketch geometry, constraints, object properties, expressions, and final-body measurements are in `freecad_model_inventory.json`.

## OpenSCAD use

Open `hafele_control_box.scad` in OpenSCAD. In Customizer, choose `case`, `lid`, or `assembly`. The lid/case preview uses millimetres. CLI exports:

```sh
openscad -o /tmp/control-box-case.stl -D 'show_part="case"' plastic_case/hafele_control_box.scad
openscad -o /tmp/control-box-lid.stl -D 'show_part="lid"' plastic_case/hafele_control_box.scad
openscad -o /tmp/control-box-assembly.stl -D 'show_part="assembly"' plastic_case/hafele_control_box.scad
```

## Extraction and comparison

FreeCAD 1.0.2, OpenSCAD CLI, Python with `trimesh`, `numpy`, and `rtree` are required. On this macOS install:

```sh
export PYTHONPATH=/Applications/FreeCAD.app/Contents/Resources/lib
export LD_LIBRARY_PATH=/Applications/FreeCAD.app/Contents/Resources/lib
FC_PY=/Applications/FreeCAD.app/Contents/Resources/bin/python
$FC_PY plastic_case/tools/export_freecad.py plastic_case/hafele_control_box_with_lid.FCStd /tmp/hafele-reference
python3 plastic_case/tools/validate_geometry.py \
  --source plastic_case/hafele_control_box_with_lid.FCStd \
  --scad plastic_case/hafele_control_box.scad \
  --configs plastic_case/tests/configurations.json \
  --freecad-python "$FC_PY" \
  --out plastic_case/tests/geometry-validation.json
python3 -m pytest -q plastic_case/tests/test_model.py
```

`export_freecad.py` exports final body tips as STL and STEP and writes an inventory. The validator compares bounds, volume, surface area, connected components, watertightness, sampled bidirectional surface distances, and a 1 mm shared-grid voxel symmetric-difference estimate. Sampled maximum distance and voxel difference are estimates; increase sample count and refine mesh tessellation for a formal tolerance certification.

## Default geometry measurements

FreeCAD API BRep (exact-kernel) and STL measurements are recorded in the inventory and `tests/geometry-validation.json`. Current default comparison:

| Part | FreeCAD STL volume (mm³) | OpenSCAD volume (mm³) | Abs volume delta (mm³) | Voxel symmetric difference estimate (mm³) | Max sampled surface distance (mm) | Result |
|---|---:|---:|---:|---:|---:|---|
| Case | 42,069.51 | 40,426.60 | 1,642.91 | 2,394 | 9.00 | Fail |
| Lid | 31,103.08 | 31,103.14 | 0.06 | 0 | 0.001 | Pass |

The tessellated FreeCAD STL volume differs slightly from its exact BRep volume. Both reference and OpenSCAD meshes are watertight at the default values. The case has 5 connected OpenSCAD components versus 1 FreeCAD component. Bounding boxes match within 0.001 mm, but that does not imply matching surfaces.

## Parameter configurations and known gaps

The automated matrix includes default, longer/thicker, and short-case configurations. All run through FreeCAD recompute and OpenSCAD export. Every case comparison fails 0.05 mm; the lid also fails the maximum sampled deviation criterion. The source FreeCAD tree itself leaves some dependent feature tips marked touched after headless parameter recompute; the exporter recomputes touched feature objects and exports each body tip, but this behavior is recorded in the inventory. The parameter runs are evidence of divergence, not proof of equivalence.

The current CSG still needs a feature-by-feature reconstruction of the exact FreeCAD shell operation, display/button face placement, screw tower locations/support details, and lid hole cuts. Some spreadsheet parameters are exposed but do not yet drive the same geometric effects as their source constraints. No geometric identity or 0.05 mm fit is claimed. These are outstanding acceptance gaps, not intentionally removed design features.
