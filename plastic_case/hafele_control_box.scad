/* Häfele standing desk control box and lid.
 * Editable native OpenSCAD CSG from extracted FreeCAD geometry and measured hardware.
 * Units are millimetres. See README_OpenSCAD.md for source and measured limits.
 */

/* [Design revision] */
design_revision = "rework"; // [baseline:FreeCAD reconstruction,rework:hardware-retention revision]
include <lib/combined_controls.scad>;
include <lib/measured_ports.scad>;
use <lib/rounded_mount_tabs.scad>;
use <lib/captive_cancel_button.scad>;

/* [Assembly] */
show_part = "assembly"; // [case,lid,assembly,controls_bracket,electronics_carrier,proto_clamp,supply_clamp,button_cap,hardware_preview]
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

/* [Measured controls: 2026-10-26] */
rework_display_window_width = 27;
rework_display_window_height = 14.5;
oled_pcb_width = 27.5;
oled_pcb_height = 28;
oled_pcb_clearance = 0.3; // Per side; calibrate with the OLED coupon.
oled_front_skin = 0.8; // Material left behind the front mask around the window.
oled_module_depth = 3.5;
oled_dupont_depth = 15; // Normal to the PCB, excludes cable bend.
connector_wire_bend = 5; // Added routing allowance, not a measured component dimension.
oled_retainer_overlap = 1.2; // Retainer lip over the PCB perimeter.
oled_header_edge = "top"; // [top,bottom,left,right]
oled_header_notch_width = 14;
oled_header_notch_depth = 5;
oled_window_offset_x = 0; // Adjustable alignment of module glass to source-derived window.
oled_window_offset_y = -1; // Derived from reported 9 mm lower / 7 mm upper viewing margins.

/* [Encoder cradle and retainer: EC11-family candidate] */
encoder_body_width = 12.5;
encoder_body_height = 11.7;
encoder_body_depth = 7.5;
encoder_body_clearance = 0.25; // Per side; calibrate with the encoder coupon.
encoder_front_skin = ancho_pared;
encoder_shaft_diameter = 6.0;
encoder_shaft_clearance = 0.35; // Radial clearance.
encoder_pcb_width = 26;
encoder_pcb_height = 18.5;
encoder_axis_from_left = 10.5; // Non-connector end of the 26 mm direction.
encoder_axis_from_bottom = 8; // User approximation; opposite side is about 10 mm.
encoder_internal_depth = 8; // Inner case face to deepest solder tip, measured.
encoder_solder_relief = 1.8; // Measured: flat PCB at 6.2 mm, deepest tip at 8 mm.
encoder_dupont_extension = 11.5; // Right-angle connector, along the long PCB direction.

/* [Low-profile cancel switch and captive cap] */
cancel_switch_width = 12;
cancel_switch_height = 12;
cancel_switch_total_depth = 5; // Body bottom to unpressed actuator tip, measured.
cancel_switch_body_depth = 3.3; // Unmeasured body-only height; adjustable.
cancel_cap_diameter = 13;
cancel_flange_diameter = 16.5;
cancel_radial_gap = 0.3;
cancel_axial_gap = 0.3;
cancel_flange_thickness = 1.8;
cancel_press_travel = 0.65; // Physical coupon must verify actuation and permitted overtravel.
cancel_cap_projection = 1.3;
cancel_stem_diameter = 4.5;
cancel_stem_length = 2.6;
cancel_guide_wall = 1.6;
cancel_guide_back = 1.5;
cancel_stem_hole = 8;
cancel_break_width = 0.4;
cancel_break_height = 0.2;
cancel_state = "as_printed"; // [as_printed,released,pressed]

/* [Combined controls bracket: upright base screws] */
controls_screw_length = 15;
controls_insert_engagement = 4.5;
controls_boss_diameter = 10;
controls_boss_floor = 1;
controls_frame_wall = 2;
controls_frame_thickness = 2.4;
retainer_floor_clearance = 0.35;
controls_rail_x = 43;
controls_rail_width = 8;
controls_rail_height = 6;
driver_access_diameter = 8;
iron_access_diameter = 12;

/* [Measured electronics: two assemblies] */
electronics_rear_extension = 25; // Includes full OLED Dupont + 5 mm wire bend; front/desk holes fixed.
proto_length = 100;
proto_width = 50;
proto_total_height = 21;
supply_length = 54;
supply_width = 24;
supply_total_height = 17;
board_floor_clearance = 2;
board_solder_height = 3; // Adjustable underside allowance, not separately measured.
board_pcb_thickness = 1.6;
board_edge_clearance = 0.3;
board_clamp_screw_length = 15;
usb_above_assembly_bottom = 18; // Approximate user datum; treated as socket lower edge.
usb_socket_height = 3.5;

/* [Desk mounting: original fixed Parker centers] */
wood_mount_spacing = 166;
wood_mount_head_diameter = 7;
wood_mount_hole_diameter = 4; // Adjustable through-clearance, thread size unspecified.
wood_mount_screw_length = 15;
wood_mount_tab_thickness = 5;
wood_mount_root_width = 24;
wood_mount_root_embed = 12;
wood_mount_clearance = 0.3;
lid_screw_length = 15;

/* [Measured molded cable boot] */
boot_neck_width = 8.5;
boot_neck_height = 10.5;
boot_wall_thickness = 2.5;
boot_fit_clearance = 0.2;
boot_from_near_end = 26;

/* [M3 heat-set insert mounting] */
m3_insert_boss_diameter = 10; // Closure barrels; Ø7.2 tool wells leave 1.4 mm wall.
m3_insert_pilot_diameter = 4.0; // Candidate only; tune to the actual insert and printed coupon.
m3_insert_length = 5.7;
m3_insert_bottom_clearance = 1.0;
m3_insert_leadin = 0.4;
m3_lid_clearance_diameter = 3.4;
m3_screw_head_diameter = 6.2;

/* [Rear-wall access] */
enable_motor_cable_exit = true;
enable_usb_access = true;
usb_access_width = 14;
usb_access_height = 10;
usb_access_corner_radius = 1.5;
usb_proto_offset_y = 15; // Layout inference along proto PCB, adjustable after connector check.
boot_wall_clearance = 0.1;
boot_pad_margin = 5;
boot_rear_flange_margin = 2.5; // Flange margin unmeasured; verify with actual molded boot.

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

/* [Lid] */
espesor_tapa = 1.5; // Preserved spreadsheet parameter; no final feature references it.
lid_rim_clearance = 0.25; // Normal clearance for the rework locating lip inside the shell.

/* [Display selection] */
// Spreadsheet aliases kept verbatim for compatibility with the FreeCAD parameter names.
// The old label pos_y_botones maps to alias altura_botones; pos_x_botones maps to x=75.

function rear_extension() = design_revision == "rework" ? electronics_rear_extension : 0;
function case_top_span() = profundidad+rear_extension();
function panel_inset() = profundidad - alto / tan(angulo_del_panel);
function source_top_center_x() =
    -radio_curvaturas*cos(90-angulo_del_panel)
    -(alto-(radio_curvaturas-radio_curvaturas*sin(90-angulo_del_panel)))
      /tan(angulo_del_panel)+profundidad/2;
function case_top_center_x() = source_top_center_x()-rear_extension()/2;
function window_width() = design_revision == "rework" ? rework_display_window_width : ancho_display;
function window_height() = design_revision == "rework" ? rework_display_window_height : alto_display;
function support_near_offset() = separacion_torres_tornillos + 2*ancho_pared;
function display_panel_x() = -longitud + pos_display_x;
function display_panel_y() = pos_display_y - alto + window_height();
function display_center_x() = display_panel_x() + window_width()/2 + oled_window_offset_x;
function display_center_y() = display_panel_y() + window_height()/2 + oled_window_offset_y;
function pushbutton_center_x() = -longitud + pos_x_botones;
function encoder_center_x() = -longitud + pos_x_botones + distancia_botones;
function panel_plane_constant() =
    source_top_center_x()+profundidad/2+alto/tan(angulo_del_panel);
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
    if (design_revision=="rework") {
        controls_floor_bores();
        board_insert_bores();
        for (x=lid_tower_xs(), y=[-source_tower_edge(),-longitud+source_tower_edge()])
            translate([x,y,0]) {
                translate([0,0,-0.1]) cylinder(d=m3_lid_clearance_diameter,h=closure_joint_z()+0.2,$fn=64);
                translate([0,0,-0.1]) cylinder(d=m3_screw_head_diameter+1.2,h=closure_head_z()+0.1,$fn=64);
                translate([0,0,closure_head_z()])
                    cylinder(d1=m3_screw_head_diameter,d2=m3_lid_clearance_diameter,
                             h=(m3_screw_head_diameter-m3_lid_clearance_diameter)/2,$fn=64);
            }
    }
}

module rounded_profile_2d() {
    // Coordinates follow Sketch Perfil_Lateral and its tangent constraints.
    r = radio_curvaturas;
    a = angulo_del_panel;
    z_left_tan = r - r*sin(90-a);
    z_right_tan = r + r*sin(90-a);
    back=-rear_extension();
    x_left_tan = back-r*cos(90-a);
    x_top_left = x_left_tan - (alto-z_left_tan)/tan(a);
    x_top_right = x_top_left + case_top_span();
    x_right_tan = x_top_right + (alto-z_right_tan)/tan(a);
    x_right_center = x_right_tan - r*cos(90-a);
    points = concat(
        [[x_top_left,alto],[x_top_right,alto],[x_right_tan,z_right_tan]],
        profile_arc_points(x_right_center,r,r,360+(90-a),270),
        [[back,0]],
        // The left profile corner is centred at x=0 (the right corner has its
        // own translated centre at x_right_center).
        profile_arc_points(back,r,r,270,180+(90-a)),
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
    back=-rear_extension();
    x_left_tan = back-r*cos(90-a);
    x_top_left = x_left_tan-(alto-z_left_tan)/tan(a);
    x_top_right = x_top_left+case_top_span();
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
        [[back,t]],
        profile_arc_points(back,r,inner_radius,270,180+(90-a))));
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
            cube([window_width(),window_height(),16]);
        translate([pushbutton_center_x(),altura_botones,-8])
            cylinder(d=design_revision=="baseline" ? dia_botones : cancel_cap_diameter+2*cancel_radial_gap,h=16,$fn=96);
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
    if (design_revision=="rework") measured_port_cutouts();
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
    if (design_revision=="baseline") screw_tower(x,y);
    else intersection() {
        union() {
            cylinder(d=m3_insert_boss_diameter,h=closure_joint_z(),$fn=96);
            near=y>-longitud/2;
            if (near) translate([-1.2,0,0]) cube([2.4,-y-ancho_pared+0.02,closure_joint_z()]);
            else translate([-1.2,-(y+longitud-ancho_pared+0.02),0])
                cube([2.4,y+longitud-ancho_pared+0.02,closure_joint_z()]);
        }
        translate([-x,-y,0]) outer_case_volume(0.001);
    }
}

module outer_case_volume(inset=0) {
    translate([0,-inset,0]) rotate([90,0,0]) linear_extrude(height=longitud-2*inset)
        offset(delta=-inset) rounded_profile_2d();
}

module lid_to_world(exploded=false) {
    translate([case_top_center_x(),-longitud/2,
               alto+ancho_pared+(exploded ? explode_gap : 0)])
        rotate([180,0,0]) children();
}

module cancel_button_fixed() {
    panel_coordinate_frame() translate([pushbutton_center_x(),altura_botones,0]) {
        captive_cancel_guide(ancho_pared,cancel_cap_diameter,cancel_flange_diameter,
            cancel_radial_gap,cancel_axial_gap,cancel_flange_thickness,cancel_press_travel,
            cancel_guide_wall,cancel_guide_back,cancel_stem_hole);
        captive_cancel_break_tabs(ancho_pared,cancel_cap_diameter,cancel_radial_gap,
            cancel_break_width,cancel_break_height,cancel_state=="as_printed");
    }
}

module cancel_button_moving() {
    panel_coordinate_frame() translate([pushbutton_center_x(),altura_botones,0])
        captive_cancel_cap(ancho_pared,cancel_cap_diameter,cancel_flange_diameter,
            cancel_axial_gap,cancel_flange_thickness,cancel_cap_projection,
            cancel_stem_diameter,cancel_stem_length,cancel_state=="pressed" ? cancel_press_travel : 0);
}

module case_body() {
    difference() {
        union() {
            enclosure_shell();
            end_closures();
            for (x=lid_tower_xs(), y=[-source_tower_edge(),-longitud+source_tower_edge()])
                translate([x,y,0]) m3_case_tower(x,y);
            if (design_revision=="baseline") support_wall_profiles();
            else {
                controls_floor_bosses();
                control_locating_rails();
                board_supports();
                measured_ports_positive();
            }
        }
        display_and_button_openings();
        rework_panel_pockets();
        external_access_cutouts();
        case_m3_insert_cutouts();
        if (design_revision=="rework") lid_to_world()
            translate([wood_local_x(),0,0])
                tab_root_relief(longitud,wood_mount_spacing,wood_mount_root_width,wood_mount_root_embed,
                                thickness=wood_mount_tab_thickness,assembly_clearance=wood_mount_clearance);
    }
    if (design_revision=="rework") { cancel_button_fixed(); cancel_button_moving(); }
}

module lid_plate() {
    // FreeCAD lid pad: 70 x 150 x 1.5, centred on XY.
    translate([-case_top_span()/2,-longitud/2,0]) cube([case_top_span(),longitud,ancho_pared]);
}

module lid_rim() {
    if (design_revision == "rework") {
        // The lip enters the opening when installed face-down. Its sides
        // follow the angled walls instead of wedging a vertical rectangle.
        rim_width = case_top_span()-2*(ancho_pared+lid_rim_clearance)/sin(angulo_del_panel);
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
    if (design_revision=="rework") translate([wood_local_x(),0,0])
        rounded_mount_tabs(longitud,wood_mount_spacing,wood_mount_root_width,wood_mount_root_embed,
                           thickness=wood_mount_tab_thickness);
    else
    for (y=[-longitud/2-8,longitud/2+8])
        translate([-8,y-8,0]) cube([16,16,ancho_pared]);
}

module lid_fastener_holes() {
    if (design_revision=="rework") {
        translate([wood_local_x(),0,0])
            wood_mount_hole_cutouts(wood_mount_spacing,wood_mount_tab_thickness,
                wood_mount_hole_diameter,wood_mount_head_diameter);
        for (x=lid_tower_xs(), y=[-longitud/2+source_tower_edge(),longitud/2-source_tower_edge()])
            translate([x-case_top_center_x(),y,0]) {
                depth=max(m3_insert_length+m3_insert_bottom_clearance,
                    closure_wood_z()-3-closure_joint_z()+0.5);
                m3_insert_bore(11-depth,depth);
            }
    } else {
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
}

module world_to_lid() {
    rotate([180,0,0]) translate([-case_top_center_x(),longitud/2,-closure_wood_z()]) children();
}

module lid_closure_bosses() {
    intersection() {
        for (x=lid_tower_xs(),y=[-longitud/2+source_tower_edge(),longitud/2-source_tower_edge()])
            translate([x-case_top_center_x(),y,0]) cylinder(d=m3_insert_boss_diameter,h=11,$fn=96);
        world_to_lid() shell_cavity(lid_rim_clearance+0.1);
    }
}

module case_lid() {
    difference() {
        union() { lid_plate(); lid_rim(); lid_end_tabs();
            if (design_revision=="rework") lid_closure_bosses(); }
        lid_fastener_holes();
        if (design_revision=="rework") world_to_lid() boot_lid_relief();
    }
}

module button_cap() {
    translate([0,0,ancho_pared+cancel_axial_gap+cancel_flange_thickness+cancel_stem_length])
        captive_cancel_cap(ancho_pared,cancel_cap_diameter,cancel_flange_diameter,
            cancel_axial_gap,cancel_flange_thickness,cancel_cap_projection,cancel_stem_diameter,cancel_stem_length);
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
    if (design_revision=="rework") {
        controls_bracket();
        board_clamp(0);
        board_clamp(1);
    }
}

if (show_part == "case") case_body();
else if (show_part == "lid") case_lid();
else if (show_part == "controls_bracket") controls_bracket();
else if (show_part == "proto_clamp") board_clamp(0);
else if (show_part == "supply_clamp") board_clamp(1);
else if (show_part == "button_cap") button_cap();
else if (show_part == "hardware_preview") { assembly(); %electronics_envelopes(); %control_connector_envelopes(); }
else if (show_part == "none") { }
else assembly();
