/* Häfele standing desk control box and lid.
 * Reconstructed as editable OpenSCAD CSG from the fully constrained FreeCAD sketches.
 * Units are millimetres. See README_OpenSCAD.md for source and measured limits.
 */

/* [Design revision] */
design_revision = "rework"; // [baseline:FreeCAD reconstruction,rework:hardware-retention revision]

/* [Assembly] */
show_part = "assembly"; // [case:Case,lid:Lid,assembly:Case and lid,oled_retainer:OLED retainer,encoder_retainer:Encoder retainer,electronics_carrier:Electronics carrier,button_cap:Button cap]
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

/* [OLED pocket and retainer: candidate module envelope] */
oled_pcb_width = 35.4; // Common 1.3-inch breakout candidate; verify actual PCB.
oled_pcb_height = 33.5;
oled_pcb_clearance = 0.3; // Per side; calibrate with the OLED coupon.
oled_front_skin = 0.8; // Material left behind the front mask around the window.
oled_module_depth = 2.9; // Common 1.3-inch I2C module drawing; verify actual board/header.
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
encoder_retainer_fastener_offset = 4.5; // Leaves 0.5 mm between body-support lip and Ø8 boss.
encoder_terminal_edge = "top"; // [top,bottom,left,right]
encoder_terminal_notch_width = 8;
encoder_terminal_notch_depth = 4;

/* [Threaded panel button: optional printed actuator cap] */
button_cap_diameter = 10;
button_cap_height = 4;
button_cap_socket_diameter = 6;
button_cap_socket_clearance = 0.3;
button_cap_socket_depth = 2.6;
button_cap_roof = 1.2;

/* [M3 heat-set insert mounting] */
m3_insert_boss_diameter = 8.0; // Candidate reinforced boss; test the 7-8 mm coupon series.
m3_insert_pilot_diameter = 4.0; // Candidate only; tune to the actual insert and printed coupon.
m3_insert_length = 5.7;
m3_insert_bottom_clearance = 1.0;
m3_insert_leadin = 0.4;
control_boss_depth = 18.0; // Rear screw plate clears the existing lid towers.
retainer_bridge_width = 3; // Rear brace joins both sides without crossing the header notch.
m3_lid_clearance_diameter = 3.4;
m3_screw_head_diameter = 6;
m3_screw_head_height = 2.4;

/* [External cable and USB openings: placement provisional] */
enable_motor_cable_exit = true;
motor_cable_end = "far"; // [near,far]
motor_cable_x = 30;
motor_cable_z = 8;
motor_cable_opening_diameter = 12;
enable_usb_access = true;
usb_access_end = "near"; // [near,far]
usb_access_x = 30;
usb_access_z = 20;
usb_access_width = 14;
usb_access_height = 9;
usb_access_corner_radius = 1.5;

/* [Relay indicator windows: inferred from rear photo, location provisional] */
enable_relay_indicator_windows = true;
relay_indicator_end = "far"; // [near,far]
relay_indicator_center_x = 48;
relay_indicator_spacing = 9;
relay_indicator_z = 10;
relay_indicator_width = 5;
relay_indicator_height = 7;
relay_indicator_corner_radius = 2;

/* [Internal support walls] */
support_floor_left_x = 6.0813014172; // Sketch006 constrained profile point.
support_inner_offset = 7.25; // Sketch007 constrained profile offset.
support_profile_base_radius = 5; // Hardcoded 5 mm sketch datum, retained from FreeCAD.
support_minimum_top = 33.5; // Hardcoded support height retained by short source configurations.

/* [Fastener towers] */
dia_torres_tornillos = 7;
long_torres_tornillos = alto - ancho_pared;
separacion_torres_tornillos = 6;
dia_interno_torres_tornillos = 4.25;

/* [Removable electronics carrier: adjustable layout] */
carrier_edge_margin = 3;
carrier_tower_clearance = 0.5;
carrier_width = panel_inset()-2*carrier_edge_margin;
carrier_length = longitud-2*(separacion_torres_tornillos+dia_torres_tornillos/2
    +max(dia_torres_tornillos,m3_insert_boss_diameter)/2+carrier_tower_clearance);
carrier_thickness = 2;
carrier_mount_height = 7;
carrier_mount_boss_diameter = 8;
carrier_mount_insert_length = 5.7;
carrier_grid_pitch = 10;
carrier_grid_hole_diameter = 3.2;
carrier_mount_edge_x = 7;
carrier_mount_panel_edge_x = 26; // Inset panel-side mounts to clear control retainers.
carrier_mount_end_y = (longitud-carrier_length)/2+carrier_mount_boss_diameter/2;
carrier_encoder_clearance = 0.35; // Relief around both control retainers and their case bosses.
retainer_floor_clearance = 0.35; // Retainer clearance to the shell cavity; OLED lower lip is open.

/* [Lid] */
espesor_tapa = 1.5; // Preserved spreadsheet parameter; no final feature references it.
lid_rim_clearance = 0.25; // Normal clearance for the rework locating lip inside the shell.

/* [Display selection] */
// Spreadsheet aliases kept verbatim for compatibility with the FreeCAD parameter names.
// The old label pos_y_botones maps to alias altura_botones; pos_x_botones maps to x=75.

function panel_inset() = profundidad - alto / tan(angulo_del_panel);
function case_top_center_x() =
    -radio_curvaturas*cos(90-angulo_del_panel)
    -(alto-(radio_curvaturas-radio_curvaturas*sin(90-angulo_del_panel)))
      /tan(angulo_del_panel)+profundidad/2;
function support_near_offset() = separacion_torres_tornillos + 2*ancho_pared;
function display_panel_x() = -longitud + pos_display_x;
function display_panel_y() = pos_display_y - alto + alto_display;
function display_center_x() = display_panel_x() + ancho_display/2 + oled_window_offset_x;
function display_center_y() = display_panel_y() + alto_display/2 + oled_window_offset_y;
function pushbutton_center_x() = -longitud + pos_x_botones;
function encoder_center_x() = -longitud + pos_x_botones + distancia_botones;
function panel_plane_constant() =
    case_top_center_x()+profundidad/2+alto/tan(angulo_del_panel);
function panel_origin_z() = panel_plane_constant()*sin(angulo_del_panel)*cos(angulo_del_panel);

module panel_coordinate_frame() {
    theta = 90-angulo_del_panel;
    a = angulo_del_panel;
    z_left_tan = radio_curvaturas-radio_curvaturas*sin(90-a);
    x_left_tan = -radio_curvaturas*cos(90-a);
    x_top_left = x_left_tan-(alto-z_left_tan)/tan(a);
    x_top_right = x_top_left+profundidad;
    // FlatFace maps the sketch origin to the orthogonal projection of the
    // global origin onto the inclined panel plane.
    plane_constant = panel_plane_constant();
    ox = plane_constant*sin(a)*sin(a);
    oz = plane_constant*sin(a)*cos(a);
    multmatrix([[0,-sin(theta),cos(theta),ox],
                [1,0,0,0],
                [0,cos(theta),sin(theta),oz],
                [0,0,0,1]]) children();
}

module inverse_panel_coordinate_frame() {
    theta = 90-angulo_del_panel;
    ox = panel_plane_constant()*sin(angulo_del_panel)*sin(angulo_del_panel);
    oz = panel_origin_z();
    multmatrix([[0,1,0,0],
                [-sin(theta),0,cos(theta),sin(theta)*ox-cos(theta)*oz],
                [cos(theta),0,sin(theta),-cos(theta)*ox-sin(theta)*oz],
                [0,0,0,1]]) children();
}

module rounded_rectangle_2d(width,height,radius) {
    offset(r=radius) square([width-2*radius,height-2*radius],center=true);
}

function profile_arc_points(cx,cz,r,start,end) =
    let(steps=max(1,ceil(abs(end-start))))
    [for (i=[0:steps]) let(angle=start+(end-start)*i/steps)
        [cx+r*cos(angle),cz+r*sin(angle)]];

module panel_m3_boss(x,y) {
    translate([x,y,-ancho_pared-control_boss_depth])
        cylinder(d=m3_insert_boss_diameter,h=control_boss_depth+0.03,$fn=48);
}

module panel_retainer_bosses(control="all") {
    if (design_revision == "rework") panel_coordinate_frame() {
        oled_screw_x = oled_pcb_width/2+oled_retainer_fastener_offset;
        if (control == "all" || control == "oled") {
            panel_m3_boss(display_center_x()-oled_screw_x,display_center_y());
            panel_m3_boss(display_center_x()+oled_screw_x,display_center_y());
        }

        encoder_screw_x = encoder_body_width/2+encoder_retainer_fastener_offset;
        if (control == "all" || control == "encoder") {
            panel_m3_boss(encoder_center_x()-encoder_screw_x,altura_botones);
            panel_m3_boss(encoder_center_x()+encoder_screw_x,altura_botones);
        }
    }
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
            translate([x,y,0])
                m3_insert_bore(long_torres_tornillos-tower_depth,tower_depth);

        carrier_mount_x = [carrier_mount_edge_x,panel_inset()-carrier_mount_panel_edge_x];
        carrier_mount_y = [-carrier_mount_end_y,-longitud+carrier_mount_end_y];
        for (x=carrier_mount_x,y=carrier_mount_y)
            translate([x,y,ancho_pared])
                m3_insert_bore(carrier_mount_height-carrier_mount_insert_length-1,
                               carrier_mount_insert_length+1);

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

module carrier_mount_bosses() {
    if (design_revision == "rework") {
        carrier_mount_x = [carrier_mount_edge_x,panel_inset()-carrier_mount_panel_edge_x];
        carrier_mount_y = [-carrier_mount_end_y,-longitud+carrier_mount_end_y];
        for (x=carrier_mount_x,y=carrier_mount_y)
            translate([x,y,ancho_pared])
                cylinder(d=carrier_mount_boss_diameter,h=carrier_mount_height,$fn=48);
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
        profile_arc_points(x_right_center,r,r,360+(90-a),270),
        [[0,0]],
        // The left profile corner is centred at x=0 (the right corner has its
        // own translated centre at x_right_center).
        profile_arc_points(0,r,r,270,180+(90-a)),
        [[x_left_tan,z_left_tan]]
    );
    polygon(points);
}

module inner_profile_2d() {
    // Exact cross-section boundaries measured from FreeCAD Thickness:
    // bottom radius is r-wall, sloping walls are offset normal to their faces,
    // and the inner edges meet the retained top rim at the original top height.
    r = radio_curvaturas;
    t = ancho_pared;
    a = angulo_del_panel;
    z_left_tan = r-r*sin(90-a);
    z_right_tan = r+r*sin(90-a);
    x_left_tan = -r*cos(90-a);
    x_top_left = x_left_tan-(alto-z_left_tan)/tan(a);
    x_top_right = x_top_left+profundidad;
    x_right_tan = x_top_right+(alto-z_right_tan)/tan(a);
    x_right_center = x_right_tan-r*cos(90-a);
    x_inner_top_left = x_top_left+t/sin(a);
    x_inner_top_right = x_top_right-t/sin(a);
    x_left_inner = x_left_tan+t*sin(a);
    z_left_inner = z_left_tan+t*cos(a);
    x_right_inner = x_right_tan-t*sin(a);
    z_right_inner = z_right_tan-t*cos(a);
    inner_radius = r-t;

    polygon(concat(
        [[x_inner_top_left,alto],
         [x_inner_top_right,alto],
         [x_right_inner,z_right_inner]],
        profile_arc_points(x_right_center,r,inner_radius,360+(90-a),270),
        [[0,t]],
        profile_arc_points(0,r,inner_radius,270,180+(90-a))));
}

module enclosure_shell() {
    // The top opening and its thin rim emerge from subtracting the measured
    // inner profile; a blanket top cut would remove material FreeCAD retains.
    rotate([90,0,0]) linear_extrude(height=longitud, convexity=10)
        difference() {
            rounded_profile_2d();
            inner_profile_2d();
        }
}

module end_closures() {
    // Closing skins at extrusion ends are retained separately from the open shell profile.
    for (y=[0,-longitud+ancho_pared])
        translate([0,y,0]) rotate([90,0,0]) linear_extrude(height=ancho_pared,convexity=5)
            rounded_profile_2d();
}

module support_wall_profiles() {
    // Native CSG transcription of Sketch006 and Sketch007. These are irregular
    // 12-edge walls; rectangular blocks create a false lower ledge in the case.
    a = angulo_del_panel;
    t = ancho_pared;
    r = support_profile_base_radius;
    // A 0.001 mm overlap at the shared inner-floor arc prevents a coincident
    // CSG face from surviving where the source additive pads meet the shell.
    csg_overlap = 0.001;
    support_radius = min(3.5,r-t)+csg_overlap;
    z_support_top = max(support_minimum_top,long_torres_tornillos);
    z_left_tan = r-support_radius*sin(90-a);
    z_right_tan = r+support_radius*sin(90-a);
    x_left_tan = -support_radius*cos(90-a);
    x_left_top = x_left_tan-(z_support_top-z_left_tan)/tan(a);
    z_shell_left = radio_curvaturas-radio_curvaturas*sin(90-a);
    z_shell_right = radio_curvaturas+radio_curvaturas*sin(90-a);
    x_shell_left = -radio_curvaturas*cos(90-a);
    x_shell_top_left = x_shell_left-(alto-z_shell_left)/tan(a);
    x_shell_top_right = x_shell_top_left+profundidad;
    x_shell_right_tan = x_shell_top_right+(alto-z_shell_right)/tan(a);
    x_right_center = x_shell_right_tan-radio_curvaturas*cos(90-a);
    x_right_tan = x_right_center+support_radius*cos(90-a);
    x_right_top = x_right_tan-(z_support_top-z_right_tan)/tan(a);
    support_right_x = panel_inset()-support_inner_offset;
    left_arc_start = 180+(90-a);
    right_arc_end = 360+(90-a);
    near_support_profile = concat(
        [[x_left_top,z_support_top],[support_inner_offset,z_support_top],
         [support_inner_offset,t],[support_right_x,t],
         [support_right_x,z_support_top],[x_right_top,z_support_top],
         [x_right_tan,z_right_tan]],
        profile_arc_points(x_right_center,r,support_radius,right_arc_end,270),
        [[x_right_center,0],[0,0],[0,t]],
        profile_arc_points(0,r,support_radius,270,left_arc_start),
        [[x_left_top,z_support_top]]);
    far_support_profile = concat(
        [[support_floor_left_x,z_support_top],[x_left_top,z_support_top],
         [x_left_tan,z_left_tan]],
        profile_arc_points(0,r,support_radius,left_arc_start,270),
        [[0,0],[x_right_center,0],[x_right_center,t]],
        profile_arc_points(x_right_center,r,support_radius,270,right_arc_end),
        [[x_right_top,z_support_top],[support_right_x,z_support_top],
         [support_right_x,t],[support_floor_left_x,t]]);

    // Source Sketch007 plane is offset by separation + two wall thicknesses.
    translate([0,-support_near_offset()+csg_overlap,0]) rotate([90,0,0]) linear_extrude(height=t+2*csg_overlap,convexity=5)
        polygon(near_support_profile);

    // Far support position is linked to the tower separation in the source sketch.
    translate([0,-longitud+2*separacion_torres_tornillos-t+csg_overlap,0])
        rotate([90,0,0]) linear_extrude(height=t+2*csg_overlap,convexity=5)
            polygon(far_support_profile);
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
    indicator_y = relay_indicator_end == "near" ? 0.1 : -longitud-0.1;
    indicator_rotation = relay_indicator_end == "near" ? 90 : -90;

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

    if (design_revision == "rework" && enable_relay_indicator_windows)
        for (x=[relay_indicator_center_x-relay_indicator_spacing/2,
                relay_indicator_center_x+relay_indicator_spacing/2])
            translate([x,indicator_y,relay_indicator_z])
                rotate([indicator_rotation,0,0])
                    linear_extrude(height=ancho_pared+0.4)
                        rounded_rectangle_2d(relay_indicator_width,
                                             relay_indicator_height,
                                             relay_indicator_corner_radius);
}

module tower_land_and_ribs(x,y) {
    h = long_torres_tornillos;
    t = ancho_pared;
    near = y > -longitud/2;

    union() {
        // Sketch003 uses an arc plus a chord where each tower meets the
        // side/end wall. The chord orientation differs by tower instance.
        radius = dia_torres_tornillos/2;
        chord = sqrt(max(0,radius*radius-(t/2)*(t/2)));
        intersection() {
            cylinder(d=dia_torres_tornillos,h=h,$fn=96);
            if (near && x < panel_inset()/2)
                translate([-chord,-radius-1,-0.1])
                    cube([radius+1+chord,2*radius+2,h+0.2]); // near-left: X-
            else if (near)
                translate([-radius-1,-radius-1,-0.1])
                    cube([2*radius+2,chord+radius+1,h+0.2]); // near-right: Y+
            else
                translate([-radius-1,-chord,-0.1])
                    cube([2*radius+2,radius+1+chord,h+0.2]); // far pair: Y-
        }

        // Sketch003 extends each cylindrical land to its nearest end wall
        // with a web as wide as the shell wall. The side walls intersect the
        // cylindrical land directly; there is no second cross-web.
        if (near)
            translate([-t/2,0,0]) cube([t,max(0,-y-t),h]);
        else
            translate([-t/2,-max(0,y+longitud-t),0])
                cube([t,max(0,y+longitud-t),h]);
    }
}

module screw_tower(x,y) {
    difference() {
        tower_land_and_ribs(x,y);
        translate([0,0,-0.1]) cylinder(d=dia_interno_torres_tornillos,h=long_torres_tornillos+0.2,$fn=48);
    }
}

module m3_case_tower(x,y) {
    if (design_revision == "baseline") screw_tower(x,y);
    else union() {
        tower_land_and_ribs(x,y);
        cylinder(d=m3_insert_boss_diameter,h=long_torres_tornillos,$fn=96);
    }
}

module case_body() {
    tower_edge_offset = separacion_torres_tornillos + dia_torres_tornillos/2;
    difference() {
        union() {
            enclosure_shell();
            end_closures();
            // Four screw lands and the webs from Sketch003.
            for (x=[tower_edge_offset,panel_inset()-tower_edge_offset], y=[-tower_edge_offset,-longitud+tower_edge_offset])
                translate([x,y,0]) m3_case_tower(x,y);
            support_wall_profiles();
            panel_retainer_bosses();
            carrier_mount_bosses();
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
    if (design_revision == "rework") {
        // The lip enters the opening when installed face-down. Its sides
        // follow the angled walls instead of wedging a vertical rectangle.
        rim_width = profundidad-2*(ancho_pared+lid_rim_clearance)/sin(angulo_del_panel);
        rim_length = longitud-2*(ancho_pared+lid_rim_clearance);
        multmatrix([[1,0,1/tan(angulo_del_panel),-ancho_pared/tan(angulo_del_panel)],
                    [0,1,0,0],[0,0,1,0],[0,0,0,1]])
            translate([-rim_width/2,-rim_length/2,ancho_pared])
                cube([rim_width,rim_length,ancho_pared]);
    } else {
    // Sketch009 retains a solver-selected extension for the 1.2 mm boundary case.
    rim_length = longitud + (ancho_pared < 1.5 ? 2*ancho_pared : -2*ancho_pared);
    translate([-(profundidad-2*ancho_pared)/2,-rim_length/2,ancho_pared])
        cube([profundidad-2*ancho_pared,rim_length,ancho_pared]);
    }
}

module lid_end_tabs() {
    for (y=[-longitud/2-8,longitud/2+8])
        translate([-8,y-8,0]) cube([16,16,ancho_pared]);
}

module lid_fastener_holes() {
    // Four panel holes pierce the 3 mm raised panel; tab holes pierce the 1.5 mm base only.
    lid_hole_d = design_revision == "baseline" ? 4 : m3_lid_clearance_diameter;
    tower_edge = separacion_torres_tornillos+dia_torres_tornillos/2;
    // Preserve the FreeCAD coordinates in baseline mode. Rework mode positions
    // the holes over the case towers after centering the lid on the top opening.
    lid_left_hole_x = design_revision == "baseline"
        ? -profundidad/2+tower_edge
        : tower_edge-case_top_center_x();
    lid_right_hole_x = design_revision == "baseline"
        ? panel_inset()-tower_edge-alto
        : panel_inset()-tower_edge-case_top_center_x();
    lid_panel_hole_y = longitud/2-tower_edge;
    for (x=[lid_left_hole_x,lid_right_hole_x],y=[-lid_panel_hole_y,lid_panel_hole_y])
        translate([x,y,-0.1]) cylinder(d=lid_hole_d,h=2*ancho_pared+0.2,$fn=96);
    for (y=[-longitud/2-8,longitud/2+8])
        translate([0,y,-0.1]) cylinder(d=lid_hole_d,h=ancho_pared+0.2,$fn=96);
}

module case_lid() {
    difference() {
        union() { lid_plate(); lid_rim(); lid_end_tabs(); }
        lid_fastener_holes();
    }
}

module control_carrier_slice(control,plate_z) {
    projection(cut=false) intersection() {
        union() {
            if (control == "encoder") encoder_retainer_installed();
            else oled_retainer_installed();
            panel_retainer_bosses(control);
            retainer_screw_head_keepouts(control);
        }
        translate([-profundidad,-longitud,plate_z-0.1])
            cube([3*profundidad,longitud,carrier_thickness+0.2]);
    }
}

module retainer_screw_head_keepouts(control) {
    is_oled = control == "oled";
    center_x = is_oled ? display_center_x() : encoder_center_x();
    center_y = is_oled ? display_center_y() : altura_botones;
    screw_x = is_oled ? oled_pcb_width/2+oled_retainer_fastener_offset
                      : encoder_body_width/2+encoder_retainer_fastener_offset;
    plate_t = is_oled ? oled_retainer_thickness : encoder_retainer_thickness;
    panel_coordinate_frame()
        for (x=[center_x-screw_x,center_x+screw_x])
            translate([x,center_y,-(ancho_pared+control_boss_depth+plate_t+m3_screw_head_height)])
                cylinder(d=m3_screw_head_diameter,h=m3_screw_head_height,$fn=64);
}

module electronics_carrier() {
    plate_z = ancho_pared+carrier_mount_height;
    mount_x = [carrier_mount_edge_x,panel_inset()-carrier_mount_panel_edge_x];
    mount_y = [-carrier_mount_end_y,-longitud+carrier_mount_end_y];
    carrier_x = (panel_inset())/2;
    difference() {
        translate([carrier_x-carrier_width/2,-longitud/2-carrier_length/2,plate_z])
            cube([carrier_width,carrier_length,carrier_thickness]);
        for (x=mount_x,y=mount_y)
            translate([x,y,plate_z-0.1])
                cylinder(d=m3_lid_clearance_diameter,h=carrier_thickness+0.2,$fn=48);
        for (x=[carrier_x-carrier_width/2+carrier_grid_pitch:
                carrier_grid_pitch:carrier_x+carrier_width/2-carrier_grid_pitch],
             y=[-longitud/2-carrier_length/2+carrier_grid_pitch:
                carrier_grid_pitch:-longitud/2+carrier_length/2-carrier_grid_pitch])
            translate([x,y,plate_z-0.1])
                cylinder(d=carrier_grid_hole_diameter,h=carrier_thickness+0.2,$fn=32);
        // Each swept relief opens to the panel-side edge. A closed ring cut
        // would leave a disconnected island of carrier inside the retainer.
        for (control=["oled","encoder"])
        translate([0,0,plate_z-0.1])
            linear_extrude(height=carrier_thickness+0.2)
                offset(delta=carrier_encoder_clearance)
                    hull() {
                        control_carrier_slice(control,plate_z);
                        translate([profundidad,0]) control_carrier_slice(control,plate_z);
                    }
    }
}

module electronics_carrier_installed() {
    if (design_revision == "rework") electronics_carrier();
}

module button_cap() {
    socket_depth = min(button_cap_socket_depth,button_cap_height-button_cap_roof);
    difference() {
        cylinder(d=button_cap_diameter,h=button_cap_height,$fn=64);
        translate([0,0,-0.01])
            cylinder(d=button_cap_socket_diameter+2*button_cap_socket_clearance,
                     h=socket_depth+0.01,$fn=48);
    }
}

module service_retainer_frame(outer_w,outer_h,inner_w,inner_h,thickness,
                              screw_x,spacer_h,notch_edge,notch_width,notch_depth,
                              support_w,support_h) {
    total_h = thickness+spacer_h;
    difference() {
        union() {
            // Rear screw plate seats against the rear faces of the case bosses.
            linear_extrude(height=thickness)
                square([outer_w,outer_h],center=true);
            // PCB support extends toward the panel, beside the bosses instead
            // of occupying their screw axes. The front edge contacts the PCB.
            translate([0,0,thickness])
                linear_extrude(height=spacer_h)
                    square([support_w,support_h],center=true);
        }
        difference() {
            translate([0,0,-0.01])
                linear_extrude(height=total_h+0.02)
                    square([inner_w,inner_h],center=true);
            // Keep a brace in the rear plate. A through header notch and an
            // open lower lip otherwise separate the OLED retainer into halves.
            linear_extrude(height=thickness)
                if (notch_edge == "top" || notch_edge == "bottom")
                    square([outer_w,retainer_bridge_width],center=true);
                else square([retainer_bridge_width,outer_h],center=true);
        }
        // Screw heads remain outside the thin rear plate, with no blind recess.
        for (x=[-screw_x,screw_x])
            translate([x,0,-0.01])
                cylinder(d=m3_lid_clearance_diameter,h=total_h+0.02,$fn=48);
        if (notch_edge == "top")
            translate([-notch_width/2,support_h/2-notch_depth,-0.01])
                cube([notch_width,(outer_h-support_h)/2+notch_depth+0.02,total_h+0.02]);
        if (notch_edge == "bottom")
            translate([-notch_width/2,-outer_h/2-0.01,-0.01])
                cube([notch_width,(outer_h-support_h)/2+notch_depth+0.02,total_h+0.02]);
        if (notch_edge == "left")
            translate([-outer_w/2-0.01,-notch_width/2,-0.01])
                cube([(outer_w-support_w)/2+notch_depth+0.02,notch_width,total_h+0.02]);
        if (notch_edge == "right")
            translate([support_w/2-notch_depth,-notch_width/2,-0.01])
                cube([(outer_w-support_w)/2+notch_depth+0.02,notch_width,total_h+0.02]);
    }
}

module retainer_shell_envelope(panel_x,panel_y,plate_base) {
    // Express the inset shell cavity in print coordinates. This opens the
    // OLED's lower lip around the curved floor without cutting the shell.
    translate([-panel_x,-panel_y,-plate_base])
        inverse_panel_coordinate_frame()
            translate([0,-ancho_pared-retainer_floor_clearance,0])
                rotate([90,0,0])
                    linear_extrude(height=longitud-2*(ancho_pared+retainer_floor_clearance))
                        offset(delta=-retainer_floor_clearance) inner_profile_2d();
}

function oled_retainer_outer_width() =
    oled_pcb_width+2*(oled_retainer_fastener_offset+m3_insert_boss_diameter/2);
function oled_retainer_outer_height() = oled_pcb_height;
function oled_retainer_spacer_height() =
    max(0,control_boss_depth+ancho_pared-(oled_front_skin+oled_module_depth));
function encoder_retainer_outer_width() =
    encoder_body_width+2*(encoder_retainer_fastener_offset+m3_insert_boss_diameter/2);
function encoder_retainer_outer_height() =
    encoder_body_height+2*(encoder_retainer_fastener_offset+m3_insert_boss_diameter/2);
function encoder_retainer_spacer_height() =
    max(0,control_boss_depth+ancho_pared-(encoder_front_skin+encoder_body_depth));

module oled_retainer_frame() {
    intersection() {
    service_retainer_frame(
        oled_retainer_outer_width(),oled_retainer_outer_height(),
        oled_pcb_width-2*oled_retainer_overlap,
        oled_pcb_height-2*oled_retainer_overlap,
        oled_retainer_thickness,
        oled_pcb_width/2+oled_retainer_fastener_offset,
        oled_retainer_spacer_height(),
        oled_header_edge,oled_header_notch_width,oled_header_notch_depth,
        oled_pcb_width,oled_pcb_height);
    retainer_shell_envelope(display_center_x(),display_center_y(),
        -(ancho_pared+control_boss_depth+oled_retainer_thickness));
    }
}

module encoder_retainer_frame() {
    intersection() {
    service_retainer_frame(
        encoder_retainer_outer_width(),encoder_retainer_outer_height(),
        encoder_body_width-2*encoder_retainer_overlap,
        encoder_body_height-2*encoder_retainer_overlap,
        encoder_retainer_thickness,
        encoder_body_width/2+encoder_retainer_fastener_offset,
        encoder_retainer_spacer_height(),
        encoder_terminal_edge,encoder_terminal_notch_width,encoder_terminal_notch_depth,
        encoder_body_width,encoder_body_height);
    retainer_shell_envelope(encoder_center_x(),altura_botones,
        -(ancho_pared+control_boss_depth+encoder_retainer_thickness));
    }
}

module oled_retainer_installed() {
    if (design_revision == "rework") panel_coordinate_frame()
        translate([display_center_x(),display_center_y(),
                   -(ancho_pared+control_boss_depth+oled_retainer_thickness)])
            oled_retainer_frame();
}

module encoder_retainer_installed() {
    if (design_revision == "rework") panel_coordinate_frame()
        translate([encoder_center_x(),altura_botones,
                   -(ancho_pared+control_boss_depth+encoder_retainer_thickness)])
            encoder_retainer_frame();
}

module case_lid_installed() {
    if (design_revision == "rework")
        translate([case_top_center_x(),-longitud/2,
                   alto+ancho_pared+(show_exploded ? explode_gap : 0)])
            rotate([180,0,0]) case_lid();
    else translate([case_top_center_x(),-longitud/2,
                    show_exploded ? alto+explode_gap : alto]) case_lid();
}

module assembly() {
    case_body();
    case_lid_installed();
    if (design_revision == "rework") {
        oled_retainer_installed();
        encoder_retainer_installed();
        electronics_carrier_installed();
    }
}

if (show_part == "case") case_body();
else if (show_part == "lid") case_lid();
else if (show_part == "oled_retainer") oled_retainer_frame();
else if (show_part == "encoder_retainer") encoder_retainer_frame();
else if (show_part == "electronics_carrier") electronics_carrier();
else if (show_part == "button_cap") button_cap();
else if (show_part == "none") { }
else assembly();
