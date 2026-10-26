# Print candidate set

Open these eight STL files as separate objects in Bambu Studio or Cura:

- `case_rework_candidate.stl`
- `lid_rework_candidate.stl`
- `oled_retainer_candidate.stl`
- `encoder_retainer_candidate.stl`
- `electronics_carrier_candidate.stl`
- `button_cap_candidate.stl`
- `motor_cable_saddle_8mm_calibration.stl`
- `motor_cable_cap_8mm_calibration.stl`

`assembly_preview.png` shows the assembled rework lid; `assembly_exploded_preview.png` shows the interior and grid carrier. They use the default OpenSCAD rework parameters. The case includes the USB opening at the near end, the motor cable opening at the far end, and adjustable relay indicator windows. The removable
electronics carrier has a 10 mm mounting grid, four M3 insert mounts, and
open 0.35 mm reliefs around both control retainers, their bosses and configured
screw-head envelopes. The
OLED and encoder use separate retainers. Original tracked FreeCAD/STL files are
untouched.

Rebuild the parts from the repository root:

```sh
python3 plastic_case/tools/build_print_set.py
python3 plastic_case/tools/build_print_set.py --verify
```

The builder checks each STL is one positive watertight solid, rebuilds both
previews, and records CAD-source and artifact SHA256 checksums in `manifest.json`.
The verification command fails if either CAD source or any generated file changes.
The following individual commands are useful for customized exports; afterward
rebuild the complete default set to update the manifest:

```sh
openscad -o plastic_case/print_candidate/case_rework_candidate.stl -D 'show_part="case"' plastic_case/hafele_control_box.scad
openscad -o plastic_case/print_candidate/lid_rework_candidate.stl -D 'show_part="lid"' plastic_case/hafele_control_box.scad
openscad -o plastic_case/print_candidate/oled_retainer_candidate.stl -D 'show_part="oled_retainer"' plastic_case/hafele_control_box.scad
openscad -o plastic_case/print_candidate/encoder_retainer_candidate.stl -D 'show_part="encoder_retainer"' plastic_case/hafele_control_box.scad
openscad -o plastic_case/print_candidate/electronics_carrier_candidate.stl -D 'show_part="electronics_carrier"' plastic_case/hafele_control_box.scad
openscad -o plastic_case/print_candidate/button_cap_candidate.stl -D 'show_part="button_cap"' plastic_case/hafele_control_box.scad
openscad -o plastic_case/print_candidate/motor_cable_saddle_8mm_calibration.stl -D 'cable_od=8' -D 'show_part="saddle"' plastic_case/tests/motor_cable_clamp.scad
openscad -o plastic_case/print_candidate/motor_cable_cap_8mm_calibration.stl -D 'cable_od=8' -D 'show_part="cap"' plastic_case/tests/motor_cable_clamp.scad
```

All eight meshes pass OpenSCAD's manifold render. The cable clamp is a separate 8 mm calibration candidate: measure the actual corrugated boot and tune its compression before installation. This is a coupon-first prototype
set, not a fit-approved enclosure: print the OLED/encoder/M3/button/USB/cable
coupons and place the actual boards on the carrier before committing to the full
case. The rework dimensions remain candidate fit values. Rebuild the enclosure
after changing `carrier_encoder_clearance` so the relief follows the retainer.
Install and tighten the OLED/encoder retainers before installing the removable
carrier. Their rear screw plates contact the ends of the case bosses and the
support lips extend forward; the OLED lower lip opens around the curved floor.
The lid installs with its locating lip facing into the case, with a configurable
0.25 mm normal clearance. Lower separate parts to the slicer's build plate and
choose an orientation appropriate for the selected material and supports.
The USB and cable opening ends and coordinates are configurable because the
photos do not establish their exact locations. The carrier grid avoids bonding
boards to the shell, but the relay/perfboard and 5 V supply still need their
actual outlines and connector/solder keep-outs checked before a final enclosure
print. These STLs are a printable prototype set; they do not certify component
fit or FreeCAD equivalence across parameter changes.

The historical `../control_box.stl` and `../control_box_lid.stl` are preserved
FreeCAD exports. They do not contain these rework features.
