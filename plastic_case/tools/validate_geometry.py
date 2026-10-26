#!/usr/bin/env python3
"""Export FreeCAD and OpenSCAD meshes for each configuration and compare geometry.
Requires FreeCAD Python, OpenSCAD CLI, trimesh, numpy, and rtree.
"""
import argparse, hashlib, importlib.util, json, os, subprocess, sys, tempfile
from pathlib import Path
import numpy as np
import trimesh
from cad_sources import source_hashes


def metrics(path):
    m=trimesh.load(path,force='mesh')
    comps=m.split(only_watertight=False)
    return {'bounds_mm':m.bounds.tolist(),'volume_mm3':float(m.volume),'area_mm2':float(m.area),'components':int(sum(c.volume>0 for c in comps)),'shells':len(comps),'zero_volume_shells':int(sum(c.volume==0 for c in comps)),'watertight':bool(m.is_watertight),'winding_consistent':bool(m.is_winding_consistent),'mesh':m}

def surface_samples(mesh,n,seed):
    p,_=trimesh.sample.sample_surface(mesh,n,seed=seed)
    # Add deterministic vertices and face centroids so narrow local features
    # are not missed by random area sampling alone.
    centroids=mesh.triangles_center
    if len(centroids)>50000:
        centroids=centroids[np.linspace(0,len(centroids)-1,50000,dtype=int)]
    vertices=mesh.vertices
    if len(vertices)>50000:
        vertices=vertices[np.linspace(0,len(vertices)-1,50000,dtype=int)]
    return np.vstack((p,centroids,vertices))

def compare(a,b,pitch=1.0,n=10000):
    am,bm=a['mesh'],b['mesh']
    pa=surface_samples(am,n,42); pb=surface_samples(bm,n,43)
    closest_b,da,_=trimesh.proximity.ProximityQuery(bm).on_surface(pa)
    closest_a,db,_=trimesh.proximity.ProximityQuery(am).on_surface(pb)
    ia=int(np.argmax(da)); ib=int(np.argmax(db))
    result = {'bbox_max_abs_delta_mm':float(np.max(np.abs(am.bounds-bm.bounds))),
            'volume_abs_delta_mm3':abs(float(am.volume-bm.volume)),
            'surface_distance_a_to_b_mm':{'p95':float(np.percentile(da,95)),'max_sampled':float(np.max(da)),'max_point_mm':pa[ia].tolist(),'closest_point_mm':closest_b[ia].tolist()},
            'surface_distance_b_to_a_mm':{'p95':float(np.percentile(db,95)),'max_sampled':float(np.max(db)),'max_point_mm':pb[ib].tolist(),'closest_point_mm':closest_a[ib].tolist()},
            'components_a':a['components'],'components_b':b['components'],
            'watertight_a':a['watertight'],'watertight_b':b['watertight'],
            'topology_passed':topology_ok(a,b),
            'surface_sampling':{'random_points_per_direction':n, 'total_points_a':len(pa), 'total_points_b':len(pb), 'certified_hausdorff_upper_bound':False}}
    if result['topology_passed']:
        result.update(symmetric_difference(am,bm,pitch))
    else:
        result['symmetric_difference_method']='unavailable_invalid_topology'
    return result

def topology_ok(a, b):
    return all(m['watertight'] and m['winding_consistent']
               and m['components'] == 1 and m.get('zero_volume_shells', 0) == 0
               and np.isfinite(m['volume_mm3']) and m['volume_mm3'] > 0
               for m in (a, b))


def symmetric_difference(am, bm, pitch):
    """Boolean of tessellated inputs; finite precision, not exact BRep identity."""
    if importlib.util.find_spec('manifold3d') is not None:
        ab = trimesh.boolean.difference([am, bm], engine='manifold')
        ba = trimesh.boolean.difference([bm, am], engine='manifold')
        va, vb = max(0.0, float(ab.volume)), max(0.0, float(ba.volume))
        return {'symmetric_difference_method':'manifold3d_tessellated_mesh_boolean',
                'symmetric_difference_mesh_mm3':va+vb,
                'a_minus_b_mesh_mm3':va, 'b_minus_a_mesh_mm3':vb,
                'symmetric_difference_limitations':
                    'Finite-precision boolean of tessellated inputs, not an exact BRep proof.'}
    # Cell centres are sampled on one shared world-space lattice. Independently
    # voxelizing each mesh and rounding two different grids can conceal offsets.
    start = np.floor(np.minimum(am.bounds[0], bm.bounds[0])/pitch).astype(int)
    stop = np.ceil(np.maximum(am.bounds[1], bm.bounds[1])/pitch).astype(int)
    shape = np.maximum(stop-start, 1)
    count, different = int(np.prod(shape)), 0
    for offset in range(0, count, 50000):
        flat = np.arange(offset, min(offset+50000, count))
        indices = np.column_stack(np.unravel_index(flat, tuple(shape)))
        points = (indices+start+0.5)*pitch
        different += int(np.count_nonzero(am.contains(points)^bm.contains(points)))
    return {'symmetric_difference_method':'shared_world_lattice_occupancy_estimate',
            'symmetric_difference_voxel_mm3_estimate':different*pitch**3,
            'voxel_pitch_mm':pitch,
            'symmetric_difference_limitations':
                'Cell-centre occupancy estimate; sub-pitch differences may be missed.'}


def comparison_passed(comparison, tolerance):
    distances = [comparison['bbox_max_abs_delta_mm'],
                 comparison['surface_distance_a_to_b_mm']['max_sampled'],
                 comparison['surface_distance_b_to_a_mm']['max_sampled']]
    return bool(comparison['topology_passed'] and all(np.isfinite(distances))
                and max(distances) <= tolerance)


def source_validation(inventory, parameterized):
    """Never call retained geometry from an invalid variant parametric proof."""
    problems = list(inventory.get('recompute', {}).get('errors', []))
    states = []
    for obj in inventory['objects']:
        state = obj.get('state', obj.get('solver', {}).get('state', []))
        entry = {'object':obj['name'], 'type':obj['type'], 'state':state}
        if 'solver' in obj:
            entry['solver'] = obj['solver']
        states.append(entry)
        if any(str(x).lower() in {'invalid', 'error', 'touched', 'recompute error'} for x in state):
            problems.append({'object':obj['name'], 'state':state})
    for solid in inventory.get('final_solids', []):
        if not solid.get('is_valid') or not solid.get('is_watertight_brep'):
            problems.append({'object':solid['object'], 'error':'Invalid final BRep'})
    invalid = bool(problems)
    classification = ('invalid_parameter_recompute' if parameterized else
                      'source_snapshot_only') if invalid else 'recomputed_valid'
    return {'classification':classification, 'parameterized':parameterized,
            'parameter_equivalence_eligible':not invalid,
            'comparison_allowed':not (invalid and parameterized),
            'problems':problems, 'object_states':states}


def freecad_environment():
    environment = dict(os.environ)
    mac_lib = Path('/Applications/FreeCAD.app/Contents/Resources/lib')
    if mac_lib.is_dir():
        environment.setdefault('PYTHONPATH', str(mac_lib))
        environment.setdefault('LD_LIBRARY_PATH', str(mac_lib))
    return environment


def validate_configurations(args):
    configs = json.loads(Path(args.configs).read_text())
    inventory = json.loads((Path(__file__).resolve().parents[1]/'freecad_model_inventory.json').read_text())
    sheet = next(o for o in inventory['objects'] if o['type']=='Spreadsheet::Sheet')
    aliases = {c['alias'] for c in sheet['cells'] if c.get('alias')}
    results = []
    for cfg in configs:
        params = cfg['parameters']
        record = {'configuration':cfg['name'], 'parameters':params, 'parts':[], 'passed':False}
        with tempfile.TemporaryDirectory(prefix='hafele-validate-') as td:
            fc_params = {k:v for k,v in params.items() if k in aliases}
            paramfile = Path(td)/'parameters.json'
            paramfile.write_text(json.dumps(fc_params))
            try:
                subprocess.run([args.freecad_python, str(Path(__file__).with_name('export_freecad.py')),
                                args.source, td, str(paramfile)], check=True,
                               env=freecad_environment(), capture_output=True, text=True)
                source_inventory = json.loads((Path(td)/'freecad_model_inventory.json').read_text())
                record['inputs_sha256'] = {
                    'freecad':source_inventory.get('source_sha256'),
                }
                record['source_validation'] = source_validation(source_inventory, bool(fc_params))
                if not record['source_validation']['comparison_allowed']:
                    record['validation_error']='FreeCAD variant recompute is invalid; retained geometry was not compared.'
                    results.append(record)
                    continue
                record['inputs_sha256']['openscad']=hashlib.sha256(Path(args.scad).read_bytes()).hexdigest()
                record['inputs_sha256']['scad_dependencies']=source_hashes([Path(args.scad)],Path(args.scad).parent)
                for part in ('case','lid'):
                    fc, sc = Path(td)/(part+'.stl'), Path(td)/('openscad_'+part+'.stl')
                    definitions=[]
                    for k,v in {**params,'show_part':part}.items():
                        definitions.extend(['-D',f'{k}={json.dumps(v)}'])
                    process=subprocess.run([args.openscad,'-o',str(sc),*definitions,args.scad],
                                           check=True,capture_output=True,text=True)
                    log=process.stdout+process.stderr
                    if 'ERROR:' in log or 'WARNING:' in log:
                        raise RuntimeError('OpenSCAD warning/error: '+log)
                    a,b=metrics(fc),metrics(sc)
                    c=compare(a,b,args.voxel_pitch,args.samples)
                    record['parts'].append({'part':part,
                        'freecad':{k:v for k,v in a.items() if k!='mesh'},
                        'openscad':{k:v for k,v in b.items() if k!='mesh'},
                        'comparison':c, 'within_0_05_mm':comparison_passed(c,0.05),
                        'distance_tolerance_mm':args.tolerance,
                        'passed':comparison_passed(c,args.tolerance)})
                record['passed']=all(p['passed'] for p in record['parts'])
            except (subprocess.CalledProcessError,RuntimeError,ValueError,OSError) as error:
                record['validation_error']=str(error)
                if isinstance(error,subprocess.CalledProcessError):
                    record['tool_output']=(error.stdout or '')+(error.stderr or '')
        results.append(record)
    return results


def main(argv=None):
    parser=argparse.ArgumentParser()
    parser.add_argument('--source',required=True)
    parser.add_argument('--scad',required=True)
    parser.add_argument('--configs',required=True)
    parser.add_argument('--freecad-python',required=True)
    parser.add_argument('--openscad',default='openscad')
    parser.add_argument('--out',default='geometry-validation.json')
    parser.add_argument('--tolerance',type=float,default=0.05)
    parser.add_argument('--samples',type=int,default=10000)
    parser.add_argument('--voxel-pitch',type=float,default=1.0)
    args=parser.parse_args(argv)
    if args.tolerance<=0 or args.samples<1 or args.voxel_pitch<=0:
        parser.error('tolerance, samples and voxel-pitch must be positive')
    results=validate_configurations(args)
    Path(args.out).write_text(json.dumps(results,indent=2)+'\n')
    print(json.dumps(results,indent=2))
    return 0 if results and all(r['passed'] for r in results) else 1


if __name__=='__main__':
    sys.exit(main())
