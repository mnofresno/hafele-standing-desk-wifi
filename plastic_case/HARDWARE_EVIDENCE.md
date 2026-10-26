# Hardware and photo evidence

This note records what the supplied photos and firmware establish, what remains
uncertain, and how the current CAD treats each interface. The photos are
`~/Downloads/Hafele Standing Desk-1-001.zip`; they have no scale and the board
silkscreen/part numbers are not legible. Dimensions marked as candidates must be
checked with the corresponding fit coupon before the full enclosure is printed.

New interior photos supplied on 2026-10-26 supersede several exterior-photo
assumptions below. See `COMMON_BRACKET_DESIGN.md` for their observations and the
requested measurements. The encoder must be retained by its full body/PCB,
according to the user's report that it cannot be fixed with a shaft nut. The
new revision replaces the metal cancel switch with a 12×12 tactile switch and
printed actuator; the currently exported enclosure still uses the older design.
The long rear-wall USB/cable placement and shaped boot are now visible. Their
existing end-face candidate positions are not measured locations.

| Part/interface | Evidence | Identification confidence | CAD decision |
|---|---|---|---|
| OLED | Firmware configures a 128×64 SSD1306 display. The photo shows a square 4-pin I²C module, with a PCB larger than the visible screen. | Display protocol/resolution are supported by firmware; exact physical module and PCB outline are not established. The board may use another compatible controller. | Preserve the FreeCAD active window (26.64 × 14.46 mm). Use an adjustable rear pocket, header notch and retainer; the 35.4 × 33.5 mm envelope is a fit candidate only. |
| Rotary encoder | User reports no usable shaft-nut retention; interior photos show a board/header envelope that must be captured. Firmware uses `ESP32Encoder`. | Encoder family and exact PCB variant are unconfirmed. EC11 is a plausible mechanism family, not a complete module envelope. | Capture the full body/PCB using the combined bracket; keep shaft, solder and connected-header clearance adjustable. |
| Pushbutton | Photo shows a metal panel button, hex nut and black actuator. | Thread, head diameter and travel are unknown. | Keep the nut as the primary panel retention. The printed cap remains optional and adjustable; it must not limit the button travel. |
| ESP32 board | Repository calls it “Wemos D1 ESP32”; `/info` reports ESP32 SoC properties. The serial bridge was identified as CP2102. | Development PCB is not identified. A D1 R32 drawing lists CH340G, so the CP2102 observation does not support choosing that board outline. | Use the perforated carrier grid and adjustable board profiles. Do not treat a D1 R32, DevKitC or D1-mini outline as confirmed. |
| Relay/perforated board | Interior photo shows blue relays on a perforated board and long Dupont wires. | Board dimensions, relay type, solder-tail height and connector positions are unknown. | Use the removable carrier's 10 mm grid for M3 screws or small cable ties. Preserve adjustable solder and Dupont clearance; no board-specific cradle is claimed. |
| 5 V supply | Interior photo shows a separate switching supply board. | Exact model, dimensions, terminal side, isolation details and heat output are unknown. | Mount on the carrier with adjustable tie-downs after measuring. Keep terminal and ventilation zones clear; do not assume the placeholder outline is exact. |
| USB access | Photo shows a hand-cut USB access opening and a cable inserted. | Connector type, overmold and exact wall location are not established. | Keep port end, position, width and height configurable. Print the USB coupon with the actual cable. |
| Motor cable | Exterior photo shows a corrugated boot through a hand-cut opening. | Boot OD, corrugation peak/valley dimensions and exact location are unmeasured. | Keep the case opening configurable. Add a separate adjustable two-piece saddle/cap clamp that mounts to the carrier grid; calibrate OD and compression on the real boot. |
| Rear red apertures | Two small red windows are visible next to the motor-cable exit in the supplied rear photo. They appear to show internal red indicators. | Their purpose is a visual inference; spacing and dimensions cannot be scaled from the photo. | Provide an enabled-by-default adjustable pair of windows on the selected end face; tune the end, center, spacing and opening size against the real LEDs. |
| M3 brass inserts | User confirmed the enclosure uses M3 heat-set inserts. | Thread size is known; insert OD and length depend on the actual insert batch. | Use blind insert seats and reinforced bosses, with pilot/boss dimensions controlled by parameters. Choose values with the insert coupon before final printing. |

The official [SSD1306 controller page](https://www.solomon-systech.com/product/ssd1306/),
[ALPS EC11E data](https://tech.alpsalpine.com/e/products/detail/EC11E15244G1/),
[Espressif DevKitC V4 drawing](https://dl.espressif.com/dl/schematics/esp32_devkitc_v4_dimensions.pdf),
and [D1 R32 drawing](https://handsontec.com/dataspecs/module/ESP/WeMos%20D1%20R32.pdf)
describe plausible component families, but none uniquely identifies the installed
PCB or panel parts. Catalog dimensions are starting envelopes only.

## What the photos do not resolve

The exact OLED board outline/header height, encoder body and terminal envelope,
button thread/head/travel, ESP32 board revision, relay board and supply outlines,
Dupont routing, solder protrusion, USB type, cable boot diameter and opening
coordinates remain unverified. A ruler photo of the open box and the three loose
boards beside a ruler would turn the candidate carrier into board-specific
supports. The current grid and cable tie strategy avoids bonding the boards to
the case while those values are being measured.
