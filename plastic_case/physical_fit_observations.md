# Physical enclosure observations from supplied photos

Source archive: `Hafele Standing Desk-1-001.zip` (five photos). These notes describe only visible evidence; dimensions and exact component part numbers require measurement or readable markings.

## Photo-by-photo evidence

| Photo | Visible evidence |
|---|---|
| `IMG_20221014_091943.jpg` | Front of the installed enclosure. A small rectangular OLED module sits left of a threaded metal panel pushbutton with a hex nut. A large rotary knob sits at the right; its mounting is hidden by the knob and a dark irregular patch/recess. The front has visible print texture, seams, and local surface irregularity. |
| `IMG_20221014_091958.jpg` | Same front controls at closer range while the display is active. Confirms the OLED's approximate visible orientation and the control spacing. It does not reveal the display controller or exact module size. |
| `IMG_20220704_121306.jpg` | Loose display module with four corner mounting holes and a four-wire header marked `GND VCC SCL SDA`; this is consistent with an I2C OLED module. A separate rotary encoder is shown with a bare splined shaft and no obvious threaded panel bushing in this view. The photo does not establish the exact encoder SKU. |
| `IMG_20240808_185650.jpg` | Enclosure open. The ESP32 development board, relay hardware on a perforated prototyping board, a separate power-supply module, and substantial loose wiring are visible. A large rough opening/cutout is visible in the inner wall behind the wiring. The boards do not appear to have a clear, serviceable printed carrier in this view; the photo is not sharp enough to identify every board or its fasteners. |
| `WhatsApp Image 2026-10-25 at 12.12.00.jpeg` | Exterior underside/rear view. A thick outgoing cable with a corrugated boot enters through a hand-cut opening near an enclosure end. Two red-centered controls or indicators are fitted through rough individual openings; their function and exact type are not identifiable from the photo. The cable opening does not show a standard bulkhead gland or a printed clamp. The lower seam/edge is uneven in this angle. |

## Confirmed design requirements

1. **Display support:** model a pocket/ledge behind the front aperture so pressing the display cannot push the module into the case. The loose-board photo shows four corner holes; a removable retaining frame or screw posts aligned to the measured hole spacing can avoid adhesive. Keep clearance for the I2C header and cable bend.
2. **Pushbutton:** preserve a front opening for the threaded metal body and its nut. The photo supports the use of a panel-mount threaded button. Exact barrel, nut, shoulder and rear-body dimensions are unknown. A printed cap/actuator could be designed after measuring stroke, button diameter and clearance behind the panel.
3. **Encoder:** design support around the encoder body/PCB and anti-rotation features; do not rely on the shaft to clamp it. The external knob hides the current mount. A split cradle plus a front bezel/retainer is a plausible serviceable approach, subject to the encoder body measurements and desired rotation torque.
4. **Cable exit:** add a deliberate opening for the motor cable and its corrugated boot. Measure the boot's largest diameter, cable diameter, and the direction the cable must leave. A shaped saddle and removable clamp can provide strain relief without hot-cutting the printed wall.
5. **Additional red-centered controls/indicators:** the rear/underside photo shows two red-centered parts in rough openings. Their function, type and dimensions are unknown. Identify them and measure their body and retaining features before adding keyed panel openings.
6. **Internal electronics:** reserve separate mounting zones for the ESP32, relay/perforated board, and power supply. Add board standoffs or rails and wire-routing paths so the lid can be removed without pulling on wiring. Use the existing component arrangement only as a rough packing reference; the photo does not establish board outlines, mounting holes, or safe clearances.
7. **Lower edge:** the new photo shows an uneven lower perimeter/seam in perspective. It is not enough to distinguish the user's complained-of CAD step from the real case's rounded edge. Confirm the intended curve/straight slope from a square-on side photo or measurements before changing the source profile again.

## Still unknown

- OLED controller and exact board SKU; the four-wire header and visible screen alone cannot distinguish SSD1306 from compatible modules.
- Display PCB outside dimensions, hole pitch, glass/window dimensions, and connector clearance.
- Pushbutton SKU, thread diameter/pitch, body depth, actuation stroke and rear terminal envelope.
- Encoder body dimensions, PCB/shaft geometry, desired knob fit, and exact means of retention in the present case.
- Exact model and dimensions of the two red-centered parts, the supply, ESP32 board and relay/perforated board.
- Cable boot diameter and retention geometry; whether the lower opening is also used for other wiring.
- Precise underside/lower-edge profile, because the available exterior angles are oblique.

## Measurements to capture before adding component pockets

Use calipers where possible and record millimetres: display PCB width/height and all four hole-center coordinates; display glass opening; pushbutton thread OD, body length and nut OD; encoder body width/height/depth and shaft diameter; each PCB outline, mounting-hole locations and component heights; rocker cutout dimensions; cable/boot diameters; and the desired lower-edge profile. A ruler in a square-on photo can serve as a fallback for inaccessible dimensions.
