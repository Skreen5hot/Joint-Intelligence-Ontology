# JIO Test Architecture (JI-004a)

Owner: Logic Ontologist Tester. Layout per Workflow v1.0 §5.

## Directory Map

| Path | Purpose | Owner |
|---|---|---|
| `tests/stub/` | Minimal harness T-Box for CI bootstrap. Replaced by `src/ontology/` once JI-003 lands. | Tester (harness only) |
| `tests/competency/` | Forward-looking SPARQL/DL-Query tests, one file per CQ. Translated by Tester from SME's `docs/scenarios/JI-###-cqs.yaml`. | Tester |
| `tests/regression/` | Backward-looking tests pinning prior behavior. Populated as modules reach FROZEN. | Tester |
| `tests/fixtures/adversarial/` | Degenerate A-Box scenarios designed to fail (six probes from `config/logic_ontologist_tester.yaml`). | Tester |
| `tests/fixtures/probes/` | Probe T-Box deltas. Loaded only by the test harness, never imported into `src/ontology/`. | Tester |
| `tests/fixtures/expected/` | Expected-result JSON for each competency / regression / adversarial test. | Tester |
| `tests/baselines/` | Inferred-hierarchy snapshot. Regenerated and committed on each merge. | Tester |

## Running Locally

Requires Java 17+ and ROBOT (`scripts/install-robot.sh` will download a pinned version to `~/.cache/robot/`).

```
bash scripts/ci-gate.sh           # Full gate (blocking + warning)
bash scripts/reason.sh --tbox tests/stub/jio-stub.ttl    # Single-TBox reason
```

Windows local dev: WSL or Git Bash. PowerShell wrapper deferred to JI-004b.

## Gate Severity

See `tests/CI-GATES.md` for the full table. Summary:

- **Blocking** — TBox satisfiability, imports-resolve, ABox consistency, CQ pass rate ≥ acceptance set, no new unsatisfiable named classes.
- **Warning (PR comment, not blocking)** — inferred-hierarchy diff over threshold, reasoner runtime regression > 2×.

## Phase 0 Caveat

Until JI-003 ships a real T-Box at `src/ontology/`, the gate runs against `tests/stub/jio-stub.ttl`. Most steps are no-op at stub level (no imports to resolve, no CQs yet). The wiring is exercised end-to-end so Onto and SME see the gate they're modeling against.
