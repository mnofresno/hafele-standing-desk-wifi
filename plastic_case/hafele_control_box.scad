/* Häfele standing desk control box and lid.
 * Reconstructed as editable OpenSCAD CSG from the fully constrained FreeCAD sketches.
 * Units are millimetres. See README_OpenSCAD.md for source and measured limits.
 */

/* [Assembly] */
show_part = "assembly"; // [case:Case,lid:Lid,assembly:Case and lid]
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
    // Exact Sketch001 coordinates transformed from its attached panel plane.
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
                [0,0,0,1]]) {
        translate([-longitud+pos_display_x,
                   pos_display_y-alto+alto_display,-8])
            cube([ancho_display,alto_display,16]);
        for (x=[-pos_x_botones,-pos_x_botones+distancia_botones])
            translate([x,altura_botones,-8]) cylinder(d=dia_botones,h=16,$fn=96);
    }
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
                translate([x,y,ancho_pared]) screw_tower(x,y);
            support_wall_profiles();
        }
        display_and_button_openings();
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
    for (x=[-25.5,16.1217782649],y=[-65.5,65.5])
        translate([x,y,-0.1]) cylinder(d=4,h=2*ancho_pared+0.2,$fn=96);
    for (y=[-83,83])
        translate([0,y,-0.1]) cylinder(d=4,h=ancho_pared+0.2,$fn=96);
}

module case_lid() {
    difference() {
        union() { lid_plate(); lid_rim(); lid_end_tabs(); }
        lid_fastener_holes();
    }
}

module assembly() {
    case_body();
    translate([0,0,show_exploded ? alto+explode_gap : alto]) case_lid();
}

if (show_part == "case") case_body();
else if (show_part == "lid") case_lid();
else assembly();
