# Command-line modes and QA environment

The native executable accepts explicit diagnostic flags. They are development tools, not a remote filesystem API. Run normal app mode without a flag. Build scripts launch through `/bin/zsh -f` so shell startup configuration is not a dependency.

| Flag | Scope | Data privacy |
|---|---|---|
| `--self-test` | Temporary model/catalogue/filesystem/native scan cases | Synthetic |
| `--documentation-capture` | Entire illustrated native capture workflow | Restricted generated synthetic root |
| `--catalog-smoke` | Bounded live/retained standard-folder pages | Local/private |
| `--explorer-smoke` | Retained page, aggregate conservation and disk page | Local/private |
| `--lens-recorded-smoke` | Derive native scan from retained ledger | Local/private |
| `--volume-context-smoke` | Read-only local diskutil context | Local/private |
| `--ui-smoke` | Structure render | Local/private |
| `--toolkit-ui-smoke` | Toolkit layout/routes | Local/private |
| `--explorer-ui-smoke` | Selected Content visualization | Local/private |
| `--lens-ui-smoke` | Provided saved scan rendering | Local/private |
| `--navigation-ui-smoke` | Single/multi-window navigation acceptance | Isolated state; outputs private |
| `--journey-ui-smoke` | Guided placement and Review acceptance | Isolated state; outputs private |
| `--classification-ui-smoke` | Editor save, retained selection/destination and held/empty states | Restricted generated synthetic root |
| `--benchmark-catalogue` | Real read-only query/cancellation and memory measurements | Owned private temporary benchmark state |
| `--journey-benchmark` | Native display-cycle journey and memory measurements | Isolated app decisions; real observations stay private |
| `--knowledge-ui-smoke` | Cancelled editing dialogs | Isolated state; outputs private |
| `--review-ui-smoke` | Comparison/candidate metadata acceptance | Synthetic review records; app state still private unless fixture-isolated |

## Environment variables

| Variable | Purpose |
|---|---|
| KONMAGIC_QA_STATE | Alternate state directory only for QA modes |
| KONMAGIC_QA_IMAGE | Private output image or output prefix for ordinary render modes |
| KONMAGIC_QA_APPEARANCE | `dark` selects Dark Aqua; otherwise Aqua in QA |
| KONMAGIC_QA_VIEW | list, foldertree, tagtree, treemap, connections or disk for Explorer smoke |
| KONMAGIC_QA_PAGE | review, structure, content or toolkit for journey screenshot |
| KONMAGIC_QA_SCAN | Existing private native scan for Disk Lens render |
| KONMAGIC_QA_ROOT | Selected root for recorded scan smoke |
| KONMAGIC_BENCHMARK_CATALOGUE | Existing read-only catalogue input for query measurement |
| KONMAGIC_BENCHMARK_STATE | Owned `/private/tmp/konmagic-benchmark-*` state/cache/report folder |

Normal app mode ignores the QA state override. Each state root has a separate instance lock. Do not point ordinary QA at the genuine decision store. Some smoke modes intentionally use the local Atlas path; their logs/screenshots are never public.

Documentation capture ignores the ordinary image prefix and creates a new Light/Dark screenshots directory beside its validated fixture State. The script prints that new state path. It refuses normal app state, missing markers and unexpected catalogue/output roots.

`python3 scripts/benchmark.py` prepares the isolated state and runs both benchmark modes. It leaves real app decisions intact and writes a private HTML report, raw JSON samples, logs and preservation receipt outside the repository. These outputs must never be promoted as public documentation fixtures. See [performance methodology](../developer/performance.md).
