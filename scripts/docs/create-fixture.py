#!/usr/bin/env python3
"""Create only invented data in a new /private/tmp documentation fixture."""
import json, os, sqlite3, stat, struct, tempfile, uuid, zlib
from pathlib import Path

root = Path(tempfile.mkdtemp(prefix='konmagic-documentation-', dir='/private/tmp'))
state = root / 'State'
state.mkdir(mode=0o700)
sources = root / 'Sources'
sources.mkdir(mode=0o700)
(root / 'Organized').mkdir(mode=0o700)
paths = {
    'Projects/Orbit': ['Design brief.txt', 'Prototype notes.txt', 'Assembly.stl', 'Interface.svg', 'Roadmap.txt', 'Prototype.png'],
    'Personal/Family celebration': ['Ceremony.mov', 'Reception.mov', 'Photo album.jpg'],
    'Personal/Cinema': ['The invented journey.mp4', 'Film notes.txt'],
    'Research': ['Materials handbook.txt', 'Reference diagram.svg', 'Reading notes.txt'],
    'Administration': ['Quarterly budget.csv', 'Agreement draft.txt'],
    'Closed projects/Beacon': ['Retrospective.txt', 'Past design.stl'],
    'Intake': ['Unsorted notes.txt', 'New inspiration.jpg'],
}
for folder, names in paths.items():
    d = sources / folder
    d.mkdir(parents=True, mode=0o700)
    for i, name in enumerate(names):
        p = d / name
        p.write_text('SYNTHETIC DOCUMENTATION EXAMPLE\n' + f'{name}: an invented design, research or personal collection.\n' * (i + 2))
        if p.suffix in ['.mov', '.mp4', '.jpg', '.stl']:
            with p.open('r+b') as f:
                f.truncate((i + 2) * 2 * 1024 * 1024)
        os.chmod(p, 0o600)
# One valid invented image permits native Quick Look/thumbnail knowledge transfer.
def png_chunk(kind, body):
    return struct.pack('>I',len(body))+kind+body+struct.pack('>I',zlib.crc32(kind+body)&0xffffffff)
w,h=640,400
pixels=b''.join(b'\x00'+bytes(v for x in range(w) for v in (int(30+100*x/w),int(90+90*y/h),int(120+70*x/w))) for y in range(h))
(sources/'Projects/Orbit/Prototype.png').write_bytes(b'\x89PNG\r\n\x1a\n'+png_chunk(b'IHDR',struct.pack('>IIBBBBB',w,h,8,2,0,0,0))+png_chunk(b'IDAT',zlib.compress(pixels))+png_chunk(b'IEND',b''))
# Equal-data examples are small, synthetic, ordinary files.
for name in ['Reading copy A.txt', 'Reading copy B.txt']:
    (sources / 'Research' / name).write_text('Synthetic equal data for a documentation example.\n')
entries = sorted(sources.rglob('*'))
db = sqlite3.connect(state / 'catalog.sqlite3')
db.executescript('''CREATE TABLE roots(path TEXT,label TEXT,purpose TEXT);
CREATE TABLE items(id INTEGER PRIMARY KEY,path TEXT UNIQUE,name TEXT,kind TEXT,size INTEGER,tags TEXT,state TEXT,barrier TEXT,confidence REAL,evidence TEXT,reason TEXT,mtime_ns INTEGER,seen TEXT,manual INTEGER,extension TEXT,parent_path TEXT,shared_text_id INTEGER,hash TEXT,text BLOB);
CREATE INDEX parent_items ON items(parent_path,path);
CREATE VIRTUAL TABLE content_index USING fts5(item_id UNINDEXED,body);''')
db.execute('INSERT INTO roots VALUES(?,?,?)', (str(sources), 'Invented example library', 'synthetic documentation'))
for i, p in enumerate(entries, 1):
    s = p.stat()
    directory = p.is_dir()
    parts = p.relative_to(sources).parts
    project = parts[1] if len(parts)>1 and parts[0] in ['Projects', 'Personal', 'Closed projects'] else 'General reference'
    owner = 'Personal' if parts[0]=='Personal' else 'Example Studio'
    family = 'Folders' if directory else {'.mov':'Video','.mp4':'Video','.jpg':'Images','.png':'Images','.stl':'Fabrication','.svg':'Design','.csv':'Finance'}.get(p.suffix,'Documents')
    tags = dict(owner=owner, project=project, family=family, role='Memory' if 'celebration' in project else 'Reference', lifecycle='Archive' if parts[0]=='Closed projects' else 'Active', method='synthetic fixture')
    reading = not directory and p.suffix=='.txt'
    body = p.read_bytes() if reading else b''
    db.execute('INSERT INTO items VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', (i,str(p),p.name,'directory' if directory else 'file',s.st_size,json.dumps(tags),'extracted' if reading else 'metadata_only','',0.9,json.dumps(['Invented documentation fixture; no user data']), 'Synthetic example',s.st_mtime_ns,'2026-10-10T12:00:00Z',0,p.suffix,str(p.parent),0,'',zlib.compress(body) if body else ''))
    if reading: db.execute('INSERT INTO content_index VALUES(?,?)',(i,body.decode()))
db.commit();db.close()
disk = sqlite3.connect(state / 'disk-coverage.sqlite3')
disk.executescript('''CREATE TABLE meta(key TEXT,value TEXT);CREATE TABLE roots(path TEXT,status TEXT);CREATE TABLE directories(path BLOB PRIMARY KEY,metadata TEXT,total INTEGER,boundary TEXT);CREATE TABLE blocks(path BLOB,part INTEGER,entries BLOB);CREATE TABLE aliases(path BLOB,canonical BLOB);CREATE TABLE issues(path TEXT,reason TEXT);''')
disk.executemany('INSERT INTO meta VALUES(?,?)', [('entries',str(len(entries))),('status','finished'),('updated','2026-10-10T12:00:00Z'),('kinds',json.dumps({'file':sum(p.is_file() for p in entries), 'directory':sum(p.is_dir() for p in entries)})),('boundaries',json.dumps({'user_data':len(entries)}))])
disk.execute('INSERT INTO roots VALUES(?,?)',(str(sources),'finished'))
for d in [sources]+[p for p in entries if p.is_dir()]:
    key=zlib.compress(str(d).encode());rows=[]
    for p in sorted(d.iterdir()):
        s=p.stat();rows.append([p.name,'directory' if p.is_dir() else 'file',s.st_size,s.st_blocks*512,s.st_mtime_ns,s.st_dev,s.st_ino,0])
    disk.execute('INSERT INTO directories VALUES(?,?,?,?)',(key,'{}',len(rows),'user_data'))
    disk.execute('INSERT INTO blocks VALUES(?,0,?)',(key,zlib.compress(json.dumps(rows).encode())))
disk.commit();disk.close()
node_paths=['00 Inbox/To sort','10 Projects/Example Studio/Orbit','20 Areas/Example Studio/Finance','30 Resources/Research','30 Resources/Personal collections/Cinema','40 Archive/Personal/Family celebration','40 Archive/Example Studio/Beacon','90 Review/Unclassified']
nodes=[]
for path in node_paths:
    parent=None
    for name in path.split('/'):
        existing=next((n for n in nodes if n.get('parent')==parent and n['name']==name), None)
        if not existing:
            existing=dict(id=str(uuid.uuid4()),name=name)
            if parent: existing['parent']=parent
            nodes.append(existing)
        parent=existing['id']
workspace=dict(version=1,nodes=nodes,assignments=[],output=str(root/'Organized'),cataloguePath=str(state/'catalog.sqlite3'),welcomed=True,guidePage=0)
(state/'workspace.json').write_text(json.dumps(workspace,indent=2))
(state/'documentation-fixture').write_text('KonMagic synthetic documentation fixture v1\n')
for p in state.iterdir(): os.chmod(p,0o600)
print(state)
