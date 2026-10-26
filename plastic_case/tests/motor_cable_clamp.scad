/*
  Standalone, adjustable strain-relief clamp for a corrugated motor cable.

  Print the saddle flat on its mounting face. Print the cap inverted, with its
  broad outside face on the bed and the cable groove facing upward. Both parts
  then have support-free orientations. The nominal cable and insert values are
  calibration starting points; measure the actual boot/corrugation and tune a
  coupon before using the clamp on the final enclosure.

  show_part: "assembly", "saddle", or "cap"
  Cable axis: X. Mounting grid: hole centers land on a 10 mm grid by default.
*/

show_part = "assembly"; // [assembly,saddle,cap]

// Calibration values. `cable_od` is the measured outside diameter across the
// cable corrugation. Positive interference makes the channel smaller.
cable_od = 8; // [6:1:12]
cable_interference = 0.0; // [0:0.05:0.6]
clamp_length = 32; // [24:1:50]
radial_channel_extra = 0.0; // [-0.4:0.05:0.8]

// Fasteners and mounting pattern. Reuse M3 heat-set inserts in the saddle and
// M3 screws for the carrier grid. Four carrier holes sit at +/- one grid pitch.
insert_pilot_d = 4.0; // [3.6:0.1:4.4]
insert_length = 5.7; // [3:0.1:8]
insert_floor = 1.2; // [0.8:0.1:2.5]
insert_lead_d = 4.8; // [4.2:0.1:5.4]
insert_lead_h = 0.6; // [0.3:0.1:1.2]
m3_clearance_d = 3.4; // [3.2:0.1:3.8]
cap_screw_head_d = 5.8; // [5:0.1:7]
cap_screw_head_h = 2.4; // [1.5:0.1:3.5]
mount_grid_pitch = 10; // [5:1:20]
mount_grid_hole_d = 3.4; // [3.2:0.1:4.2]

body_min_width = 28;
edge_wall = 4;
cap_roof_thickness = 2;
base_thickness = 3;
$fn = 96;

channel_r = max(1, cable_od / 2 - cable_interference + radial_channel_extra);
cap_thickness = channel_r + cap_roof_thickness;
split_z = max(base_thickness + channel_r, insert_length + insert_floor);
bolt_offset = channel_r + edge_wall;
body_width = max(body_min_width, 2 * (bolt_offset + edge_wall));
mount_xy = mount_grid_pitch;

module x_cylinder(r, h) {
    rotate([0, 90, 0]) cylinder(r=r, h=h, center=true);
}

module saddle() {
    difference() {
        // Flat mounting face and four holes on the carrier's 10 mm grid.
        translate([0, 0, split_z / 2])
            cube([clamp_length, body_width, split_z], center=true);
        // Upper half of the cylinder is open; this leaves a semicircular cradle.
        translate([0, 0, split_z])
            x_cylinder(channel_r, clamp_length + 0.4);

        // Blind M3 insert pilots for the cap screws.
        for (side = [-1, 1]) {
            translate([0, side * bolt_offset, split_z - insert_length])
                cylinder(d=insert_pilot_d, h=insert_length + 0.02);
            translate([0, side * bolt_offset, split_z - insert_lead_h])
                cylinder(d1=insert_pilot_d, d2=insert_lead_d,
                         h=insert_lead_h + 0.02);
        }

        // Carrier-grid M3 through holes; ±pitch coordinates are grid points.
        for (x = [-mount_xy, mount_xy], y = [-mount_xy, mount_xy])
            translate([x, y, -0.01])
                cylinder(d=mount_grid_hole_d, h=split_z + 0.02);
    }
}

module cap() {
    difference() {
        // The cap mating face is z=0 in this local coordinate system.
        translate([0, 0, cap_thickness / 2])
            cube([clamp_length, body_width, cap_thickness], center=true);
        // Matching semicircular half-channel, open at the mating face.
        translate([0, 0, 0])
            x_cylinder(channel_r, clamp_length + 0.4);

        for (side = [-1, 1]) {
            translate([0, side * bolt_offset, -0.01])
                cylinder(d=m3_clearance_d, h=cap_thickness + 0.02);
            translate([0, side * bolt_offset,
                       cap_thickness - cap_screw_head_h])
                cylinder(d=cap_screw_head_d, h=cap_screw_head_h + 0.02);
        }
    }
}

if (show_part == "saddle") {
    saddle();
} else if (show_part == "cap") {
    cap();
} else {
    saddle();
    translate([0, 0, split_z]) cap();
}
