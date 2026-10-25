/* Häfele standing desk control box and lid.
 * Reconstructed as editable OpenSCAD CSG from the fully constrained FreeCAD sketches.
 * Units are millimetres. See README_OpenSCAD.md for source and measured limits.
 */

/* [Design revision] */
design_revision = "rework"; // [baseline:FreeCAD reconstruction,rework:hardware-retention revision]

/* [Assembly] */
show_part = "assembly"; // [case:Case,lid:Lid,assembly:Case and lid,oled_retainer:OLED retainer,encoder_retainer:Encoder retainer]
show_exploded = false;
explode_gap = 8;
$fn = 96;

/* [Case: primary dimensions] */
longitud = 150; // [100:1:250]
alto = 35; // [20:1:60]
profundidad = 70; // [40:1:120]
radio_curvaturas = 5; // [2:0.25:10]
angulo_del_panel = 75; // [45:1:90]
ancho_pared = 1.5; // [0.8:0.1:3]

/* [Display and buttons] */
ancho_display = 26.64;
alto_display = 14.46;
pos_display_x = 20;
pos_display_y = 15;
distancia_botones = 40;
altura_botones = 3;
pos_x_botones = 75;
dia_botones = 8.68;
panel_sketch_offset = 19.113; // FreeCAD attachment offset from the panel's top corner.

/* [OLED pocket and retainer: candidate module envelope] */
oled_pcb_width = 35.4; // Common 1.3-inch breakout candidate; verify actual PCB.
oled_pcb_height = 33.5;
oled_pcb_clearance = 0.3; // Per side; calibrate with the OLED coupon.
oled_front_skin = 0.8; // Material left behind the front mask around the window.
oled_module_depth = 2.6; // PCB and components envelope from front skin to rear surface.
oled_retainer_overlap = 1.2; // Retainer lip over the PCB perimeter.
oled_retainer_thickness = 1.6;
oled_retainer_fastener_offset = 5.0;
oled_header_edge = "top"; // [top,bottom,left,right]
oled_header_notch_width = 14;
oled_header_notch_depth = 5;
oled_window_offset_x = 0; // Adjustable alignment of module glass to source-derived window.
oled_window_offset_y = 0;

/* [Encoder cradle and retainer: EC11-family candidate] */
encoder_body_width = 12.5;
encoder_body_height = 11.7;
encoder_body_depth = 7.5;
encoder_body_clearance = 0.25; // Per side; calibrate with the encoder coupon.
encoder_front_skin = 0.8;
encoder_shaft_diameter = 6.0;
encoder_shaft_clearance = 0.35; // Radial clearance.
encoder_retainer_overlap = 0.8;
encoder_retainer_thickness = 1.6;
encoder_retainer_fastener_offset = 4.0;
encoder_terminal_edge = "top"; // [top,bottom,left,right]
encoder_terminal_notch_width = 8;
encoder_terminal_notch_depth = 4;

/* [M3 heat-set insert mounting] */
m3_insert_boss_diameter = 8.0; // Candidate reinforced boss; test the 7-8 mm coupon series.
m3_insert_pilot_diameter = 4.0; // Candidate only; tune to the actual insert and printed coupon.
m3_insert_length = 5.7;
m3_insert_bottom_clearance = 1.0;
m3_insert_leadin = 0.4;
control_boss_depth = 11.0; // Axial depth behind the angled panel for the retainer standoffs.
m3_lid_clearance_diameter = 3.4;

/* [External cable and USB openings: placement provisional] */
enable_motor_cable_exit = false;
motor_cable_end = "far"; // [near,far]
motor_cable_x = 30;
motor_cable_z = 8;
motor_cable_opening_diameter = 12;
enable_usb_access = false;
usb_access_end = "near"; // [near,far]
usb_access_x = 30;
usb_access_z = 20;
usb_access_width = 14;
usb_access_height = 9;
usb_access_corner_radius = 1.5;

/* [Internal support walls] */
support_floor_left_x = 6.0813014172; // Sketch006 constrained profile point.
support_inner_offset = 7.25; // Sketch007 constrained profile offset.
support_near_offset = 9; // Near support sketch plane from the Y=0 end.

/* [Lid] */
espesor_tapa = 1.5; // Preserved spreadsheet parameter; no final feature references it.

/* [Fastener towers] */
dia_torres_tornillos = 7;
long_torres_tornillos = alto - ancho_pared;
separacion_torres_tornillos = 6;
dia_interno_torres_tornillos = 4.25;

/* [Display selection] */
// Spreadsheet aliases kept verbatim for compatibility with the FreeCAD parameter names.
// The old label pos_y_botones maps to alias altura_botones; pos_x_botones maps to x=75.

function panel_inset() = profundidad - alto / tan(angulo_del_panel);
function display_panel_x() = -longitud + pos_display_x;
function display_panel_y() = pos_display_y - alto + alto_display;
function display_center_x() = display_panel_x() + ancho_display/2 + oled_window_offset_x;
function display_center_y() = display_panel_y() + alto_display/2 + oled_window_offset_y;
function pushbutton_center_x() = -pos_x_botones;
function encoder_center_x() = -pos_x_botones + distancia_botones;

module panel_coordinate_frame() {
    theta = 90-angulo_del_panel;
    a = angulo_del_panel;
    z_left_tan = radio_curvaturas-radio_curvaturas*sin(90-a);
    x_left_tan = -radio_curvaturas*cos(90-a);
    x_top_left = x_left_tan-(alto-z_left_tan)/tan(a);
    x_top_right = x_top_left+profundidad;
    ox = x_top_right+panel_sketch_offset*sin(theta);
    oz = alto-panel_sketch_offset*cos(theta);
    multmatrix([[0,-sin(theta),cos(theta),ox],
                [1,0,0,0],
                [0,cos(theta),sin(theta),oz],
                [0,0,0,1]]) children();
}

module rounded_rectangle_2d(width,height,radius) {
    offset(r=radius) square([width-2*radius,height-2*radius],center=true);
}

module panel_m3_boss(x,y) {
    translate([x,y,-ancho_pared-control_boss_depth])
        cylinder(d=m3_insert_boss_diameter,h=control_boss_depth+0.03,$fn=48);
}

module panel_retainer_bosses() {
    if (design_revision == "rework") panel_coordinate_frame() {
        oled_screw_x = oled_pcb_width/2+oled_retainer_fastener_offset;
        panel_m3_boss(display_center_x()-oled_screw_x,display_center_y());
        panel_m3_boss(display_center_x()+oled_screw_x,display_center_y());

        encoder_screw_x = encoder_body_width/2+encoder_retainer_fastener_offset;
        panel_m3_boss(encoder_center_x()-encoder_screw_x,altura_botones);
        panel_m3_boss(encoder_center_x()+encoder_screw_x,altura_botones);
    }
}

module m3_case_tower() {
    if (design_revision == "baseline") screw_tower(0,0);
    else cylinder(d=m3_insert_boss_diameter,h=long_torres_tornillos,$fn=48);
}

module m3_insert_bore(drive_z,depth,lead_in_at_start=false) {
    translate([0,0,drive_z])
        cylinder(d=m3_insert_pilot_diameter,h=depth+0.02,$fn=48);
    if (lead_in_at_start)
        translate([0,0,drive_z-0.01])
            cylinder(d1=m3_insert_pilot_diameter+2*m3_insert_leadin,
                     d2=m3_insert_pilot_diameter,
                     h=m3_insert_leadin+0.02,$fn=48);
    else
        translate([0,0,drive_z+depth-m3_insert_leadin])
            cylinder(d1=m3_insert_pilot_diameter,
                     d2=m3_insert_pilot_diameter+2*m3_insert_leadin,
                     h=m3_insert_leadin+0.02,$fn=48);
}

module case_m3_insert_cutouts() {
    if (design_revision == "rework") {
        tower_edge_offset = separacion_torres_tornillos+dia_torres_tornillos/2;
        tower_depth = m3_insert_length+m3_insert_bottom_clearance;
        for (x=[tower_edge_offset,panel_inset()-tower_edge_offset],
             y=[-tower_edge_offset,-longitud+tower_edge_offset])
            translate([x,y,ancho_pared])
                m3_insert_bore(long_torres_tornillos-tower_depth,tower_depth);

        panel_coordinate_frame() {
            oled_screw_x = oled_pcb_width/2+oled_retainer_fastener_offset;
            panel_m3_insert_bore(display_center_x()-oled_screw_x,display_center_y());
            panel_m3_insert_bore(display_center_x()+oled_screw_x,display_center_y());
            encoder_screw_x = encoder_body_width/2+encoder_retainer_fastener_offset;
            panel_m3_insert_bore(encoder_center_x()-encoder_screw_x,altura_botones);
            panel_m3_insert_bore(encoder_center_x()+encoder_screw_x,altura_botones);
        }
    }
}

module panel_m3_insert_bore(x,y) {
    translate([x,y,-ancho_pared-control_boss_depth-0.02])
        m3_insert_bore(0,m3_insert_length+m3_insert_bottom_clearance,true);
}

module rounded_profile_2d() {
    // Coordinates follow Sketch Perfil_Lateral and its tangent constraints.
    r = radio_curvaturas;
    a = angulo_del_panel;
    z_left_tan = r - r*sin(90-a);
    z_right_tan = r + r*sin(90-a);
    x_left_tan = -r*cos(90-a);
    x_top_left = x_left_tan - (alto-z_left_tan)/tan(a);
    x_top_right = x_top_left + profundidad;
    x_right_tan = x_top_right + (alto-z_right_tan)/tan(a);
    x_right_center = x_right_tan - r*cos(90-a);
    points = concat(
        [[x_top_left,alto],[x_top_right,alto],[x_right_tan,z_right_tan]],
        [for (angle=[375:-3:270]) [x_right_center+r*cos(angle),r+r*sin(angle)]],
        [[0,0]],
        [for (angle=[270:-3:195]) [r+r*cos(angle),r+r*sin(angle)]],
        [[x_left_tan,z_left_tan]]
    );
    polygon(points);
}

module enclosure_shell() {
    // The base is the FreeCAD thickness feature represented by a constant inset cross section.
    // Support ribs and screw lands are added below as separate CSG features.
    rotate([90,0,0]) linear_extrude(height=longitud, convexity=10)
        difference() {
            rounded_profile_2d();
            offset(delta=-ancho_pared) rounded_profile_2d();
            // Thickness Face2 is removed in the FreeCAD shell, leaving the top edge open.
            translate([-100,alto-ancho_pared]) square([250,ancho_pared+2]);
        }
}

module end_closures() {
    // Closing skins at extrusion ends are retained separately from the open shell profile.
    for (y=[-0.02,-longitud+ancho_pared+0.02])
        translate([0,y,0]) rotate([90,0,0]) linear_extrude(height=ancho_pared,convexity=5)
            rounded_profile_2d();
}

module support_wall_profiles() {
    // Native CSG transcription of Sketch006 and Sketch007. These are irregular
    // 12-edge walls; rectangular blocks create a false lower ledge in the case.
    r = radio_curvaturas;
    a = angulo_del_panel;
    t = ancho_pared;
    z_left_outer = r-r*sin(90-a);
    z_right_outer = r+r*sin(90-a);
    x_left_outer = -r*cos(90-a);
    x_top_left = x_left_outer-(alto-z_left_outer)/tan(a);
    x_top_right = x_top_left+profundidad;
    x_right_outer = x_top_right+(alto-z_right_outer)/tan(a);
    x_right_center = x_right_outer-r*cos(90-a);

    z_left_inner = z_left_outer+t*cos(a);
    x_left_inner = x_left_outer+t*sin(a);
    z_right_inner = z_right_outer-t*cos(a);
    x_right_inner = x_right_outer-t*sin(a);
    z_support_top = alto-t;
    x_left_inner_top = x_left_inner-(z_support_top-z_left_inner)/tan(a);
    x_right_inner_top = x_right_inner-(z_support_top-z_right_inner)/tan(a);

    support_right_x = panel_inset()-support_inner_offset;

    // Near support: Y=-9 mm, pad proceeds 1.5 mm toward the enclosure interior.
    translate([0,-support_near_offset,0]) rotate([90,0,0]) linear_extrude(height=t,convexity=5)
        polygon([[support_floor_left_x,z_support_top],
                 [x_left_inner_top,z_support_top],
                 [x_left_inner,z_left_inner],
                 [0,t],[0,0],
                 [x_right_center,0],[x_right_center,t],
                 [x_right_inner,z_right_inner],
                 [x_right_inner_top,z_support_top],
                 [support_right_x,z_support_top],
                 [support_right_x,t],
                 [support_floor_left_x,t]]);

    // Far support position is linked to the tower separation in the source sketch.
    translate([0,-longitud+2*separacion_torres_tornillos-t,0])
        rotate([90,0,0]) linear_extrude(height=t,convexity=5)
            polygon([[x_left_inner,z_left_inner],
                     [x_left_inner_top,z_support_top],
                     [support_inner_offset,z_support_top],
                     [support_inner_offset,t],
                     [support_right_x,t],
                     [support_right_x,z_support_top],
                     [x_right_inner_top,z_support_top],
                     [x_right_inner,z_right_inner],
                     [x_right_center,t],
                     [x_right_center,0],[0,0],[0,t]]);
}

module display_and_button_openings() {
    // Source-derived display and pushbutton locations in the angled panel frame.
    panel_coordinate_frame() {
        translate([display_panel_x(),display_panel_y(),-8])
            cube([ancho_display,alto_display,16]);
        translate([pushbutton_center_x(),altura_botones,-8])
            cylinder(d=dia_botones,h=16,$fn=96);
        encoder_hole = design_revision == "baseline"
            ? dia_botones : encoder_shaft_diameter+2*encoder_shaft_clearance;
        translate([encoder_center_x(),altura_botones,-8])
            cylinder(d=encoder_hole,h=16,$fn=96);
    }
}

module rework_panel_pockets() {
    if (design_revision == "rework") panel_coordinate_frame() {
        oled_cut_w = oled_pcb_width+2*oled_pcb_clearance;
        oled_cut_h = oled_pcb_height+2*oled_pcb_clearance;
        oled_total_depth = oled_front_skin+oled_module_depth;
        translate([display_center_x()-oled_cut_w/2,
                   display_center_y()-oled_cut_h/2,
                   -oled_total_depth])
            cube([oled_cut_w,oled_cut_h,oled_total_depth-oled_front_skin+0.02]);

        encoder_cut_w = encoder_body_width+2*encoder_body_clearance;
        encoder_cut_h = encoder_body_height+2*encoder_body_clearance;
        encoder_total_depth = encoder_front_skin+encoder_body_depth+0.5;
        translate([encoder_center_x()-encoder_cut_w/2,
                   altura_botones-encoder_cut_h/2,
                   -encoder_total_depth])
            cube([encoder_cut_w,encoder_cut_h,
                  encoder_total_depth-encoder_front_skin+0.02]);
    }
}

module external_access_cutouts() {
    cable_y = motor_cable_end == "near" ? 0.1 : -longitud-0.1;
    cable_rotation = motor_cable_end == "near" ? 90 : -90;
    usb_y = usb_access_end == "near" ? 0.1 : -longitud-0.1;
    usb_rotation = usb_access_end == "near" ? 90 : -90;

    if (design_revision == "rework" && enable_motor_cable_exit)
        translate([motor_cable_x,cable_y,motor_cable_z])
            rotate([cable_rotation,0,0])
                linear_extrude(height=ancho_pared+0.4)
                    circle(d=motor_cable_opening_diameter,$fn=64);

    if (design_revision == "rework" && enable_usb_access)
        translate([usb_access_x,usb_y,usb_access_z])
            rotate([usb_rotation,0,0])
                linear_extrude(height=ancho_pared+0.4)
                    rounded_rectangle_2d(usb_access_width,usb_access_height,
                                         usb_access_corner_radius);
}

module screw_tower(x,y) {
    difference() {
        cylinder(d=dia_torres_tornillos,h=long_torres_tornillos,$fn=48);
        translate([0,0,-0.1]) cylinder(d=dia_interno_torres_tornillos,h=long_torres_tornillos+0.2,$fn=48);
    }
}

module case_body() {
    tower_edge_offset = separacion_torres_tornillos + dia_torres_tornillos/2;
    difference() {
        union() {
            enclosure_shell();
            end_closures();
            // Four cylindrical screw lands at the source sketch coordinates.
            for (x=[tower_edge_offset,panel_inset()-tower_edge_offset], y=[-tower_edge_offset,-longitud+tower_edge_offset])
                translate([x,y,ancho_pared]) m3_case_tower();
            support_wall_profiles();
            panel_retainer_bosses();
        }
        display_and_button_openings();
        rework_panel_pockets();
        external_access_cutouts();
        case_m3_insert_cutouts();
    }
}

module lid_plate() {
    // FreeCAD lid pad: 70 x 150 x 1.5, centred on XY.
    translate([-profundidad/2,-longitud/2,0]) cube([profundidad,longitud,ancho_pared]);
}

module lid_rim() {
    // FreeCAD Alzada_de_tapa pad is the raised inset panel, 1.5 mm inside each edge.
    translate([-(profundidad-2*ancho_pared)/2,-(longitud-2*ancho_pared)/2,ancho_pared])
        cube([profundidad-2*ancho_pared,longitud-2*ancho_pared,ancho_pared]);
}

module lid_end_tabs() {
    for (y=[-longitud/2-8,longitud/2+8])
        translate([-8,y-8,0]) cube([16,16,ancho_pared]);
}

module lid_fastener_holes() {
    // Four panel holes pierce the 3 mm raised panel; tab holes pierce the 1.5 mm base only.
    lid_hole_d = design_revision == "baseline" ? 4 : m3_lid_clearance_diameter;
    for (x=[-25.5,16.1217782649],y=[-65.5,65.5])
        translate([x,y,-0.1]) cylinder(d=lid_hole_d,h=2*ancho_pared+0.2,$fn=96);
    for (y=[-83,83])
        translate([0,y,-0.1]) cylinder(d=lid_hole_d,h=ancho_pared+0.2,$fn=96);
}

module case_lid() {
    difference() {
        union() { lid_plate(); lid_rim(); lid_end_tabs(); }
        lid_fastener_holes();
    }
}

module service_retainer_frame(outer_w,outer_h,inner_w,inner_h,thickness,
                              screw_x,spacer_h,notch_edge,notch_width,notch_depth) {
    total_h = thickness+spacer_h;
    head_d = 6.0;
    head_recess = 2.0;
    difference() {
        union() {
            linear_extrude(height=thickness)
                square([outer_w,outer_h],center=true);
            for (x=[-screw_x,screw_x])
                translate([x,0,thickness])
                    cylinder(d=m3_insert_boss_diameter,h=spacer_h,$fn=48);
        }
        translate([0,0,-0.01])
            linear_extrude(height=thickness+0.02)
                square([inner_w,inner_h],center=true);
        for (x=[-screw_x,screw_x]) {
            translate([x,0,-0.01])
                cylinder(d=m3_lid_clearance_diameter,h=total_h+0.02,$fn=48);
            translate([x,0,total_h-head_recess])
                cylinder(d=head_d,h=head_recess+0.02,$fn=48);
        }
        if (notch_edge == "top")
            translate([0,outer_h/2-notch_depth/2,-0.01])
                cube([notch_width,notch_depth,thickness+0.02],center=true);
        if (notch_edge == "bottom")
            translate([0,-outer_h/2+notch_depth/2,-0.01])
                cube([notch_width,notch_depth,thickness+0.02],center=true);
        if (notch_edge == "left")
            translate([-outer_w/2+notch_depth/2,0,-0.01])
                cube([notch_depth,notch_width,thickness+0.02],center=true);
        if (notch_edge == "right")
            translate([outer_w/2-notch_depth/2,0,-0.01])
                cube([notch_depth,notch_width,thickness+0.02],center=true);
    }
}

function oled_retainer_outer_width() =
    oled_pcb_width+2*(oled_retainer_fastener_offset+m3_insert_boss_diameter/2);
function oled_retainer_outer_height() = oled_pcb_height+2*(oled_retainer_overlap+2);
function oled_retainer_spacer_height() =
    max(0,control_boss_depth+ancho_pared-(oled_front_skin+oled_module_depth)-oled_retainer_thickness);
function encoder_retainer_outer_width() =
    encoder_body_width+2*(encoder_retainer_fastener_offset+m3_insert_boss_diameter/2);
function encoder_retainer_outer_height() =
    encoder_body_height+2*(encoder_retainer_fastener_offset+m3_insert_boss_diameter/2);
function encoder_retainer_spacer_height() =
    max(0,control_boss_depth+ancho_pared-(encoder_front_skin+encoder_body_depth)-encoder_retainer_thickness);

module oled_retainer_frame() {
    service_retainer_frame(
        oled_retainer_outer_width(),oled_retainer_outer_height(),
        oled_pcb_width-2*oled_retainer_overlap,
        oled_pcb_height-2*oled_retainer_overlap,
        oled_retainer_thickness,
        oled_pcb_width/2+oled_retainer_fastener_offset,
        oled_retainer_spacer_height(),
        oled_header_edge,oled_header_notch_width,oled_header_notch_depth);
}

module encoder_retainer_frame() {
    service_retainer_frame(
        encoder_retainer_outer_width(),encoder_retainer_outer_height(),
        encoder_body_width-2*encoder_retainer_overlap,
        encoder_body_height-2*encoder_retainer_overlap,
        encoder_retainer_thickness,
        encoder_body_width/2+encoder_retainer_fastener_offset,
        encoder_retainer_spacer_height(),
        encoder_terminal_edge,encoder_terminal_notch_width,encoder_terminal_notch_depth);
}

module oled_retainer_installed() {
    if (design_revision == "rework") panel_coordinate_frame()
        translate([display_center_x(),display_center_y(),
                   -(oled_front_skin+oled_module_depth)])
            rotate([180,0,0]) oled_retainer_frame();
}

module encoder_retainer_installed() {
    if (design_revision == "rework") panel_coordinate_frame()
        translate([encoder_center_x(),altura_botones,
                   -(encoder_front_skin+encoder_body_depth)])
            rotate([180,0,0]) encoder_retainer_frame();
}

module assembly() {
    case_body();
    translate([0,0,show_exploded ? alto+explode_gap : alto]) case_lid();
    if (design_revision == "rework") {
        oled_retainer_installed();
        encoder_retainer_installed();
    }
}

if (show_part == "case") case_body();
else if (show_part == "lid") case_lid();
else if (show_part == "oled_retainer") oled_retainer_frame();
else if (show_part == "encoder_retainer") encoder_retainer_frame();
else assembly();
