/* Measured rear-wall interfaces. Host: hafele_control_box.scad.
 * All three public modules emit WORLD coordinates. Add the positive pad to
 * the case, subtract measured_port_cutouts() from the case, and subtract
 * boot_lid_relief() from the INSTALLED lid. The roof above z=alto is preserved.
 * The molded boot seats on a vertical local patch: its axis is horizontal and
 * its top is flush with the horizontal lid seam. A surrounding wedge joins
 * that patch to the old sloping wall. The assumed flange relief is adjustable;
 * the unmeasured flange itself and wire bend are not certified by this model.
 */
function mp_port_epsilon() = 0.05;
function mp_rear_top_x() = source_top_center_x()-profundidad/2-rear_extension();
function mp_boot_width() = boot_neck_width+2*boot_fit_clearance;
function mp_boot_height() = boot_neck_height+boot_fit_clearance;
function mp_boot_pad_margin() = is_undef(boot_pad_margin) ? 5 : boot_pad_margin;
function mp_boot_flange_margin() = is_undef(boot_rear_flange_margin)
    ? 2.5 : boot_rear_flange_margin;
function mp_boot_wall_clearance() = is_undef(boot_wall_clearance)
    ? 0.1 : boot_wall_clearance;
function mp_boot_seat_thickness() = boot_wall_thickness-mp_boot_wall_clearance();
function mp_boot_inner_x() = mp_rear_top_x()+mp_boot_seat_thickness();
function mp_old_wall_inner_x(z) = mp_rear_top_x()
    +(alto-z)/tan(angulo_del_panel)+ancho_pared/sin(angulo_del_panel);
function mp_old_wall_join_x(z) = mp_rear_top_x()
    +(alto-z)/tan(angulo_del_panel)+ancho_pared/(2*sin(angulo_del_panel));
function mp_boot_lid_clearance() = is_undef(lid_rim_clearance) ? 0.25 : lid_rim_clearance;
function mp_usb_y() = proto_y0()+(is_undef(usb_proto_offset_y) ? 15 : usb_proto_offset_y);
function mp_usb_z() = board_lowest_z()+usb_above_assembly_bottom+usb_socket_height/2;
function mp_clip_extent() = 2*max(longitud,profundidad+rear_extension(),alto);

// u follows world Y; v climbs the inclined rear wall; w points into the case.
// w=0 is the original outside rear-wall plane, including the rear extension.
module rear_wall_frame() {
    a = angulo_del_panel;
    multmatrix([[0,-cos(a),sin(a),mp_rear_top_x()],
                [1,0,0,0],
                [0,sin(a),cos(a),alto],
                [0,0,0,1]]) children();
}

module mp_below_lid_seam() {
    extent = mp_clip_extent();
    translate([-extent,-extent,-extent])
        cube([2*extent,2*extent,extent+alto]);
}

module mp_boot_cutout() {
    epsilon = mp_port_epsilon();
    translate([mp_rear_top_x()-epsilon,
               -boot_from_near_end-mp_boot_width()/2,alto-mp_boot_height()])
        cube([mp_boot_seat_thickness()+2*epsilon,
              mp_boot_width(),mp_boot_height()+epsilon]);
}

module mp_boot_flange_relief() {
    // Remove the former sloping wall behind the thin seat. Without this relief
    // a printed neck gauge fits the opening but the boot's inner shoulder jams.
    margin = mp_boot_flange_margin();
    bottom = alto-mp_boot_height()-margin;
    end_x = max(mp_boot_inner_x(),mp_old_wall_inner_x(bottom))+mp_port_epsilon();
    translate([mp_boot_inner_x(),
               -boot_from_near_end-mp_boot_width()/2-margin,bottom])
        cube([end_x-mp_boot_inner_x(),mp_boot_width()+2*margin,
              alto-bottom+mp_port_epsilon()]);
}

module measured_ports_positive() {
    if (design_revision == "rework" && enable_motor_cable_exit) {
        margin = mp_boot_pad_margin();
        bottom = alto-mp_boot_height()-margin;
        width = mp_boot_width()+2*margin;
        assert(mp_boot_seat_thickness() > 0,"Boot wall clearance exceeds neck groove");
        assert(margin > mp_boot_flange_margin(),"Boot gussets need margin beyond flange relief");
        // No vertex extends behind the original rear top X bound. The union
        // retains the measured vertical seat and overlaps halfway into the
        // host wall; the central rear relief leaves side/bottom gussets.
        translate([0,-boot_from_near_end+width/2,0]) rotate([90,0,0])
            linear_extrude(height=width)
                union() {
                    translate([mp_rear_top_x(),bottom])
                        square([mp_boot_seat_thickness(),alto-bottom]);
                    polygon([[mp_rear_top_x(),bottom],
                             [mp_old_wall_join_x(bottom),bottom],
                             [mp_old_wall_join_x(alto),alto],
                             [mp_rear_top_x(),alto]]);
                }
    }
}

module mp_usb_cutout() {
    epsilon = mp_port_epsilon();
    start_x = mp_rear_top_x()-epsilon;
    end_x = board_left_x()+epsilon;
    radius = min(usb_access_corner_radius,usb_access_width/2,usb_access_height/2);
    assert(end_x > start_x,"USB socket must lie inward of the rear wall");
    // A horizontal plug corridor terminates at the measured assembly's left
    // edge. Its cross-section is width in world Y and height in world Z.
    multmatrix([[0,0,1,start_x],
                [1,0,0,mp_usb_y()],
                [0,1,0,mp_usb_z()],
                [0,0,0,1]])
        linear_extrude(height=end_x-start_x)
            offset(r=radius)
                square([usb_access_width-2*radius,
                        usb_access_height-2*radius],center=true);
}

module measured_port_cutouts() {
    if (design_revision == "rework") {
        if (enable_motor_cable_exit) {
            mp_boot_cutout();
            mp_boot_flange_relief();
        }
        if (enable_usb_access) mp_usb_cutout();
    }
}

module boot_lid_relief() {
    if (design_revision == "rework" && enable_motor_cable_exit)
        intersection() {
            union() {
                mp_boot_cutout();
                mp_boot_flange_relief();
                // The lip must clear the whole mounting patch, including its
                // side shoulders, rather than only the neck opening.
                if (mp_boot_lid_clearance() > 0)
                    minkowski() {
                        measured_ports_positive();
                        sphere(r=mp_boot_lid_clearance(),$fn=24);
                    }
                else measured_ports_positive();
            }
            // The locating lip is below this plane; the full roof begins here.
            mp_below_lid_seam();
        }
}

module boot_neck_envelope() {
    // Physical-fit positive control: measured neck only, excluding its flanges.
    translate([mp_rear_top_x(),-boot_from_near_end-boot_neck_width/2,
               alto-boot_neck_height])
        cube([boot_wall_thickness,boot_neck_width,boot_neck_height]);
}
