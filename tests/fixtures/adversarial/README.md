# Adversarial Fixtures

Degenerate A-Box scenarios designed to *fail* under correct modeling. Counterparts to the six probes in `config/logic_ontologist_tester.yaml`:

- `role_stress_test/` — agents without roles; verify ontology does not infer role membership from participation alone.
- `process_boundary_test/` — sub-process chains; verify Phase I and Phase II BDA do not collapse into equivalence classes.
- `ice_confusion_test/` — Imagery / Reports / RFIs; verify none are inferred as Process or Agent under any property chain.
- `temporal_consistency_test/` — `precedes`/`preceded_by`; verify cycles are detected and asymmetry holds.
- `overconstraint_test/` — valid real-world entities that should be admissible but are blocked by overly strict restrictions.
- `underconstraint_test/` — invalid entities that should be rejected but slip through loose definitions.

Each subdir contains:
- `fixture.jsonld` — the degenerate A-Box
- `expected.json` — the *failure* the reasoner must surface (e.g., specific unsatisfiable individual, contradiction, or absent inference)
- optionally `probe.ttl` (symlink-or-copy of relevant `tests/fixtures/probes/*.ttl`)

## Phase 0 status (JI-004b — delivered 2026-05-09)

Six skeleton fixtures present, each with `fixture.jsonld` + `expected.json`:

| Probe | Fixture | Probe T-Box delta |
|---|---|---|
| `role_stress_test` | ✓ | none (uses real T-Box) |
| `process_boundary_test` | ✓ | none |
| `ice_confusion_test` | ✓ | none |
| `temporal_consistency_test` | ✓ | optional `tests/fixtures/probes/temporal_consistency_test.ttl` (asserts `BFO_0000063 a IrreflexiveProperty`) — author when needed by JI-005 |
| `overconstraint_test` | ✓ | none |
| `underconstraint_test` | ✓ | none |

The fixtures use the JI-008-corrected CCO IRI prefix (`https://www.commoncoreontologies.org/`) and opaque CCO IDs (`ont00001262`, `ont00001986`, etc.), declared inline in each fixture's `@context`. When Onto's JI-003 lands the project-wide namespace fix, fixtures may collapse back to the project `cco:` shorthand.

The runner is `scripts/run-adversarial.sh`. At Phase 0 it validates fixture structure and runs ROBOT merge+reason against whichever T-Box `JIO_TBOX` resolves (with stub fallback). Per-fixture verdict against `must_surface` / `must_not_surface` activates when JI-005 ships real classes.
