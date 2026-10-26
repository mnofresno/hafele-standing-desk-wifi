#!/usr/bin/env python3
"""Extract a FreeCAD document inventory and export final body solids to STL/STEP.
Run with FreeCAD's bundled Python: FreeCAD Python export_freecad.py file.FCStd outdir.
"""
import hashlib, json, os, sys
import FreeCAD as App
import Part, Mesh, MeshPart


def vector(v): return [float(v.x), float(v.y), float(v.z)]
def box(b): return [float(b.XMin), float(b.YMin), float(b.ZMin), float(b.XMax), float(b.YMax), float(b.ZMax)]
def geom(g):
    d={'type':type(g).__name__}
    for attr in ('StartPoint','EndPoint','Center','Radius','Axis','Angle','XAxis','YAxis'):
        if hasattr(g,attr):
            val=getattr(g,attr)
            d[attr]=vector(val) if hasattr(val,'x') else float(val) if isinstance(val,(int,float)) else str(val)
    if hasattr(g,'FirstParameter'): d.update(first_parameter=float(g.FirstParameter),last_parameter=float(g.LastParameter))
    return d

def constraint_record(sketch, constraint, index):
    data = {'type':constraint.Type,'value':float(constraint.Value),
            'first':int(constraint.First),'first_position':int(constraint.FirstPos),
            'second':int(constraint.Second),'second_position':int(constraint.SecondPos),
            'third':int(constraint.Third),'third_position':int(constraint.ThirdPos),
            'name':str(constraint.Name)}
    try:
        data['driving'] = bool(sketch.getDriving(index))
    except (ValueError,RuntimeError):
        # FreeCAD does not expose driving state for every constraint type.
        data['driving'] = None
    return data

def main(path,outdir,param_path=None):
    os.makedirs(outdir,exist_ok=True)
    doc=App.openDocument(os.path.abspath(path))
    if param_path:
        values=json.load(open(param_path)); sheet=doc.getObject('Spreadsheet001')
        for alias,value in values.items():
            cell=sheet.getCellFromAlias(alias)
            if not cell: raise ValueError('Unknown spreadsheet alias: '+alias)
            sheet.set(cell,str(value))
    recompute={'calls':[],'errors':[]}
    def recompute_document(phase):
        try:
            result=doc.recompute()
            recompute['calls'].append({'phase':phase,'success':result})
            if result is False:
                recompute['errors'].append({'phase':phase,'error':'Document recompute returned False'})
        except Exception as error:
            recompute['errors'].append({'phase':phase,'error':str(error)})
    recompute_document('initial')
    for iteration in range(3):
        for obj in doc.Objects:
            try:
                if 'Touched' in obj.State: obj.recompute()
            except Exception as error:
                recompute['errors'].append({'object':obj.Name,'iteration':iteration,'error':str(error)})
        recompute_document('settle_'+str(iteration))
    with open(path,'rb') as source:
        source_sha256=hashlib.sha256(source.read()).hexdigest()
    data={'source':os.path.abspath(path),'source_sha256':source_sha256,'freecad_version':App.Version(),
          'document':doc.Name,'recompute':recompute,'objects':[],'spreadsheet':[],'final_solids':[]}
    for o in doc.Objects:
        rec={'name':o.Name,'label':o.Label,'type':o.TypeId,'state':list(o.State),'properties':{},'expressions':[],
             'dependencies':[x.Name for x in o.OutList],
             'dependents':[x.Name for x in o.InList]}
        if hasattr(o,'Placement'):
            rec['placement']={'base':vector(o.Placement.Base),
                              'rotation_quaternion':list(o.Placement.Rotation.Q)}
        try: rec['expressions']=[[str(a),str(b)] for a,b in o.ExpressionEngine]
        except: pass
        if o.TypeId=='Sketcher::SketchObject':
            rec['placement']['rotation']=str(o.Placement.Rotation)
            rec['solver']={'fully_constrained':bool(getattr(o,'FullyConstrained',False)),
                           'degrees_of_freedom':int(getattr(o,'DoF',-1)),
                           'state':list(o.State)}
            rec['geometry']=[{**geom(g),'construction':bool(o.getConstruction(i))}
                             for i,g in enumerate(o.Geometry)]
            rec['external_geometry']=[{'object':obj.Name,'subelements':list(subelements)}
                                      for obj,subelements in o.ExternalGeometry]
            rec['constraints']=[constraint_record(o,c,i) for i,c in enumerate(o.Constraints)]
        if o.TypeId=='Spreadsheet::Sheet':
            for cell in o.getNonEmptyCells():
                rec['cells'].append({'cell':cell,'contents':o.getContents(cell),'alias':o.getAlias(cell) or None}) if 'cells' in rec else rec.update(cells=[{'cell':cell,'contents':o.getContents(cell),'alias':o.getAlias(cell) or None}])
        for p in o.PropertiesList:
            if p in ('Shape','Group','Geometry','Constraints','cells','ExpressionEngine','InternalShape','ShapeMaterial'): continue
            try:
                v=getattr(o,p)
                if hasattr(v,'Value') and hasattr(v,'Unit'): rec['properties'][p]={'value':float(v.Value),'unit':str(v.Unit)}
                elif isinstance(v,(str,int,float,bool)): rec['properties'][p]=v
                elif p in ('Profile','Base','BaseFeature','Tip','Support','AttachmentSupport'): rec['properties'][p]=str(v)
            except Exception: pass
        if hasattr(o,'Shape') and not o.Shape.isNull():
            s=o.Shape
            rec['shape']={'solids':len(s.Solids),'volume_mm3':float(s.Volume),'area_mm2':float(s.Area),'bbox_mm':box(s.BoundBox),'is_valid':bool(s.isValid())}
        data['objects'].append(rec)
    # Export only terminal solids of each PartDesign body, avoiding duplicate intermediate features.
    for o in doc.Objects:
        if o.TypeId!='PartDesign::Body': continue
        feature=o.Tip if getattr(o,'Tip',None) else o
        s=feature.Shape
        if s.isNull() or not s.Solids: continue
        label='lid' if 'lid' in o.Label.lower() or 'tapa' in o.Label.lower() else 'case' if 'case' in o.Label.lower() else o.Name
        stl=os.path.join(outdir,label+'.stl'); step=os.path.join(outdir,label+'.step')
        # Fine tessellation keeps mesh discretization below the requested
        # 0.05 mm model tolerance; the STEP remains the exact BRep reference.
        mesh=MeshPart.meshFromShape(Shape=s,LinearDeflection=0.01,
                                    AngularDeflection=0.1,Relative=False)
        mesh.write(stl)
        Part.export([feature],step)
        data['final_solids'].append({'object':o.Name,'label':o.Label,'stl':os.path.basename(stl),'step':os.path.basename(step),'solids':len(s.Solids),'volume_mm3':float(s.Volume),'area_mm2':float(s.Area),'bbox_mm':box(s.BoundBox),'is_valid':bool(s.isValid()),'is_watertight_brep':all(x.isClosed() for x in s.Solids),'recompute_state':list(feature.State)})
    with open(os.path.join(outdir,'freecad_model_inventory.json'),'w') as f: json.dump(data,f,indent=2,ensure_ascii=False)
    print(json.dumps(data['final_solids'],indent=2))

if __name__=='__main__': main(sys.argv[1],sys.argv[2],sys.argv[3] if len(sys.argv)>3 else None)
