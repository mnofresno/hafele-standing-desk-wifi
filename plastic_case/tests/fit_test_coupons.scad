/* Häfele enclosure fit-test coupons.
 * Print one test_set at a time. Dimensions are millimetres.
 * Clearances are per side unless a label says otherwise.
 */

/* [Test set] */
test_set = "m3_insert"; // [all,oled,encoder,button,usb,motor_cable,dupont,m3_insert,m3_screw,board_edge,board_outline]
$fn = 64;

/* [Shared fit increments] */
fit_first_clearance = 0.0; // [0:0.05:0.8]
fit_clearance_step = 0.2; // [0.05:0.05:0.5]
fit_sample_count = 4; // [2:1:7]
coupon_spacing = 3; // [1:1:8]
coupon_wall = 2.0; // [1:0.2:4]
panel_thickness = 2.0; // [1.2:0.2:4]

/* [OLED module] */
oled_board_format = "1.3 inch candidate"; // [1.3 inch candidate,0.96 inch alternative]
oled_pcb_width_override = 0; // [0:0.1:60]
oled_pcb_height_override = 0; // [0:0.1:60]
oled_pcb_width_default = oled_board_format == "1.3 inch candidate" ? 35.4 : 27.3;
oled_pcb_height_default = oled_board_format == "1.3 inch candidate" ? 33.5 : 27.3;
oled_window_width = 26.64;
oled_window_height = 14.46;
oled_module_thickness = 2.6; // Excludes soldered header and Dupont plug.
oled_header_keepout_width = 14;
oled_header_keepout_length = 14;
oled_pocket_depth = 12; // Leaves a test volume for header/connector access.

/* [Rotary encoder] */
encoder_body_x = 12.5; // EC11-family nominal envelope.
encoder_body_y = 11.7;
encoder_body_depth = 7.5;
encoder_terminal_keepout = 3;
encoder_shaft_diameter = 6;
encoder_shaft_hole = 6.8;
encoder_knob_bore_first = 5.6;
encoder_knob_bore_step = 0.2;
encoder_terminal_notch_width = 8;

/* [Panel pushbutton] */
pushbutton_thread_nominal = 8; // Existing FreeCAD opening is 8.68 mm.
pushbutton_hole_first = 8.2;
pushbutton_hole_step = 0.2;
pushbutton_hole_count = 6;
pushbutton_nut_across_flats = 14;
pushbutton_nut_recess_depth = 0.8;
pushbutton_cap_head_diameter = 8;
pushbutton_cap_clearance_first = 0.0;
pushbutton_cap_clearance_step = 0.2;

/* [USB and motor cable] */
usb_plug_width = 12;
usb_plug_height = 8;
motor_boot_diameter = 12;

/* [Dupont connector] */
dupont_pitch = 2.54;
dupont_pin_count = 4;
dupont_housing_depth = 8;
dupont_wire_bend_keepout = 12;
dupont_keepout_first = 8;
dupont_keepout_step = 2;

/* [M3 brass heat-set insert] */
m3_insert_length = 5.7; // Standard-length reference; short M3 inserts need a separate setting.
m3_insert_bore_first = 3.8; // Print-hole trial series; not an insert-body standard.
m3_insert_bore_step = 0.1;
m3_insert_bore_count = 5;
m3_insert_boss_diameter = 7.0; // Existing screw-tower outside diameter.
m3_insert_boss_diameter_min = 6.5; // Generic reference; the chosen insert maker may differ.
m3_insert_bottom = 1.0;
m3_insert_chamfer = 0.4;
m3_screw_hole_first = 3.0;
m3_screw_hole_step = 0.1;
m3_screw_hole_count = 5;
m3_screw_head_diameter = 6.0;
m3_screw_head_depth = 2.2;

/* [PCB edge support] */
board_outline_target = "esp32"; // [esp32,relay_perforated,power_supply]
esp32_board_variant = "DevKitC V4 48.26x27.94"; // [DevKitC V4 48.26x27.94,D1 mini-compatible 34.2x25.6,D1 R32 68x53]
esp32_board_width_override = 0; // [0:0.1:100]
esp32_board_length_override = 0; // [0:0.1:120]
relay_board_width = 70;
relay_board_length = 50;
power_board_width = 45;
power_board_length = 25;
board_connector_edge = "short"; // [short,long,none]
board_connector_opening = 16;
board_outline_height = 5;
board_outline_sample_count = 4;
board_edge_thickness = 1.6;
board_edge_clearance_first = 0.0;
board_edge_clearance_step = 0.2;
board_edge_clearance_count = 4;
board_solder_standoff_first = 2.0;
board_solder_standoff_step = 1.0;
board_solder_standoff_count = 6;

function fit_clearance(i) = fit_first_clearance + i*fit_clearance_step;
function oled_pcb_w() = oled_pcb_width_override > 0 ? oled_pcb_width_override : oled_pcb_width_default;
function oled_pcb_h() = oled_pcb_height_override > 0 ? oled_pcb_height_override : oled_pcb_height_default;
function hex_corner_d(flat_to_flat) = flat_to_flat/cos(30);
function selected_board_w() = board_outline_target == "esp32" ?
    (esp32_board_width_override > 0 ? esp32_board_width_override :
     esp32_board_variant == "DevKitC V4 48.26x27.94" ? 48.26 :
     esp32_board_variant == "D1 mini-compatible 34.2x25.6" ? 34.2 : 68) :
    board_outline_target == "relay_perforated" ? relay_board_width : power_board_width;
function selected_board_l() = board_outline_target == "esp32" ?
    (esp32_board_length_override > 0 ? esp32_board_length_override :
     esp32_board_variant == "DevKitC V4 48.26x27.94" ? 27.94 :
     esp32_board_variant == "D1 mini-compatible 34.2x25.6" ? 25.6 : 53) :
    board_outline_target == "relay_perforated" ? relay_board_length : power_board_length;

module label3d(value, size=2.4, height=0.35) {
    linear_extrude(height=height)
        text(str(value), size=size, halign="center", valign="center");
}

module oled_coupon(clearance, index) {
    board_w = oled_pcb_w();
    board_h = oled_pcb_h();
    plate_w = board_w + 8;
    plate_h = board_h + 8;
    pocket_w = board_w + 2*clearance;
    pocket_h = board_h + 2*clearance;
    frame_outer_w = pocket_w + 2*coupon_wall;
    frame_outer_h = pocket_h + 2*coupon_wall;
    frame_x = (plate_w-frame_outer_w)/2;
    frame_y = (plate_h-frame_outer_h)/2;
    window_x = (plate_w-oled_window_width)/2;
    window_y = (plate_h-oled_window_height)/2;
    header_w = min(oled_header_keepout_width, pocket_w);

    difference() {
        union() {
            cube([plate_w,plate_h,panel_thickness]);
            translate([frame_x,frame_y,panel_thickness])
                difference() {
                    cube([frame_outer_w,frame_outer_h,oled_pocket_depth]);
                    translate([coupon_wall,coupon_wall,-0.05])
                        cube([pocket_w,pocket_h,oled_pocket_depth+0.1]);
                }
            translate([plate_w/2,2,panel_thickness])
                label3d(str("C+",clearance),2.1,0.35);
        }
        // Front mask opening: intentionally smaller than the module PCB.
        translate([window_x,window_y,-0.1])
            cube([oled_window_width,oled_window_height,panel_thickness+0.2]);
        // Open the connector edge so the real 4-pin plug and wire can leave the pocket.
        translate([plate_w/2-header_w/2,frame_y+frame_outer_h-coupon_wall,
                   panel_thickness-0.1])
            cube([header_w,coupon_wall+oled_header_keepout_length,oled_pocket_depth+0.2]);
    }
}

module encoder_coupon(clearance, index) {
    plate_w = encoder_body_x + 14;
    plate_h = encoder_body_y + 14;
    pocket_w = encoder_body_x + 2*clearance;
    pocket_h = encoder_body_y + 2*clearance;
    frame_w = pocket_w + 2*coupon_wall;
    frame_h = pocket_h + 2*coupon_wall;
    frame_depth = encoder_body_depth + encoder_terminal_keepout;
    frame_x = (plate_w-frame_w)/2;
    frame_y = (plate_h-frame_h)/2;
    difference() {
        union() {
            cube([plate_w,plate_h,panel_thickness]);
            translate([frame_x,frame_y,panel_thickness])
                difference() {
                    cube([frame_w,frame_h,frame_depth]);
                    translate([coupon_wall,coupon_wall,-0.05])
                        cube([pocket_w,pocket_h,frame_depth+0.1]);
                }
            translate([plate_w/2,2,panel_thickness])
                label3d(str("C+",clearance),2.1,0.35);
        }
        translate([plate_w/2,plate_h/2,-0.1])
            cylinder(d=encoder_shaft_hole,h=panel_thickness+0.2);
        // Slot for the encoder's terminal row and attached wires.
        translate([plate_w/2-encoder_terminal_notch_width/2,frame_y-0.1,
                   panel_thickness+frame_depth-encoder_terminal_keepout])
            cube([encoder_terminal_notch_width,coupon_wall+2,encoder_terminal_keepout+0.2]);
    }
}

module encoder_shaft_gauge(index) {
    bore = encoder_knob_bore_first+index*encoder_knob_bore_step;
    difference() {
        union() {
            cylinder(d=12,h=8);
            translate([0,-9,0.3]) label3d(str("D",bore),2.0,0.35);
        }
        translate([0,0,-0.1]) cylinder(d=bore,h=8.2);
    }
}

module button_hole_coupon(index) {
    hole_d = pushbutton_hole_first+index*pushbutton_hole_step;
    tile = 25;
    difference() {
        union() {
            cube([tile,tile,panel_thickness]);
            translate([tile/2,2,panel_thickness])
                label3d(str("D",hole_d),2.2,0.35);
        }
        translate([tile/2,tile/2,-0.1])
            cylinder(d=hole_d,h=panel_thickness+0.2);
        // Hex relief for a panel-button nut on the rear face.
        translate([tile/2,tile/2,panel_thickness-pushbutton_nut_recess_depth])
            cylinder(d=hex_corner_d(pushbutton_nut_across_flats),
                     h=pushbutton_nut_recess_depth+0.1,$fn=6);
    }
}

module button_cap_gauge(index) {
    clearance = pushbutton_cap_clearance_first+index*pushbutton_cap_clearance_step;
    cap_outer = pushbutton_cap_head_diameter+4;
    difference() {
        union() {
            cylinder(d=cap_outer,h=6);
            translate([0,-8,0.3]) label3d(str("C+",clearance),1.9,0.35);
        }
        translate([0,0,1.0])
            cylinder(d=pushbutton_cap_head_diameter+2*clearance,h=5.2);
    }
}

module rounded_slot_2d(width,height,radius) {
    offset(r=radius)
        square([max(0.1,width-2*radius),max(0.1,height-2*radius)],center=true);
}

module usb_coupon(index) {
    clearance = fit_clearance(index);
    tile_w = usb_plug_width+12;
    tile_h = usb_plug_height+12;
    opening_w = usb_plug_width+2*clearance;
    opening_h = usb_plug_height+2*clearance;
    difference() {
        union() {
            cube([tile_w,tile_h,panel_thickness]);
            translate([tile_w/2,2,panel_thickness])
                label3d(str("C+",clearance),2.1,0.35);
        }
        translate([tile_w/2,tile_h/2,-0.1])
            linear_extrude(height=panel_thickness+0.2)
                rounded_slot_2d(opening_w,opening_h,1.2);
    }
}

module motor_cable_coupon(index) {
    clearance = fit_clearance(index);
    tile = motor_boot_diameter+10;
    hole_d = motor_boot_diameter+2*clearance;
    difference() {
        union() {
            cube([tile,tile,panel_thickness]);
            translate([tile/2,2,panel_thickness])
                label3d(str("D",hole_d),2.1,0.35);
        }
        translate([tile/2,tile/2,-0.1])
            cylinder(d=hole_d,h=panel_thickness+0.2);
    }
}

module dupont_depth_coupon(index) {
    headroom = dupont_keepout_first+index*dupont_keepout_step;
    width = dupont_pin_count*dupont_pitch+8;
    length = dupont_housing_depth+dupont_wire_bend_keepout;
    wall = coupon_wall;
    frame_width = dupont_pin_count*dupont_pitch+4;
    frame_length = dupont_housing_depth+dupont_wire_bend_keepout;
    pin_d = 1.2;
    union() {
        // Header pin gauge: mate the real female Dupont housing to these pins.
        cube([width,length,panel_thickness]);
        for (i=[0:dupont_pin_count-1])
            translate([width/2+(i-(dupont_pin_count-1)/2)*dupont_pitch,
                       6,panel_thickness]) cylinder(d=pin_d,h=8);
        translate([width/2,length-3,panel_thickness])
            label3d(str("Z",headroom),2.0,0.35);

        // Separate bottom-open headroom gauge. Lower it over the connected plug
        // to check side clearance and the roof height without trapping the board.
        translate([width+6,0,0]) {
            cube([wall,frame_length,headroom]);
            translate([frame_width-wall,0,0]) cube([wall,frame_length,headroom]);
            translate([0,0,headroom-wall]) cube([frame_width,frame_length,wall]);
        }
    }
}

module m3_insert_coupon(bore_d,boss_d,index) {
    cell_w = 18;
    cell_h = 16;
    base_t = 1.2;
    boss_h = m3_insert_length+m3_insert_bottom;
    boss_x = 12.3;
    boss_y = cell_h/2;
    difference() {
        union() {
            cube([cell_w,cell_h,base_t]);
            translate([boss_x,boss_y,base_t]) cylinder(d=boss_d,h=boss_h);
            translate([4.2,cell_h/2,base_t])
                label3d(str(bore_d,"/",boss_d),2.1,0.3);
        }
        translate([boss_x,boss_y,base_t+boss_h-m3_insert_length-m3_insert_bottom])
            cylinder(d=bore_d,h=m3_insert_length+m3_insert_bottom+0.05);
        translate([boss_x,boss_y,base_t+boss_h-m3_insert_chamfer])
            cylinder(d1=bore_d+m3_insert_chamfer,d2=bore_d,
                     h=m3_insert_chamfer+0.02);
    }
}

module m3_screw_coupon(index) {
    hole_d = m3_screw_hole_first+index*m3_screw_hole_step;
    tile = 18;
    difference() {
        union() {
            cube([tile,tile,3]);
            translate([tile/2,2,3]) label3d(str("D",hole_d),2.0,0.3);
        }
        translate([tile/2,tile/2,-0.1]) cylinder(d=hole_d,h=3.2);
        translate([tile/2,tile/2,3-m3_screw_head_depth])
            cylinder(d=m3_screw_head_diameter,h=m3_screw_head_depth+0.1);
    }
}

module board_edge_coupon(clearance,index) {
    channel = board_edge_thickness+2*clearance;
    length = 28;
    width = 14;
    height = 9;
    difference() {
        union() {
            cube([width,length,height]);
            translate([width/2,length-3,height])
                label3d(str("C+",clearance),1.9,0.3);
        }
        // U-slot captures a board edge without needing a mounting hole or adhesive.
        translate([2,-0.1,height-channel/2])
            cube([width-4,length+0.2,channel]);
        translate([width/2,length/2,height-channel/2-0.1])
            cube([width+0.2,4,channel+0.2]);
    }
}

module board_outline_coupon(clearance,index) {
    board_w = selected_board_w();
    board_l = selected_board_l();
    inner_w = board_w+2*clearance;
    inner_l = board_l+2*clearance;
    outer_w = inner_w+2*coupon_wall;
    outer_l = inner_l+2*coupon_wall;
    h = board_outline_height;
    notch_w = min(board_connector_opening,inner_w-2);
    difference() {
        union() {
            difference() {
                cube([outer_w,outer_l,h]);
                translate([coupon_wall,coupon_wall,-0.1])
                    cube([inner_w,inner_l,h+0.2]);
            }
            translate([outer_w/2,2,h]) label3d(str("C+",clearance),2.1,0.35);
        }
        if (board_connector_edge == "short")
            translate([outer_w/2-notch_w/2,outer_l-coupon_wall-0.1,-0.1])
                cube([notch_w,coupon_wall+0.2,h+0.2]);
        if (board_connector_edge == "long")
            translate([outer_w-coupon_wall-0.1,outer_l/2-notch_w/2,-0.1])
                cube([coupon_wall+0.2,notch_w,h+0.2]);
    }
}

module solder_height_gauge(index) {
    height = board_solder_standoff_first+index*board_solder_standoff_step;
    difference() {
        union() {
            cube([14,14,height]);
            translate([7,3,height]) label3d(str(height),2.0,0.3);
        }
        translate([7,7,-0.1]) cylinder(d=3.4,h=height+0.2);
    }
}

module oled_set() {
    w = oled_pcb_w()+8;
    h = oled_pcb_h()+8;
    for (i=[0:fit_sample_count-1])
        translate([(i%2)*(w+coupon_spacing),floor(i/2)*(h+coupon_spacing),0])
            oled_coupon(fit_clearance(i),i);
}

module encoder_set() {
    w = encoder_body_x+14;
    h = encoder_body_y+14;
    for (i=[0:fit_sample_count-1])
        translate([(i%2)*(w+coupon_spacing),floor(i/2)*(h+coupon_spacing),0])
            encoder_coupon(fit_clearance(i),i);
    for (i=[0:3])
        translate([2+i*15,2*(h+coupon_spacing)+4,0]) encoder_shaft_gauge(i);
}

module button_set() {
    cols = 5;
    for (i=[0:pushbutton_hole_count-1])
        translate([(i%cols)*28,floor(i/cols)*28,0]) button_hole_coupon(i);
    for (i=[0:fit_sample_count-1])
        translate([i*18,58,0]) button_cap_gauge(i);
}

module usb_set() {
    w = usb_plug_width+12;
    h = usb_plug_height+12;
    for (i=[0:fit_sample_count-1])
        translate([(i%2)*(w+coupon_spacing),floor(i/2)*(h+coupon_spacing),0])
            usb_coupon(i);
}

module motor_cable_set() {
    tile = motor_boot_diameter+10;
    for (i=[0:fit_sample_count-1])
        translate([i*(tile+coupon_spacing),0,0]) motor_cable_coupon(i);
}

module dupont_set() {
    base_w = dupont_pin_count*dupont_pitch+8;
    gauge_w = dupont_pin_count*dupont_pitch+4;
    cell_w = base_w+6+gauge_w;
    for (i=[0:fit_sample_count-1])
        translate([i*(cell_w+coupon_spacing),0,0]) dupont_depth_coupon(i);
}

module m3_insert_set() {
    for (i=[0:m3_insert_bore_count-1], j=[0:3]) {
        boss_d = j == 0 ? m3_insert_boss_diameter_min :
                 j == 1 ? m3_insert_boss_diameter :
                 j == 2 ? m3_insert_boss_diameter+0.5 :
                          m3_insert_boss_diameter+1.0;
        translate([i*20,j*18,0])
            m3_insert_coupon(m3_insert_bore_first+i*m3_insert_bore_step,
                             boss_d,i);
    }
}

module m3_screw_set() {
    for (i=[0:m3_screw_hole_count-1])
        translate([i*21,0,0]) m3_screw_coupon(i);
}

module board_edge_set() {
    for (i=[0:board_edge_clearance_count-1])
        translate([i*18,0,0])
            board_edge_coupon(board_edge_clearance_first+i*board_edge_clearance_step,i);
    for (i=[0:board_solder_standoff_count-1])
        translate([i*17,36,0]) solder_height_gauge(i);
}

module board_outline_set() {
    w = selected_board_w()+2*fit_first_clearance+2*coupon_wall;
    l = selected_board_l()+2*fit_first_clearance+2*coupon_wall;
    for (i=[0:board_outline_sample_count-1])
        translate([(i%2)*(w+coupon_spacing),floor(i/2)*(l+coupon_spacing),0])
            board_outline_coupon(fit_clearance(i),i);
}

module all_sets_preview() {
    translate([0,0,0]) oled_set();
    translate([105,0,0]) encoder_set();
    translate([0,115,0]) button_set();
    translate([0,190,0]) usb_set();
    translate([85,190,0]) motor_cable_set();
    translate([85,225,0]) dupont_set();
    translate([150,115,0]) m3_insert_set();
    translate([150,190,0]) m3_screw_set();
    translate([0,250,0]) board_edge_set();
    translate([110,250,0]) board_outline_set();
}

if (test_set == "all") all_sets_preview();
else if (test_set == "oled") oled_set();
else if (test_set == "encoder") encoder_set();
else if (test_set == "button") button_set();
else if (test_set == "usb") usb_set();
else if (test_set == "motor_cable") motor_cable_set();
else if (test_set == "dupont") dupont_set();
else if (test_set == "m3_insert") m3_insert_set();
else if (test_set == "m3_screw") m3_screw_set();
else if (test_set == "board_edge") board_edge_set();
else if (test_set == "board_outline") board_outline_set();
