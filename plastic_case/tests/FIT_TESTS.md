# Enclosure fit-test coupons

`fit_test_coupons.scad` produces small calibration pieces for the interfaces that could otherwise force drilling, melting, gluing, or rebuilding the full enclosure. Print one `test_set` per job. The `all` setting is a layout preview and may exceed the printer bed.

## First test: M3 heat-set inserts

The brass insert body is not dimensioned by the M3 thread standard: manufacturers sell different outer diameters and lengths. The coupon therefore tests both the printed pilot bore and the boss outside diameter.

Defaults print 20 bosses with pilot bores from 3.8 to 4.2 mm in 0.1 mm steps and boss diameters 6.5, 7.0, 7.5, and 8.0 mm. The bore depth suits a 5.7 mm insert plus a 1 mm bottom reserve. Change `m3_insert_length` to match shorter inserts before slicing. Labels are `bore/boss diameter` in mm.

Reference examples differ: a general insert guide lists M3 at 4.0 mm pilot, 4.6 mm OD, 4–6 mm length and 6.5 mm minimum boss; AndyMark's specific M3 insert is 4.2 mm OD by 4 mm long and calls for a 4 mm installation hole. The exact packet or manufacturer drawing wins over either generic example. Sources: [Albany County Fasteners size table](https://www.albanycountyfasteners.com/media/64/3d/5a/1764619189/heat-set-insert-specs.pdf?ts=1764619189), [AndyMark insert dimensions](https://andymark.com/products/m3-heat-set-threaded-insert), [Prusa/CNC Kitchen insert set](https://www.prusa3d.com/product/heat-set-inserts-m3-standard-100-pcs/).

The SCAD `baseline` revision has 7 mm screw-tower outside diameters and 4.25 mm **through-bores**. Those are not M3 insert seats. The `rework` revision now uses blind Ø4.0 mm pilot candidates in Ø8 mm bosses, with insert length, bottom clearance and lead-in configurable. The coupon tests pilot bores from 3.8–4.2 mm and bosses from 6.5–8.0 mm; use the actual insert package and printed coupon to choose the final values. The rework lid pass-through is 3.4 mm for an M3 clearance fit and remains configurable.

## Other coupon sets

| `test_set` | What it tests |
|---|---|
| `oled` | Front window at 26.64 × 14.46 mm and rear PCB pocket. Default PCB candidate 35.4 × 33.5 mm; alternate 27.3 × 27.3 mm. The four board mounting holes do not locate or retain the display. The open edge leaves room for the I2C header. |
| `encoder` | EC11-family body pocket over several per-side clearances, plus shaft-bore gauges for a printed knob. The encoder body is captured; the shaft does not retain the encoder. |
| `button` | Panel hole gauges Ø8.2–9.2 mm in 0.2 mm steps around the source-model Ø8.68 mm opening, plus a shallow adjustable hex relief for the existing metal nut and a cap/socket gauge. |
| `usb` | Rounded port openings around an adjustable cable-plug envelope. Set `usb_plug_width` and `usb_plug_height` for the actual cable overmold. |
| `motor_cable` | Circular opening series for the corrugated cable boot. This tests fit only; the final case also needs a separate clamp to take cable pull. |
| `dupont` | Header and connector clearance coupons with adjustable depth/bend allowance. Test the actual female housings and wire direction. |
| `m3_screw` | Through-hole and head recess sizes for M3 screws. |
| `board_edge` | Edge-channel clearance for the soldered perfboard, plus standoff-height gauges for solder tails below it. This coupon is a gauge only; the current carrier is a universal grid and does not yet include board-specific rails or clips. M3 inserts go in the carrier/case, not through tiny perfboard holes. |
| `board_outline` | Adjustable perimeter-frame coupons for the ESP32 board, relay/perfboard, or 5 V supply. Options include the official ESP32-DevKitC V4 outline (48.26 × 27.94 mm), a D1-mini-compatible outline (34.2 × 25.6 mm), and a D1 R32 outline (68 × 53 mm). The official LOLIN D1 mini is an ESP8266 board, so its outline is only a size alternative for a compatible clone, not evidence of the installed ESP32 board. The repo's `Wemos D1 ESP32` name and generic Arduino FQBN do not distinguish the installed PCB. Relay-board and supply outlines are editable starting values, not verified measurements. Dimensions are candidate profiles from the [Espressif DevKitC V4 drawing](https://dl.espressif.com/dl/schematics/esp32_devkitc_v4_dimensions.pdf), [LOLIN D1 mini specifications](https://www.wemos.cc/en/latest/d1/d1_mini.html), and [D1 R32 drawing](https://handsontec.com/dataspecs/module/ESP/WeMos%20D1%20R32.pdf). |

## Corrugated motor-cable strain relief

`motor_cable_clamp.scad` is a standalone two-piece accessory; it does not change the enclosure model. It has a semicircular saddle and a matching cap, two M3 cap screws seated in heat-set inserts in the saddle, and four M3 carrier mounting holes. Those four mounting-hole centers are at `(+/-mount_grid_pitch, +/-mount_grid_pitch)`: with the 10 mm default, they land on the existing 10 mm carrier grid (the four corners span 20 × 20 mm). The model's `cable_od` and `cable_interference` are calibration variables; the defaults do not assert the installed boot diameter or a proven squeeze. Measure across the cable corrugations, then use a printed gauge/clamp to tune fit and retention.

The saddle prints with its flat mounting face on the bed. Print the cap upside down, with the broad outer face on the bed and semicircular groove facing upward. Both parts are designed for these orientations without support; use the same material and layer settings as the enclosure. Attach the saddle to the carrier grid with four M3 screws. Fit the cap with two M3 screws and the matching inserts installed in the saddle. Do not use this as the final cable strain relief until a pull test on the actual boot and wire has confirmed the cable cannot slide or load its electrical termination.

Render and inspect both parts at candidate cable diameters 6, 8, 10, and 12 mm:

```sh
for d in 6 8 10 12; do
  openscad -o "/tmp/motor-cable-saddle-${d}mm.stl" \
    -D "cable_od=${d}" -D 'show_part="saddle"' \
    plastic_case/tests/motor_cable_clamp.scad
  openscad -o "/tmp/motor-cable-cap-${d}mm.stl" \
    -D "cable_od=${d}" -D 'show_part="cap"' \
    plastic_case/tests/motor_cable_clamp.scad
done
```

Check the measured boot at its corrugation peaks and valleys. Adjust `cable_od`, `cable_interference`, `radial_channel_extra`, insert dimensions, and `clamp_length` in the Customizer or command line; start with zero interference, then test small increments. Verify that the clamp bolts close the cap, that the cable is retained without cutting its jacket, and that the installed saddle clears the carrier, boards, lid and cable bend. These STL calibration sizes are not the enclosure's final end-wall opening or cable-exit coordinates.

For reusable mounts, use M3 inserts in the case/lid towers, a removable internal carrier, the encoder cradle, and the adjustable two-piece cable clamp. The carrier grid accepts small zip ties or screws at 10 mm pitch, so the existing ESP32, perfboard and supply can be secured without bonding; board-specific rails/clips and a supply cradle are still future refinements pending exact outlines. Keep insert bosses out of thin enclosure walls and away from connector and lid paths.

## Reproduction

Run from the repository root. For example:

```sh
openscad -o /tmp/m3-insert-coupon.stl \
  -D 'test_set="m3_insert"' plastic_case/tests/fit_test_coupons.scad
openscad -o /tmp/oled-coupon.stl \
  -D 'test_set="oled"' plastic_case/tests/fit_test_coupons.scad
openscad -o /tmp/encoder-coupon.stl \
  -D 'test_set="encoder"' plastic_case/tests/fit_test_coupons.scad
```

Import the STL into Bambu Studio or Cura. Print coupons in the same material, nozzle, layer height, orientation, and wall count intended for the enclosure. Install an insert with the same soldering-iron tip and temperature planned for the final parts. Choose the smallest bore that accepts the insert straight without splitting the boss, and the smallest boss that survives installation without cracking. Record the winning settings in the Customizer parameters before updating the main case model.

For board supports, first select the closest `board_outline_target` and ESP32 variant, then lower the actual PCB into the selected frame. Inspect solder/lead clearance on the underside, connect and disconnect the actual Dupont housings, then close the connector-clearance gauge around the assembled plug.

The existing `GET http://192.168.1.6/info` page was queried on 2026-10-25. It reports an `esp32`, chip revision 1, 4 MB flash, 0 PSRAM, and 240 MHz CPU, plus firmware/build and network information. It has no development-board model or PCB dimensions. `firmware/build.sh` uses the generic `esp32:esp32:esp32` FQBN, which also does not identify the board layout. We reused `/info`; no firmware endpoint or firmware change was needed. The board-outline profiles therefore remain fit candidates until the actual PCB can be measured or matched visually. For the OLED, press at the center and corners: the PCB perimeter should bottom on the shoulder, while the front mask must not press on the active glass.
