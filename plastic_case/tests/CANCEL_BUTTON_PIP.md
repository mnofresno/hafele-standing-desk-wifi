# Captive cancel-button coupon

This is a new prototype, not yet part of the enclosure print set. The main enclosure is awaiting measured OLED/encoder/PCB envelopes and the combined base-mounted bracket.

## Reference and mechanism

`$HOME/magic-shoebox/cad/magic_shoebox.scad`, commit `73c68b32776ad2cf10696732584ce6a8d60d5aa6`, uses a 12×12 mm tactile-switch family, a Ø13 mm printed cap, Ø16.5 mm retaining flange, Ø13.6 mm panel opening, and a Ø5.2 mm stem socket. That source does not identify the actual switch SKU or body/plunger heights; its cap is a separate printed piece.

The [Omron B3F datasheet](https://omronfs.omron.com/en_US/ecb/products/pdf/en-b3f.pdf) provides a documented low-profile reference: the B3F-4000 family is 12×12 mm with 4.3 mm height, while projected-plunger variants are taller. Its specified electrical pretravel is not a maximum permissible overtravel. This reference does not identify the user's switch. The future cradle and cap pusher must match the selected/actual part.

The prototype adds front and rear captive stops and two sacrificial necks. Print orientation reproduces the 75° enclosure panel. The first inward press breaks the narrow connections; their wider roots remain on the panel. The released cap then translates along its axis. A rear ring limits inward travel; the flange prevents outward escape. The switch spring must provide return after installation—there is no printed return spring.

Defaults are 0.3 mm radial gap, 0.3 mm resting flange gap, 0.65 mm candidate travel, and 0.4×0.2 mm neck cross-sections. Travel, stem and stop dimensions are provisional; they do not establish switch overtravel safety. The low-profile switch will use a flat contact pusher rather than assuming that the shoebox's Ø5.2 socket fits every plunger.

## Print and release

Start with `print/cancel_pip_clearance_0p30.stl`. The other two files vary only radial clearance, at 0.25 and 0.35 mm. Use the same filament, nozzle and layer settings as the future enclosure; 0.2 mm layers are the initial neck-height assumption. The wide base lies flat on the build plate. Avoid slicer-generated supports entering the moving gap: inspect the sliced paths before printing.

1. **Before installing a switch**, press once to release the cap. Fracture force is not measured by CAD and must not be transmitted into a newly installed tactile switch.
2. Inspect the neck remnants and clear strings. Check the cap slides without rubbing; push it back from the rear opening for this switch-free coupon.
3. Check that the cap remains captive in both directions and reaches a definite inward stop.
4. With the actual switch/cradle, tune stem reach, resting clearance and the stop. Verify that the switch is not held electrically closed at rest, clicks before the stop, and returns reliably. Neither native CSG nor the mesh tests prove these physical events.

Reproduce from the repository root:

```sh
openscad -o /tmp/cancel-pip.stl -D 'radial_clearance=0.3' plastic_case/tests/cancel_pip_coupon.scad
python3 -m pytest -q plastic_case/tests/test_cancel_pip.py
```

`part="fixed"` and `part="moving"`, with `state="released"`, export independent positive controls. The released model keeps the wall-side tab roots and omits the narrow fractured necks; actual fracture remnants/stringing are not predicted. Tests establish one connected as-printed solid, two released solids, no overlap over the candidate stroke, and geometric stops against overpress/outward escape. They do not prove print-in-place clearance, release force, return, wear or fit to the actual switch.
