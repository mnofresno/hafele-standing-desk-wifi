"""Mechanical coupon checks; no claim about real FDM release force or switch fit."""
from pathlib import Path
import math
import shutil
import subprocess

import pytest
import trimesh

pytest.importorskip('manifold3d')
pytestmark=pytest.mark.skipif(not shutil.which('openscad'),reason='OpenSCAD CLI required')
SOURCE=Path(__file__).with_name('cancel_pip_coupon.scad')


def export(tmp_path,part,state):
    output=tmp_path/f'{part}-{state}.stl'
    run=subprocess.run(['openscad','-o',str(output),'-D',f'part="{part}"',
                        '-D',f'state="{state}"',str(SOURCE)],capture_output=True,text=True)
    assert run.returncode==0 and 'WARNING:' not in run.stderr,run.stderr
    mesh=trimesh.load_mesh(output)
    assert mesh.is_volume and mesh.is_watertight
    return mesh


def intersection_volume(a,b):
    return abs(trimesh.boolean.intersection([a,b],engine='manifold').volume)


def test_as_printed_coupon_is_connected_by_tabs(tmp_path):
    mesh=export(tmp_path,'coupon','as_printed')
    assert sum(shell.volume>0 for shell in mesh.split())==1


def test_released_cap_is_separate_and_moves_to_stop_without_overlap(tmp_path):
    fixed=export(tmp_path,'fixed','released')
    cap=export(tmp_path,'moving','released')
    combined=trimesh.util.concatenate([fixed,cap])
    assert sum(shell.volume>0 for shell in combined.split())==2
    theta=math.radians(75)
    for distance in (0,0.325,0.65):
        moved=cap.copy()
        moved.apply_translation([0,math.sin(theta)*distance,-math.cos(theta)*distance])
        assert intersection_volume(fixed,moved)<1e-4


@pytest.mark.parametrize('distance',[0.8,-0.45])
def test_captive_stops_block_overpress_and_outward_escape(tmp_path,distance):
    fixed=export(tmp_path,'fixed','released')
    cap=export(tmp_path,'moving','released')
    theta=math.radians(75)
    cap.apply_translation([0,math.sin(theta)*distance,-math.cos(theta)*distance])
    assert intersection_volume(fixed,cap)>0.1
