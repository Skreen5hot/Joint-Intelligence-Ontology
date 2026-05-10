# JIO Modeling Patterns

| Field | Value |
|---|---|
| Owner | Ontologist |
| Tester veto | Available per workflow §6 Rule 4 (testability-impacting patterns); ADR-overridable |
| Source-of-truth | This file is consulted whenever a JI-### ticket touches an `ex:*` class or `jio:*` term. Patterns documented here are commitments, not suggestions. |
| Related | [docs/scope.md](scope.md), [docs/relation-mapping.md](relation-mapping.md), [docs/decisions/ADR-001-iao-119-semantics.md](decisions/ADR-001-iao-119-semantics.md), [docs/scenarios/JI-005-canonical-ca.md](scenarios/JI-005-canonical-ca.md), [docs/reviews/JI-005-sme-checklist.md](reviews/JI-005-sme-checklist.md) |

---

## How to read this document

Each pattern has four sections:

1. **Statement** — the rule, in one or two sentences.
2. **When to use** — the trigger conditions.
3. **Worked example** — how the pattern manifests in [src/ontology/jio-core.ttl](../src/ontology/jio-core.ttl).
4. **Rationale + caveats** — why this pattern over alternatives, and the failure modes it prevents or admits.

If a pattern's worked example contradicts what's in `jio-core.ttl`, the file wins; this document needs updating.

---

## Pattern 1 — Anti-rigidity Person/Role separation

### Statement

Agent classes (e.g., `ex:IntelligenceAnalyst`, `ex:TargetAnalyst`) are **defined classes** via `owl:equivalentClass`, expressed as `Person ⊓ bearer_of some <RoleClass>`. They are **never** declared as `rdfs:subClassOf cco:ont00001262` (Person). Doctrinal specialization between agent classes (e.g., `TargetAnalyst ⊑ IntelligenceAnalyst`) is **inferred** from a parallel role hierarchy (`TargetAnalysisRole ⊑ AnalyticalRole`), not asserted directly.

### When to use

Any agent class whose membership depends on what the agent *does* — i.e., any role-bearing classification. Currently applies to `ex:IntelligenceAnalyst` and `ex:TargetAnalyst`. Forward extensions like `ex:SIGINTAnalyst` follow the same pattern.

### Worked example

```turtle
# Role hierarchy — structural, with ex:AnalyticalRole as the parent
# narrowing the broad cco:ont00000984 (OccupationRole) to roles
# pertaining to intelligence analysis.

ex:AnalyticalRole rdfs:subClassOf cco:ont00000984 .
ex:TargetAnalysisRole rdfs:subClassOf ex:AnalyticalRole .

# Agent classes — defined via Person + bearer-of-some-role.
# NOT declared subClassOf cco:ont00001262 (Person).

ex:IntelligenceAnalyst owl:equivalentClass [
    owl:intersectionOf (
        cco:ont00001262                       # Person
        [ a owl:Restriction ;
          owl:onProperty obo:RO_0000053 ;     # bearer of
          owl:someValuesFrom ex:AnalyticalRole ]
    )
] .

ex:TargetAnalyst owl:equivalentClass [
    owl:intersectionOf (
        cco:ont00001262
        [ a owl:Restriction ;
          owl:onProperty obo:RO_0000053 ;
          owl:someValuesFrom ex:TargetAnalysisRole ]
    )
] .
```

By the role hierarchy, `TargetAnalysisRole ⊑ AnalyticalRole`, so any individual classified as `ex:TargetAnalyst` is automatically classified as `ex:IntelligenceAnalyst` — the specialization holds by inference, not direct assertion.

### Rationale + caveats

- **Why not `ex:IntelligenceAnalyst rdfs:subClassOf cco:ont00001262`?** That's the rigidity bug from the v0 plan. It treats analyst-ness as an essential property of the person, conflicting with operational reality (a person's analyst role is realized over time and across processes, not baked into their identity). Failing to separate these breaks the SME persona's `role_stress_test` probe and admits classifications like "everyone in a JIOC is an analyst" by mere co-location.

- **Why a structural `ex:AnalyticalRole`?** Without it, defining `IntelligenceAnalyst` as `Person ⊓ bearer_of some cco:ont00000984` would classify any Person bearing any OccupationRole — marine biologist, carpenter, plumber — as an Intelligence Analyst. CCO's `OccupationRole` is too broad; `ex:AnalyticalRole` is the structural narrowing. This composition was the topic of PR #12's anti-rigidity heads-up and SME's accepted resolution.

- **Tester implication.** CQ-012 verifies classification works only via role-bearing; `role_stress_test` adversarial fixture verifies a Person bearing a non-`AnalyticalRole` `OccupationRole` is *not* classified as an Intelligence Analyst.

- **Forward extension.** Adding `ex:SIGINTAnalyst` later means: declare `ex:SIGINTAnalysisRole rdfs:subClassOf ex:AnalyticalRole` plus `ex:SIGINTAnalyst owl:equivalentClass [Person ⊓ bearer_of some ex:SIGINTAnalysisRole]`. The relation `SIGINTAnalyst ⊑ IntelligenceAnalyst` follows by inference.

---

## Pattern 2 — Combat Assessment leaf processes as defined classes

### Statement

The five Combat Assessment leaf process classes (`Phase1BattleDamageAssessment`, `Phase2BattleDamageAssessment`, `Phase3BattleDamageAssessment`, `MunitionsEffectivenessAssessment`, `ReAttackRecommendation`) are **defined classes** via `owl:equivalentClass` with conditions on `has_input` and `has_output`. Umbrella process classes (`CombatAssessmentProcess`, `BattleDamageAssessmentProcess`) are `rdfs:subClassOf` only — taxonomic, not defined.

Temporal ordering and process-mereology constraints (`preceded_by`, `is_part_of_process`) are carried as **additional `rdfs:subClassOf` restrictions** outside the `equivalentClass` body — i.e., as necessary-only conditions, not as part of what defines the leaf class.

### When to use

For any process class whose membership is determined by an input/output signature and where positive classification of an untyped individual is a doctrinal requirement (per scope §5 #3, locked under Option α).

### Worked example

```turtle
ex:Phase2BattleDamageAssessment
    owl:equivalentClass [
        owl:intersectionOf (
            obo:BFO_0000015                              # Process
            [ a owl:Restriction ;
              owl:onProperty cco:ont00001921 ;           # has input
              owl:someValuesFrom ex:Phase1BDAReport ]
            [ a owl:Restriction ;
              owl:onProperty cco:ont00001986 ;           # has output
              owl:someValuesFrom ex:Phase2BDAReport ]
        )
    ] ;
    rdfs:subClassOf ex:BattleDamageAssessmentProcess ;
    rdfs:subClassOf [ a owl:Restriction ;
        owl:onProperty obo:BFO_0000062 ;                 # preceded by
        owl:someValuesFrom ex:Phase1BattleDamageAssessment ] ;
    rdfs:subClassOf [ a owl:Restriction ;
        owl:onProperty cco:ont00001857 ;                 # is part of process
        owl:someValuesFrom ex:CombatAssessmentProcess ] .
```

A bare `obo:BFO_0000015` individual asserted with a `Phase1BDAReport` input and a `Phase2BDAReport` output classifies as `Phase2BattleDamageAssessment` automatically. The `preceded_by` and `is_part_of_process` constraints become necessary conditions but don't gatekeep classification.

### Rationale + caveats

- **Why split equivalentClass from subClassOf restrictions?** If `preceded_by some Phase1BDA` were inside the `equivalentClass`, an untyped Phase 2 individual without an asserted predecessor wouldn't classify. That's too strict — under OWA the reasoner satisfies the predecessor existential anonymously even when classification requirement is met, but mixing the two in one equivalence collapses the distinction between "what makes you a Phase 2" (signature) and "what must hold of any Phase 2" (predecessor). Splitting is cleaner and matches scope §5 #3's "inferential behavior, not encoding form" intent.

- **Why aren't umbrella classes (BDA, CA) defined?** They have no I/O signature distinguishing them from each other independent of leaves. CombatAssessmentProcess is "any of {Phase1, Phase2, Phase3, MEA, RAR}-or-their-merge"; making it a defined class would require listing the leaves as the definition. Cleaner as a `rdfs:subClassOf obo:BFO_0000015` with leaves rooting under it via subClassOf.

- **Conjunctive RAR.** The Re-Attack Recommendation has TWO `has_input` restrictions in the equivalentClass body (one for `Phase3BDAReport`, one for `MEAReport`). Both required. Doctrinally locked in JI-001 review (C-1/C-6) and re-confirmed in JI-002 CQ-007/CQ-008.

- **Tester implication.** CQ-009 (positive classification) is satisfied because the encoding is `equivalentClass`, not `subClassOf`-only. CQ-010 (negative case) is the contrapositive — a process individual missing required I/O is denied classification under any leaf. The five untyped test individuals required by JI-005a Q-O-3 exist precisely to give CQ-009 inferential teeth.

---

## Pattern 3 — Pairwise disjointness on Combat Assessment leaves

### Statement

The five CA leaf process classes are declared **pairwise disjoint** via a single `owl:AllDisjointClasses` block. No leaf can be inferred as another leaf or as more than one leaf simultaneously.

### When to use

Whenever a set of sibling classes have non-overlapping doctrinal commitments and a type-level conflation would constitute a modeling error. Currently applies to the five CA leaves; would extend to any future sibling-class set with the same disjointness intent (e.g., the five Report subclasses, though those don't currently have asserted disjointness because BFO doesn't enforce it on ICEs).

### Worked example

```turtle
[] rdf:type owl:AllDisjointClasses ;
   owl:members (
     ex:Phase1BattleDamageAssessment
     ex:Phase2BattleDamageAssessment
     ex:Phase3BattleDamageAssessment
     ex:MunitionsEffectivenessAssessment
     ex:ReAttackRecommendation
   ) .
```

### Rationale + caveats

- **Why this pattern?** Per Onto's JI-001 review C-2: BFO_0000063 (precedes) is `TransitiveProperty` but **not** `AsymmetricProperty` or `IrreflexiveProperty`. Without explicit constraints, an instance typed as both Phase 1 and Phase 2 would create a transitivity gateway to a precedence cycle. Pairwise disjointness on the leaves makes this impossible at the type level — an individual cannot be both `Phase1BDA` and `Phase2BDA`.

- **Instance-level cycles** within the same type (e.g., two distinct Phase 2 BDAs that mutually precede each other) are not caught by this pattern. They are caught by Tester's `temporal_consistency_test` adversarial probe via SPARQL closed-world enumeration. Different layer; complementary mitigation.

- **Why not declare each leaf disjoint with every other leaf individually?** `owl:AllDisjointClasses` is a single block instead of 10 `owl:disjointWith` axioms (5 choose 2). Equivalent in OWL DL semantics, more compact, easier to read. HermiT handles either form.

- **Why not pairwise disjointness on Report classes too?** Doctrinally, `Phase1BDAReport` and `Phase2BDAReport` etc. are obviously distinct, but the JI-005 acceptance criteria (CQ-011) only require ICE/Process disjointness — and that follows automatically from BFO continuant/occurrent partition. Adding sibling Report disjointness is harmless but currently unmotivated by any CQ. Defer to first failing test.

---

## Pattern 4 — Permissive `IntelligenceProduct` input class

### Statement

Process classes with sensor-driven inputs use the **broadest reasonable parent class** as the `has_input some <X>` filler, rather than the narrowest specific class observed in canonical scenarios. Currently: `Phase1BattleDamageAssessment` and `MunitionsEffectivenessAssessment` use `has_input some ex:IntelligenceProduct` rather than `has_input some ex:PostStrikeImagery`.

### When to use

When a process can doctrinally accept any of a family of sensor or product inputs, and tying it to a specific narrow class would force a refactor when the family is extended. Currently applies to Phase 1 BDA and MEA; the same pattern should apply to any future v2.0 process consuming `ex:IntelligenceProduct` subtypes.

### Worked example

```turtle
ex:Phase1BattleDamageAssessment owl:equivalentClass [
    owl:intersectionOf (
        obo:BFO_0000015
        [ a owl:Restriction ;
          owl:onProperty cco:ont00001921 ;
          owl:someValuesFrom ex:IntelligenceProduct ]   # <— permissive parent class
        [ a owl:Restriction ;
          owl:onProperty cco:ont00001986 ;
          owl:someValuesFrom ex:Phase1BDAReport ]
    )
] .
```

### Rationale + caveats

- **Why permissive?** Per Onto's JI-001 review C-4: tying Phase 1 BDA to `has_input some PostStrikeImagery` would mean a SIGINT-derived post-strike report (when v2.0 lands the SIGINT subtree) would *not* satisfy Phase 1 BDA's input requirement. The doctrine is "any post-strike sensor product"; the encoding should reflect that. `ex:IntelligenceProduct` is the discipline-neutral parent, and any sub-class (current `ex:PostStrikeImagery`, future `ex:SIGINTPostStrikeReport`) satisfies the existential.

- **Caveat: too permissive?** The CCO `IntelligenceProduct` could in principle include products outside the post-strike sensor-collection domain. The current encoding doesn't formally constrain Phase 1 BDA's input to *post-strike* products. A future tightening could introduce `ex:PostStrikeIntelligenceProduct` as a subclass of `ex:IntelligenceProduct` and shift the restriction. Reserved for v1.x if a CQ surfaces the gap. Per scope §7 forward-compatibility, that change would not refactor this pattern — it would just restrict the allowed inputs.

- **Tester implication.** CQ-009 positive classification works under permissive encoding because the canonical scenario uses `PostStrikeImagery`, which is `⊑ Imagery ⊑ GEOINTProduct ⊑ IntelligenceProduct`. The reasoner satisfies the existential through the subClass chain.

---

## Pattern 5 — Doctrinal annotation via `jio:derivedFrom`

### Statement

Every `ex:*` class declared in the project carries a `jio:derivedFrom` annotation citing its doctrinal source (e.g., `"JP 3-60 App C (Phase II FDA)"`). The `obo:IAO_0000119` annotation property is **reserved** for cases where the textual `obo:IAO_0000115` definition is a verbatim or near-verbatim quote from a doctrinal source — currently no v1.0 class meets that bar; expect zero `IAO_0000119` usage in v1.0.

`jio:derivedFrom` is declared as `rdf:type owl:AnnotationProperty ; rdfs:subPropertyOf rdfs:isDefinedBy` so generic RDF tooling discovers doctrinal grounding without needing JIO-specific awareness.

### When to use

Every class declared in `src/ontology/`. Scope §5 #9 requires it; CQ-003 enumerates every class and asserts the annotation must be present.

### Worked example

```turtle
jio:derivedFrom rdf:type owl:AnnotationProperty ;
    rdfs:subPropertyOf rdfs:isDefinedBy ;
    rdfs:label "derived from" ;
    obo:IAO_0000115 "An annotation property linking a class or instance to a doctrinal source ..." .

ex:Phase1BattleDamageAssessment
    obo:IAO_0000115 "A Battle Damage Assessment Process that ..." ;
    jio:derivedFrom "JP 3-60 App C (Phase I PDA)" .
```

### Rationale + caveats

- **Why not `obo:IAO_0000119`?** ADR-001 ratified Pattern B: `IAO_0000119` is strictly the source of the *textual definition* per IAO design. Using it for general doctrinal provenance ("this concept derives from JP 2-0") on synthesized definitions is a semantic drift that breaks IAO interoperability. `jio:derivedFrom` is the project-level annotation that captures the broader claim cleanly.

- **Why subordinate to `rdfs:isDefinedBy`?** Generic RDF tooling that doesn't know about `jio:derivedFrom` will still surface the doctrinal grounding under `rdfs:isDefinedBy`. Discovery without JIO-specific awareness.

- **Citation granularity.** Paragraph-level (`"JP 3-60 App C ¶12"`) is preferred. Coarser anchors (`"JP 2-0"`) are acceptable for v1.0 but flag any class that could plausibly cite a more specific paragraph during review. Per JI-005 SME checklist §7.

- **What if the same class derives from multiple sources?** Multiple `jio:derivedFrom` triples are allowed — `ex:CombatAssessmentProcess jio:derivedFrom "JP 3-60 App C", "JP 2-0 ch.I" .` Use multiple values when both sources contribute to the doctrinal commitment.

---

## Pattern 6 — `iao:editor_note` for deferred-scope concepts

### Statement

When a doctrinal concept has a v2.0 (or later) deferral but the v1.0 model would benefit from a placeholder annotation recording the deferral intent, attach an `obo:IAO_0000116` (editor note) annotation to the relevant class. The note states: (a) what the v2.0 extension will add, (b) why it's deferred from v1.0, (c) a pointer to the scope rationale.

The annotation property is `obo:IAO_0000116` — IAO's "editor note" — distinct from `jio:derivedFrom` (provenance) and `obo:IAO_0000115` (definition).

### When to use

Whenever a v1.0 class is structurally simpler than its full doctrinal counterpart and the simplification is intentional per scope §4 deferral. Currently applies to:

- `ex:Phase3BattleDamageAssessment` (theater-context input deferred to v2.0 per JI-001 review C-5)
- `ex:SIGINTProduct`, `ex:HUMINTProduct`, `ex:MASINTProduct` (declared placeholders, sub-classes deferred to v2.0 per scope §3.4)

### Worked example

```turtle
ex:Phase3BattleDamageAssessment
    obo:IAO_0000115 "A Battle Damage Assessment Process that estimates the effect on the broader target system ..." ;
    obo:IAO_0000116 "v2.0 will extend has_input to include broader theater-intelligence context (logistics overlays, adversary order of battle, etc.) per scope §4 deferral. v1.0 models only the Phase II BDA Report input as a structural simplification; the doctrinal reality is that Phase III TSA also consumes theater-context information. See docs/patterns.md §'iao:editor_note for deferred-scope concepts.'" ;
    jio:derivedFrom "JP 3-60 App C (Phase III TSA)" .
```

### Rationale + caveats

- **Why not just leave the simplification undocumented?** A v1.0 model without the annotation looks complete but encodes a doctrinal partial-truth silently. Future SMEs reviewing the model would need to chase down why theater-context is missing; the editor note is a single-source explanation right on the class.

- **Why `IAO_0000116` rather than a custom `jio:` annotation?** `IAO_0000116` is the standard IAO editor-note property — interoperable with OBO Foundry tooling, no project-specific term required. Reuse-first.

- **What goes in the note vs. in scope §4?** Scope §4 lists deferred *concepts* (JIPOE, Collection Management, etc.) at the macro level. Editor notes capture deferred *attributes of in-scope classes* — micro-level. Both layers are useful; they don't duplicate each other.

- **Tester implication.** Editor notes are annotations and don't affect reasoning. They surface in inferred-hierarchy diffs only if a class with a note gets renamed or removed, which is rare. No specific gate or CQ tests for them; their value is documentary.

- **Scaling.** When v2.0 implements the deferral, the editor note is *removed* (or rewritten to record the original deferral as historical context). Migration is mechanical.

---

## Cross-pattern interactions

A few patterns compose; documenting the interactions explicitly:

- **Pattern 1 + Pattern 5.** `ex:AnalyticalRole` (the structural class introduced by Pattern 1) must carry a `jio:derivedFrom` per Pattern 5, even though it's not in scope §3.2's enumeration. Currently cited as `"JP 2-0 ch.III (analyst function)"` — the same anchor as `IntelligenceAnalyst`. JI-002 CQ-001 and CQ-003 enumerations include `ex:AnalyticalRole` per PR #9 commit `82e0984`.

- **Pattern 2 + Pattern 3.** Defined-class encoding for the five CA leaves (Pattern 2) combined with pairwise disjointness (Pattern 3) means an untyped process individual can satisfy at most one leaf's `equivalentClass` body. The reasoner gets a unique classification or none — never multi-classification.

- **Pattern 2 + Pattern 4.** Permissive input encoding (Pattern 4) is what allows the `equivalentClass` body of Phase 1 BDA / MEA to use `IntelligenceProduct` (the broad parent) rather than `PostStrikeImagery` (the specific). The defined-class semantics still classify correctly because the canonical scenario uses `PostStrikeImagery ⊑ ... ⊑ IntelligenceProduct`.

- **Pattern 5 + Pattern 6.** `jio:derivedFrom` records what the class *is* derived from (positive provenance); `IAO_0000116` records what the class *isn't* yet capturing (deferral note). Both can apply to the same class.

---

## Pattern 7 — Reasoner profile compatibility (ELK for B3/B7, HermiT for B5)

### Statement

Every axiom written into [src/ontology/jio-core.ttl](../src/ontology/jio-core.ttl) is **EL-profile syntactically valid** (uses only `equivalentClass`, `intersectionOf`, `someValuesFrom`, `subClassOf`, and `disjointWith` / `AllDisjointClasses` over the project's class names) so that the CI's B3 (TBox consistent) and B7 (adversarial probes) gates — both running ELK per [scripts/ci-gate.sh:96–106](../scripts/ci-gate.sh) — can classify the T-Box without falling back to a non-EL profile.

A-Box consistency (B5) runs HermiT, which is fully OWL DL. The Q-O-3 untyped classification-test individuals classify correctly under both reasoners; the canonical scenario A-Box reasons cleanly under HermiT.

### When to use

Always — until the B3/B7 reasoner choice is reconsidered (per [scripts/ci-gate.sh:101–103](../scripts/ci-gate.sh) the comment explicitly invites JI-005 / JI-005+ to re-evaluate). Any future ticket adding a non-EL construct (universal restriction, qualified cardinality on transitive properties, `unionOf` in superclass position, complex role chain, etc.) must either:

- (a) Stay within EL — find an EL-equivalent encoding that satisfies the same CQs, or
- (b) File an ADR and an explicit reasoner-switch sub-task before merge — switching B3 from ELK to HermiT in CI is non-trivial because HermiT on the full BFO+CCO+IAO+RO closure runs ~15 minutes vs. ELK's ~30 seconds (per [scripts/ci-gate.sh:97–98](../scripts/ci-gate.sh)).

### Worked example

JI-005 v1.0's encoding is EL-profile valid:

| Construct | EL-valid? | Used in v1.0 |
|---|---|---|
| `owl:equivalentClass` with `intersectionOf` of named class + `someValuesFrom` restrictions | ✓ | Five CA leaf classes (Phase1/Phase2/Phase3 BDA, MEA, RAR); `IntelligenceAnalyst`; `TargetAnalyst` |
| `rdfs:subClassOf` with `someValuesFrom` restrictions | ✓ | Temporal ordering (`preceded_by`); process mereology (`is part of process`) |
| `owl:AllDisjointClasses` (sugar for pairwise `disjointWith`) | ✓ | Five CA leaves |
| Transitive properties (BFO_0000062 / 63) | ✓ | Used as `someValuesFrom` filler — no qualified cardinality on them |
| `owl:unionOf` in restriction filler | ✗ NOT used in v1.0 | Considered for `(Phase3BDA ∨ MEA) precedes RAR` but rejected per JI-001 doctrinal call (conjunctive, not disjunctive) — landed as two separate `subClassOf` restrictions |
| `owl:allValuesFrom` (universal restriction) | ✗ NOT used in v1.0 | Not required by any scope §3.6 / §3.7 axiom |
| Inverse properties (`owl:inverseOf`) | ✗ NOT used in v1.0 | Project uses both `BFO_0000056` (participates_in) and `BFO_0000057` (has_participant) directly; we do not declare or rely on inverses ourselves (the upstream BFO declares `0000056 inverseOf 0000057`, but that's an upstream axiom ELK ignores under EL) |

### Rationale + caveats

- **Why ELK for B3?** Performance. The full closure of imports (BFO 2020 + RO + IAO + CCO Merged) is ~30K axioms. HermiT classification on that closure exceeds the GitHub Actions runner timeout. ELK runs in ~30s. CI green at all is the precondition for the rest of the workflow.

- **Why HermiT for B5?** A-Box consistency checks may exercise inferences (e.g., `BFO_0000056 inverseOf BFO_0000057` from upstream BFO) that are non-EL. Running HermiT only on the merged T-Box+A-Box (much smaller than the full T-Box closure for B3) is tractable and gives full DL coverage where it matters.

- **What the v1.0 encoding deliberately did NOT use, even though scope or doctrine could have invited it:**
  - **Disjunctive RAR predecessors.** The doctrine reads as conjunctive (RAR consumes both Phase III BDA and MEA); encoded as two separate axioms, EL-valid. Disjunctive encoding would have used `unionOf`, non-EL.
  - **Cardinality on outputs** (e.g., "RAR has exactly one RAR Report output"). Tempting but non-EL with `=N`/`≥N`/`≤N`. v1.0 uses `someValuesFrom` (≥ 1), accepting the looseness. If a CQ later requires "exactly one," that's the trigger for a HermiT-or-DL switch.
  - **Inverse property axioms.** Project does not declare its own inverses. If a CQ needs to traverse "what processes does this analyst participate in?" via the inverse direction, the SPARQL query layer handles that without requiring an OWL `inverseOf` axiom in the T-Box.

- **Tester implication.** Tester's adversarial probes under B7 use ELK. Probe T-Box deltas at `tests/fixtures/probes/*.ttl` should also stay EL-valid unless the probe specifically tests a DL-only feature (in which case the probe should override the reasoner choice locally, not in `ci-gate.sh`). For v1.0, no probe delta requires DL.

- **When to revisit.** The next time a CQ or scope requirement genuinely needs `unionOf`, qualified cardinality, or universal restriction, that's an ADR-worthy escalation. Options at that point: (i) stay EL with a creative reformulation, (ii) split the T-Box into an EL fast core + a DL extension imported only for B5/B6 (hybrid), (iii) bite the cost and switch B3 to HermiT (and probably split CI into a fast smoke-test stage and a slow full-DL stage). v1.x retro item.

---

## Pattern register

| Pattern | Scope reference | First applied | Tester veto consulted? |
|---|---|---|---|
| Anti-rigidity Person/Role separation | §3.2, §5 #5; PR #12 §1 | JI-005 | Yes — testability via CQ-012 + `role_stress_test`; not vetoed |
| CA leaves as defined classes | §3.7, §5 #3 (Option α) | JI-005 | Yes — testability via CQ-009 + CQ-010; not vetoed |
| CA sub-process pairwise disjointness | §3.6; Onto C-2 from JI-001 review | JI-005 | Yes — supports `temporal_consistency_test`; not vetoed |
| Permissive `IntelligenceProduct` input | §3.7; Onto C-4 from JI-001 review | JI-005 | Yes — testability neutral; not vetoed |
| `jio:derivedFrom` doctrinal annotation | §5 #9; ADR-001 (Option B) | JI-005 | Implicit via ADR ratification |
| `iao:editor_note` for deferred scope | §3.4, §4; Onto C-5 from JI-001 review | JI-005 | Implicit; documentary |
| Reasoner profile compatibility (ELK B3/B7; HermiT B5) | scripts/ci-gate.sh:96–106 (PR #16); ELK switch from HermiT for runtime | JI-005 | Yes — directly tester-facing; not vetoed |

---

## When to add a new pattern

A new pattern is added to this document when:

1. A modeling decision in JI-005 or any later ticket establishes a structural commitment that future tickets should follow.
2. The decision is non-obvious — i.e., a future contributor reading just `jio-core.ttl` without this document would plausibly choose a different encoding.
3. The decision interacts with the test surface (CQs, adversarial fixtures, baselines) in a way that a Tester veto would be relevant.

Patterns that are obvious from `jio-core.ttl` alone (e.g., "use BFO_0000056 for participates_in") do **not** belong here. They live in the file itself. This document is for the patterns where the *why* matters.

When proposing a new pattern: open a ticket, draft the pattern in a PR against this file, route to Tester for veto review per workflow §6 Rule 4, and merge with three-signoff. New patterns require an ADR if they introduce a new term or property; otherwise the pattern doc is the canonical record.
