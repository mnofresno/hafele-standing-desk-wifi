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
| Longer, thicker | Case | 0.00051 | 55.07 | 3.999 / 3.260 | 1 / yes | Fail |
| Longer, thicker | Lid | 0.00000 | 0.075 | 0.0010 / 0.0010 | 1 / yes | Pass |
| Short boundary | Case | 5.55859 | 101.37 | 7.196 / 4.664 | 1 / yes | Fail |
| Short boundary | Lid | 0.00000 | 150.69 | 1.766 / 1.162 | 1 / yes | Fail |

The default reconstruction meets the measured surface threshold, but the larger case volume delta remains 15.00 mm³ (0.036%). Longer and short parameter configurations do not match. The FreeCAD source also reports `Sketch007` as `Invalid` with one degree of freedom at its default recompute; the inventory records sketch solver state. Its dependent support sketches can produce different geometry after parameter changes, so the source itself does not provide a stable reference for a strict parametric guarantee. The original FreeCAD document and tracked STL exports remain unchanged.

## Parameter configurations and known gaps

`tests/configurations.json` applies values to the FreeCAD spreadsheet and OpenSCAD independently. The case support profiles now use native CSG and retain the raised support height, and the lid holes follow the source tower offsets. The validation results above still fail on longer/short case geometry and short lid geometry. Do not describe the reconstruction as fully equivalent or parametric equivalence as guaranteed. Making the FreeCAD sketch solver deterministic or restricting the supported parameter domain is required before that claim can be made.

## Hardware fit-test coupons

Parametric coupon models for the OLED pocket, EC11-family encoder body/knob, panel pushbutton, USB opening, motor cable boot, Dupont connector headroom, PCB outline/edge rails/solder clearance, and M3 brass inserts are in `plastic_case/tests/fit_test_coupons.scad`. Printing instructions, parameter ranges, and component-retention decisions are in `plastic_case/tests/FIT_TESTS.md`. Render one coupon family at a time with `-D 'test_set="m3_insert"'` (or another selector). A live read of `/info` reports ESP32 chip revision 1, 4 MB flash, no PSRAM and 240 MHz; the USB enumerates as a CP2102 bridge. Neither identifies the physical PCB outline, so the coupons keep ESP32/relay/supply profiles adjustable. Rework mode includes blind M3 insert seats; print the insert coupon and tune the pilot/boss dimensions before printing the enclosure.

The hardware rework sequence and evidence-backed mechanical decisions are tracked in `plastic_case/REWORK_PLAN.md`. In `rework` mode, the model adds a candidate OLED pocket and removable retainer, an EC11-family encoder pocket/retainer, blind M3 insert towers, four M3 carrier mounts, a removable 10 mm grid carrier, configurable USB/motor-cable openings (enabled by default), and an adjustable optional button cap. The cap is a separate fit candidate and does not replace the metal panel button. The grid carrier is a generic mounting surface, not a dimensioned cradle for all three boards. ESP32 PCB revision, relay/perfboard outline, supply outline, solder height and connector keep-outs still need physical checks. The USB bridge is CP2102; it does not identify the controller PCB. A six-part, watertight print candidate set is in `plastic_case/print_candidate/`; see its README before printing. It is a prototype and does not certify physical fit.

`validate_rework.py` reports mesh bounds, volume and area, watertightness, winding, connected positive-volume solids, and enclosed cavity shells across the candidate configuration matrix. The blind M3 insert bores create enclosed voids that STL represents as separate inward-wound shells; these are reported separately from printable solid components. This mesh check verifies CSG validity only, not fit to unmeasured hardware.

The current `validate_rework.py` run reports OpenSCAD `NoError`, one connected positive-volume component, and watertight meshes for the case, OLED retainer, encoder retainer, electronics carrier and button cap configurations. These checks establish valid CSG output, not fit or electrical clearance.
