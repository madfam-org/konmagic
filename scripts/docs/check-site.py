#!/usr/bin/env python3
"""Validate local site links/anchors, synthetic asset hashes and native Help routes."""
import hashlib, json, os, re, sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
ROOT=Path(__file__).resolve().parents[2]
SITE=ROOT/'.build/docs-site'
errors=[]
local_user=Path.home().name
private_user=local_user if local_user not in {'runner','root','example','user','build'} else None
private_session=os.environ.get('CODEX_THREAD_ID')
manifest=ROOT/'docs/assets/screenshots/manifest.json'
if not manifest.exists(): raise SystemExit('Missing synthetic screenshot manifest')
m=json.loads(manifest.read_text())
assert m['synthetic_only'] is True and m['app_version']=='0.5.1'
images=m['images'];listed=set()
for row in images:
 p=manifest.parent/row['file'];listed.add(row['file'])
 if '/' in row['file'] or not p.is_file() or p.is_symlink():errors.append('Invalid asset '+row['file']);continue
 if hashlib.sha256(p.read_bytes()).hexdigest()!=row['sha256']:errors.append('Asset hash differs '+row['file'])
 if row['fixture'] not in ['generated-documentation-library-v1','synthetic-review-metadata-v1']:errors.append('Unknown fixture '+row['file'])
 if not all(row.get(k) for k in ['alt','caption','scenario','appearance','title']):errors.append('Missing screenshot knowledge-transfer fields '+row['file'])
if listed!={p.name for p in manifest.parent.glob('*.png')}:errors.append('Unmanifested or missing screenshots')
for p in list((ROOT/'docs').rglob('*'))+[ROOT/'mkdocs.yml']:
 if p.suffix in ['.md','.json','.js','.css','.yml']:
  s=p.read_text()
  if re.search(r'/Users/(?!example(?:/|\b)|<)[A-Za-z0-9_.-]+|\.machine-audit',s) or (private_user and private_user in s) or (private_session and private_session in s):errors.append('Private path/identity in '+str(p.relative_to(ROOT)))
class Page(HTMLParser):
 def __init__(self):super().__init__();self.ids=set();self.links=[];self.images=[]
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  if 'id' in a:self.ids.add(a['id'])
  if tag in ['a','link'] and a.get('href'):self.links.append(a['href'])
  if tag in ['img','script'] and a.get('src'):self.links.append(a['src'])
  if tag=='img' and 'assets/screenshots/' in a.get('src','') and not a.get('alt'):errors.append('Screenshot lacks alt text')
parsed={}
for p in SITE.rglob('*.html'):
 h=Page();h.feed(p.read_text());parsed[p.resolve()]=h
links=0
for p,h in parsed.items():
 for link in h.links:
  u=urlsplit(link)
  if u.scheme or u.netloc or link.startswith('data:'):continue
  path=unquote(u.path)
  if path.startswith('/konmagic/'):target=SITE/path.removeprefix('/konmagic/')
  elif path.startswith('/'):target=SITE/path.lstrip('/')
  elif not path:target=p
  else:target=p.parent/path
  if target.is_dir():target=target/'index.html'
  target=target.resolve();links+=1
  if not target.exists():errors.append(f'Broken local link {p.relative_to(SITE)} → {link}');continue
  if u.fragment and target.suffix=='.html' and unquote(u.fragment) not in parsed.get(target,Page()).ids:errors.append(f'Broken anchor {p.relative_to(SITE)} → {link}')
swift=(ROOT/'Sources/Documentation.swift').read_text()
routes=sorted(set(re.findall(r'"(guide/[^\"]+/)"',swift)))+['','developer/architecture/']
for route in routes:
 if not (SITE/route/'index.html').is_file():errors.append('Missing native Help route '+route)
if len(routes)!=9:errors.append('Expected 5 page routes + previews/evidence + home/developer')
if errors:
 print('\n'.join(sorted(set(errors))));raise SystemExit(1)
print(f'DOCS_CHECK passed=true; pages={len(parsed)}; localLinks={links}; screenshots={len(images)}; publicHelpRoutes=9; privateIdentityMatches=0')
