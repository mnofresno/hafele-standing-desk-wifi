# OLED mechanical reference and measured envelope

Research date: 2026-10-26. Manufacturer/module-supplier references below are
comparisons, **not identification of the installed module**. The controller name
SSD1306 and a four-pin header do not identify a PCB outline or its glass offset.

## User measurements and fixed design requirement

| Item | Value | Evidence / consequence |
|---|---:|---|
| Installed PCB width × height | 27.5 × 28 mm | User measurement; use for the pocket before adding configurable print clearance. |
| Module depth | 3.5 mm | User measurement; keep separate from connector clearance. |
| Enclosure window width × height | **27 × 14.5 mm** | User explicitly requires this opening because the existing enclosure window works. Do not resize it to a catalog active area. |
| Bottom PCB edge to visible-region bottom | About 9 mm | User measurement; exact region/edge definition requires confirmation. |
| Top PCB edge to visible-region top | About 7 mm | Approximate user measurement; use with the same edge definition as the bottom. |
| Dupont extension | 15 mm rearward, normal to the PCB | User clarified the direction. Reserve this projection behind the module separately from its 3.5 mm body; housing width and wire bend still require their own keep-out. |

## Reference module families

The dimensions fit common 0.96-inch boards much better than the earlier
35.4 × 33.5 mm 1.3-inch candidate. This narrows the mechanical family without
establishing a part number.

| Primary reference | Published outline | Optical dimensions / relevant limit |
|---|---|---|
| [Raystar REA012864D-03](https://www.raystar-optronics.com/spa/oled-graphic-display-module/i2c-oled.html) | Module 27.3 × 27.3 × 2.37 mm | Viewing area 23.94 × 12.06; active pixels 21.74 × 10.86 mm; SSD1306, I2C. |
| [LCDwiki MC096VX module documentation](https://www.lcdwiki.com/0.96inch_OLED_Module_MC096VX) | PCB 27.3 × 27.8 mm | Effective display area 21.744 × 10.864 mm; four-pin I2C. |
| [FriendlyElec product 1709](https://www.friendlyelec.com/index.php?product_id=217&route=product/product) | PCB 27.3 × 27.3 mm | 128 × 64, four-pin 2.54 mm interface. No exact glass offset established from this page. |
| [Joy-IT SBC-OLED01V2](https://joy-it.net/en/products/SBC-OLED01V2) | Product 27 × 28 × 11 mm | SSD1306, 128 × 64. The published full-product depth must not replace the user's measured 3.5 mm module depth. |

The [Raystar manufacturer drawing, PDF page 4](https://www.raystar-optronics.com/upload_files/oled-display/128x64-oled-graphic-display/REA012864D-03-datasheet.pdf)
separately shows a 26.7 × 19.26 mm glass outline, larger than its viewing and
active regions. Its drawing places glass 4.02 mm below the PCB top, viewing area
another 1.84 mm below glass top, and active pixels 2.44 mm below glass top. For
that reference orientation, calculated viewing margins are 5.86 mm at the PCB
top and 9.38 mm at the bottom; viewing-center offset is 1.76 mm toward the top.
Those offsets belong to that drawing, not to the user's unidentified board.

The [LCDwiki dimension drawing](https://www.lcdwiki.com/images/1/19/MC096-015.jpg)
distinguishes PCB 27.3 × 27.8 mm, panel/glass 26.7 × 19.27 mm, and active area
21.74 × 10.86 mm. Its PCB-to-glass top spacing is 4.27 mm and glass-to-active top
spacing 2.10 mm. That implies active-area top/bottom PCB margins of 6.37/10.57 mm
for this reference layout. These different definitions must not be mixed with
the user's approximate “visible” margins.

## Alignment calculation and remaining uncertainty

If both user margins refer to the same visible rectangle, its height is
`28 - 9 - 7 = 12 mm`. Its center is `9 + 12/2 = 15 mm` above the PCB bottom,
whereas PCB center is 14 mm above the bottom: the visible center is **1 mm
toward the PCB top**. Thus a PCB centered **1 mm below the window center** would
center that region in the fixed opening. In the model's panel coordinates this
corresponds to a PCB/pocket offset of `-1 mm` along the positive-up axis, provided
the measured orientation is confirmed. This is a calculation from approximate
measurements, not a catalog-derived exact offset.

A 12 mm reported visible height is consistent with a viewing region near
12.06 mm; it is not the 10.86 mm pixel-active height listed for the two reference
panels. A 27 × 14.5 mm enclosure cutout can be larger than either optical region.
Preserve that cutout and treat PCB position, optical alignment, glass outline,
and connector envelope as independent dimensions.

The user subsequently confirmed that the 15 mm Dupont extension points
rearward, normal to the OLED PCB. Model that projection explicitly behind the
3.5 mm module body. The installed header-row position, housing width, removal
space and initial wire bend remain independent dimensions; do not infer them
from the nominal display diagonal or controller.
