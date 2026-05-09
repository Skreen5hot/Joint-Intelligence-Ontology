# ADR-001 — `IAO_0000119` semantics: definition source vs. doctrinal provenance

- **Status:** **Accepted (2026-05-09) — Option B selected**
- **Author:** Ontologist
- **Date:** 2026-05-09
- **Triggered by:** JI-008 ([docs/relation-mapping.md](../relation-mapping.md) §IAO caveat); blocks JI-005 entry to AXIOMATIZED
- **Related:** [docs/workflow.md §6 Rule 3](../workflow.md) (new term proposals + reuse-first), [docs/relation-mapping.md](../relation-mapping.md) (IAO terms in use)

---

## Context

The working-tree draft T-Box at [src/ontology/intelligenceAnalysisProcess.ttl](../../src/ontology/intelligenceAnalysisProcess.ttl) annotates several doctrinal classes with `obo:IAO_0000119`:

```turtle
ex:Phase1BattleDamageAssessment a owl:Class ;
    rdfs:subClassOf ex:BattleDamageAssessmentProcess ;
    obo:IAO_0000115 "A Battle Damage Assessment Process that estimates the quantitative extent of physical damage sustained by a target entity using post-strike observational inputs." ;
    obo:IAO_0000119 "JP 2-0" ;
    ...
```

**The semantic question:** is the string `"JP 2-0"` here:
- (a) the source of the *textual definition* immediately above (IAO_0000119's intended use), or
- (b) a general claim that this entity is doctrinally grounded in JP 2-0 (broader provenance)?

`IAO_0000119`'s canonical IAO definition is **"definition source"** — strictly, the source from which the textual `IAO_0000115` definition was drawn (verified in [docs/relation-mapping.md](../relation-mapping.md) §"Verified terms — IAO"). The IAO design intent is bibliographic citation of the definition itself, not general topical provenance.

In our usage, several classes use `IAO_0000119 "JP 2-0"` where the `IAO_0000115` definition was *synthesized by us* — not literally extracted from JP 2-0. That's a semantic drift: we're using the property to mean "this concept is grounded in this doctrine" rather than "the prose definition above came from this doctrine."

**Why this matters before JI-005:** JI-005 will scale doctrinal annotations across every `ex:*` class. Locking the wrong pattern now means refactoring N classes later (and re-running every CQ that touches doctrinal-source filtering, which JI-002 may introduce). Cheaper to decide once, here.

**Reasoner impact:** none. Annotation properties are invisible to OWL DL reasoning. This is a semantics-and-tooling decision, not a logical correctness decision.

---

## Considered options

### Option A — Keep `IAO_0000119`; tighten our usage to match its strict semantic

**Rule:** `IAO_0000119` may only be used on a class when the `IAO_0000115` textual definition is verbatim or near-verbatim quoted/paraphrased from the cited source. For "this concept is doctrinally grounded but the definition is synthesized," use a different annotation (see "Companion choice" below).

**Companion choice required.** If we adopt A, we still need *some* property for general doctrinal grounding. Default companion: `rdfs:isDefinedBy` pointing to a doctrine IRI, or `dcterms:source` for broad provenance. Either is reuse-first compliant.

**Pros:**
- Reuse-first compliant (workflow operating principle): no new project-specific terms.
- Honors IAO design intent. Stays interoperable with any tooling that consumes `IAO_0000119` correctly (OBO Foundry tools, ROBOT report profiles, OntoTools).
- Forces definition rigor: every class with `IAO_0000119` traces to a verifiable doctrinal quote, which is a quality-gate the SME persona explicitly values ("paragraph references in JP 2-0 / JP 3-60 to justify your structural requirements").
- Zero new schema; only an SOP change.

**Cons:**
- Higher SME authoring burden — every doctrinally-anchored class must have its definition extracted from a paragraph, not synthesized. Some doctrinal concepts don't have a single-quote definition and have to be paraphrased anyway, putting them in a grey zone.
- Splits the annotation surface across two properties (definition source vs. general doctrinal source), which is conceptually correct but more to remember.
- Risks under-annotation: SMEs who can't find a verbatim definition source may skip annotation entirely rather than reach for the companion property.

**Migration cost (existing draft .ttl):** review every current `IAO_0000119 "JP 2-0"` usage; for each, either (i) confirm the `IAO_0000115` definition is a doctrinal quote (keep as-is), or (ii) move to the companion property. Likely ~15–25 classes once JI-005 expands, manageable.

### Option B — Introduce `jio:derivedFrom` for general doctrinal provenance; reserve `IAO_0000119` for strict definition-source citations

**Rule:** Declare a project-specific annotation property `jio:derivedFrom` (or similar — name negotiable) under our project namespace. Use it for any "this entity is doctrinally grounded in source X" claim. Continue to allow `IAO_0000119` only when the `IAO_0000115` definition is literally quoted from the source.

**Schema sketch:**
```turtle
jio:derivedFrom rdf:type owl:AnnotationProperty ;
    rdfs:label "derived from" ;
    obo:IAO_0000115 "An annotation property linking a class to a doctrinal source (e.g., JP 2-0, JP 3-60) from which the concept derives. Distinct from IAO_0000119, which cites the source of the textual definition itself." ;
    rdfs:subPropertyOf rdfs:isDefinedBy .
```

**Pros:**
- Semantic precision: each property does one job. No coercion of `IAO_0000119` beyond its design intent.
- Lower SME friction: annotate any doctrinally-grounded class without needing to find a verbatim definition extract first.
- Matches the SME persona's stated practice ("annotations referencing specific paragraphs in Joint Doctrine") cleanly — `jio:derivedFrom "JP 2-0 §IV-12"` reads as exactly that.
- Subordinating to `rdfs:isDefinedBy` keeps it discoverable by generic RDF tooling.

**Cons:**
- Violates the spirit of reuse-first by introducing a new property when an existing one (with a companion) could cover the case. Workflow §6 Rule 3 requires ADR justification — that's what this document is for, but the principle is real.
- Project-specific term: not interoperable with external OBO-Foundry consumers without explanation. Anyone importing JIO has to learn `jio:derivedFrom`.
- Sets a precedent: once we mint one project-level annotation property, future ones become easier to justify, and reuse-first weakens over time.
- Future-proofing risk: if OBO Foundry / IAO ever publishes an official "topical source" annotation property, we'd want to migrate, but `jio:derivedFrom` will be embedded across hundreds of classes by then.

**Migration cost:** declare the property in `src/ontology/jio-core.ttl` (one place); rewrite existing `IAO_0000119 "JP 2-0"` annotations to `jio:derivedFrom "JP 2-0"` where the definition was synthesized. Same ~15–25 class touch-up as Option A.

### Other options briefly considered (not advanced)

- **`rdfs:seeAlso`** — too weak; no provenance commitment, just "consider this related." Loses the assertion that the doctrine is the *source*.
- **`dcterms:source`** alone, replacing `IAO_0000119` everywhere — viable but gives up IAO interoperability for genuinely-quoted definitions; collapses the distinction the SME persona values.
- **`rdfs:isDefinedBy` alone, replacing `IAO_0000119`** — semantically targets ontology-IRI-level definition, not paragraph-level provenance; mismatched granularity.

---

## Trade-off matrix

| Dimension | Option A | Option B |
|---|---|---|
| Reuse-first compliance | ✓ Strong | ✗ Introduces new property |
| Semantic precision (IAO sense) | ✓ Honored strictly | ✓ Honored, with project-level companion |
| SME authoring burden | Higher (must source verbatim quotes) | Lower (annotate without quote-finding) |
| Reasoner impact | None | None |
| External tool interoperability | ✓ | Partial — `jio:` requires explanation |
| Forward extensibility (JP 3-60, JP 5-0, ...) | ✓ | ✓ |
| Risk of under-annotation | Higher | Lower |
| Migration cost (existing draft) | Equal | Equal |
| Precedent risk for future ADRs | Low | Higher — eases the next "new term" request |

---

## Decision

**Option B selected.** Introduce `jio:derivedFrom` as a project-level annotation property for general doctrinal provenance; reserve `IAO_0000119` for strict definition-source citations.

**SME rationale:** the SME persona's stated practice ([config/SME.yaml](../../config/SME.yaml)) is to annotate doctrinal claims with paragraph-level references (e.g., "JP 2-0 §IV-12"). Option A's strict-quote requirement creates a grey zone for synthesized definitions, which the ADR itself flags as common in this domain. The cognitive overhead of "find a verbatim definition or pivot to a companion property" raises the per-class authoring cost across the ~15–25 doctrinal classes JI-005 will produce, and grows linearly as the ontology expands to JP 3-60 / JP 5-0. Option B's lower SME friction and one-property-one-job semantics outweigh the reuse-first cost in this project's annotation-heavy context.

**Mitigations against the documented cons of Option B:**
- **Reuse-first weakening:** `jio:derivedFrom` is declared `rdfs:subPropertyOf rdfs:isDefinedBy`, keeping it discoverable by generic RDF tooling. External tools that don't recognize the project namespace can still trace doctrinal grounding via the parent property.
- **Precedent risk:** this ADR establishes that any future `jio:*` term proposal requires the same three-signoff ADR discipline. Reuse-first remains the default; new terms remain the exception.
- **OBO Foundry migration risk:** if/when an official "topical source" annotation property ships in IAO or related upper ontologies, an UPSTREAM-BUMP-style retrofit migrates `jio:derivedFrom` usages. Cost is bounded (single property, single replacement).

**Canonical name:** `jio:derivedFrom` (as drafted in the schema sketch above).

**Implementation plan:**
1. Ontologist declares `jio:derivedFrom` in [src/ontology/jio-core.ttl](../../src/ontology/jio-core.ttl) under JI-005.
2. Ontologist updates [docs/patterns.md](../patterns.md) with the chosen annotation pattern (creating the file under JI-005).
3. Ontologist rewrites all working-tree-draft `IAO_0000119 "JP 2-0"` annotations to `jio:derivedFrom "JP 2-0 §<paragraph>"` in JI-005's T-Box landing.
4. Logic Tester adds a regression probe verifying `jio:derivedFrom` is declared exactly once and is referenced consistently across the T-Box ([tests/fixtures/probes/](../../tests/fixtures/probes/) — out of scope for JI-005, owned by Tester in a follow-up).
5. SME, when authoring CQs (JI-002 onward) that filter by doctrinal source, references `jio:derivedFrom` per the IRI registry.

## Tester impact

Per workflow §282 (ADR template requirement).

| Question | Answer |
|---|---|
| Does this change the test surface? | **Minimal.** Annotation properties don't appear in CQ result sets or `subClassOf` baselines. CQs that filter by source annotation (none currently exist) would target `IAO_0000119` under A or `jio:derivedFrom` under B. |
| Does it require a CQ rewrite? | No CQs exist yet to rewrite. The structured CQ template ([docs/templates/cq-template.yaml](../templates/cq-template.yaml)) does not currently constrain annotation queries; if SME wants to query by doctrinal source, the chosen property name will be referenced from that point onward. No retroactive rewrite. |
| Force a baseline reset? | No. `tests/baselines/inferred-hierarchy.txt` extracts `subClassOf` pairs only; annotation triples are not in scope. |
| New blocking gate? | Optional under Option B: a one-line check that `jio:derivedFrom` is declared in `src/ontology/jio-core.ttl` (or wherever it lives). Cheap to add to B5 or as a new B-rank gate; defer until SME selects. |
| New warning gate? | None. |

**Net Tester verdict:** both options are roughly equivalent in test cost. No veto on either pattern from the Tester perspective.

---

## References

- IAO definition of `IAO_0000119`: see [docs/relation-mapping.md](../relation-mapping.md) §"Verified terms — IAO" (annotated as a `definition source` annotation property in `src/imports/iao-edit.owl`).
- SME persona on doctrinal annotation practice: [config/SME.yaml](../../config/SME.yaml) (paragraph-reference annotation citation).
- Workflow rules invoked: §5 (conflict resolution), §6 Rule 1 (pattern selection), §6 Rule 3 (new term proposals), §282 (ADR Tester-impact requirement).
- Reuse-first principle: workflow operating principle list.

## Ratification

| Role | Decision | Date | Notes |
|---|---|---|---|
| SME | **Accepted (B)** | 2026-05-09 | Selected Option B per PO direction; lower authoring friction outweighs reuse-first cost in this project's annotation-heavy context. |
| Ontologist | **Authored** | 2026-05-09 | Drafted both options; abstained from selection per workflow §6 Rule 1. Implementation lands in JI-005. |
| Logic Tester | **Acknowledged (no veto)** | 2026-05-09 | Per Tester impact analysis above: both options roughly equivalent in test cost, no testability veto on either pattern. |

**Status: Accepted.** JI-005 may enter AXIOMATIZED once JI-001 + JI-002 land.
