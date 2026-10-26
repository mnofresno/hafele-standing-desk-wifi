#!/usr/bin/env python3
"""Build or verify the default rework STL set and previews, with source hashes."""
import argparse
import hashlib
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

from validate_rework import mesh_metrics

ROOT = Path(__file__).resolve().parents[1]
PARTS = {
    'case_rework_candidate.stl': ('hafele_control_box.scad', 'case'),
    'lid_rework_candidate.stl': ('hafele_control_box.scad', 'lid'),
    'oled_retainer_candidate.stl': ('hafele_control_box.scad', 'oled_retainer'),
    'encoder_retainer_candidate.stl': ('hafele_control_box.scad', 'encoder_retainer'),
    'electronics_carrier_candidate.stl': ('hafele_control_box.scad', 'electronics_carrier'),
    'button_cap_candidate.stl': ('hafele_control_box.scad', 'button_cap'),
    'motor_cable_saddle_8mm_calibration.stl': ('tests/motor_cable_clamp.scad', 'saddle'),
    'motor_cable_cap_8mm_calibration.stl': ('tests/motor_cable_clamp.scad', 'cap'),
}


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_openscad(command):
    result = subprocess.run(command, capture_output=True, text=True)
    log = result.stdout + result.stderr
    if result.returncode or 'WARNING:' in log or 'ERROR:' in log:
        raise RuntimeError(f'OpenSCAD failed: {command}\n{log}')


def verify(destination):
    manifest = json.loads((destination/'manifest.json').read_text())
    for source, checksum in manifest['sources_sha256'].items():
        if sha256(ROOT/source) != checksum:
            raise RuntimeError(f'Stale print set: source {source} has changed')
    for name, record in manifest['artifacts'].items():
        if sha256(destination/name) != record['sha256']:
            raise RuntimeError(f'Artifact differs from manifest: {name}')
    if set(manifest['artifacts']) != set(PARTS) | {'assembly_preview.png', 'assembly_exploded_preview.png'}:
        raise RuntimeError('Manifest does not contain the complete print set')
    print(f'Verified {len(manifest["artifacts"])} artifacts against both CAD sources.')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', type=Path, default=ROOT/'print_candidate')
    parser.add_argument('--openscad', default='openscad')
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    if args.verify:
        verify(args.out)
        return
    version = subprocess.run([args.openscad, '--version'], capture_output=True, text=True, check=True)
    manifest = {'design_revision':'rework', 'parameters':'source defaults; cable_od=8 for clamp',
                'openscad_version':(version.stdout+version.stderr).strip(),
                'sources_sha256':{p:sha256(ROOT/p) for p in sorted({x[0] for x in PARTS.values()})},
                'artifacts':{}}
    with tempfile.TemporaryDirectory(prefix='hafele-print-build-') as temp:
        directory = Path(temp)
        for name, (source, selector) in PARTS.items():
            output = directory/name
            run_openscad([args.openscad, '-o', str(output), '-D', f'show_part="{selector}"',
                          '-D', 'design_revision="rework"', '-D', 'cable_od=8', str(ROOT/source)])
            metrics = mesh_metrics(output)
            if not (metrics['watertight'] and metrics['winding_consistent']
                    and metrics['solid_components'] == 1 and metrics['volume_mm3'] > 0):
                raise RuntimeError(f'Invalid printable part {name}: {metrics}')
            manifest['artifacts'][name] = {'sha256':sha256(output), 'metrics':metrics}
        for exploded in (False, True):
            name = 'assembly_exploded_preview.png' if exploded else 'assembly_preview.png'
            output = directory/name
            run_openscad([args.openscad, '--render', '--autocenter', '--viewall', '--projection=o',
                          '--imgsize=900,700', '-o', str(output), '-D', 'show_part="assembly"',
                          '-D', 'design_revision="rework"', '-D', f'show_exploded={str(exploded).lower()}',
                          str(ROOT/'hafele_control_box.scad')])
            manifest['artifacts'][name] = {'sha256':sha256(output)}
        args.out.mkdir(parents=True, exist_ok=True)
        for name in manifest['artifacts']:
            shutil.copyfile(directory/name, args.out/name)
        (args.out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    verify(args.out)


if __name__ == '__main__':
    main()
