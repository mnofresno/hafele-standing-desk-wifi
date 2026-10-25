#!/usr/bin/env python3
"""Export FreeCAD and OpenSCAD meshes for each configuration and compare geometry.
Requires FreeCAD Python, OpenSCAD CLI, trimesh, numpy, and rtree.
"""
import argparse, json, os, subprocess, tempfile
import numpy as np
import trimesh


def metrics(path):
    m=trimesh.load(path,force='mesh')
    comps=m.split(only_watertight=False)
    return {'bounds_mm':m.bounds.tolist(),'volume_mm3':float(m.volume),'area_mm2':float(m.area),'components':len(comps),'watertight':bool(m.is_watertight),'winding_consistent':bool(m.is_winding_consistent),'mesh':m}

def surface_samples(mesh,n,seed):
    p,_=trimesh.sample.sample_surface(mesh,n,seed=seed)
    return p

def compare(a,b,pitch=1.0,n=2500):
    am,bm=a['mesh'],b['mesh']
    pa=surface_samples(am,n,42); pb=surface_samples(bm,n,43)
    da=trimesh.proximity.ProximityQuery(bm).on_surface(pa)[1]
    db=trimesh.proximity.ProximityQuery(am).on_surface(pb)[1]
    # Voxelize each surface, fill its interior, then align voxel centres on a shared grid.
    lo=np.minimum(am.bounds[0],bm.bounds[0])-pitch; hi=np.maximum(am.bounds[1],bm.bounds[1])+pitch
    dims=np.ceil((hi-lo)/pitch).astype(int)
    occ=[]
    for mesh in (am,bm):
        vox=mesh.voxelized(pitch,method="ray").fill()
        ijk=np.rint((vox.points-lo)/pitch-0.5).astype(int)
        grid=np.zeros(tuple(dims),dtype=bool)
        good=np.all((ijk>=0)&(ijk<dims),axis=1)
        grid[tuple(ijk[good].T)]=True
        occ.append(grid)
    xor=int(np.count_nonzero(occ[0]^occ[1]))
    return {'bbox_max_abs_delta_mm':float(np.max(np.abs(am.bounds-bm.bounds))),
            'volume_abs_delta_mm3':abs(float(am.volume-bm.volume)),
            'symmetric_difference_voxel_mm3_estimate':xor*pitch**3,
            'voxel_pitch_mm':pitch,
            'surface_distance_a_to_b_mm':{'p95':float(np.percentile(da,95)),'max_sampled':float(np.max(da))},
            'surface_distance_b_to_a_mm':{'p95':float(np.percentile(db,95)),'max_sampled':float(np.max(db))},
            'components_a':a['components'],'components_b':b['components'],
            'watertight_a':a['watertight'],'watertight_b':b['watertight']}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--source',required=True); ap.add_argument('--scad',required=True); ap.add_argument('--configs',required=True)
    ap.add_argument('--freecad-python',required=True); ap.add_argument('--openscad',default='openscad'); ap.add_argument('--out',default='geometry-validation.json')
    args=ap.parse_args(); configs=json.load(open(args.configs)); result=[]
    for cfg in configs:
        name=cfg['name']; params=cfg['parameters']
        with tempfile.TemporaryDirectory(prefix='hafele-validate-') as td:
            paramfile=os.path.join(td,'parameters.json'); json.dump(params,open(paramfile,'w'))
            subprocess.run([args.freecad_python,os.path.join(os.path.dirname(__file__),'export_freecad.py'),args.source,td,paramfile],check=True,env={**os.environ,'PYTHONPATH':'/Applications/FreeCAD.app/Contents/Resources/lib','LD_LIBRARY_PATH':'/Applications/FreeCAD.app/Contents/Resources/lib'},stdout=subprocess.DEVNULL)
            sr=[]
            for part in ('case','lid'):
                fc=os.path.join(td,part+'.stl'); sc=os.path.join(td,'openscad_'+part+'.stl')
                definitions=[f'-D {k}={json.dumps(v)}' for k,v in {**params,'show_part':part}.items()]
                subprocess.run([args.openscad,'-o',sc,*definitions,args.scad],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
                a,b=metrics(fc),metrics(sc); c=compare(a,b)
                sr.append({'part':part,'freecad':{k:v for k,v in a.items() if k!='mesh'},'openscad':{k:v for k,v in b.items() if k!='mesh'},'comparison':c,'within_0_05_mm':max(c['bbox_max_abs_delta_mm'],c['surface_distance_a_to_b_mm']['max_sampled'],c['surface_distance_b_to_a_mm']['max_sampled'])<=0.05})
            result.append({'configuration':name,'parameters':params,'parts':sr})
    with open(args.out,'w') as f: json.dump(result,f,indent=2)
    print(json.dumps(result,indent=2))
if __name__=='__main__': main()
