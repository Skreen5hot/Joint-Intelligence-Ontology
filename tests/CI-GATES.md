# CI Gates — Blocking vs Warning

Per Workflow v1.0 §7. Gates are ordered: each step's failure prevents subsequent blocking steps from running, but warning steps run regardless of prior warning outcomes.

## Blocking Gates (PR cannot merge if any fail)

| # | Gate | Source rule | Tool | Skipped when |
|---|---|---|---|---|
| B1 | TBox parses | T-Box must load | ROBOT `reason --reasoner HermiT` (parse phase) | never |
| B2 | Imports resolve | All `owl:imports` resolve via catalog | ROBOT `merge --catalog` | T-Box has no `owl:imports` |
| B3 | TBox consistent | No contradictions | ROBOT `reason --reasoner ELK` | B1 failed |
| B4 | No unsatisfiable named classes | No `C ⊑ owl:Nothing` for named C | ROBOT `report --profile profile-tester.tsv` | B3 failed |
| B5 | ABox consistent | Every `src/instances/*.jsonld` merged with T-Box reasons clean | ROBOT `reason --reasoner ELK` per instance | no instance files present |
| B6 | CQ pass rate ≥ acceptance | Every `tests/competency/**/*.rq` returns must_infer ⊆ result and must_not_infer ∩ result = ∅ | `scripts/run-competency.sh` | no CQs present |
| B7 | Adversarial probes | Each fixture under `tests/fixtures/adversarial/` runs without unexpected crash; per-fixture verdict against `expected.json` activates with canonical T-Box | `scripts/run-adversarial.sh` | no fixtures present |

## Warning Gates (PR comment, not blocking)

| # | Gate | Threshold | Tool |
|---|---|---|---|
| W1 | Inferred-hierarchy diff | > 5 lines changed vs `tests/baselines/inferred-hierarchy.txt` | `diff` |
| W2 | Reasoner runtime regression | > 2× median of last 10 runs | `scripts/runtime-tracker.sh` |
| W3 | Relation-mapping coverage | Any external IRI in `src/ontology/**/*.ttl` (BFO/CCO/IAO/RO namespaces) not present in `docs/relation-mapping.md` | `scripts/check-relation-mapping.py` |

### W3 promotion path

W3 is **warning by default** because the failure mode "IRI exists but isn't documented" is a documentation gap, not a model bug — it should not block a model PR while the registry catches up. Promotion to **blocking** is ADR-overridable per workflow §6 Rule 4 once the registry matures (post-JI-005 once Onto's IRI registry has a steady set of canonical terms and drift becomes the exception, not the norm). Promotion ADR template requirement: state the registry-stability evidence (e.g., "no new terms added in last N tickets") that justifies the gate-tier change.

## Validation Timing

Per Tester pushback §3 / PM observation: IRI-resolution validation in CQ files fires **only after** the AXIOMATIZED→SMOKE-CLEAN auto-gate has passed. SME may author CQs at DOCTRINE-READY time with placeholder IRIs; the validation kicks in once the T-Box exists to validate against.

## SMOKE-CLEAN Auto-Gate

Inserted between AXIOMATIZED and the Tester queue (Workflow v1.0 §2). SMOKE-CLEAN is the conjunction of B1 + B2 + B3 + B4. If any fail, the PR cannot enter the Tester queue (does not advance to REASONED state). This is automatic — no human gate.

## Phase 0 Behavior

| Gate | Phase 0 status |
|---|---|
| B1 | Active (against `tests/stub/jio-stub.ttl`) |
| B2 | Skipped (stub has no imports). Activates when JI-003 ships catalog. |
| B3 | Active |
| B4 | Active |
| B5 | Skipped until first JI-### scenario lands |
| B6 | Skipped until first competency test lands (SME JI-002 + Tester translation) |
| B7 | Stub-active. Six fixtures present from JI-004b; per-fixture verdict against `expected.json` activates once `JIO_TBOX` points to a real T-Box (post-JI-003 + JI-005). |
| W1 | Active (initial baseline = empty) |
| W2 | Active (rolling window populated as runs accumulate; needs ≥ 3 prior runs before checks fire) |
| W3 | Active against current `src/ontology/jio-core.ttl` stub (4 import IRIs, all covered by `docs/relation-mapping.md`). Activates on every `src/ontology/` change; warning surfaces uncovered IRIs in PR comment. |
