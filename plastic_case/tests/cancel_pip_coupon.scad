/* Print at the enclosure's 75-degree panel angle, flat base on the bed.
 * Break tabs with a first press BEFORE fitting a switch. Inspect/remove strings,
 * then check free motion. The switch spring provides return after installation.
 * This coupon does not establish force, fatigue or allowable switch overtravel.
 */
use <../lib/captive_cancel_button.scad>;

part="coupon"; // [coupon,fixed,moving]
state="as_printed"; // [as_printed,released,pressed]
panel_angle=75;
panel_thickness=1.5;
cap_diameter=13;
flange_diameter=16.5;
radial_clearance=0.3;
axial_clearance=0.3;
flange_thickness=1.8;
cap_projection=1.3;
press_travel=0.65; // Candidate cap travel, not a verified switch overtravel limit.
stem_diameter=4.5;
stem_length=2.6;
guide_wall=1.6;
guide_back_thickness=1.5;
stem_hole_diameter=8;
break_neck_width=0.4;
break_neck_height=0.2;
coupon_width=28;
coupon_height=28;
$fn=96;

module coupon_fixed() {
    difference() {
        translate([-coupon_width/2,-coupon_height/2,-panel_thickness])
            cube([coupon_width,coupon_height,panel_thickness]);
        translate([0,0,-panel_thickness-0.01])
            cylinder(d=cap_diameter+2*radial_clearance,h=panel_thickness+0.02);
    }
    captive_cancel_guide(panel_thickness,cap_diameter,flange_diameter,
        radial_clearance,axial_clearance,flange_thickness,press_travel,
        guide_wall,guide_back_thickness,stem_hole_diameter);
    captive_cancel_break_tabs(panel_thickness,cap_diameter,radial_clearance,
                              break_neck_width,break_neck_height,state=="as_printed");
}

module coupon_moving() {
    captive_cancel_cap(panel_thickness,cap_diameter,flange_diameter,
        axial_clearance,flange_thickness,cap_projection,stem_diameter,stem_length,
        state=="pressed" ? press_travel : 0);
}

guide_depth=cancel_guide_depth(panel_thickness,axial_clearance,flange_thickness,
                              press_travel,guide_back_thickness);
guide_od=flange_diameter+2*(radial_clearance+guide_wall);
lift=max(coupon_height/2*sin(panel_angle)+panel_thickness*cos(panel_angle),
         guide_od/2*sin(panel_angle)+guide_depth*cos(panel_angle));
module oriented() {
    translate([0,0,lift]) rotate([panel_angle,0,0]) children();
}

if (part!="moving") {
    // Wide base keeps the inclined coupon stable; it stays below the moving cap.
    translate([-coupon_width/2,-11,0]) cube([coupon_width,22,2]);
    oriented() coupon_fixed();
}
if (part!="fixed") oriented() coupon_moving();
