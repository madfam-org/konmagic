#!/usr/bin/env python3
"""Private read-only query/native-journey measurements; never publish real runs."""
import argparse
import datetime
import hashlib
import html
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess
import tempfile


def private_read(path, limit):
    """Check every parent component without following links, then read bounded state."""
    parts=path.parts
    fd=os.open('/', os.O_RDONLY | os.O_DIRECTORY)
    try:
        for part in parts[1:-1]:
            nxt=os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            os.close(fd);fd=nxt
        try:
            file=os.open(parts[-1], os.O_RDONLY | os.O_NOFOLLOW, dir_fd=fd)
        except FileNotFoundError:
            return None
        try:
            stat=os.fstat(file)
            import stat as mode
            if not mode.S_ISREG(stat.st_mode) or stat.st_uid != os.getuid() or stat.st_mode & 0o077 or stat.st_size > limit:
                raise RuntimeError('Input app state must be owned, private and bounded.')
            data=bytearray()
            while len(data)<=limit:
                block=os.read(file,min(65536,limit+1-len(data)))
                if not block:break
                data.extend(block)
            if len(data)>limit:raise RuntimeError('Input state exceeded its bound.')
            return bytes(data)
        finally:os.close(file)
    finally:os.close(fd)


def digest(data):
    return hashlib.sha256(data).hexdigest() if data is not None else None


def save(path,data):
    if isinstance(data,str):data=data.encode()
    path.write_bytes(data);path.chmod(0o600)


def identity(path):
    try:
        stat=path.lstat()
        if path.is_symlink():raise RuntimeError('Catalogue links are held.')
        return dict(inode=stat.st_ino,size=stat.st_size,mtime_ns=stat.st_mtime_ns)
    except FileNotFoundError:return None


def report_html(reports,environment,preserved):
    sections=[]
    for report in reports:
        groups={}
        for sample in report['samples']:groups.setdefault(sample['name'],[]).append(sample)
        rows=[]
        for name,samples in groups.items():
            good=[s for s in samples if s['status']=='ok']
            times=[s['milliseconds'] for s in good]
            med=statistics.median(times) if times else None
            worst=max(times) if times else None
            peak=max(s['peakResidentBytes'] for s in samples)/1048576
            label=html.escape(name.replace('_',' '))
            bar=min(100,(med or 0)/10)
            detail='; '.join(s.get('detail','') for s in samples if s.get('detail'))
            rows.append(f'<tr><td>{label}<div class="bar" style="width:{bar:.1f}%"></div></td><td>{len(good)}/{len(samples)}</td><td>{med:.2f}</td><td>{worst:.2f}</td><td>{peak:.1f}</td></tr>' if times else f'<tr><td>{label}<small>{html.escape(detail)}</small></td><td>Held</td><td>—</td><td>—</td><td>{peak:.1f}</td></tr>')
        counts=' · '.join(f'{html.escape(k)}: {v:,}' for k,v in report.get('coverage',{}).items())
        notes=''.join(f'<li>{html.escape(n)}</li>' for n in report.get('notes',[]))
        sections.append(f'<section><h2>{html.escape(report["mode"].replace("-"," ").title())}</h2><p>{counts}</p><div class="table"><table><thead><tr><th>Measurement</th><th>Successful samples</th><th>Median ms</th><th>Slowest ms</th><th>Process peak MiB</th></tr></thead><tbody>{"".join(rows)}</tbody></table></div><details><summary>Measurement scope</summary><ul>{notes}</ul></details></section>')
    env=html.escape(json.dumps(environment,indent=2))
    return f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>KonMagic · Private journey benchmark</title><style>
    :root{{color-scheme:light dark;--bg:#faf9fd;--panel:#fff;--text:#292640;--muted:#646779;--accent:#087f83;--line:#dadbe7}}@media(prefers-color-scheme:dark){{:root{{--bg:#1d2029;--panel:#282d39;--text:#efeaf8;--muted:#bec3d1;--accent:#78ddd5;--line:#4b5265}}}}
    body{{background:var(--bg);color:var(--text);font:16px/1.55 system-ui;margin:0;padding:32px}}main{{max-width:1180px;margin:auto}}h1{{font-size:32px}}section{{background:var(--panel);border:1px solid var(--line);border-radius:18px;padding:24px;margin:24px 0}}p,small{{color:var(--muted)}}small{{display:block}}.table{{overflow:auto}}table{{border-collapse:collapse;width:100%;font-size:14px}}td,th{{text-align:left;border-bottom:1px solid var(--line);padding:12px}}td:not(:first-child){{font-variant-numeric:tabular-nums;white-space:nowrap}}.bar{{height:3px;background:var(--accent);margin-top:5px}}summary{{cursor:pointer;color:var(--accent)}}pre{{overflow:auto;font-size:12px}}.safe{{color:var(--accent);font-weight:600}}
    </style><main><p>KONMAGIC / PRIVATE PERFORMANCE OBSERVATION</p><h1>Your catalogue, measured</h1><p class="safe">Original bodies unopened. No approved copies. Working app decisions preserved: {str(preserved).lower()}.</p><p>Real catalogue measurements on this Mac under the recorded workload. Filesystem caches were not flushed. Timings describe these runs; they are not portable guarantees. Peak memory is cumulative for each process, not the allocation of an individual action. Tagged and disk coverage overlap.</p>{''.join(sections)}<section><h2>Run context</h2><details><summary>Machine and workload details</summary><pre>{env}</pre></details><p>Raw samples and logs are stored beside this private report. No filenames, tags, source paths or document contents are embedded in this page.</p></section></main></html>'''


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary',type=Path,default=Path.home()/'Library/Caches/KonMagic Build/KonMagic')
    parser.add_argument('--skip-ui',action='store_true')
    args=parser.parse_args()
    if args.binary.is_symlink() or not args.binary.is_file() or args.binary.stat().st_size>32*1024*1024:
        raise RuntimeError('Use a regular current KonMagic build for benchmarking.')
    code=args.binary.read_bytes()
    if b'CATALOGUE_BENCHMARK' not in code or b'JOURNEY_BENCHMARK' not in code:
        raise RuntimeError('This binary lacks the isolated benchmark modes. Build the current source first.')
    del code
    source=Path.home()/'Library/Application Support/KonMagic'
    inputs={name:private_read(source/name,limit) for name,limit in [('workspace.json',2*1024*1024),('knowledge.json',8*1024*1024),('catalogue-summary.json',32*1024*1024),('disk-lens-preferences.json',2*1024*1024)]}
    workspace=json.loads(inputs['workspace.json'])
    catalogue=Path(workspace.get('cataloguePath') or Path.home()/'Library/Application Support/Workstation Atlas/catalog.sqlite3')
    directory=Path(tempfile.mkdtemp(prefix='konmagic-benchmark-',dir='/private/tmp'));directory.chmod(0o700)
    state=directory/'State';state.mkdir(mode=0o700)
    workspace.update(assignments=[],welcomed=True,output=str(directory/'Output not created'),outputBookmark=None,catalogueBookmark=None,cataloguePath=str(catalogue))
    save(state/'workspace.json',json.dumps(workspace))
    for name in ['knowledge.json','catalogue-summary.json']:
        if inputs[name] is not None:save(state/name,inputs[name])
    database_files=[catalogue,catalogue.with_name(catalogue.name+'-wal'),catalogue.with_name('disk-coverage.sqlite3')]
    before={str(p):identity(p) for p in database_files}
    environment=dict(date=datetime.datetime.now(datetime.timezone.utc).isoformat(),architecture=platform.machine(),os=platform.mac_ver()[0],load_average_before=os.getloadavg(),filesystem_cache_flushed=False,binary_sha256=digest(args.binary.read_bytes()))
    for label,command in [('compiler',['/usr/bin/xcrun','swiftc','--version']),('sdk',['/usr/bin/xcrun','--show-sdk-version'])]:
        tool=subprocess.run(command,capture_output=True,text=True,timeout=15)
        environment[label]=tool.stdout.strip() if tool.returncode==0 else 'Unavailable'
    env=os.environ.copy();env.update(KONMAGIC_BENCHMARK_CATALOGUE=str(catalogue),KONMAGIC_BENCHMARK_STATE=str(state),KONMAGIC_QA_STATE=str(state))
    print('PRIVATE_BENCHMARK_DIRECTORY='+str(directory),flush=True)
    reports=[]
    for flag,name,timeout in [('--benchmark-catalogue','catalogue',420)]+([] if args.skip_ui else [('--journey-benchmark','journey',180)]):
        print('Running '+name+' measurements; originals remain untouched.',flush=True)
        with (directory/(name+'.log')).open('w') as log:
            os.chmod(log.name,0o600)
            subprocess.run(['/usr/bin/time','-l',str(args.binary),flag],env=env,stdout=log,stderr=log,timeout=timeout,check=True)
        report_file=state/(name+'-benchmark.json')
        report=json.loads(report_file.read_text())
        if name=='journey':report['notes'] += ['Classification open/cancel includes a fixed 400 ms cancellation timer; it does not measure editor-open latency.', 'Storage page samples display controls; no whole-machine scan is imported. Semantic Content maps use actual retained aggregates.']
        reports.append(report)
        print(name+' measurements complete.',flush=True)
    environment['load_average_after']=os.getloadavg()
    preserved=all(digest(private_read(source/name,limit))==digest(inputs[name]) for name,limit in [('workspace.json',2*1024*1024),('knowledge.json',8*1024*1024),('disk-lens-preferences.json',2*1024*1024)])
    database_preserved=before=={str(p):identity(p) for p in database_files}
    save(directory/'preservation.json',json.dumps(dict(user_decisions_preserved=preserved,input_database_identities_unchanged=database_preserved)))
    save(directory/'environment.json',json.dumps(environment,indent=2))
    save(directory/'report.html',report_html(reports,environment,preserved and database_preserved))
    if not preserved or not database_preserved:raise RuntimeError('State or catalogue changed during measurement. Review the private receipt before interpreting results.')
    print('Preservation checks passed. Private report: '+str(directory/'report.html'),flush=True)


if __name__=='__main__':main()
