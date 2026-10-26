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
electronics carrier has a 10 mm mounting grid, four M3 insert mounts, and a
0.35 mm radial relief around the encoder-retainer footprint to eliminate its
measured CSG overlap. The
OLED and encoder use separate retainers. Original tracked FreeCAD/STL files are
untouched.

Rebuild the parts from the repository root:

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
The USB and cable opening ends and coordinates are configurable because the
photos do not establish their exact locations. The carrier grid avoids bonding
boards to the shell, but the relay/perfboard and 5 V supply still need their
actual outlines and connector/solder keep-outs checked before a final enclosure
print. These STLs are a printable prototype set; they do not certify component
fit or FreeCAD equivalence across parameter changes.
