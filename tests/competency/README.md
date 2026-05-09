# Competency Tests (forward-looking)

One subdirectory per ticket: `tests/competency/JI-###/`.
Each CQ in `docs/scenarios/JI-###-cqs.yaml` (locked v1.0 template) gets a sibling `.rq` file:

```
tests/competency/JI-###/CQ-001.rq          # SPARQL or DL-Query
tests/competency/JI-###/CQ-001.expected.json   # must_infer / must_not_infer extracted from the YAML
```

The expected.json is auto-generated from the YAML by `scripts/build-expected.sh` so the SPARQL author cannot drift from the SME's locked acceptance criteria.

## SPARQL Conventions

- Queries run against the **inferred** model (T-Box + A-Box + reasoner closure), produced by `robot reason --output-iri ...`.
- Use the project namespace `ex: <http://example.org/jp2/>` plus the four upper/mid namespaces (`obo:`, `cco:`, `iao:`, `ro:`).
- For `expected_form: boolean`, use `ASK`. For `list`/`single`/`count`, use `SELECT`.
- For `expected_form: none` (pure brittleness CQ), use `SELECT` and assert empty result.

## Stub

`tests/competency/stub/CQ-STUB.rq` is a wiring proof — confirms the SPARQL runner finds queries, merges the stub T-Box, executes, and compares to expected. Delete after first real module lands.
