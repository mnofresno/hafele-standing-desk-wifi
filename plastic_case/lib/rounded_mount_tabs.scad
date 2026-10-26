/* Rounded wood-mount tabs for the rework lid. Units: mm.
 *
 * Local z=0 is the flat wood-contact plane; all reinforcement grows into +Z.
 * rounded_mount_tabs() emits raw solids. Union these with the lid, then
 * subtract wood_mount_hole_cutouts() from the complete union.
 *
 * The hole pattern is independent of lid length: default centers [0,+/-83]
 * retain the original 166 mm spacing. tab_root_relief() follows the same
 * outline and must receive the same installed transform as the tabs before
 * being subtracted from the case. It leaves room for the embedded tab roots.
 */

function wood_mount_hole_centers(spacing=166) =
    [[0,-spacing/2],[0,spacing/2]];

// A 90-degree countersink rises (head_diameter-hole_diameter)/2. Preserve
// bearing_web of material below its narrow end, even with a shallow old lid.
function wood_mount_head_plane(hole_diameter=4,head_diameter=7,
                               reference_head_plane=1.5,bearing_web=0.6) =
    max(reference_head_plane,(head_diameter-hole_diameter)/2+bearing_web);

// Countersunk screw stock length includes its head. This is the projection
// beyond the wood-contact plane for a seated screw, not a promised wood fit.
function wood_mount_screw_projection(screw_length=15,hole_diameter=4,
                                     head_diameter=7,reference_head_plane=1.5,
                                     bearing_web=0.6) =
    screw_length-wood_mount_head_plane(hole_diameter,head_diameter,
                                      reference_head_plane,bearing_web);

module _rounded_mount_tab_outline(length=150,spacing=166,root_width=24,
                                  root_embed=12,root_radius=6,tip_radius=9) {
    assert(length>0 && spacing>0,"Lid length and hole spacing must be positive");
    assert(root_radius>0 && root_width>=2*root_radius,
           "Root width must contain its rounded ends");
    assert(root_embed>=root_radius && length>2*root_embed,
           "The rounded roots must embed inside the lid ends");
    assert(tip_radius>0,"Tab tip radius must be positive");
    for (side=[-1,1]) hull() {
        // root_embed measures the complete overlap into the lid, including
        // the root radius. The hull joins round roots directly to the tip.
        for (x=[-root_width/2+root_radius,root_width/2-root_radius])
            translate([x,side*(length/2-root_embed+root_radius)])
                circle(r=root_radius,$fn=96);
        translate([0,side*spacing/2]) circle(r=tip_radius,$fn=96);
    }
}

module rounded_mount_tabs(length=150,spacing=166,root_width=24,root_embed=12,
                          root_radius=6,tip_radius=9,thickness=5) {
    assert(thickness>0,"Tab thickness must be positive");
    linear_extrude(height=thickness)
        _rounded_mount_tab_outline(length,spacing,root_width,root_embed,
                                   root_radius,tip_radius);
}

module wood_mount_hole_cutouts(spacing=166,thickness=5,hole_diameter=4,
                               head_diameter=7,reference_head_plane=1.5,
                               bearing_web=0.6,tool_diameter_extra=2) {
    assert(hole_diameter>0 && head_diameter>hole_diameter,
           "The countersunk head must be wider than the through-hole");
    assert(bearing_web>0 && reference_head_plane>0,
           "The screw seat needs a positive bearing web");
    assert(tool_diameter_extra>=0,"Tool clearance cannot be negative");
    head_plane=wood_mount_head_plane(hole_diameter,head_diameter,
                                     reference_head_plane,bearing_web);
    cone_height=(head_diameter-hole_diameter)/2;
    assert(thickness>=head_plane,"Tab is too thin for the countersunk seat");
    for (center=wood_mount_hole_centers(spacing)) {
        translate([center[0],center[1],-0.01])
            cylinder(d=hole_diameter,h=thickness+0.02,$fn=96);
        translate([center[0],center[1],head_plane-cone_height])
            cylinder(d1=hole_diameter,d2=head_diameter,h=cone_height,$fn=96);
        // The outer well admits the head and screwdriver from local +Z.
        translate([center[0],center[1],head_plane])
            cylinder(d=head_diameter+tool_diameter_extra,
                     h=thickness-head_plane+0.02,$fn=96);
    }
}

module tab_root_relief(length=150,spacing=166,root_width=24,root_embed=12,
                       root_radius=6,tip_radius=9,thickness=5,
                       assembly_clearance=0.3) {
    assert(assembly_clearance>=0,"Assembly clearance cannot be negative");
    assert(thickness>0,"Tab thickness must be positive");
    translate([0,0,-assembly_clearance])
        linear_extrude(height=thickness+2*assembly_clearance)
            offset(delta=assembly_clearance)
                _rounded_mount_tab_outline(length,spacing,root_width,root_embed,
                                           root_radius,tip_radius);
}
