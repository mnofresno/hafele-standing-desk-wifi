/* Host: hafele_control_box.scad. Native common bracket and measured-board mounts.
 * All placements use the same front-panel frame as the FreeCAD reconstruction.
 */
function panel_point(u,v,w) =
    let(s=cos(angulo_del_panel),c=sin(angulo_del_panel),ox=panel_plane_constant()*c*c)
    [ox-s*v+c*w,u,panel_origin_z()+c*v+s*w];
// Rotate the module 180° in its own plane: header points toward the button,
// avoiding the near-end lid pillar. The shaft/hole position stays unchanged.
function encoder_board_x() = encoder_center_x()-(encoder_pcb_width/2-encoder_axis_from_left);
function encoder_board_y() = altura_botones-(encoder_pcb_height/2-encoder_axis_from_bottom);
function encoder_board_depth() = ancho_pared+encoder_internal_depth-encoder_solder_relief;
function cancel_tip_depth() = ancho_pared+cancel_axial_gap+cancel_flange_thickness+cancel_stem_length;
function cancel_switch_back() = cancel_tip_depth()+0.1+cancel_switch_total_depth;
function controls_seat_z() = ancho_pared+m3_insert_length+m3_insert_bottom_clearance+controls_boss_floor;
function controls_grip() = controls_screw_length-min(controls_insert_engagement,m3_insert_length-0.5);
function controls_head_z() = controls_seat_z()+controls_grip();
function controls_mounts() = [[controls_rail_x,display_center_x()-16],
    [controls_rail_x-4,pushbutton_center_x()],[controls_rail_x,encoder_center_x()+15]];
function source_tower_edge() = separacion_torres_tornillos+dia_torres_tornillos/2;
function lid_tower_xs() = [design_revision=="rework" ? -rear_extension()-3 : source_tower_edge(),
                         panel_inset()-source_tower_edge()];
function wood_local_x() = source_top_center_x()-case_top_center_x();
function closure_wood_z() = alto+ancho_pared;
function closure_joint_z() = closure_wood_z()-11;
function closure_head_z() = closure_wood_z()-3-lid_screw_length;
function board_left_x() = -rear_extension()+3;
function proto_y0() = -longitud+38;
function supply_y0() = proto_y0()-supply_width-1;
function board_insert_seat_z() = ancho_pared+m3_insert_length+m3_insert_bottom_clearance+1.5;
function board_pcb_z() = board_insert_seat_z()+1;
function board_lowest_z() = board_pcb_z()-board_solder_height;
function board_top_z() = board_pcb_z()+board_pcb_thickness;
function board_clamp_grip() = board_clamp_screw_length-min(controls_insert_engagement,m3_insert_length-0.5);
function board_mounts() = [[board_left_x()+proto_width+4.2,proto_y0()+proto_length/2],
    [board_left_x()+supply_length/2,supply_y0()-4.2]];

module vertical_countersink(z_top,diameter=m3_lid_clearance_diameter,head=m3_screw_head_diameter) {
    h=(head-diameter)/2;
    translate([0,0,z_top-h]) cylinder(d1=diameter,d2=head+0.04,h=h+0.02,$fn=64);
}

module shell_cavity(clearance=0) {
    translate([0,-ancho_pared-clearance,0]) rotate([90,0,0])
        linear_extrude(height=longitud-2*(ancho_pared+clearance))
            offset(delta=-clearance) inner_profile_2d();
}

module controls_floor_bosses() {
    for (p=controls_mounts()) translate([p[0],p[1],ancho_pared])
        cylinder(d=controls_boss_diameter,h=controls_seat_z()-ancho_pared,$fn=64);
}

module controls_floor_bores() {
    for (p=controls_mounts()) translate([p[0],p[1],0])
        m3_insert_bore(controls_seat_z()-m3_insert_length-m3_insert_bottom_clearance,
                       m3_insert_length+m3_insert_bottom_clearance);
}

module control_locating_rails() {
    // Locate boards while the common rear bracket is lowered into place.
    // These guides stop at the PCB's front surface; they do not squeeze glass.
    panel_coordinate_frame() {
        d=oled_front_skin+oled_module_depth-board_pcb_thickness;
        for (side=[-1,1],sy=[-1,1])
            translate([display_center_x()+side*(oled_pcb_width/2+oled_pcb_clearance)
                       +(side<0 ? -1.6 : 0),display_center_y()+sy*(oled_pcb_height/2-5)-2,-d])
                cube([1.6,4,d-ancho_pared+0.02]);
        ed=encoder_board_depth()-board_pcb_thickness;
        for (sy=[-1,1])
            translate([encoder_board_x()+encoder_pcb_width/2+encoder_body_clearance,
                       encoder_board_y()+sy*(encoder_pcb_height/2-3)-2,-ed])
                cube([1.6,4,ed-ancho_pared+0.02]);
        for (sy=[-1,1])
            translate([encoder_board_x()+encoder_pcb_width/2-6,
                       encoder_board_y()+sy*(encoder_pcb_height/2+encoder_body_clearance)
                       +(sy<0 ? -1.6 : 0),-ed])
                cube([4,1.6,ed-ancho_pared+0.02]);
    }
}

module contact_ring(cx,cy,w,h,depth,notch="top",notch_w=14,notch_depth=4) {
    panel_coordinate_frame() translate([cx,cy,-depth-controls_frame_thickness])
        difference() {
            linear_extrude(height=controls_frame_thickness)
                difference() {
                    square([w,h],center=true);
                    square([w-2*oled_retainer_overlap,h-2*oled_retainer_overlap],center=true);
                }
            if (notch=="top") translate([-notch_w/2,h/2-notch_depth,-0.01])
                cube([notch_w,notch_depth+0.1,controls_frame_thickness+0.02]);
            if (notch=="right") translate([w/2-notch_depth,-notch_w/2,-0.01])
                cube([notch_depth+0.1,notch_w,controls_frame_thickness+0.02]);
            if (notch=="left") translate([-w/2-0.1,-notch_w/2,-0.01])
                cube([notch_depth+0.1,notch_w,controls_frame_thickness+0.02]);
        }
}

module rounded_strut(a,b,r=1.8) {
    hull() { translate(a) sphere(r=r,$fn=24); translate(b) sphere(r=r,$fn=24); }
}

module ring_arms(cx,cy,w,depth) {
    for (side=[-1,1]) {
        u=cx+side*(w/2-oled_retainer_overlap/2);
        p=panel_point(u,cy,-depth-controls_frame_thickness);
        rounded_strut([controls_rail_x,u,controls_head_z()-controls_rail_height/2],p);
    }
}

module cancel_switch_cradle() {
    d=cancel_switch_back();
    panel_coordinate_frame() translate([pushbutton_center_x(),altura_botones,-d]) {
        // Central support leaves the two terminal rows and soldered wires open.
        translate([-cancel_switch_width/2,-4,-controls_frame_thickness])
            cube([cancel_switch_width,8,controls_frame_thickness]);
        for (side=[-1,1]) {
            translate([side>0 ? cancel_switch_width/2+0.3 : -cancel_switch_width/2-2.1,-4,-controls_frame_thickness])
                cube([1.8,8,controls_frame_thickness+cancel_switch_body_depth]);
            // Small locating hooks; body-only height remains adjustable.
            translate([side>0 ? cancel_switch_width/2-0.2 : -cancel_switch_width/2-0.9,-3.5,
                       cancel_switch_body_depth-0.5]) cube([1.1,7,0.5]);
        }
    }
    ring_arms(pushbutton_center_x(),altura_botones,cancel_switch_width,cancel_switch_back());
}

module controls_bracket_raw() {
    mounts=controls_mounts();
    hull() for (y=[mounts[0][1],mounts[2][1]])
        translate([controls_rail_x,y,controls_head_z()-controls_rail_height])
            cylinder(d=controls_rail_width,h=controls_rail_height,$fn=48);
    for (p=mounts) translate([p[0],p[1],controls_seat_z()])
        cylinder(d=controls_boss_diameter,h=controls_grip(),$fn=64);
    contact_ring(display_center_x(),display_center_y(),oled_pcb_width,oled_pcb_height,
                 oled_front_skin+oled_module_depth,"top",oled_header_notch_width,oled_header_notch_depth);
    ring_arms(display_center_x(),display_center_y(),oled_pcb_width,oled_front_skin+oled_module_depth);
    contact_ring(encoder_board_x(),encoder_board_y(),encoder_pcb_width,encoder_pcb_height,
                 encoder_board_depth(),"left",14,4);
    ring_arms(encoder_board_x(),encoder_board_y(),encoder_pcb_width,encoder_board_depth());
    cancel_switch_cradle();
}

module controls_bracket() {
    difference() {
        intersection() { controls_bracket_raw(); shell_cavity(retainer_floor_clearance); }
        for (p=controls_mounts()) translate([p[0],p[1],0]) {
            translate([0,0,controls_seat_z()-0.1])
                cylinder(d=m3_lid_clearance_diameter,h=controls_grip()+0.2,$fn=64);
            vertical_countersink(controls_head_z());
        }
        control_connector_envelopes(wire_allowance=true);
    }
}

module control_connector_envelopes(wire_allowance=true) {
    bend=wire_allowance ? connector_wire_bend : 0;
    panel_coordinate_frame() {
        translate([display_center_x()-7,display_center_y()+oled_pcb_height/2-4,
                   -(oled_front_skin+oled_module_depth+oled_dupont_depth+bend)])
            cube([14,4,oled_dupont_depth+bend]);
        translate([encoder_board_x()-encoder_pcb_width/2-encoder_dupont_extension-bend,encoder_board_y()-6.5,
                   -encoder_board_depth()-4])
            cube([encoder_dupont_extension+bend,13,4]);
    }
}

module controls_tool_access(iron=false) {
    for (p=controls_mounts()) translate([p[0],p[1],iron ? controls_seat_z() : controls_head_z()])
        cylinder(d=iron ? iron_access_diameter : driver_access_diameter,h=60,$fn=48);
}

module board_tool_access(iron=false) {
    for (p=board_mounts()) translate([p[0],p[1],
        iron ? board_insert_seat_z() : board_insert_seat_z()+board_clamp_grip()]) {
        if (iron) {
            cylinder(d=6,h=12,$fn=48);
            translate([0,0,12]) cylinder(d=iron_access_diameter,h=48,$fn=48);
        } else cylinder(d=driver_access_diameter,h=60,$fn=48);
    }
}

module board_supports_raw() {
    for (board=[0,1]) {
        w=board==0 ? proto_width : supply_length;
        l=board==0 ? proto_length : supply_width;
        y=board==0 ? proto_y0() : supply_y0();
        x=board_left_x();
        // Four small pads support the PCB edges, leaving its soldered underside open.
        for (px=[x+1,x+w-1],py=[y+1,y+l-1])
            translate([px,py,ancho_pared]) cylinder(r=1.25,h=board_pcb_z()-ancho_pared,$fn=32);
        for (py=[y+2,y+l-6]) {
            translate([x-board_edge_clearance-1.6,py,ancho_pared])
                cube([1.6,4,board_top_z()+0.5-ancho_pared]);
            // Leave the far power-board/front corner free beside the controls foot.
            if (!(board==1 && py<y+3))
                translate([x+w+board_edge_clearance,py,ancho_pared])
                    cube([1.6,4,board_top_z()+0.5-ancho_pared]);
        }
        for (px=[x+3,x+w-7])
            translate([px,y-board_edge_clearance-1.6,ancho_pared])
                cube([4,1.6,board_top_z()+0.5-ancho_pared]);
    }
    for (p=board_mounts()) translate([p[0],p[1],ancho_pared])
        cylinder(d=9,h=board_insert_seat_z()-ancho_pared,$fn=64);
}

module board_supports() {
    intersection() { board_supports_raw(); outer_case_volume(0.001); }
}

module board_insert_bores() {
    for (p=board_mounts()) translate([p[0],p[1],0])
        m3_insert_bore(board_insert_seat_z()-m3_insert_length-m3_insert_bottom_clearance,
                       m3_insert_length+m3_insert_bottom_clearance);
}

module board_clamp(board=0) {
    p=board_mounts()[board];
    top=board_insert_seat_z()+board_clamp_grip();
    difference() {
        intersection() {
            union() {
                translate([p[0],p[1],board_insert_seat_z()])
                    cylinder(d=9,h=board_clamp_grip(),$fn=64);
                if (board==0) translate([p[0]-4.5,p[1]-4,board_top_z()])
                    cube([4.5,8,2]);
                else translate([p[0]-4,p[1],board_top_z()]) cube([8,7,2]);
            }
            shell_cavity(0.35);
        }
        if (board==0) translate([p[0]-4.5,p[1]-5,board_insert_seat_z()-0.1])
            cube([2.3,10,board_top_z()-board_insert_seat_z()+0.1]);
        translate([p[0],p[1],board_insert_seat_z()-0.01])
            cylinder(d=m3_lid_clearance_diameter,h=board_clamp_grip()+0.02,$fn=64);
        translate([p[0],p[1],0]) vertical_countersink(top);
    }
}

module electronics_envelopes() {
    translate([board_left_x(),proto_y0(),board_lowest_z()]) cube([proto_width,proto_length,proto_total_height]);
    translate([board_left_x(),supply_y0(),board_lowest_z()]) cube([supply_length,supply_width,supply_total_height]);
}
