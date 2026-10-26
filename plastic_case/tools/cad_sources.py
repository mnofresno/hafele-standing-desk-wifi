"""Hash entry SCAD files and their local include/use dependencies."""
import hashlib
from pathlib import Path
import re


def source_hashes(sources, root):
    root=Path(root).resolve()
    pending=[Path(p).resolve() for p in sources]
    result={}
    seen=set()
    while pending:
        source=pending.pop()
        if source in seen:
            continue
        seen.add(source)
        data=source.read_bytes()
        try:
            name=source.relative_to(root).as_posix()
        except ValueError:
            name=source.as_posix()
        result[name]=hashlib.sha256(data).hexdigest()
        code=re.sub(r'/\*.*?\*/|//[^\n]*','',data.decode(),flags=re.S)
        for include in re.findall(r'^\s*(?:include|use)\s*<([^>]+)>',code,flags=re.M):
            pending.append((source.parent/include).resolve())
    return dict(sorted(result.items()))
