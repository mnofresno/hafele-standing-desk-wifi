# Enclosure rework plan

This plan converts the physical fixes reported by the user into modeled features. It distinguishes verified interfaces from candidate dimensions so provisional values do not silently become manufacturing dimensions.

## Design direction

Use one removable internal electronics carrier, attached to the case with M3 heat-set inserts. The carrier captures the ESP32 board, relay/perforated board, and 5 V supply with edge rails or replaceable clips. It should install as one assembly, leave solder and connector space below/above each PCB, and keep wires away from the lid seam and screw paths. The display and encoder receive local retainers tied to the same serviceable structure. Add a separate two-piece clamp for the motor cable so cable pull does not load its electrical terminals.

The SCAD now exposes `design_revision="baseline"` for the FreeCAD reconstruction and `design_revision="rework"` for the hardware-retention prototype. The rework mode defaults to candidate hardware dimensions from available photos/catalog envelopes; fit coupons and physical placement checks must still tune them before printing a complete enclosure.

## Feature decisions and evidence

| Feature | Proposed CAD change | Current evidence and limits | Validation before final enclosure |
|---|---|---|---|
| OLED | Rear pocket for the PCB envelope; opening remains the 26.64 × 14.46 mm active-area mask. A two-screw removable retainer supports the PCB perimeter and prevents it being pushed into the case. The header notch and alignment offsets are configurable. | Implemented in SCAD rework mode. The 35.4 × 33.5 mm 1.3-inch PCB is the best-fit candidate, not a confirmed SKU; cavity and retainer values remain adjustable. | Print `oled` coupon; compare actual PCB/header orientation; verify front glass position and retainer screws before full case.
| Panel pushbutton | Keep the metal threaded button and nut. Its existing panel through-hole is retained; a rear body pocket and printed actuator cap are not modeled yet because their dimensions and travel are unknown. | Photo shows a threaded metal button with nut. Exact thread, body length, nut size and stroke are unknown; do not replace its metal retention with a guessed snap fit. | `button` coupon; measure or photograph the actual body/nut and verify available internal depth and cap travel before adding either feature.
| Rotary encoder | Replace the oversized/unsupported shaft-only mounting with a body-capture pocket and removable perimeter retainer. The panel shaft opening is separate from the body envelope. | Implemented in SCAD rework mode. Candidate EC11-family body is 12.5 × 11.7 mm, depth 7.5 mm and nominal shaft Ø6 mm; exact variant and terminal edge remain unverified/configurable. | `encoder` coupon with the real encoder; check shaft clearance, axial push, terminal relief and knob engagement.
| ESP32 and USB | Put the ESP32 in the removable carrier with USB plug insertion/removal corridor. A rounded end-wall access slot is parameterized and disabled by default until its end and coordinates are verified. | USB slot is implemented in SCAD rework mode. USB enumerates as Silicon Labs CP2102 (`/dev/cu.usbserial-0001`); this identifies the bridge, not the ESP32 PCB. The internal carrier and USB position are still pending board-layout evidence. | `board_outline` plus `usb` coupons; verify actual board edge, port face, position and cable overmold before enabling the slot.
| Relay/perforated PCB | Capture its edges on insulated rails or clips. Use a local relief below solder tails and leave connector unplugging space above. Do not put M3 fasteners through the perfboard. | Open-case photo shows a separate perforated relay board, but its outline, thickness, solder height and Dupont placement are not measurable from that image. | `board_outline`, `board_edge`, and `dupont` coupons with the assembled board and connectors.
| 5 V switching supply | Give it a separate cradle on the carrier, with ventilation and terminal/wire access. Preserve separation from low-voltage signal wiring and do not enclose mains terminals behind inaccessible printed walls. | Photo shows a separate supply board; exact model, terminal locations and heat dissipation are unknown. | Measure its full terminal/connector envelope and verify clearances in the carrier mockup before printing the full case.
| Motor output cable | A round end-wall opening is parameterized and disabled by default; a two-piece strain-relief clamp remains to be designed after the boot and cable angle are checked. | Cutout is implemented in SCAD rework mode. Exterior photo confirms an existing end-near opening and corrugated boot, but boot diameter, side/end selection and exact coordinates are unknown. | `motor_cable` coupon; set the correct end/position from the enclosure photo; design and test the clamp on the actual boot.
| M3 inserts | Rework towers use blind insert seats with a bottom clearance and lead-in. Lid holes use configurable M3 clearance. Panel retainers attach to blind M3 insert bosses. | Implemented in SCAD rework mode with candidate Ø8 mm bosses, Ø4 mm pilot and 5.7 mm insert; baseline mode retains Ø7/Ø4.25 through-bores. Insert dimensions are manufacturer-specific. | Print `m3_insert` and `m3_screw` coupons with the actual insert/screw; tune pilot, boss OD, embed depth and lid clearance from physical fit.
| Bottom/rear lower profile | Remove the introduced stair-step/chamfer and use one continuous rounded or straight transition. | User reports that the rendered step is absent from the real case. Existing photos are oblique, so exact curve/ramp is not measurable yet. | Compare an orthogonal side photo or a few profile measurements against the source shell before finalizing the profile.

## Current numerical candidates

- Front display mask: 26.64 × 14.46 mm (source-derived and to be preserved).
- OLED PCB pocket: 35.4 × 33.5 mm starting envelope; clearance and header relief are separate parameters.
- Encoder: body 12.5 × 11.7 mm, nominal shaft Ø6 mm; test an adjustable shaft clearance range rather than treating the catalog nominal as a print size.
- M3 insert coupon: pilot Ø3.8–4.2 mm, boss Ø6.5–8 mm, initial insert length 5.7 mm and 1 mm bottom reserve. The actual insert manufacturer's drawing and printed coupon decide final dimensions.
- ESP32, relay board, power supply, cable boot, and USB-plug opening remain editable placeholders until the physical parts are identified or measured.

## Work sequence

1. Print the small fit coupons first: M3 inserts, OLED, encoder, button, USB/cable, then board/connector gauges.
2. Measure/photograph component envelopes and connector keep-outs, then tune rework-mode parameters and choose the USB/cable end positions.
3. Lay out the removable carrier and check it against case walls, support ribs, lid towers, display retainers, and wire paths.
4. Design the rail/clip supports for ESP32, relay/perfboard, and PSU and the two-piece motor cable clamp.
5. Render and inspect the case, carrier, retainers and lid together; run mesh checks and produce a final full-size fit/assembly preview.

## Still needed from the physical assembly

When convenient, provide square-on photos with a ruler of (a) the enclosure exterior showing display, button, encoder, USB and motor cable; (b) the open enclosure from above with every board in place; and (c) the ESP32 board front/back with its silkscreen readable. These will determine feature locations and may identify the development-board outline without needing to disassemble individual components.
