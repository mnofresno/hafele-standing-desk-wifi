// Diagnostic solid used by validate_clearance.py. The empty intersection means
// the installed encoder retainer and electronics carrier are disjoint.
include <../hafele_control_box.scad>;

intersection() {
    encoder_retainer_installed();
    electronics_carrier_installed();
}
