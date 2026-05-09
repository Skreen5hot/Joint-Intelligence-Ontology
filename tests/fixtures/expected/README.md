# Expected Results

Each adversarial / probe test ships a sibling `expected.json` describing what the reasoner *must* surface for the test to count as passing.

Schema:
```json
{
  "test_id": "role_stress_test",
  "fixture": "tests/fixtures/adversarial/role_stress_test/fixture.jsonld",
  "probe": "tests/fixtures/probes/role_stress.ttl",
  "must_surface": [
    { "kind": "unsat_class", "iri": "ex:..." },
    { "kind": "missing_inference", "subject": "ex:...", "predicate": "ex:...", "object": "ex:..." }
  ],
  "must_not_surface": [
    { "kind": "type_inference", "individual": "ex:Imagery_001", "type": "obo:BFO_0000015" }
  ]
}
```

The runner asserts that every `must_surface` entry appears in the reasoner output and no `must_not_surface` entry does.
