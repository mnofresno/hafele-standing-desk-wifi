# Enclosure rework plan

This plan converts the physical fixes reported by the user into modeled features. It distinguishes verified interfaces from candidate dimensions so provisional values do not silently become manufacturing dimensions.

## Design direction

Use one removable internal electronics carrier, attached to four M3 heat-set inserts. The 55 × 118 mm grid plate has 10 mm spaced 3.2 mm holes and 7 mm of plenum below it. It gives a glue-free mounting surface for board screws or small zip ties, but is not yet a fitted cradle for the relay/perforated board or supply. The display and encoder have local removable retainers. A separate adjustable two-piece motor-cable clamp is modeled to attach to the carrier grid; its cable diameter and final placement still need a fit and pull test.

The SCAD now exposes `design_revision="baseline"` for the FreeCAD reconstruction and `design_revision="rework"` for the hardware-retention prototype. The rework mode defaults to candidate hardware dimensions from available photos/catalog envelopes; fit coupons and physical placement checks must still tune them before printing a complete enclosure.

## Feature decisions and evidence

| Feature | Proposed CAD change | Current evidence and limits | Validation before final enclosure |
|---|---|---|---|
| OLED | Rear pocket for the PCB envelope; opening remains the 26.64 × 14.46 mm active-area mask. A two-screw removable retainer supports the PCB perimeter and prevents it being pushed into the case. The header notch and alignment offsets are configurable. | Implemented in SCAD rework mode. Firmware configures a 128 × 64 SSD1306 display; the exact module/PCB is not identified. The 35.4 × 33.5 mm envelope is a candidate only. | Print `oled` coupon; compare actual PCB/header orientation; verify front glass position and retainer screws before full case.
| Panel pushbutton | Keep the metal threaded button and nut. A separately printable, adjustable socket cap is available as `show_part="button_cap"`; it does not replace the metal nut retention. | Photo shows a threaded metal button with nut. The cap starts at a 10 mm outside diameter and 6 mm socket, but button head diameter and stroke are unknown. | Print the `button` coupon and cap first; tune socket and roof before relying on it. Do not print the full enclosure to validate the button cap.
| Rotary encoder | Replace the oversized/unsupported shaft-only mounting with a body-capture pocket and removable perimeter retainer. The panel shaft opening is separate from the body envelope. | Implemented in SCAD rework mode. Candidate EC11-family body is 12.5 × 11.7 mm, depth 7.5 mm and nominal shaft Ø6 mm; exact variant and terminal edge remain unverified/configurable. | `encoder` coupon with the real encoder; check shaft clearance, axial push, terminal relief and knob engagement.
| ESP32 and USB | Place the ESP32 on the removable grid carrier and route a USB plug through an adjustable rounded slot. | Repository names a Wemos D1 ESP32; the observed USB bridge is CP2102. That does not identify the PCB and conflicts with the CH340G shown in the D1 R32 drawing. USB slot is enabled in the candidate default; connector type and location remain uncertain. | `board_outline` and `usb` coupons; check board outline, port end, slot coordinates, and connector overmold.
| Relay/perforated PCB | Use the carrier grid for adjustable M3 mounts or tie-downs; add edge clips once the board is measured. Keep solder tails and Dupont housings in the 7 mm plenum and open grid holes. | Photo shows a perforated relay board, but its outline, thickness, solder height and Dupont placement are not measurable. The grid is universal support, not a board-specific cradle. | `board_outline`, `board_edge`, and `dupont` coupons with the board and connectors; then set clip positions and confirm solder clearance.
| 5 V switching supply | Attach it to the carrier grid with adjustable clips or ties; add ventilation and terminal/wire access after locating the terminals. | Photo shows a separate supply board; exact model, outline, terminal locations, and heat dissipation are unknown. | Verify full terminal and connector envelope before finalizing clips or positioning it near the low-voltage boards.
| Motor output cable | A round end-wall opening is parameterized and enabled in the candidate default. A standalone two-piece saddle/cap clamp mounts to the carrier grid. | Photo confirms a corrugated boot; its diameter and exact exit coordinates are unknown. The clamp 6–12 mm variants are calibration candidates, not a measured boot. | Print the `motor_cable` coupon and saddle/cap; tune end/position and cable diameter, then pull-test the actual boot and wire.
| Lid assembly | Center the rework lid plate over the case top and place its four clearance holes over the case towers. | The source bodies are separate at the origin; their raw standalone coordinates do not define an assembled placement. Rework uses the shell top profile and tower centers; baseline geometry remains unchanged. | Check the lid sits flat, the M3 screws enter all four inserts, and the perimeter closes after printing the fit coupons. |
| Rear indicator windows | Add two adjustable rounded openings on the end face selected for the cable. | Two red apertures appear next to the cable in the rear photo; interpreting them as relay indicators is an inference. Their dimensions and coordinates are unmeasured. | Align the actual relay board LEDs behind the openings and tune center, spacing and shape before full enclosure printing. |
| M3 inserts | Rework towers use blind insert seats with a bottom clearance and lead-in. Lid holes use configurable M3 clearance. Panel retainers attach to blind M3 insert bosses. | Implemented in SCAD rework mode with candidate Ø8 mm bosses, Ø4 mm pilot and 5.7 mm insert; baseline mode retains Ø7/Ø4.25 through-bores. Insert dimensions are manufacturer-specific. | Print `m3_insert` and `m3_screw` coupons with the actual insert/screw; tune pilot, boss OD, embed depth and lid clearance from physical fit.
| Bottom/rear lower profile | Remove the introduced stair-step/chamfer and use one continuous rounded or straight transition. | User reports that the rendered step is absent from the real case. Existing photos are oblique, so exact curve/ramp is not measurable yet. | Compare an orthogonal side photo or a few profile measurements against the source shell before finalizing the profile.

## Current numerical candidates

- Front display mask: 26.64 × 14.46 mm (source-derived and to be preserved).
- OLED PCB pocket: 35.4 × 33.5 × 2.9 mm starting envelope from a common 1.3-inch 128 × 64 I²C module listing; vendor variants differ, so clearance, depth and header relief remain parameters.
- Encoder: body 12.5 × 11.7 mm, nominal shaft Ø6 mm; test an adjustable shaft clearance range rather than treating the catalog nominal as a print size.
- M3 insert coupon: pilot Ø3.8–4.2 mm, boss Ø6.5–8 mm, initial insert length 5.7 mm and 1 mm bottom reserve. The actual insert manufacturer's drawing and printed coupon decide final dimensions.
- ESP32, relay board, power supply, cable boot, and USB-plug opening remain editable placeholders until the physical parts are identified or measured.

## Work sequence

1. Print fit coupons for M3 inserts, OLED, encoder, button cap, USB and cable before relying on those interfaces.
2. Tune the USB/cable end and position parameters using the actual plugs and boot.
3. Place the actual three boards on the removable carrier grid and position clips or fasteners around their solder and Dupont connector keep-outs.
4. Test the two-piece motor clamp and confirm cable retention without loading its electrical termination.
5. Confirm the shifted rework lid seats on the case and all four screw holes align.
6. Render the full assembly, verify board and lid clearances, then print the final full-size enclosure.

## Still needed from the physical assembly

When convenient, provide square-on photos with a ruler of (a) the enclosure exterior showing display, button, encoder, USB and motor cable; (b) the open enclosure from above with every board in place; and (c) the ESP32 board front/back with its silkscreen readable. These will determine feature locations and may identify the development-board outline without needing to disassemble individual components. The current photo and firmware evidence is summarized in `HARDWARE_EVIDENCE.md`.
