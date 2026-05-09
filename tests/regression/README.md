# Regression Tests (backward-looking)

Pin prior behavior. Populated as modules reach FROZEN.

Naming: `tests/regression/JI-###/<freeze-date>-<short-name>.rq`

Each regression test captures an inference that was *correct at module freeze*. If the test ever fails on a later PR, either:
- The model drifted (revert or re-bump SemVer to MAJOR), or
- The doctrinal claim itself changed (open an UPSTREAM-BUMP ticket and update the regression with a new freeze entry — never edit prior frozen entries).

Phase 0: empty. First entries land when first module reaches ACCEPTED → FROZEN.
