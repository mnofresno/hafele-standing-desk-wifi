# Häfele control box: OpenSCAD reconstruction

This folder contains an editable OpenSCAD CSG reconstruction of the FreeCAD case and lid, plus a hardware rework revision. The FreeCAD document remains the geometric reference. The `baseline` reconstruction is **not yet equivalent**: the case misses the 0.05 mm tolerance and some parameter changes do not reproduce the FreeCAD feature behavior. The `rework` revision intentionally changes hardware interfaces and is still a fit-test prototype. Do not treat either OpenSCAD revision as physically validated for fabrication yet.

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

Open `hafele_control_box.scad` in OpenSCAD. In Customizer, choose `design_revision="baseline"` to view/export the FreeCAD reconstruction or `design_revision="rework"` for the hardware-retention prototype. The rework mode is the default. Choose `case`, `lid`, `assembly`, `oled_retainer`, or `encoder_retainer` with `show_part`. All dimensions are millimetres. CLI exports:

```sh
openscad -o /tmp/control-box-case.stl -D 'show_part="case"' plastic_case/hafele_control_box.scad
openscad -o /tmp/control-box-lid.stl -D 'show_part="lid"' plastic_case/hafele_control_box.scad
openscad -o /tmp/control-box-assembly.stl -D 'show_part="assembly"' plastic_case/hafele_control_box.scad
openscad -o /tmp/oled-retainer.stl -D 'show_part="oled_retainer"' plastic_case/hafele_control_box.scad
openscad -o /tmp/encoder-retainer.stl -D 'show_part="encoder_retainer"' plastic_case/hafele_control_box.scad
openscad -o /tmp/control-box-baseline.stl -D 'design_revision="baseline"' -D 'show_part="case"' plastic_case/hafele_control_box.scad
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
python3 plastic_case/tools/validate_rework.py \
  --scad plastic_case/hafele_control_box.scad \
  --configs plastic_case/tests/rework_configurations.json \
  --out /tmp/hafele-rework-validation.json
```

`export_freecad.py` exports final body tips as STL and STEP and writes an inventory. The validator compares bounds, volume, surface area, connected components, watertightness, sampled bidirectional surface distances, and a 1 mm shared-grid voxel symmetric-difference estimate. Sampled maximum distance and voxel difference are estimates; increase sample count and refine mesh tessellation for a formal tolerance certification.

## Baseline geometry measurements

FreeCAD's exact BRep metrics and a fine STL inventory are in `freecad_model_inventory.json`. The validator exports FreeCAD with 0.01 mm linear tessellation, samples 10,000 random surface points plus up to 50,000 mesh vertices and face centers in each direction, and estimates symmetric difference on a shared 1 mm voxel grid. The surface maxima are measured samples, not a mathematical upper bound.

| Configuration | Part | BBox max delta (mm) | Volume delta (mm³) | Sampled surface max A→B / B→A (mm) | Components / watertight | 0.05 mm check |
|---|---|---:|---:|---:|---|---|
| Default | Case | 0.00051 | 15.00 | 0.042 / 0.035 | 1 / yes | Pass |
| Default | Lid | 0.00000 | 0.056 | 0.0010 / 0.0010 | 1 / yes | Pass |
| Longer, thicker, support sketch coordinates transcribed | Case | 0.00051 | 17.30 | 0.127 / 0.115 | 1 / yes | Fail |
| Longer, thicker | Lid | 0.00000 | 0.075 | 0.0010 / 0.0010 | 1 / yes | Pass |

For the longer case, the validation config explicitly sets the two additional OpenSCAD support-profile parameters to the coordinates returned by the recomputed FreeCAD sketches: `support_floor_left_x=7.12701665379` and `support_inner_offset=8`. The case still has a sampled surface residual of 0.127 mm at approximately (7.127, -11, 2) mm and a 17.30 mm³ volume difference; the default case passes the sampled 0.05 mm threshold. This residual is localized at a support/floor intersection and remains an unresolved geometry difference. It is not explained by solver drift: five clean FreeCAD exports of the longer configuration all reported Sketch006/007 `Up-to-date`, 0 DoF, support coordinates 7.12701665/8.0 mm, and case volume 68,141.249454 mm³ (coordinate/volume variation below 1e-6 mm/mm³).

The earlier short-boundary probe (`alto=30`, `longitud=120`, `ancho_pared=1.2`, `profundidad=62`, `angulo_del_panel=72`, `radio_curvaturas=4`) is excluded from the valid comparison matrix. FreeCAD reported Sketch006 `Invalid`, 1 DoF and Sketch007 `Invalid`, 4 DoF after recompute, retaining stale 33.5 mm support geometry above the 30 mm case. Raising `alto` to 33.5 made both sketches `Up-to-date` with 0 DoF, but that point is not included until its geometry comparison is run. The default source also reports Sketch007 invalid with 1 DoF. Do not claim general parametric equivalence. The original FreeCAD document and tracked STL exports remain unchanged.

## Parameter configurations and known gaps

`tests/configurations.json` compares the default and a longer/thicker configuration whose two extra support coordinates are transcribed from the valid FreeCAD sketch solve. This demonstrates the exposed support parameters but does not make them formulas of the spreadsheet values. The longer case remains outside tolerance by 0.077 mm over the sampled maximum target; keep that configuration outside any equivalence claim until the floor/support intersection is corrected and revalidated.

## Hardware fit-test coupons

Parametric coupon models for the OLED pocket, EC11-family encoder body/knob, panel pushbutton, USB opening, motor cable boot, Dupont connector headroom, PCB outline/edge rails/solder clearance, and M3 brass inserts are in `plastic_case/tests/fit_test_coupons.scad`. Printing instructions, parameter ranges, and component-retention decisions are in `plastic_case/tests/FIT_TESTS.md`. Render one coupon family at a time with `-D 'test_set="m3_insert"'` (or another selector). A live read of `/info` reports ESP32 chip revision 1, 4 MB flash, no PSRAM and 240 MHz; the USB enumerates as a CP2102 bridge. Neither identifies the physical PCB outline, so the coupons keep ESP32/relay/supply profiles adjustable. Rework mode includes blind M3 insert seats; print the insert coupon and tune the pilot/boss dimensions before printing the enclosure.

The hardware rework sequence and evidence-backed mechanical decisions are tracked in `plastic_case/REWORK_PLAN.md`. In `rework` mode, the model adds a candidate OLED pocket and removable retainer, an EC11-family encoder pocket/retainer, blind M3 insert towers, four M3 carrier mounts, a removable 10 mm grid carrier, configurable USB/motor-cable openings (enabled by default), and an adjustable optional button cap. The cap is a separate fit candidate and does not replace the metal panel button. The grid carrier is a generic mounting surface, not a dimensioned cradle for all three boards. ESP32 PCB revision, relay/perfboard outline, supply outline, solder height and connector keep-outs still need physical checks. The USB bridge is CP2102; it does not identify the controller PCB. A six-part, watertight print candidate set is in `plastic_case/print_candidate/`; see its README before printing. It is a prototype and does not certify physical fit.

`validate_rework.py` reports mesh bounds, volume and area, watertightness, winding, connected positive-volume solids, and enclosed cavity shells across the candidate configuration matrix. The blind M3 insert bores create enclosed voids that STL represents as separate inward-wound shells; these are reported separately from printable solid components. This mesh check verifies CSG validity only, not fit to unmeasured hardware.

The current `validate_rework.py` run reports OpenSCAD `NoError`, one connected positive-volume component, and watertight meshes for the case, OLED retainer, encoder retainer, electronics carrier and button cap configurations. These checks establish valid CSG output, not fit or electrical clearance.
