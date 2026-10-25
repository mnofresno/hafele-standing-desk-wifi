# Physical enclosure observations from supplied photos

Source archive: `Hafele Standing Desk-1-001.zip` (five photos). These notes describe only visible evidence; dimensions and exact component part numbers require measurement or readable markings.

## Photo-by-photo evidence

| Photo | Visible evidence |
|---|---|
| `IMG_20221014_091943.jpg` | Front of the installed enclosure. A small rectangular OLED module sits left of a threaded metal panel pushbutton with a hex nut. A large rotary knob sits at the right; its mounting is hidden by the knob and a dark irregular patch/recess. The front has visible print texture, seams, and local surface irregularity. |
| `IMG_20221014_091958.jpg` | Same front controls at closer range while the display is active. Confirms the OLED's approximate visible orientation and the control spacing. It does not reveal the display controller or exact module size. |
| `IMG_20220704_121306.jpg` | Loose display module with four corner mounting holes and a four-wire header marked `GND VCC SCL SDA`; this is consistent with an I2C OLED module. The holes are not the intended retention method: capture the PCB perimeter in a pocket. A separate rotary encoder is shown with a bare splined shaft and no obvious threaded panel bushing in this view. The photo does not establish the exact encoder SKU. |
| `IMG_20240808_185650.jpg` | Enclosure open. The ESP32 development board, relay hardware on a perforated prototyping board, a separate power-supply module, and substantial loose wiring are visible. A large rough opening/cutout is visible in the inner wall behind the wiring. The boards do not appear to have a clear, serviceable printed carrier in this view; the photo is not sharp enough to identify every board or its fasteners. |
| `WhatsApp Image 2026-10-25 at 12.12.00.jpeg` | Exterior underside/rear view. A thick outgoing cable with a corrugated boot enters through a hand-cut opening near an enclosure end. Two red-centered controls or indicators are fitted through rough individual openings; their function and exact type are not identifiable from the photo. The cable opening does not show a standard bulkhead gland or a printed clamp. The lower seam/edge is uneven in this angle. |

## Confirmed design requirements

1. **Display support:** treat `ancho_display` × `alto_display` (26.64 × 14.46 mm) as the front viewing window, which intentionally masks the non-display border. Recess the larger module behind it and support the PCB perimeter with a pocket shoulder plus compliant retaining lips. Do not load the OLED glass or depend on the four PCB mounting holes. Leave an open keep-out behind the I2C header for the Dupont housing, unplugging, and wire bend.
2. **Pushbutton:** preserve a front opening for the threaded metal body and its nut. The photo supports the use of a panel-mount threaded button. Exact barrel, nut, shoulder and rear-body dimensions are unknown. A printed cap/actuator could be designed after measuring stroke, button diameter and clearance behind the panel.
3. **Encoder:** design support around the encoder body/PCB and anti-rotation features; do not rely on the shaft to clamp it. The external knob hides the current mount. A split cradle plus a front bezel/retainer is a plausible serviceable approach, subject to the encoder body measurements and desired rotation torque.
4. **Cable exit:** add a deliberate opening for the motor cable and its corrugated boot. Measure the boot's largest diameter, cable diameter, and the direction the cable must leave. A shaped saddle and removable clamp can provide strain relief without hot-cutting the printed wall.
5. **Additional red-centered controls/indicators:** the rear/underside photo shows two red-centered parts in rough openings. Their function, type and dimensions are unknown. Identify them and measure their body and retaining features before adding keyed panel openings.
6. **Internal electronics:** reserve separate mounting zones for the ESP32, relay/perforated board, and power supply. Add board standoffs or rails and wire-routing paths so the lid can be removed without pulling on wiring. Use the existing component arrangement only as a rough packing reference; the photo does not establish board outlines, mounting holes, or safe clearances.
7. **Lower edge:** the new photo shows an uneven lower perimeter/seam in perspective. It is not enough to distinguish the user's complained-of CAD step from the real case's rounded edge. Confirm the intended curve/straight slope from a square-on side photo or measurements before changing the source profile again.

## Display and encoder dimensional research

The source repository identifies a 128×64 I2C OLED using the SSD1306 library and records a visible window of about 26.7 × 14.7 mm. The FreeCAD opening is 26.64 × 14.46 mm. This is the **window**, not the outer PCB size; the PCB and its inactive border sit behind the case face. The loose photo's nearly square four-hole board and 4-pin header are consistent with a common 1.3-inch breakout, but the generic photos do not uniquely identify the vendor/module.

Useful published envelopes:

| Candidate | Board/module envelope | Active display area | Mechanical implication |
|---|---:|---:|---|
| Common 1.3-inch OLED breakout | about 35.4 × 33.5 mm PCB; panel/module drawings vary | 29.42 × 14.70 mm | Best first-fit candidate for the source's 14.7 mm window height and square-board photo. Model the pocket by board outline; retain the user's smaller front mask to hide the inactive border. |
| Common 0.96-inch I2C OLED breakout | 27.3 × 27.3 mm PCB; about 2.37 mm module thickness before header | 21.74 × 10.86 mm | Smaller alternate. Does not match the source's stated 26.7 × 14.7 mm visible region, so should not be the default pocket assumption. |

Sources: [SparkFun 1.3-inch OLED hardware overview](https://docs.sparkfun.com/SparkFun_Qwiic_OLED_1.3in/hardware_overview/) specifies 128×64 and 29.42 × 14.7 mm active area; a common 1.3-inch PCB drawing lists 35.4 × 33.5 mm. [Raystar's 0.96-inch SSD1306 module](https://www.raystar-optronics.com/jap/oled-graphic-display-module/i2c-oled.html) specifies 27.3 × 27.3 × 2.37 mm module dimensions, 23.94 × 12.06 mm viewing area, and 21.74 × 10.86 mm active area. [FriendlyElec's 0.96-inch I2C module](https://www.friendlyelec.com/index.php?product_id=217&route=product/product) independently lists 27.3 × 27.3 mm PCB dimensions.

The photographed encoder is consistent with the standard EC11-family 11 mm incremental encoder form factor. Alps Alpine's [EC11E product catalog drawing](https://tech.alpsalpine.com/assets/catalog/product-catalog-ec-all.en.pdf) gives a body near 12.5 × 11.7 mm, a nominal 6 mm shaft (with product-specific tolerance/shaft options), and PCB terminal details. This is a useful parametric starting envelope, not an exact part-number identification. The model should leave body width/depth, shaft diameter/length, terminal/solder height, and side clearance independently adjustable. The encoder is to be captured by its body in an anti-rotation cradle; the printed knob and front bezel must not pull on the solder pins.

## Connector and board collision rules for the next CAD revision

- Add a board-envelope parameter for each PCB, plus X/Y placement and orientation. Put boards on discrete standoffs or side rails in a removable carrier so the three-board assembly can be installed and serviced together.
- Reserve a board-to-shell keep-out; size the gap from the tallest underside solder joint, trimmed lead, or component. Support perforated board at insulated stand-offs and avoid a continuous conductive-looking shelf under exposed solder pads.
- Treat each header as a three-dimensional connector volume, not a point: include the female Dupont housing height/width, enough straight length to remove the plug, and a bend lane for the wires. Route a service loop/channel along the wall and keep it clear of the lid seam and fasteners.
- Give the ESP32 USB connector an unobstructed plug insertion/removal corridor and an opening that includes the actual plug overmold. The connector must remain reachable after the internal carrier is installed.
- Use a separate clamping feature or removable strap for the motor cable boot, with adjustable opening and rounded edges. It should transfer cable pull to the enclosure wall rather than the soldered terminals.
- Keep mains switching/power hardware in a physically distinct zone from ESP32/display signal wiring; add a printed divider and wire channels only after the actual supply, relay-board, and cable dimensions are entered. Leave lid screw towers and lid closure paths as explicit keep-outs.
- Expose print-fit clearances as parameters. Initial rigid PCB pocket clearance should be small and configurable; flexible capture lips should absorb printer and vendor variation without squeezing the glass or relying on friction alone.

## Still unknown

- OLED controller and exact board SKU; the four-wire header and visible screen alone cannot distinguish SSD1306 from compatible modules.
- Exact display module PCB envelope and header direction; 1.3-inch is the best-fit candidate, not a verified SKU. The pocket must therefore expose adjustable PCB width/depth and connector keep-out parameters.
- Pushbutton SKU, thread diameter/pitch, body depth, actuation stroke and rear terminal envelope.
- Encoder body dimensions, PCB/shaft geometry, desired knob fit, and exact means of retention in the present case.
- Exact model and dimensions of the two red-centered parts, the supply, ESP32 board and relay/perforated board.
- Cable boot diameter and retention geometry; whether the lower opening is also used for other wiring.
- Precise underside/lower-edge profile, because the available exterior angles are oblique.

## Measurements to capture before adding component pockets

Use calipers where possible and record millimetres: display PCB width/height and all four hole-center coordinates; display glass opening; pushbutton thread OD, body length and nut OD; encoder body width/height/depth and shaft diameter; each PCB outline, mounting-hole locations and component heights; rocker cutout dimensions; cable/boot diameters; and the desired lower-edge profile. A ruler in a square-on photo can serve as a fallback for inaccessible dimensions.
