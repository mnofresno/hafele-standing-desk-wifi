/* Captive translating cap. Local front face is z=0; pressing moves toward -Z.
 * Geometry only: release force, printability and switch overtravel need a coupon.
 * The switch spring provides return; the printed cap has no return spring.
 */

function cancel_flange_front(panel_t, axial_gap) = -panel_t-axial_gap;
function cancel_flange_back(panel_t, axial_gap, flange_t) =
    cancel_flange_front(panel_t,axial_gap)-flange_t;
function cancel_stop_front(panel_t,axial_gap,flange_t,travel) =
    cancel_flange_back(panel_t,axial_gap,flange_t)-travel;
function cancel_guide_depth(panel_t,axial_gap,flange_t,travel,back_t) =
    -cancel_stop_front(panel_t,axial_gap,flange_t,travel)+back_t;

module captive_cancel_guide(panel_t=1.5, cap_d=13, flange_d=16.5,
                            radial_gap=0.3, axial_gap=0.3, flange_t=1.8,
                            travel=0.65, guide_wall=1.6, back_t=1.5,
                            stem_hole_d=8) {
    stop_front=cancel_stop_front(panel_t,axial_gap,flange_t,travel);
    back=stop_front-back_t;
    chamber_d=flange_d+2*radial_gap;
    assert(radial_gap>0 && axial_gap>0 && travel>0 && guide_wall>0 && back_t>0,
           "Moving clearances, stroke and walls must be positive");
    assert(flange_d>cap_d+2*radial_gap && chamber_d>stem_hole_d,
           "The flange must be captive between the front and rear stops");
    difference() {
        translate([0,0,back])
            cylinder(d=chamber_d+2*guide_wall,h=-panel_t-back+0.02,$fn=96);
        translate([0,0,stop_front])
            cylinder(d=chamber_d,h=-stop_front+0.1,$fn=96);
        translate([0,0,back-0.01])
            cylinder(d=stem_hole_d,h=-back+0.1,$fn=64);
    }
}

module captive_cancel_cap(panel_t=1.5, cap_d=13, flange_d=16.5,
                          axial_gap=0.3, flange_t=1.8, projection=1.3,
                          stem_d=4.5, stem_length=2.6, press=0) {
    flange_front=cancel_flange_front(panel_t,axial_gap);
    flange_back=cancel_flange_back(panel_t,axial_gap,flange_t);
    translate([0,0,-press]) union() {
        translate([0,0,flange_back])
            cylinder(d=cap_d,h=projection-flange_back,$fn=96);
        translate([0,0,flange_back])
            cylinder(d=flange_d,h=flange_t,$fn=96);
        translate([0,0,flange_back-stem_length])
            cylinder(d=stem_d,h=stem_length+0.01,$fn=64);
    }
}

module captive_cancel_break_tabs(panel_t=1.5,cap_d=13,radial_gap=0.3,
                                 neck_width=0.4,neck_height=0.2,include_necks=true) {
    // Two roots stay attached to the wall. Each has one thin neck at the cap,
    // so breaking it need not produce a separate loose printed fragment.
    for (angle=[0,180]) rotate([0,0,angle]) {
        translate([cap_d/2+0.75*radial_gap,-0.6,-panel_t/2-0.3])
            cube([radial_gap+0.2,1.2,0.6]);
        if (include_necks)
        translate([cap_d/2-0.05,-neck_width/2,-panel_t/2-neck_height/2])
            cube([0.75*radial_gap+0.15,neck_width,neck_height]);
    }
}
