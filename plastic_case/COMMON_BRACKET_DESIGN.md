# Combined controls and mounting revision — in progress

## User requirements (2026-10-26)

- One removable printed bracket retains the OLED, replacement cancel switch and encoder.
- Prefer upright floor-mounted heat-set inserts and vertical screwdriver access through the open lid. Place inserts in an empty case; keep a clear approach for the soldering iron.
- Use countersunk M3 screws from the user's stock: 10, 12, 15, 20 and 25 mm, favoring 15 mm. M3 lengths include the countersunk head. Size integral grips/standoffs and blind-bore tip clearance so the selected screw clamps before bottoming.
- Replace the threaded metal cancel button with a low-profile 12×12 tactile switch and printed captive actuator based on magic-shoebox. Investigate print-in-place breakaway supports with the standalone coupon before integrating them.
- Secure each electronics board with a single removable clamp screw where feasible, plus locating rails/stops that resist rotation. A lone screw without positive location is insufficient. Support solder-side clearance and connector/wire access.
- Retain the existing wood-mount hole centers. Replace square thin ears with rounded/teardrop outlines and broad, reinforced roots. Keep the wood contact plane; use an accessible recessed countersunk seat so reinforcement does not require longer Parker screws. Check the actual head/thread dimensions and wood thickness before fixing seat depth/penetration.

## Combined bracket design direction

Use a single longitudinal structural rail, three component-specific support shoes and three spaced floor-mount ears. Each shoe follows the front-panel angle, while screws and inserts face upward. A triangular mounting pattern is preferable to three collinear supports if the measured PCB/connector space permits it. Place screw-head seats behind the components, with modeled driver and iron approach envelopes. No angled-panel insert operation is intended for the new bracket.

For an M3×15 screw with 4.5 mm engagement, the distance from its flush head plane to the insert entrance is 10.5 mm. This is an initial relationship, not a fixed final dimension: actual insert length, tip clearance, component depths and tool corridors determine the final grips. Incorporate spacers into the bracket rather than loose stacks. Use true conical countersinks and leave access to their heads. The lid also needs countersunk-head seats and sufficient pilot depth for the chosen M3 length; proud heads must not prevent flush mounting against the wood.

The PCB perimeter, not the OLED's mounting holes, locates the display. The encoder shoe must account for its complete PCB/header envelope rather than assuming a bare EC11 body. The switch cradle must support its body and leave its terminals/wires free. Stops and cap geometry must avoid preload and excessive switch travel.

## New interior-photo evidence

Three unique photos were supplied: `WhatsApp Image 2026-10-26 at 10.36.39.jpeg`, `...10.36.40.jpeg`, and `...10.36.40 (1).jpeg` (the latter was attached twice). No scale is present.

- The ESP32 is a narrow micro-USB development board with four corner holes; its exact PCB revision and dimensions remain unmeasured.
- Two separate blue Songle relay packages are visible on relay-module PCBs over the brown perforated board. The package inscription includes `SRD-05VDC-SL-C`; that identifies the relay package, not the complete module outline.
- The converter board has a toroidal inductor, blue trimmer, finned heatsink and electrolytic capacitors. Its IC marking and input/output ratings are not readable. Do not infer a mains input from the earlier phrase “switching supply.” Preserve space for the heatsink and adjustment access.
- Dupont housings and long wire loops occupy substantial space behind the controls; these must be modeled as envelopes before closing the layout.
- Hot glue visibly retains parts at the control side and perforated-board area. Replace those contacts with the new shoes, rails and removable clamps.
- The USB access and molded cable boot are at the long rear wall opposite the controls. Existing end-face opening defaults are provisional and do not establish these locations. Final cuts should follow the revised board placement and measured boot/plug envelopes.
- The boot has shoulders and a shaped neck. A split seat at the lid seam may capture it more simply than a round opening and extra clamp; its neck dimensions and permitted wall thickness are required.

## Inputs requested while the case is open

OLED PCB/module/Dupont envelope; encoder PCB/axis/header envelope; insert OD/length; Parker thread/head diameters and wood thickness; converter/ESP32/perfboard outlines and populated/connected heights; cable-boot neck and shoulder spacing; and actual new tactile-switch heights if available. Those measurements are pending. Production bracket positions, board clamps and mounting ears must not be reported fit-approved before they are incorporated and checked.
