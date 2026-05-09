# Baselines

Snapshots of derived state. Regenerated and committed on each merge to `main`.

| File | Source | Used by |
|---|---|---|
| `inferred-hierarchy.txt` | `robot reason --output --reasoner HermiT` then `robot extract` of subClassOf closure | W1 hierarchy-diff warning gate |
| `runtime.json` | Wall-clock of `scripts/ci-gate.sh` (median of last 10 runs) | W2 runtime-regression warning gate |

A baseline change is a deliberate act, not a side effect: the regenerating PR must call out the diff and explain it. Onto-driven additive changes typically grow `inferred-hierarchy.txt`; class renames or pattern refactors compress it. Either way, the diff goes in the PR description.

Phase 0: `inferred-hierarchy.txt` initialized empty; populated on first merge that runs the gate. `runtime.json` initialized as `{"runs":[]}`; populated by every `ci-gate.sh` run via `scripts/runtime-tracker.sh RECORD`. W2 only fires once at least 3 prior runs are recorded, then checks current vs 2× median of last 10.
