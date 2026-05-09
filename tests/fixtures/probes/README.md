# Probe T-Box Deltas (harness-only)

Workflow v1.0 §2 rule: **the Tester does not edit `src/ontology/`.** Probe deltas — small T-Box additions used to confirm a constraint actually catches its target violation — live here.

Loading rule: probe `.ttl` files are merged with the canonical T-Box **only inside the test harness**, via `scripts/reason.sh --probe FILE`. They are never declared as `owl:imports` of `src/ontology/`.

Naming: one `.ttl` per probe scenario, matching the adversarial fixture name where applicable.

Phase 0: empty. Populated by JI-004b.
