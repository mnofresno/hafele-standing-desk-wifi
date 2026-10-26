"""Isolated rear-wall interface fixtures; no dependence on the evolving case."""
import json
from pathlib import Path
import shutil
import subprocess

import numpy as np
import pytest

trimesh = pytest.importorskip("trimesh")
pytest.importorskip("manifold3d")
pytestmark = pytest.mark.skipif(not shutil.which("openscad"), reason="OpenSCAD CLI is required")
LIB = Path(__file__).resolve().parents[1] / "lib" / "measured_ports.scad"
A = np.deg2rad(75)
TOP_X = -5*np.cos(np.deg2rad(15))-(35-(5-5*np.sin(np.deg2rad(15))))/np.tan(A)-25
FRAME = np.array([[0,-np.cos(A),np.sin(A)], [1,0,0], [0,np.sin(A),np.cos(A)]])
ORIGIN = np.array([TOP_X, 0, 35])

GLOBALS = """
design_revision="rework";
alto=35; profundidad=70; longitud=150; angulo_del_panel=75; ancho_pared=1.5;
boot_neck_width=8.5; boot_neck_height=10.5; boot_wall_thickness=2.5;
boot_fit_clearance=0.2; boot_from_near_end=26;
enable_motor_cable_exit=true; enable_usb_access=false;
usb_access_width=14; usb_access_height=10; usb_access_corner_radius=1.5;
usb_above_assembly_bottom=18; usb_socket_height=3.5;
function rear_extension()=25;
function source_top_center_x()=
    -5*cos(15)-(35-(5-5*sin(15)))/tan(75)+70/2;
function board_left_x()=-22;
function proto_y0()=-112;
function board_lowest_z()=7.7;
module wall_fixture() {
    intersection() {
        rear_wall_frame() translate([-70,-30,0]) cube([60,35,ancho_pared]);
        translate([-200,-200,0]) cube([400,400,alto]);
    }
}
module lid_fixture() {
    union() {
        translate([mp_rear_top_x()-2,-50,alto]) cube([30,40,ancho_pared]);
        intersection() {
            rear_wall_frame() translate([-50,-2,ancho_pared+0.25]) cube([40,3,5]);
            translate([-200,-200,0]) cube([400,400,alto]);
        }
    }
}
$fn=64;
"""


def render(tmp_path, expression, **definitions):
    source = tmp_path / "fixture.scad"
    mesh_path = tmp_path / "fixture.stl"
    source.write_text(GLOBALS + f"\ninclude <{LIB.as_posix()}>;\n" + expression)
    args = []
    for key, value in definitions.items():
        args.extend(["-D", f"{key}={json.dumps(value)}"])
    result = subprocess.run([shutil.which("openscad"), "-o", str(mesh_path), *args,
                             str(source)], capture_output=True, text=True)
    log = result.stdout + result.stderr
    assert result.returncode == 0, log
    assert "WARNING:" not in log and "ERROR:" not in log, log
    mesh = trimesh.load_mesh(mesh_path, process=True)
    assert mesh.is_watertight and mesh.is_winding_consistent
    assert sum(part.volume > 0 for part in mesh.split(only_watertight=False)) == 1
    return mesh


def world(u, v, w):
    return ORIGIN + FRAME @ np.array([u, v, w])


def material_at(mesh, points):
    # Small volume probes avoid ray-casting ambiguity on coincident wall edges.
    occupied = []
    for point in points:
        probe = trimesh.creation.box(extents=[0.02]*3,
                    transform=trimesh.transformations.translation_matrix(point))
        overlap = trimesh.boolean.intersection([mesh,probe],engine="manifold")
        with np.errstate(divide="ignore",invalid="ignore"):
            occupied.append(abs(overlap.volume) > probe.volume/2)
    return np.array(occupied)


def test_boot_patch_stays_within_case_bound_and_has_vertical_2_4mm_seat(tmp_path):
    mesh = render(tmp_path, "measured_ports_positive();")
    assert mesh.bounds[0,0] == pytest.approx(TOP_X, abs=1e-5)
    assert mesh.bounds[1,0] < -22  # No intrusion into the assembly's board edge.
    assert mesh.bounds[1,2] == pytest.approx(35, abs=1e-5)
    section = """intersection() {
      difference(){union(){wall_fixture(); measured_ports_positive();} measured_port_cutouts();}
      translate([mp_rear_top_x()-1,-boot_from_near_end+5,30]) cube([10,0.1,0.1]);
    }"""
    seat = render(tmp_path, section)
    assert seat.bounds[:,0] == pytest.approx([TOP_X,TOP_X+2.4], abs=1e-5)
    tuned = render(tmp_path, section, boot_wall_clearance=0.2)
    assert np.ptp(tuned.bounds[:,0]) == pytest.approx(2.3, abs=1e-5)


def test_boot_cutout_has_8_9mm_width_and_opens_up_through_seam(tmp_path):
    mesh = render(tmp_path, """intersection() {
      measured_port_cutouts();
      translate([mp_rear_top_x()+0.5,-100,0]) cube([0.1,100,100]);
    }""")
    assert np.ptp(mesh.bounds[:,1]) == pytest.approx(8.9, abs=1e-5)
    assert mesh.bounds[0,2] == pytest.approx(35-10.5-0.2, abs=1e-5)
    assert mesh.bounds[1,2] > 35


def test_boot_wall_is_u_open_with_solid_side_rails_and_bottom_bridge(tmp_path):
    mesh = render(tmp_path, "difference(){ union(){wall_fixture(); measured_ports_positive();} measured_port_cutouts();}")
    opening = [[TOP_X+x,-26,34.99] for x in (0.1,1.2,2.3)]
    assert not material_at(mesh, opening).any()
    rails = np.array([[TOP_X+1,-31,34], [TOP_X+1,-21,34], [TOP_X+1,-26,23.8]])
    assert material_at(mesh, rails).all()


def test_inner_shoulder_clearance_removes_old_wall_but_keeps_gussets(tmp_path):
    mesh = render(tmp_path, "difference(){ union(){wall_fixture(); measured_ports_positive();} measured_port_cutouts();}")
    assert not material_at(mesh, [[TOP_X+3.5,-26,26]]).any()
    assert material_at(mesh, [[TOP_X+3.5,-18,26], [TOP_X+4.5,-26,20.5]]).all()


def test_boot_lid_relief_cuts_locating_lip_and_preserves_roof(tmp_path):
    relief = render(tmp_path, "boot_lid_relief();")
    assert relief.bounds[1,2] == pytest.approx(35, abs=1e-5)
    lid = render(tmp_path, "difference(){lid_fixture(); boot_lid_relief();}")
    assert not material_at(lid, [world(-26,-1,2)]).any()
    assert material_at(lid, [world(-12,-1,2)]).all()
    assert material_at(lid, [[TOP_X+1,-26,35.5]]).all()


def test_measured_neck_fits_vertical_seat_and_touches_lid_without_overlap(tmp_path):
    neck = render(tmp_path, "boot_neck_envelope();")
    assert neck.bounds[:,0] == pytest.approx([TOP_X,TOP_X+2.5], abs=1e-5)
    assert np.ptp(neck.bounds[:,1]) == pytest.approx(8.5, abs=1e-5)
    assert neck.bounds[:,2] == pytest.approx([24.5,35], abs=1e-5)
    case = render(tmp_path, "difference(){ union(){wall_fixture(); measured_ports_positive();} measured_port_cutouts();}")
    lid = render(tmp_path, "difference(){lid_fixture(); boot_lid_relief();}")
    for first,second in ((neck,case),(neck,lid),(case,lid)):
        overlap = trimesh.boolean.intersection([first,second], engine="manifold")
        with np.errstate(divide="ignore",invalid="ignore"):
            assert abs(overlap.volume) < 1e-6


def test_usb_corridor_uses_socket_datum_and_world_axis_dimensions(tmp_path):
    mesh = render(tmp_path, "measured_port_cutouts();",
                  enable_motor_cable_exit=False, enable_usb_access=True)
    assert mesh.bounds[:,1] == pytest.approx([-104,-90], abs=1e-5)
    assert mesh.bounds[:,2] == pytest.approx([22.45,32.45], abs=1e-5)
    assert mesh.bounds[0,0] < TOP_X and mesh.bounds[1,0] >= -22
    shifted = render(tmp_path, "measured_port_cutouts();",
                     enable_motor_cable_exit=False, enable_usb_access=True,
                     usb_proto_offset_y=22)
    assert shifted.bounds[:,1] == pytest.approx(mesh.bounds[:,1]+7, abs=1e-5)
