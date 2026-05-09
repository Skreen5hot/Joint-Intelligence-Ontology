# JI-005 — SME Review Checklist

| Field | Value |
|---|---|
| Owner | SME |
| Purpose | Doctrinal correctness review of Onto's bundled JI-005 PR |
| Pre-authored | Pre-emptively, before JI-005 PR opens, so review is reactive only against Onto's specific choices |
| Authoritative sources | [docs/scope.md](../scope.md), [docs/scenarios/JI-002-cqs.yaml](../scenarios/JI-002-cqs.yaml), [docs/scenarios/JI-005-canonical-ca.md](../scenarios/JI-005-canonical-ca.md), [docs/decisions/ADR-001-iao-119-semantics.md](../decisions/ADR-001-iao-119-semantics.md), [docs/relation-mapping.md](../relation-mapping.md) |
| Signoff role | SME's third of three-signoff per workflow §5 (Onto authors; Tester verifies testability; SME verifies doctrinal correctness) |

---

## Purpose

JI-005 is the largest single PR planned for the project: anti-rigidity refactor + namespace corrections + full T-Box per scope §3 + canonical scenario A-Box + `jio:derivedFrom` pattern + patterns.md authoring. SME review of a PR this size benefits from pre-thought criteria — reviewing reactively against a 50-class T-Box without a checklist invites missing things that won't show up until a downstream CQ fails.

This checklist is **not** a contract Onto must satisfy item-by-item. Onto chose the encoding; this list is what *I* will check. If an item is non-applicable because Onto picked a structurally different (but equivalent) encoding, that's a "noted, not a failure" outcome on review.

---

## Pre-review setup (mechanical)

Before opening the PR diff, run:

- [ ] Pull the JI-005 branch locally (`git fetch origin && git checkout <onto-branch>`)
- [ ] Verify CI is green: SMOKE-CLEAN passing (B1+B2+B3+B4), B5 ABox consistency passing on the new `src/instances/JI-005-canonical-ca.jsonld`, B6 CQ pass-rate at 15/15, B7 adversarial probes all passing
- [ ] Read the PR description for Onto's stated encoding choices on each of the C-2/C-4/C-5 items (disjointness pairs, permissive `IntelligenceProduct` input, Phase 3 editor note)
- [ ] Confirm PR diff contains: (a) updated [src/ontology/jio-core.ttl](../../src/ontology/jio-core.ttl), (b) new [src/instances/JI-005-canonical-ca.jsonld](../../src/instances/JI-005-canonical-ca.jsonld), (c) new or updated [docs/patterns.md](../patterns.md), (d) deletions of working-tree drafts at [src/ontology/intelligenceAnalysisProcess.ttl](../../src/ontology/intelligenceAnalysisProcess.ttl) and [src/instances/Phase1Report.jsonld](../../src/instances/Phase1Report.jsonld) (the JI-005-orphan files)

If any of the above are missing, that's not a doctrinal failure but it's a procedural blocker — surface to Onto before substantive review.

---

## §1 — Class hierarchy correctness (against scope §3)

For each subsection of [scope §3](../scope.md), verify the corresponding T-Box content:

### Combat Assessment process tree (scope §3.1)

- [ ] `ex:CombatAssessmentProcess` declared as `subClassOf obo:BFO_0000015 (Process)`
- [ ] `ex:BattleDamageAssessmentProcess subClassOf ex:CombatAssessmentProcess`
- [ ] **All three** BDA phases present: `ex:Phase1BattleDamageAssessment`, `ex:Phase2BattleDamageAssessment`, `ex:Phase3BattleDamageAssessment` — each `subClassOf ex:BattleDamageAssessmentProcess`. **Failing this is the v0 doctrinal bug repeating itself.**
- [ ] `ex:MunitionsEffectivenessAssessment subClassOf ex:CombatAssessmentProcess` (NOT `subClassOf ex:BattleDamageAssessmentProcess` — MEA is a sister of BDA, not a child)
- [ ] `ex:ReAttackRecommendation subClassOf ex:CombatAssessmentProcess` (also a sister of BDA)
- [ ] Five CA sub-process classes are pairwise disjoint per Onto C-2 (5 classes → 10 disjointness axioms; or one `owl:AllDisjointClasses` block)

### Analyst roles (scope §3.2)

- [ ] `ex:IntelligenceAnalyst` declared as a class, **NOT** as `subClassOf cco:ont00001262` (Person). The anti-rigidity refactor's whole point.
- [ ] `ex:TargetAnalyst subClassOf ex:IntelligenceAnalyst` (specialization within the analyst class hierarchy is OK — what's not OK is rigid Person sub-classing)
- [ ] `ex:TargetAnalysisRole subClassOf cco:ont00000984 (OccupationRole)` (this is correct sub-classing — Roles are realizable entities, not rigid types of agents)
- [ ] An axiom (somewhere — restriction, equivalent class, or property chain) capturing "an instance is a TargetAnalyst iff it is a Person bearing a TargetAnalysisRole." Encoding choice is Onto's lane; behavior verified via CQ-012 and `role_stress_test`.

### Facilities (scope §3.3)

- [ ] `ex:MilitaryFacility subClassOf cco:ont00000192 (Facility)`
- [ ] `ex:IntelligenceOperationsCenter subClassOf ex:MilitaryFacility`

### ICE hierarchy (scope §3.4)

- [ ] `ex:IntelligenceProduct subClassOf obo:IAO_0000030 (ICE)`
- [ ] `ex:GEOINTProduct subClassOf ex:IntelligenceProduct`
- [ ] `ex:Imagery subClassOf ex:GEOINTProduct` (NOT `subClassOf obo:IAO_0000030` directly per the v0 plan — Imagery is a discipline-specific product)
- [ ] `ex:PostStrikeImagery subClassOf ex:Imagery`
- [ ] **Declared but not axiomatized** (extension points): `ex:SIGINTProduct`, `ex:HUMINTProduct`, `ex:MASINTProduct`. Mere declaration with no axioms is the correct v1.0 state.
- [ ] `ex:Report subClassOf obo:IAO_0000030`
- [ ] All five report classes: `ex:Phase1BDAReport`, `ex:Phase2BDAReport`, `ex:Phase3BDAReport`, `ex:MEAReport`, `ex:RARReport` — each `subClassOf ex:Report`
- [ ] **`ex:Phase3BDAReport` may be aliased as `ex:TargetSystemAssessmentReport`** per scope §3.4 — either name acceptable, but pick one and stay consistent

### Material entities (scope §3.5)

- [ ] `ex:Target subClassOf obo:BFO_0000040 (MaterialEntity)`

---

## §2 — Anti-rigidity verification (scope §5 #5)

The behavioral check, not the encoding check:

- [ ] CQ-012 passes: a participant agent without `bearer_of` a TargetAnalysisRole is NOT classified as TargetAnalyst
- [ ] `role_stress_test` adversarial probe passes
- [ ] T-Box does NOT contain the v0 bug: `ex:IntelligenceAnalyst rdfs:subClassOf cco:ont00001262`
- [ ] T-Box does NOT contain: `ex:TargetAnalyst rdfs:subClassOf cco:ont00001262`
- [ ] If Onto encoded the role-bearing pattern as a property chain (e.g., `RO_0000053 ∘ rdf:type → some_pattern`), confirm it's documented in [patterns.md](../patterns.md)

---

## §3 — Namespace corrections (JI-008 F-1, F-2, F-3)

- [ ] CCO namespace prefix in T-Box is `https://www.commoncoreontologies.org/` (NOT `http://www.ontologyrepository.com/CommonCoreOntologies/`)
- [ ] `owl:imports` line for CCO points to `<https://www.commoncoreontologies.org/CommonCoreOntologiesMerged>` (NOT the wrong v0 URL)
- [ ] All Person/Facility/OccupationRole references use opaque IRIs: `cco:ont00001262`, `cco:ont00000192`, `cco:ont00000984` — NOT `cco:Person`, `cco:Facility`, `cco:OccupationRole`
- [ ] No symbolic-name CCO references survive in either the T-Box or the A-Box
- [ ] Working-tree-draft pre-correction files ([src/ontology/intelligenceAnalysisProcess.ttl](../../src/ontology/intelligenceAnalysisProcess.ttl), [src/instances/Phase1Report.jsonld](../../src/instances/Phase1Report.jsonld)) deleted by JI-005's PR per the orphan-cleanup plan

---

## §4 — Temporal ordering (scope §3.6)

For each ordering, verify the encoding produces the correct inferential behavior (not the encoding itself — Onto's lane):

- [ ] CQ-004 passes: Phase1BDA precedes Phase2BDA
- [ ] CQ-005 passes: Phase2BDA precedes Phase3BDA
- [ ] CQ-006 passes: Phase1BDA precedes MEA
- [ ] CQ-007 passes: Phase3BDA precedes RAR
- [ ] CQ-008 passes: MEA precedes RAR
- [ ] **RAR conjunctively preceded by both Phase3BDA AND MEA** — both CQ-007 and CQ-008 must pass; the encoding produces TWO separate `preceded_by` axioms on RAR, not one disjunctive axiom. (Per JI-001 doctrinal call.)
- [ ] Asymmetry preserved: T-Box does NOT contain `Phase1 ⊑ precedes some Phase2` (Phase 1 may exist without successor; Onto C-3 confirmed this is the doctrinal reading)
- [ ] BFO_0000063 transitivity correctly propagates Phase1→Phase2→Phase3 in the canonical scenario instance

---

## §5 — Information flow (scope §3.7)

- [ ] CQ-009 passes: a process individual with all required I/O classifies under the expected sub-class
- [ ] CQ-010 passes: a bare process without I/O does NOT classify under any CA sub-class (`underconstraint_test`)
- [ ] **Phase 3 BDA input is `Phase2BDAReport` only** in the T-Box. Theater-context input is NOT modeled per scope §3.7 / Onto C-5
- [ ] **`iao:editor_note` on `ex:Phase3BattleDamageAssessment`** records the v2.0 theater-context extension intent. Verify the note exists and reads coherently (something like "v2.0 will extend has_input to include theater-intelligence context per scope §4 deferral")
- [ ] Phase 1 BDA input is the permissive class — `has_input some IntelligenceProduct` (or its hierarchy parent), NOT strictly `has_input some PostStrikeImagery`. Per Onto C-4
- [ ] All five report types correctly placed as `has_output` of their respective sub-process classes

---

## §6 — ICE/Process disjointness (scope §5 #4)

- [ ] CQ-011 passes: no ICE class is inferable as a Process under any property chain
- [ ] `ice_confusion_test` adversarial probe passes
- [ ] No extra disjointness axiom needed — `IAO_0000030 ⊓ BFO_0000015 ⊑ ⊥` follows from BFO continuant/occurrent partition. If Onto added a redundant explicit disjointness axiom, that's harmless but document the rationale

---

## §7 — `jio:derivedFrom` annotation pattern (per ADR-001)

- [ ] `jio:derivedFrom` declared as `owl:AnnotationProperty` in [src/ontology/jio-core.ttl](../../src/ontology/jio-core.ttl)
- [ ] Declared with `rdfs:subPropertyOf rdfs:isDefinedBy` (per ADR-001 mitigation against reuse-first cost)
- [ ] CQ-001 passes: every `ex:*` class has an `iao:IAO_0000115` definition
- [ ] CQ-002 passes: every `ex:*` class has at least one logical axiom
- [ ] CQ-003 passes: every `ex:*` class has a `jio:derivedFrom` annotation
- [ ] Annotation values are paragraph-level where possible (e.g., `"JP 3-60 App C ¶3"`) — coarse anchors like `"JP 2-0"` alone are acceptable for v1.0 but flag any class that could plausibly cite a more specific paragraph
- [ ] Working-tree draft `IAO_0000119 "JP 2-0"` annotations are gone — replaced by `jio:derivedFrom`. `IAO_0000119` reserved for actual definition-source citations (likely zero usage in v1.0; that's acceptable)

---

## §8 — Canonical scenario A-Box (against [docs/scenarios/JI-005-canonical-ca.md](../scenarios/JI-005-canonical-ca.md))

Verify [src/instances/JI-005-canonical-ca.jsonld](../../src/instances/JI-005-canonical-ca.jsonld) faithfully IRI-fies the SME narrative:

- [ ] Every handle in narrative §3 (`Analyst_Jane_001`, `Role_TargetAnalysis_Jane_001`, `Target_Bridge_42`, `Site_CENTCOM_JIOC`) appears in the JSON-LD with the expected class typing
- [ ] Every handle in narrative §4 (six ICEs) appears with the expected class typing
- [ ] Every process handle in narrative §5 (six processes including `Process_CombatAssessment_OpAlpha`) appears with the expected class typing
- [ ] **No introduced entities** — JSON-LD does not add agents, roles, ICEs, or processes that aren't in the narrative. (If something was added, that's a unilateral A-Box authoring move and routes back through SME for narrative update.)
- [ ] **No omitted entities** — every narrative handle has a corresponding JSON-LD individual
- [ ] All §5 process table relationships present in the JSON-LD: `has_input`, `has_output`, `has_participant`, `occurs_at`, `preceded_by`, `is_part_of_process`, `bearer_of`, `realized_in`
- [ ] CQ-013 passes: process participants are correctly scoped (Jane, Bridge_42 yes; JIOC, ICEs, Role no)
- [ ] CQ-014 passes: count of CA sub-processes part_of `Process_CombatAssessment_OpAlpha` is exactly 5
- [ ] CQ-015 passes: `Target_Bridge_42` is not classified as Person/Analyst/Agent

---

## §9 — Adversarial probe extensions

If Onto IRI-fied the JI-005a §9.1 and §9.2 adversarial variants into Tester's fixture directories:

- [ ] `tests/fixtures/adversarial/temporal_consistency_test/JI-005-phase2-without-phase1.jsonld` exists (or similar — exact filename Tester's choice)
- [ ] `tests/fixtures/adversarial/role_stress_test/JI-005-analyst-without-role.jsonld` exists
- [ ] Both fixtures use the canonical scenario IRIs as a base, with the documented breakage applied

If Onto deferred this to Tester (which is structurally correct per workflow §5 — Tester owns adversarial fixtures), confirm Onto opened a follow-up handoff to Tester rather than leaving it implicit.

---

## §10 — patterns.md authoring (per JI-005 deliverables)

[docs/patterns.md](../patterns.md) is created (or updated) and contains at minimum:

- [ ] **Anti-rigidity pattern** — the canonical "Person bears Role realized in Process" structure, with worked example (TargetAnalyst / TargetAnalysisRole / Phase1BDA)
- [ ] **CA sub-process disjointness pattern** — pairwise disjointness on the 5 CA sub-process classes, with rationale (prevents transitivity-cycle gateway per Onto C-2)
- [ ] **Permissive input class pattern** — `IntelligenceProduct` as the input class for sensor-driven processes, with v2.0 extension note (per Onto C-4)
- [ ] **Doctrinal annotation pattern** — `jio:derivedFrom` for general provenance; `IAO_0000119` reserved for strict definition sources (per ADR-001)
- [ ] **`iao:editor_note` for deferred-scope concepts** — pattern for recording v2.0 extension points without violating §4 deferral discipline (per Onto C-5)
- [ ] Tester's testability veto applied or waived for each pattern with rationale

If patterns.md is split into multiple files (Onto's discretion), confirm a top-level index references all of them.

---

## §11 — JI-002 CQ acceptance run

- [ ] **All 15 CQs in [docs/scenarios/JI-002-cqs.yaml](../scenarios/JI-002-cqs.yaml) pass** when run against the merged T-Box + A-Box
- [ ] B6 (CQ pass rate) blocking gate green
- [ ] Any CQ failure is triaged via workflow §3 reject path: Tester → Onto triage → AXIOMATIZED (model bug) or DOCTRINE-READY (CQ bug). SME does not edit T-Box; Tester does not edit CQs

---

## §12 — Tester impact (per ADR template requirement)

- [ ] All Tester-facing impacts (new probe T-Box deltas, new gate definitions, new regression baseline lines) are explicitly listed in the PR description
- [ ] Tester has signed off on the PR before SME final-signs

---

## SME signoff condition

I sign off when:

- (a) Every checkbox above passes, OR
- (b) Specific failures are documented in the PR review with one of: a justified deferral note, a fix-it-before-merge request, or an ADR-worthy escalation per workflow §6 Rule 1

I will NOT sign off if:

- The CCO namespace bugs (F-1, F-2, F-3) are unresolved
- BDA is truncated to two phases (the v0 doctrinal error)
- Combat Assessment is conflated with BDA (v0 doctrinal error)
- Anti-rigidity is violated (`ex:IntelligenceAnalyst rdfs:subClassOf cco:ont00001262` survives in the diff)
- RAR ordering is encoded disjunctively rather than conjunctively
- Any of the 15 CQs fails without an Onto-triage routing note

These are the floor. Anything above the floor is a judgment call recorded in the PR review.

---

## Failure-mode triage

If a check fails, route per workflow §3:

- **Encoding choice produces wrong behavior** → Onto triage → back to AXIOMATIZED (model bug)
- **CQ assertion is doctrinally wrong** → Onto triage → back to DOCTRINE-READY (CQ bug; SME revises)
- **Scenario narrative was wrong** → back to DOCTRINE-READY (SME revises [docs/scenarios/JI-005-canonical-ca.md](../scenarios/JI-005-canonical-ca.md), then Onto regenerates A-Box)
- **Doctrinal claim has no logically-valid representation** → ADR-worthy escalation per workflow §6 Rule 1

I do not edit Onto's T-Box. Tester does not edit my CQs. Onto routes; lane discipline holds.

---

## Notes for future SME reviews

This checklist is JI-005-specific but the structure generalizes. After JI-005 ships, this file is a candidate for promotion to a `docs/templates/sme-review-checklist.md` template — strip the JI-005-specific items and keep the §1–§12 skeleton. Decision deferred to v1.1 retro.
