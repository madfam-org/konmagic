#!/usr/bin/env python3
"""Promote only a completed invented capture, after visual review by a maintainer."""
import argparse, hashlib, json, shutil, struct
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('fixture_root',type=Path);p.add_argument('--appearance',choices=['light','dark'],required=True);p.add_argument('--reviewed',action='store_true');p.add_argument('--review-metadata',action='store_true');a=p.parse_args()
r=a.fixture_root
if not a.reviewed:raise SystemExit('Visually inspect every synthetic image first, then pass --reviewed.')
if not str(r).startswith('/private/tmp/konmagic-documentation-') or r.is_symlink():raise SystemExit('Only generated temporary documentation fixtures are accepted')
if (r/'State/documentation-fixture').read_text()!='KonMagic synthetic documentation fixture v1\n':raise SystemExit('Invalid fixture marker')
if a.review_metadata:
 log=(r/'review.log').read_text()
 if 'REVIEW_UI_QA passed=true' not in log:raise SystemExit('Synthetic review acceptance run did not pass')
 files=[r/'review-comparison.png',r/'review-duplicates.png'];fixture='synthetic-review-metadata-v1'
else:
 log=(r/f'capture-{a.appearance}.log').read_text()
 if 'DOCUMENTATION_CAPTURE passed=true' not in log:raise SystemExit('Documentation capture did not pass')
 files=sorted((r/('Dark screenshots' if a.appearance=='dark' else 'Light screenshots')).glob('*.png'));fixture='generated-documentation-library-v1'
 if len(files)!=52:raise SystemExit(f'Expected 52 owned-view captures, got {len(files)}')
assets=ROOT/'docs/assets/screenshots';manifest=assets/'manifest.json'
m=json.loads(manifest.read_text()) if manifest.exists() else {'schema':1,'app_version':'0.5.3','synthetic_only':True,'images':[]}
for f in files:
 if f.is_symlink() or not f.is_file():raise SystemExit('Linked or absent capture')
 name=f.stem.removeprefix('review-') if a.review_metadata else f.stem
 target=f'{a.appearance}-{name}.png'
 title=name.replace('-',' ').title()
 caption='Real native AppKit view populated exclusively by the invented documentation library; no personal catalogue or file content. Capture performs no approved copy.'
 if name=='review-verified':caption='Exact preview verified against one small generated temporary file using the test-only fixture allowance. No copy is approved.'
 if name=='comparison':caption='Synthetic metadata acceptance fixture with 601 added records; complete comparison paging remains available beyond the visible 500 rows.'
 if name=='duplicates':caption='Synthetic equal-size candidate fixture with 601 invented records. It exceeds the 100-file proof bound and enables no automatic body hashing or deletion.'
 shutil.copyfile(f,assets/target)
 width,height=struct.unpack('>II',f.read_bytes()[16:24])
 row=dict(width=width,height=height,file=target,title=title,alt=f'KonMagic native {title.lower()} with synthetic example data',caption=caption,appearance=a.appearance,app_version='0.5.3',fixture=fixture,scenario='--review-ui-smoke' if a.review_metadata else '--documentation-capture',sha256=hashlib.sha256(f.read_bytes()).hexdigest())
 m['images']=[x for x in m['images'] if x['file']!=target]+[row]
m['app_version']='0.5.3'
m['images']=sorted(m['images'],key=lambda x:x['file']);manifest.write_text(json.dumps(m,indent=2,sort_keys=True)+'\n')
print(f'Promoted {len(files)} reviewed invented captures; manifest total {len(m["images"])}.')
