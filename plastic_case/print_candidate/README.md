# Print candidate set

Open these four STL files as separate objects in Bambu Studio or Cura:

- `case_rework_candidate.stl`
- `lid_rework_candidate.stl`
- `oled_retainer_candidate.stl`
- `encoder_retainer_candidate.stl`
- `electronics_carrier_candidate.stl`
- `button_cap_candidate.stl`

They use the default OpenSCAD rework parameters. The case includes the USB
opening at the near end and the motor cable opening at the far end. The removable
electronics carrier has a 10 mm mounting grid and four M3 insert mounts. The
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
```

All six meshes pass OpenSCAD's manifold render. The rework dimensions remain
candidate fit values: verify the OLED/encoder coupons and M3 insert coupon first.
The USB and cable opening ends and coordinates are configurable because the
photos do not establish their exact locations. The carrier grid avoids bonding
boards to the shell, but the relay/perfboard and 5 V supply still need their
actual outlines and connector/solder keep-outs checked before a final enclosure
print. These STLs are a printable prototype set; they do not certify component
fit or FreeCAD equivalence across parameter changes.
