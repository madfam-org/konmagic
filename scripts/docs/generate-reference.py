#!/usr/bin/env python3
"""Deterministic source-linked declaration index and synthetic screenshot gallery."""
import json, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / 'docs'
repo = 'https://github.com/madfam-org/konmagic/blob/main/'
modules = {
'App': 'Application startup, menus, Structure, source browser and preview/copy commands.',
'Model': 'Validated virtual nodes, exact assignments, workspace persistence and session draft undo.',
'Filesystem': 'Descriptor identity, eligibility, no-follow traversal, full hashing, copy plans and durable publication.',
'Navigation': 'Five-page cached hosts, viewport/history, shared decisions, active routing and additional windows.',
'ToolkitUI': 'Four-stage overview, private coverage summary and public documentation entry.',
'ReorganizationReviewUI': 'Exact path review, assignment search, verified child paging and complete manifest export.',
'Catalog': 'Live bounded source metadata and compatible tagged observation adapter.',
'CatalogueDatabase': 'Read-only SQLite, compression, query slices, partitions, FTS and tag overlay queries.',
'DiskCatalogue': 'Compressed whole-disk ledger, aliases, exceptions and stamped aggregate caches.',
'CatalogueExplorer': 'Dataset/query/facet/list/tree/map controls, evidence and exact destination handoff.',
'CatalogueVisuals': 'Content treemap and bounded semantic relationship drawing.',
'Knowledge': 'Exact-path human corrections, saved collections/rules, naming and draft proposal semantics.',
'KnowledgeUI': 'Native classification, collection and proposal dialogs.',
'DiskLensModel': 'Scan nodes/snapshots/totals, metrics/display/colors, filters and preferences.',
'DiskLensScan': 'Current metadata traversal, historical ledger import and filtered derived observations.',
'DiskLensStore': 'Private SQLite writer, parent folding and bounded retained tree reader.',
'DiskLensController': 'Storage controls, selection/current checks, observation work and destination handoff.',
'DiskLensMap': 'Proportional adaptive layout and native canvas interaction.',
'DiskLensFilters': 'Native compound filter editor and type-color customization.',
'DiskLensExports': 'Complete export, root-matched metadata difference paging and image export support.',
'DiskLensWatcher': 'Current-session FSEvents history and gap-aware refresh decisions.',
'DuplicateReview': 'Size candidates, bounded explicit complete-hash proof and no-delete evidence UI.',
'ScanComparisonUI': 'Paged complete metadata comparison and full text export.',
'VolumeContext': 'Bounded read-only diskutil volume/container/snapshot context.',
'ContextHelp': 'Native contextual explanations and popover guidance.',
'InspectorTypography': 'Native path/evidence text and dialog layout helpers.',
'MetadataLabels': 'Human-readable retained metadata labels.',
'Documentation': 'Fixed public HTTPS routes and active-page native Help actions.',
'SourcePreview': 'Embedded native file Quick Look, paged folder list/gallery, explicit bounded thumbnails and metadata-only tree/map handoff.',
'SourcePreviewTests': 'Synthetic preview identity, link, protected name and changed-source refusal checks.',
'DocumentationCapture': 'Restricted generated fixture validation and owned synthetic window screenshot workflow.',
'main': 'Explicit diagnostic dispatch and native application entry point.',
}
files = sorted((ROOT/'Sources').glob('*.swift'))
lines=['# Source module map','', 'This inventory follows the current source tree. Links point to public generic implementation; private runtime data is never embedded.', '', '| Module | Responsibility |', '|---|---|']
for p in files:
 desc=modules.get(p.stem, 'Synthetic verification and native UI acceptance checks.' if 'Tests' in p.stem else 'Native support module; inspect the source-linked declaration index.')
 lines.append(f'| [{p.name}]({repo}Sources/{p.name}) | {desc} |')
lines+=['','## Where to start','', '| Change | Read first |', '|---|---|', '| Destination hierarchy | Model → App → Review |', '| Search/facets/readings | CatalogueDatabase → Catalog → CatalogueExplorer → Knowledge |', '| Scan size/coverage/maps | DiskLensModel → Scan → Store → Map → Controller |', '| Copy or recovery behavior | Filesystem → App → Review → Tests |', '| Another page/window | Navigation → page controller → NavigationTestsUI |', '| Public manual link | Documentation → App/ToolkitUI → docs route validation |', '| Screenshot workflow | DocumentationCapture → scripts/docs → manifest/gallery |', '', '[Complete declaration index](../reference/symbols.md). This index lists source declarations; it is not a compiler-generated call graph or a stable external API.']
(DOCS/'developer/modules.md').write_text('\n'.join(lines).rstrip()+'\n')
index=['# Source declaration index','', 'Generated from the current Swift sources. Includes internal and test declarations; names here are navigation aids, not an exported SDK contract. The regex-based index does not infer call graphs, access guarantees or complete overload semantics.', '']
count=0
for p in files:
 declarations=[]
 for n,line in enumerate(p.read_text().splitlines(),1):
  if re.match(r'^\s*(?:(?:private|final|static|override|@objc|mutating)\s+)*(?:class|struct|enum|func|init)\b',line):
   signature=line.split(' {')[0].strip()
   if len(signature)>210: signature=signature[:207]+'…'
   signature=signature.replace('|','\\|').replace('`','')
   declarations.append(f'| `{signature}` | [L{n}]({repo}Sources/{p.name}#L{n}) |')
 if declarations:
  index += [f'## {p.name}','', '| Declaration | Source |','|---|---|']+declarations+['']
  count+=len(declarations)
(DOCS/'reference/symbols.md').write_text('\n'.join(index).rstrip()+'\n')
manifest=DOCS/'assets/screenshots/manifest.json'
if manifest.exists():
 data=json.loads(manifest.read_text());images=data['images']
 gallery=['# Screenshot atlas','', f"**{len(images)} native screenshots · KonMagic {data['app_version']} · entirely invented fixture data.**", '', 'All images depict real AppKit views. Example sources, tags and readings are synthetic. No ordinary local QA image or personal catalogue is included. Enlarge images with the image button; Escape closes the viewer. See [testing/capture workflow](../developer/testing.md) and [documentation maintenance](../developer/documentation.md).', '']
 for item in images:
  gallery += [f"## {item['title']} · {item['appearance']}", '', f'<figure markdown>\n![{item["alt"]}](../assets/screenshots/{item["file"]}){{ loading=lazy decoding=async width="{item["width"]}" height="{item["height"]}" }}\n<figcaption>{item["caption"]}</figcaption>\n</figure>', '', f"Capture: `{item['scenario']}` · Origin: `{item['fixture']}` · SHA-256: `{item['sha256']}`", '']
 (DOCS/'reference/screenshots.md').write_text('\n'.join(gallery).rstrip()+'\n')
welcome=['# The eight-page native welcome guide','', 'The local Welcome guide introduces the Toolkit, manual ownership, drops/buckets, semantic decisions, retained Content/Storage evidence, preview and separately approved copying. These captures show its actual native pages against the invented fixture.', '']
for i in range(1,9):
 welcome += [f'## Page {i}', '', f'<figure markdown>\n![KonMagic native welcome guide page {i}](../assets/screenshots/light-welcome-{i}.png)\n<figcaption>Native welcome page {i}; entirely synthetic session context. Continue later preserves progress.</figcaption>\n</figure>', '']
(DOCS/'guide/welcome.md').write_text('\n'.join(welcome).rstrip()+'\n')
print(f'Generated {len(files)} module links and {count} source declarations; gallery follows manifest.')
