# Häfele control box: OpenSCAD reconstruction

This folder contains the native OpenSCAD reconstruction (`baseline`) and the hardware-retention prototype (`rework`). The measured baseline checks pass the sampled 0.05 mm threshold for the saved default geometry and two recomputed variants. The default FreeCAD support sketches are invalid, so its saved solid is a snapshot reference, not proof of a valid recompute. General parametric equivalence and physical component fit remain unproven.

For the improved enclosure use the eight STL files in [print_candidate](print_candidate/README.md). `control_box.stl` and `control_box_lid.stl` are the historical FreeCAD exports and do not contain the rework features. [The post-merge audit](CAD_AUDIT.md) records the corrected assembly and validation defects.

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
| B9 | `pos_display_x` | 20 | `pos_display_x` | Display sketch position in the source-aligned panel frame |
| B10 | `pos_display_y` | 15 | `pos_display_y` | Display sketch position in the source-aligned panel frame |
| B11 | `distancia_botones` | 40 | `distancia_botones` | Button spacing |
| B12 | `altura_botones` / source label pos_y_botones | 3 | `altura_botones` | Button/encoder sketch elevation in the source-aligned panel frame |
| B13 | `pos_x_botones` | 75 | `pos_x_botones` | Source location is `-longitud + pos_x_botones`; encoder adds `distancia_botones` |
| B14 | `dia_botones` | 8.68 | `dia_botones` | Button opening diameter |
| B15 | `espesor_tapa` | 1.5 | `espesor_tapa` | No final feature expression references this cell; retained but source geometry follows `ancho_pared` |
| B16 | `dia_torres_tornillos` | 7 | `dia_torres_tornillos` | Tower outer diameter |
| B17 | `long_torres_tornillos` | `=B2-B8` | `long_torres_tornillos` | Tower height |
| B18 | `separacion_torres_tornillos` | 6 | `separacion_torres_tornillos` | Tower spacing and near support plane offset; underconstrained support-profile points remain explicit extra parameters |
| B19 | `dia_interno_torres_tornillos` | 4.25 | `dia_interno_torres_tornillos` | Tower bore diameter |

The 45-object inventory in `freecad_model_inventory.json` includes source SHA256, dependencies/dependents, object states and placements, construction flags, sketch/constraint positions, expressions, spreadsheet contents, and final BRep measurements. Construction geometry is explicitly distinguished from solid-profile geometry.

## OpenSCAD use

Open `hafele_control_box.scad` in OpenSCAD. In Customizer, choose `design_revision="baseline"` to view/export the FreeCAD reconstruction or `design_revision="rework"` for the hardware-retention prototype. The rework mode is the default. Choose `case`, `lid`, `assembly`, `oled_retainer`, `encoder_retainer`, `electronics_carrier`, or `button_cap` with `show_part`. All dimensions are millimetres. CLI exports:

```sh
openscad -o /tmp/control-box-case.stl -D 'show_part="case"' plastic_case/hafele_control_box.scad
openscad -o /tmp/control-box-lid.stl -D 'show_part="lid"' plastic_case/hafele_control_box.scad
openscad -o /tmp/control-box-assembly.stl -D 'show_part="assembly"' plastic_case/hafele_control_box.scad
openscad -o /tmp/oled-retainer.stl -D 'show_part="oled_retainer"' plastic_case/hafele_control_box.scad
openscad -o /tmp/encoder-retainer.stl -D 'show_part="encoder_retainer"' plastic_case/hafele_control_box.scad
openscad -o /tmp/control-box-baseline.stl -D 'design_revision="baseline"' -D 'show_part="case"' plastic_case/hafele_control_box.scad
```

## Extraction and comparison

FreeCAD 1.0.2 and OpenSCAD CLI are required. Install the tested Python dependencies with `python3 -m pip install -r plastic_case/tools/requirements-cad.txt` in a Python 3.9 environment. FreeCAD exports use its separate bundled Python. On this macOS install:

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
python3 -m pytest -q plastic_case/tests
python3 plastic_case/tools/validate_rework.py \
  --scad plastic_case/hafele_control_box.scad \
  --configs plastic_case/tests/rework_configurations.json \
  --out plastic_case/tests/rework-validation.json
python3 plastic_case/tools/validate_clearance.py \
  --configs plastic_case/tests/assembly_configurations.json \
  --out plastic_case/tests/assembly-clearance.json
python3 plastic_case/tools/build_print_set.py
python3 plastic_case/tools/build_print_set.py --verify
```

`export_freecad.py` exports final body tips as fine STL and STEP plus the inventory. `validate_geometry.py` fails with a nonzero exit code for failed topology, excessive sampled distance, tool errors, or an invalid parameterized FreeCAD recompute. A saved default with invalid sketches is classified `source_snapshot_only`; variants require a valid recompute. Reports include object/solver states.

The comparator measures bounds, volume, surface area, connected solids, watertightness/winding, and sampled bidirectional surface distances. It computes symmetric differences with a finite-precision mesh Boolean using `manifold3d`. If unavailable, a clearly labeled shared-lattice occupancy estimate is used instead. Neither method proves exact BRep identity.
## Baseline geometry measurements

FreeCAD's exact BRep metrics and a fine STL inventory are in `freecad_model_inventory.json`. The validator exports FreeCAD with 0.01 mm linear tessellation, samples 10,000 random surface points plus up to 50,000 mesh vertices and face centers in each direction, and computes symmetric difference between the two tessellated meshes. The surface maxima are measured samples, not a mathematical upper bound.

| Configuration | Part | BBox max delta (mm) | Volume delta (mm³) | Mesh symmetric difference (mm³) | Sampled surface max A→B / B→A (mm) | 0.05 mm check |
|---|---|---:|---:|---:|---:|---|
| Default saved snapshot | case | 0.000502 | 6.7285 | 12.1150 | 0.043642 / 0.034062 | Pass |
| Default saved snapshot | lid | 0.000000 | 0.0565 | 0.0765 | 0.000987 / 0.001026 | Pass |
| Longer / thicker | case | 0.000502 | 7.2524 | 13.3299 | 0.004557 / 0.004524 | Pass |
| Longer / thicker | lid | 0.000000 | 0.0753 | 0.1020 | 0.001009 / 0.001026 | Pass |
| 78.5° / source edge remap | case | 0.000111 | 9.4283 | 15.0947 | 0.004557 / 0.004496 | Pass |
| 78.5° / source edge remap | lid | 0.000000 | 0.0753 | 0.1020 | 0.001009 / 0.001000 | Pass |

The longer configuration explicitly sets `support_floor_left_x=7.12701665379` and `support_inner_offset=8` from the recomputed FreeCAD sketches. Its prior 0.127 mm residual came from the four tower profiles: Sketch003 uses instance-specific arc/chord boundaries. The OpenSCAD towers now reproduce those chords from `dia_torres_tornillos` and `ancho_pared`; the measured longer-configuration maximum is below 0.0046 mm in both sample directions after restoring exact end-skin positions and reducing the internal CSG overlap to 0.001 mm. The finite surface samples and mesh Boolean support the stated checks but are not a certified Hausdorff bound or a mathematical proof of identity.

The earlier short-boundary probe (`alto=30`, `longitud=120`, `ancho_pared=1.2`, `profundidad=62`, `angulo_del_panel=72`, `radio_curvaturas=4`) is excluded from the valid comparison matrix. FreeCAD reported Sketch006 `Invalid`, 1 DoF and Sketch007 `Invalid`, 4 DoF after recompute, retaining stale 33.5 mm support geometry above the 30 mm case. Raising `alto` to 33.5 made both sketches `Up-to-date` with 0 DoF, but that point is not included until its geometry comparison is run. The default source reports invalid support sketches after recompute; their states and degrees of freedom are captured in the report. Its comparison is therefore classified as a saved-solid snapshot. Do not claim general parametric equivalence. The original FreeCAD document and tracked STL exports remain unchanged.

## Parameter configurations and known gaps

`tests/configurations.json` compares the default snapshot, a valid longer/thicker recompute, and a valid 78.5° recompute with explicitly transcribed support coordinates. The angle case changes `Pad002.Edge156` from a near-left tower edge to a far-right tower edge in FreeCAD. `Sketch006` therefore moves `support_floor_left_x` from 7.12701665379 to 56.26881262189947 mm even though it remains fully constrained. The model reproduces that source snapshot using the explicit coordinate; it does not encode an edge-number jump as a design formula. `support_inner_offset` remains 8 mm. These two support coordinates are exposed parameters, so arbitrary spreadsheet variations still need a source solve and comparison. See `CAD_AUDIT.md` for the reference chain.

## Hardware fit-test coupons

Parametric coupon models for the OLED pocket, EC11-family encoder body/knob, panel pushbutton, USB opening, motor cable boot, Dupont connector headroom, PCB outline/edge rails/solder clearance, and M3 brass inserts are in `plastic_case/tests/fit_test_coupons.scad`. Printing instructions, parameter ranges, and component-retention decisions are in `plastic_case/tests/FIT_TESTS.md`. Render one coupon family at a time with `-D 'test_set="m3_insert"'` (or another selector). A live read of `/info` reports ESP32 chip revision 1, 4 MB flash, no PSRAM and 240 MHz; the USB enumerates as a CP2102 bridge. Neither identifies the physical PCB outline, so the coupons keep ESP32/relay/supply profiles adjustable. Rework mode includes blind M3 insert seats; print the insert coupon and tune the pilot/boss dimensions before printing the enclosure.

The hardware rework sequence is tracked in `plastic_case/REWORK_PLAN.md`, and photo/firmware identification evidence is in `plastic_case/HARDWARE_EVIDENCE.md`. In `rework` mode, the model adds a candidate OLED pocket and removable retainer, an EC11-family encoder pocket/retainer, blind M3 insert towers, four M3 carrier mounts, a removable 10 mm grid carrier, configurable USB/motor-cable openings and two photo-derived relay-indicator windows (enabled by default), and an adjustable optional button cap. Rework installs the lid with its locating lip inside the opening. The lip follows the angled walls with 0.25 mm normal clearance and its holes match the tower centers; baseline standalone geometry retains the FreeCAD lid. The standalone two-piece motor-cable clamp is in `tests/motor_cable_clamp.scad`; it mounts to the carrier grid and has a separate calibration STL pair. The cap is a separate fit candidate and does not replace the metal panel button. The grid carrier is a generic mounting surface, not a dimensioned cradle for all three boards. ESP32 PCB revision, relay/perfboard outline, supply outline, solder height and connector keep-outs still need physical checks. The USB bridge is CP2102; it does not identify the controller PCB. An eight-part print candidate set (six enclosure pieces plus a calibration clamp pair) is in `plastic_case/print_candidate/`; the folder also has assembled and exploded previews. See its README before printing. It is a prototype and does not certify physical fit.

`validate_rework.py` reports mesh bounds, volume and area, watertightness, winding, connected positive-volume solids, and enclosed cavity shells across the candidate configuration matrix. The blind M3 insert bores create enclosed voids that STL represents as separate inward-wound shells; these are reported separately from printable solid components. This mesh check verifies CSG validity only, not fit to unmeasured hardware.

`carrier_encoder_clearance` now clears both control retainers, their case bosses and configurable screw-head envelopes. Each relief opens to the carrier edge so it cannot leave disconnected islands. `validate_clearance.py` first exports all five installed parts as positive controls, rejecting empty/missing/invalid meshes, then measures all ten pairwise intersections. Its 0.0001 mm³ default tolerance allows finite-precision surface contact; it does not measure printer clearance. The default and longer/thicker assemblies pass. The regression suite also checks head access to the cable-clamp recesses and retainer screw-head clearance to the case/carrier.

Install the OLED and encoder and tighten their rear retainers **before** installing the carrier. The rear plates bear against the boss ends; support lips extend forward beside the bosses. A rear brace joins the OLED retainer around its header notch, while its lower lip opens around the curved shell floor. The default carrier is approximately 54.62 × 122 × 2 mm with a 7 mm plenum; its panel-side mounts sit farther inward to clear the controls. Actual board, header, Dupont and wire envelopes still require physical checks.
The current `validate_rework.py` run reports OpenSCAD `NoError`, one connected positive-volume component, and watertight meshes for the case, OLED retainer, encoder retainer, electronics carrier and button cap configurations. These checks establish valid CSG output, not fit or electrical clearance. The standalone clamp saddle/cap also rendered at 6, 8, 10 and 12 mm cable candidates; all eight meshes were watertight, consistently wound, and one positive-volume component.
