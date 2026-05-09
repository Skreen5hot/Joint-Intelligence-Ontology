# JI-Onto v1.0 Scope (Combat Assessment)

**Ticket:** JI-001
**Owner:** SME
**Status:** Draft for three-signoff (SME + Onto + Tester)
**Date:** 2026-05-09
**Supersedes:** the v0 sketch in [docs/plan.md](plan.md), which limited modeling to BDA Phases I/II only

---

## 1. Purpose

This document locks the doctrinal boundary of the v1.0 ontology. It defines what the v1.0 release shall represent, what it explicitly defers, and the acceptance criteria for declaring v1.0 complete. Every ticket in the JI-Onto Phase 1+ backlog must be traceable to a class, relation, or scenario in this scope — anything outside it requires a v1.x amendment via the workflow §10 retro process.

**Why this scope and not another:** the project's dual mandate is operational utility for analysts in a JIOC and machine-reasonable inference under BFO/CCO. Combat Assessment is the most operationally demanding intelligence flow that has clear doctrinal structure (JP 3-60 Appendix C), well-defined inputs/outputs/sequencing, and direct CCIR linkage. It exercises every constraint type the ontology must support — temporal ordering, role realization, ICE provenance, multi-agent participation, hierarchical sub-process decomposition — without demanding the full breadth of pre-conflict intelligence planning that a v1.0 effort cannot responsibly cover.

---

## 2. Doctrinal Anchors

Primary sources of truth for v1.0:

| Doctrine | Coverage | Repo location |
|---|---|---|
| **JP 3-60, *Joint Targeting* (current edition)** | Combat Assessment, BDA phasing, MEA, RAR | external; cite by chapter/appendix |
| **JP 2-0, *Joint Intelligence*** | Analyst roles, intelligence cycle context, JIOC structure | [docs/jp2_0.pdf](jp2_0.pdf) |
| **JP 5-0, *Joint Planning*** | Operational design context (consulted, not modeled) | external reference only |

Citations in T-Box and A-Box use the `jio:derivedFrom` annotation property per [ADR-001](decisions/ADR-001-iao-119-semantics.md). Format: `"JP 3-60 App C ¶<paragraph>"` or `"JP 2-0 ch.III §<section>"`. Specific paragraph numbers are populated during JI-005 axiomatization, not in this document.

---

## 3. In Scope (v1.0)

### 3.1 Combat Assessment — full stack

The complete Combat Assessment process per JP 3-60 Appendix C, decomposed as follows:

```
CombatAssessmentProcess
├── BattleDamageAssessmentProcess
│   ├── Phase1BattleDamageAssessment   (Physical Damage Assessment)
│   ├── Phase2BattleDamageAssessment   (Functional Damage Assessment)
│   └── Phase3BattleDamageAssessment   (Target System Assessment)
├── MunitionsEffectivenessAssessment   (MEA)
└── ReAttackRecommendation             (RAR)
```

**Doctrinal correction recorded:** the v0 plan ([docs/plan.md](plan.md)) modeled only BDA Phases I/II and conflated BDA with Combat Assessment. This is doctrinally wrong on two counts:

1. **BDA has three phases**, not two. Phase III (Target System Assessment) evaluates the effect on the broader target system — the enemy IADS, lines of communication, command-and-control network — and is what enables operational-level commanders to assess whether a campaign is degrading the adversary's capability. Modeling only physical and functional damage truncates BDA at the tactical level.
2. **CA ⊋ BDA.** Combat Assessment is the sum of BDA + MEA + RAR. Modeling CA without MEA (which assesses *whether the weapon performed as expected*) and RAR (the actual decision artifact that re-enters the targeting cycle) reduces CA to its largest sub-process and loses the doctrinal closure of the cycle.

### 3.2 Analyst Roles

| Class | Doctrinal grounding | Notes |
|---|---|---|
| `ex:IntelligenceAnalyst` | JP 2-0 ch.III (analyst function) | Person bearing an analytical role; **not a rigid sub-class of Person** (per ADR forthcoming under JI-005's anti-rigidity refactor) |
| `ex:TargetAnalyst` | JP 3-60 ch.II (targeting cell roles) | Person bearing `ex:TargetAnalysisRole`; primary analyst for BDA |
| `ex:TargetAnalysisRole` | JP 3-60 ch.II | Realizable role, not essential property |

**Out of scope for v1.0 — but reserved as forward extension points:** GEOINT/SIGINT/HUMINT/MASINT discipline-specific analyst sub-roles. The ICE hierarchy (§3.4) provides discipline-neutral product classes; if Phase 2+ requires discipline-specific analyst roles to model collection-management workflows, they extend `ex:IntelligenceAnalyst`.

### 3.3 Facilities

| Class | Doctrinal grounding |
|---|---|
| `ex:MilitaryFacility` | JP 1, JP 2-0 (CCMD/JTF infrastructure) |
| `ex:IntelligenceOperationsCenter` | JP 2-0 ch.II (JIOC) |

**Out of scope:** subordinate cells (Targeting Cell, Collection Management Cell, Production Cell), distributed reach-back nodes. v2.0 if needed.

### 3.4 Information Content Entities (ICEs)

Discipline-neutral product hierarchy:

```
IAO_0000030 (Information Content Entity)
├── ex:IntelligenceProduct
│   ├── ex:GEOINTProduct
│   │   ├── ex:Imagery
│   │   │   └── ex:PostStrikeImagery
│   │   └── ex:GeospatialAnalysisReport
│   ├── ex:SIGINTProduct       (placeholder for v2.0; not axiomatized in v1.0)
│   ├── ex:HUMINTProduct       (placeholder for v2.0)
│   └── ex:MASINTProduct       (placeholder for v2.0)
└── ex:Report
    ├── ex:Phase1BDAReport
    ├── ex:Phase2BDAReport
    ├── ex:Phase3BDAReport     (alias: Target System Assessment Report)
    ├── ex:MEAReport
    └── ex:RARReport
```

**v1.0 axiomatized:** GEOINT subtree (down to `ex:PostStrikeImagery`) and the five Combat Assessment report types. The other discipline subtrees are *declared* but not axiomatized — they exist as forward extension points so v2.0 doesn't have to refactor the ICE hierarchy.

**Doctrinal note on `ex:Imagery`:** the v0 plan treated `ex:Imagery` as the only sensor product. v1.0 corrects this — Imagery is a sub-class of GEOINTProduct, which is one of several discipline-specific product classes. This avoids the v2.0 refactor cost.

### 3.5 Material Entities

| Class | Doctrinal grounding | Notes |
|---|---|---|
| `ex:Target` | JP 3-60 ch.II | Targets are participants in CA processes via `BFO_0000057 (has participant)` — **not** intentional `has_object` relations. The ontology models the target as a material entity participating in an analytical process; it does not encode targeting intent (which is a Joint Force Commander function, out of scope for an intelligence ontology). |

### 3.6 Process Sequencing

The v1.0 ontology must support these temporal orderings as inferable (not just stated):

- `Phase1BDA` precedes `Phase2BDA` (BFO_0000063)
- `Phase2BDA` precedes `Phase3BDA` (BFO_0000063)
- `Phase1BDA` precedes `MEA` (MEA depends on physical damage observations)
- `Phase3BDA` precedes `RAR` **AND** `MEA` precedes `RAR` (conjunctive — RAR is informed by both target-system effect and munition-performance assessment per JP 3-60; encoded as two separate `preceded_by` axioms on `RAR`)
- All five sub-processes are `is_part_of_process` of a single `CombatAssessmentProcess` instance

**Asymmetry note:** the orderings above are encoded as constraints on the *downstream* process (e.g., `Phase2BDA ⊑ preceded_by some Phase1BDA`). This is intentional: a Phase1BDA may exist without a successor (analyst may stop at Phase 1 if physical damage is operationally sufficient), and similarly for Phase2 → Phase3 and whether MEA is conducted at all. Do not add `Phase1 ⊑ precedes some Phase2` — the asymmetry matches doctrinal reality.

### 3.7 Information Flow (has_input / has_output)

Each Combat Assessment sub-process has well-defined ICE inputs and outputs. The v1.0 axiomatization must encode at minimum:

| Process | Required input(s) | Required output |
|---|---|---|
| Phase1BDA | PostStrikeImagery (or other sensor data) | Phase1BDAReport |
| Phase2BDA | Phase1BDAReport | Phase2BDAReport |
| Phase3BDA | Phase2BDAReport (broader theater intelligence context noted as a v2.0 extension point per §4 — `iao:editor_note` recorded on `ex:Phase3BattleDamageAssessment` during JI-005) | Phase3BDAReport |
| MEA | PostStrikeImagery, weapon-employment data | MEAReport |
| RAR | Phase3BDAReport **AND** MEAReport (conjunctive — both required, matches §3.6 sequencing) | RARReport |

---

## 4. Out of Scope (deferred)

| Concept | Rationale for deferral | Reserved for |
|---|---|---|
| **JIPOE** (Joint Intelligence Preparation of the Operational Environment) | Different doctrinal flow (pre-conflict planning) anchored in JP 2-01.3. Mixing pre-conflict and during/post-strike flows in v1.0 would dilute focus; both deserve dedicated attention. | v2.0 |
| **Collection Management** (CCIRM, PIRs, RFIs, EEIs, collection plan) | Foundational to operational intel but introduces a parallel ICE hierarchy and a new process tree that would double v1.0 scope. | v2.0 |
| **Intelligence Cycle scaffolding** (the six-phase cycle of JP 2-0 ch.I) | The cycle is a *meta-process* containing CA, JIPOE, CM, and dissemination. v1.0 axiomatizes a slice (CA); the parent cycle waits until enough children are modeled to make the parent meaningful. | v2.0 or v3.0 |
| **CCIRs / PIRs / FFIRs** | Connect to Collection Management; deferring CM defers these. | v2.0 |
| **Discipline-specific analyst roles** (GEOINT/SIGINT/HUMINT/MASINT analyst sub-classes) | Not needed to exercise CA inference; extension points reserved in §3.4. | v2.0 |
| **Targeting Cycle (JP 3-60 chs. II–III)** | The cycle that *produces* targets and consumes RAR. v1.0 models CA as a self-contained slice; the cycle wrapper waits. | v2.0 |
| **Adversary COA modeling** | Belongs to JIPOE. | v2.0 |
| **Multi-INT fusion processes** | Requires the discipline-specific products to be axiomatized first. | v2.0+ |
| **Dissemination / consumer workflows** | Out of CA scope. | v2.0 |

**Deferral discipline:** any v1.0 ticket that reaches into a deferred concept is grounds for SME pushback. Forward extension points (declared-but-unaxiomatized classes in §3.4) are the seam — sub-classes can be added in v2.0 without refactoring v1.0.

---

## 5. Acceptance Criteria for v1.0

The v1.0 release is complete when **all** the following hold:

1. **Every §3 class is axiomatized** — defined as carrying ALL THREE: (a) an `iao:IAO_0000115` textual definition (Aristotelian form per workflow §3.3); (b) at least one logical axiom (`subClassOf` placement under BFO/CCO upper, OR `owl:equivalentClass` definition, OR a `someValuesFrom`/`allValuesFrom` restriction); (c) a `jio:derivedFrom` annotation per ADR-001. Verified by SPARQL queries in the competency suite.
2. **All §3.6 temporal orderings** inferable from the T-Box; verified by competency tests under [tests/competency/](../tests/competency/).
3. **All §3.7 has_input / has_output relations are inferable** from the T-Box such that: (a) a correctly-instantiated process individual with all required inputs and outputs classifies as the expected sub-class (positive case); (b) a bare process individual with no inputs/outputs does NOT classify as any CA sub-class (negative case via `underconstraint_test` adversarial probe). Classification (positive case) implies the five CA leaf process classes (Phase1BDA, Phase2BDA, Phase3BDA, MEA, RAR) are **defined classes** with `owl:equivalentClass` — necessary AND sufficient conditions on inputs/outputs. Encoding choice within that constraint (`someValuesFrom` restrictions inside the equivalentClass body, closure axioms, property chains, or other valid OWL DL patterns) is Ontologist's lane per workflow §5; SME's acceptance criterion is the inferential behavior, not the encoding.
4. **The five Combat Assessment report types** correctly classified as sub-classes of `IAO_0000030 (ICE)` under `ex:Report`, never inferable as `BFO_0000015 (Process)` — verified by the Tester's `ice_confusion_test` adversarial probe ([tests/fixtures/adversarial/ice_confusion_test/](../tests/fixtures/adversarial/ice_confusion_test/)). Note: this property follows automatically from BFO's continuant/occurrent disjointness (`IAO_0000030 ⊓ BFO_0000015 ⊑ ⊥`); no extra axiom is required from JI-005.
5. **Anti-rigidity satisfied:** an analyst classification is inferable from role realization, not from class membership in `cco:Person` (`ont00001262`). Specifically: `ex:TargetAnalyst` is not a sub-class of `cco:Person`; analyst classification depends on bearing `ex:TargetAnalysisRole`. Encoding choice (`bearer_of`, `RO_0000053` inverse, property chain, etc.) is Ontologist's lane. Verified by `role_stress_test` adversarial probe.
6. **At least three SME-authored A-Box scenarios** exercise the full CA flow end-to-end (BDA I → II → III → MEA → RAR) under [src/instances/](../src/instances/), each with a corresponding narrative under `docs/scenarios/`.
7. **At least 15 competency questions** in the structured CQ format ([docs/templates/cq-template.yaml](templates/cq-template.yaml)), covering each acceptance criterion, with `must_infer` and `must_not_infer` populated. JI-002 deliverable.
8. **Reasoner runs clean** (HermiT) over the merged T-Box + A-Box; CI gates B1–B7 all pass; W1 hierarchy diff baseline established.
9. **Doctrinal traceability:** every `ex:*` class carries a `jio:derivedFrom` annotation citing JP 3-60 or JP 2-0 at paragraph or section level (per ADR-001).

---

## 6. Dependencies and Sequencing

| Ticket | Dependency on this scope |
|---|---|
| JI-002 | 15 CQs are authored against §3 classes and §5 acceptance criteria |
| JI-005 | Anti-rigidity refactor and full T-Box axiomatization land §3 classes; namespace corrections per JI-008; ADR-001 (jio:derivedFrom) implementation |
| JI-006 | Tester persona alignment may include scope-specific probes (e.g., a CA-completeness check) |
| Future scenario tickets | Each A-Box scenario must trace to §3 classes; out-of-scope concepts are grounds for SME pushback |

---

## 7. Forward Compatibility Promise

Adding the deferred v2.0 concepts (§4) **shall not require renaming or removing** any v1.0 class. Specifically:

- The CA process tree (§3.1) is closed under decomposition — adding parent processes (the targeting cycle, the intelligence cycle) wraps `ex:CombatAssessmentProcess` rather than restructuring it.
- The ICE hierarchy (§3.4) reserves discipline-specific subtrees as declared classes, so v2.0 sub-classing extends rather than refactors.
- The role hierarchy (§3.2) resolves anti-rigidity in v1.0 so v2.0 discipline-specific roles inherit the correct pattern.

If a v2.0 amendment requires breaking a v1.0 class commitment, that's a MAJOR SemVer bump per workflow §3 and forces a full regression re-run.

---

## 8. SME Sign-Off

This scope is authored by SME and submitted for three-signoff. **Onto and Tester:** review for whether the scope (a) admits a coherent axiomatization at this level of granularity (Onto), and (b) produces inference patterns that the gate harness can verify (Tester). If either lane sees a structural problem, push back via PR review — the scope changes before JI-005 starts, not after.
