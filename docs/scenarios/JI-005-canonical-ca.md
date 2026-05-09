# Scenario Narrative — JI-005 `canonical-ca` (Canonical Combat Assessment Cycle)

| Field | Value |
|---|---|
| Ticket | JI-005a (SME-side scenario narrative; companion to JI-005 axiomatization) |
| Author (SME) | SME persona |
| Date | 2026-05-09 |
| Doctrinal anchor | JP 3-60 App C (Combat Assessment); JP 2-0 ch.III (analyst roles) |
| Scope reference | [docs/scope.md §3 (in scope)](../scope.md), [§5 (acceptance)](../scope.md) |
| Related ADRs | [ADR-001](../decisions/ADR-001-iao-119-semantics.md) (jio:derivedFrom annotation pattern) |

**Companion artifacts (Onto-produced, IRI-fied from this narrative):**
- `src/instances/JI-005-canonical-ca.jsonld` — A-Box scenario instance
- Referenced by [docs/scenarios/JI-002-cqs.yaml](JI-002-cqs.yaml) for v1.0 acceptance CQ evaluation

---

## 1. Purpose of This Scenario

Provides the **canonical end-to-end Combat Assessment cycle** against which v1.0 acceptance is verified. Exercises the full §3.1 process tree (BDA Phases I/II/III + MEA + RAR), §3.6 temporal orderings (including the conjunctive RAR predecessors), and §3.7 information flow at one consistent target.

This is the *first* of the ≥3 SME-authored CA scenarios required by scope §5 #6. Two additional scenarios (degraded variants and multi-target stress) are reserved for later tickets.

---

## 2. Operational Context

USCENTCOM JTF-Alpha conducting deliberate strike operations against an adversary's lines of communication (LOC) network. **Target Bridge_42** is a road-rail bridge serving as a logistical chokepoint — its destruction or degradation forces adversary resupply convoys onto routes vulnerable to interdiction. Strike was conducted at H+0 by a fixed-wing platform employing a single PGM. This scenario covers the Combat Assessment cycle from H+2 (post-strike imagery acquired) through H+24 (RAR delivered to JFC).

The scenario is fictionalized; details are operationally plausible but do not reference any real engagement.

---

## 3. Participants

### 3.1 Agents

| Handle | Class | Bearing role(s) | Notes |
|---|---|---|---|
| `Analyst_Jane_001` | `TargetAnalyst` | `Role_TargetAnalysis_Jane_001` | Assigned to USCENTCOM JIOC; primary analyst for the Bridge_42 BDA chain |

### 3.2 Roles

| Handle | Class | Realized in | Borne by |
|---|---|---|---|
| `Role_TargetAnalysis_Jane_001` | `TargetAnalysisRole` | `Process_Phase1BDA_001`, `Process_Phase2BDA_001`, `Process_Phase3BDA_001`, `Process_RAR_001` | `Analyst_Jane_001` |

**Single-role design choice:** Jane bears one `TargetAnalysisRole` realized across all four processes she participates in. This matches the doctrinal reality (a target analyst owns the BDA chain through phases) and the SME persona's note (config/SME.yaml lines 28-30) that an analyst's role is realized in different processes — not that they bear multiple parallel roles. Jane does NOT participate in MEA; weapons effects analysis is a separate analyst function.

### 3.3 Material Entities

| Handle | Class | Notes |
|---|---|---|
| `Target_Bridge_42` | `Target` | Road-rail bridge, fixed structure, logistical chokepoint |

### 3.4 Facilities

| Handle | Class | Notes |
|---|---|---|
| `Site_CENTCOM_JIOC` | `IntelligenceOperationsCenter` | USCENTCOM Joint Intelligence Operations Center |

---

## 4. Information Content Entities

| Handle | Class | Origin | Consumed by |
|---|---|---|---|
| `ICE_UAV_Imagery_001` | `PostStrikeImagery` | External (UAV platform, H+2) | `Process_Phase1BDA_001`, `Process_MEA_001` |
| `ICE_Phase1_Report_001` | `Phase1BDAReport` | `Process_Phase1BDA_001` | `Process_Phase2BDA_001` |
| `ICE_Phase2_Report_001` | `Phase2BDAReport` | `Process_Phase2BDA_001` | `Process_Phase3BDA_001` |
| `ICE_Phase3_Report_001` | `Phase3BDAReport` | `Process_Phase3BDA_001` | `Process_RAR_001` |
| `ICE_MEA_Report_001` | `MEAReport` | `Process_MEA_001` | `Process_RAR_001` |
| `ICE_RAR_Report_001` | `RARReport` | `Process_RAR_001` | (delivered to JFC; not modeled as an in-scenario consumer) |

---

## 5. Processes

| Handle | Class | Inputs | Outputs | Participants | Occurs at | Preceded by | Precedes |
|---|---|---|---|---|---|---|---|
| `Process_CombatAssessment_OpAlpha` | `CombatAssessmentProcess` | — | — | — | `Site_CENTCOM_JIOC` | — | — |
| `Process_Phase1BDA_001` | `Phase1BattleDamageAssessment` | `ICE_UAV_Imagery_001` | `ICE_Phase1_Report_001` | `Analyst_Jane_001`, `Target_Bridge_42` | `Site_CENTCOM_JIOC` | — | `Process_Phase2BDA_001`, `Process_MEA_001` |
| `Process_Phase2BDA_001` | `Phase2BattleDamageAssessment` | `ICE_Phase1_Report_001` | `ICE_Phase2_Report_001` | `Analyst_Jane_001`, `Target_Bridge_42` | `Site_CENTCOM_JIOC` | `Process_Phase1BDA_001` | `Process_Phase3BDA_001` |
| `Process_Phase3BDA_001` | `Phase3BattleDamageAssessment` | `ICE_Phase2_Report_001` | `ICE_Phase3_Report_001` | `Analyst_Jane_001`, `Target_Bridge_42` | `Site_CENTCOM_JIOC` | `Process_Phase2BDA_001` | `Process_RAR_001` |
| `Process_MEA_001` | `MunitionsEffectivenessAssessment` | `ICE_UAV_Imagery_001` | `ICE_MEA_Report_001` | (weapons-effects analyst — not modeled by handle in v1.0) | `Site_CENTCOM_JIOC` | `Process_Phase1BDA_001` | `Process_RAR_001` |
| `Process_RAR_001` | `ReAttackRecommendation` | `ICE_Phase3_Report_001`, `ICE_MEA_Report_001` | `ICE_RAR_Report_001` | `Analyst_Jane_001` | `Site_CENTCOM_JIOC` | `Process_Phase3BDA_001`, `Process_MEA_001` | — |

**`is_part_of_process` relationships:** `Process_Phase1BDA_001`, `Process_Phase2BDA_001`, `Process_Phase3BDA_001`, `Process_MEA_001`, and `Process_RAR_001` are all `cco:ont00001857 (is part of process)` of `Process_CombatAssessment_OpAlpha`. This satisfies CQ-014 (count of 5).

**RAR conjunctive predecessors:** `Process_RAR_001` is `obo:BFO_0000062 (preceded by)` BOTH `Process_Phase3BDA_001` AND `Process_MEA_001` — two separate axioms on the RAR instance. Per the JI-001 doctrinal call, this is conjunctive, not disjunctive.

---

## 6. Narrative Walkthrough

At **H+0**, JTF-Alpha executes a deliberate strike against `Target_Bridge_42` using a single precision-guided munition delivered by a fixed-wing platform. The strike is part of operational campaign Operation Alpha; the umbrella Combat Assessment process for Operation Alpha is `Process_CombatAssessment_OpAlpha`, occurring at `Site_CENTCOM_JIOC`.

At **H+2**, a UAV platform overflies the target area and acquires `ICE_UAV_Imagery_001` — post-strike imagery showing the bridge with visible structural damage to the central span. The imagery is transmitted to `Site_CENTCOM_JIOC` for analysis.

`Analyst_Jane_001`, a target analyst at the JIOC bearing `Role_TargetAnalysis_Jane_001`, initiates `Process_Phase1BDA_001` (Phase I Battle Damage Assessment / Physical Damage Assessment). Consuming `ICE_UAV_Imagery_001` and considering the structural damage observable in the imagery, she produces `ICE_Phase1_Report_001` — a Phase I BDA Report estimating the quantitative extent of physical damage. `Target_Bridge_42` participates in this process as the entity being assessed; Jane's role is realized in this process via `obo:BFO_0000054 (realized in)`.

At **H+8**, with Phase I results in hand, Jane initiates `Process_Phase2BDA_001` (Phase II BDA / Functional Damage Assessment). She consumes `ICE_Phase1_Report_001` and assesses the bridge's remaining functional capability — given the central-span damage, can the bridge still bear vehicle traffic above some threshold weight? The output is `ICE_Phase2_Report_001`. This process is `obo:BFO_0000062 (preceded by) Process_Phase1BDA_001` — Phase II depends on Phase I's prior assessment of physical damage.

In parallel with Jane's analytical chain, a **weapons-effects analyst** (not modeled by handle in v1.0; participation could be added in v2.0 with a dedicated MEA-analyst role) initiates `Process_MEA_001` (Munitions Effectiveness Assessment). MEA also consumes `ICE_UAV_Imagery_001` to assess whether the PGM was delivered as planned — did it impact the intended aimpoint, did the fuze function, did the warhead achieve its expected effect on a structure of this type. The output is `ICE_MEA_Report_001`. MEA is `preceded by Process_Phase1BDA_001` (it depends on the same physical-damage observations) but otherwise runs independently of the Phase II / III chain.

At **H+12**, Jane initiates `Process_Phase3BDA_001` (Phase III BDA / Target System Assessment). She consumes `ICE_Phase2_Report_001` and assesses the broader operational impact — what does the bridge's degraded functional capacity mean for the adversary's logistical network? Are convoys forced onto alternative routes that expose them to interdiction? The output is `ICE_Phase3_Report_001`. This process is `preceded by Process_Phase2BDA_001`, and via BFO_0000063 transitivity, also preceded by `Process_Phase1BDA_001`.

At **H+24**, Jane initiates `Process_RAR_001` (Re-Attack Recommendation). She consumes `ICE_Phase3_Report_001` (target-system effect achieved or not?) AND `ICE_MEA_Report_001` (did the weapon perform as designed?). Both inputs are required — a recommendation that hadn't considered both would be doctrinally unsound. The output is `ICE_RAR_Report_001`, delivered to the JFC. `Process_RAR_001` is `preceded by Process_Phase3BDA_001` AND `preceded by Process_MEA_001` — two separate axioms expressing the conjunctive doctrinal requirement.

All five processes (`Process_Phase1BDA_001`, `Process_Phase2BDA_001`, `Process_Phase3BDA_001`, `Process_MEA_001`, `Process_RAR_001`) are `is_part_of_process Process_CombatAssessment_OpAlpha`. Operational tempo across the cycle is illustrative — actual timelines vary widely based on target type, operational urgency, and analyst availability.

---

## 7. Acceptance — Must-Infer

When the reasoner processes this scenario merged with the JI-005 T-Box, the following inferences MUST hold:

- **`Analyst_Jane_001` participates in** `Process_Phase1BDA_001`, `Process_Phase2BDA_001`, `Process_Phase3BDA_001`, and `Process_RAR_001` via `obo:BFO_0000056` (and inversely, those processes have her as `BFO_0000057 (has participant)`).
- **`Target_Bridge_42` participates in** `Process_Phase1BDA_001`, `Process_Phase2BDA_001`, and `Process_Phase3BDA_001` (BDA processes assess the target as a participant — but Bridge_42 does NOT participate in MEA, which assesses weapon performance, or RAR, which is purely an analytical recommendation).
- **`Role_TargetAnalysis_Jane_001` is realized in** `Process_Phase1BDA_001`, `Process_Phase2BDA_001`, `Process_Phase3BDA_001`, and `Process_RAR_001` via `obo:BFO_0000054`.
- **Temporal ordering:** `Process_Phase1BDA_001` precedes `Process_Phase2BDA_001` precedes `Process_Phase3BDA_001` precedes `Process_RAR_001` (via direct axioms and BFO_0000063 transitivity).
- **MEA branch ordering:** `Process_Phase1BDA_001` precedes `Process_MEA_001` precedes `Process_RAR_001`.
- **RAR conjunctive predecessors:** `Process_RAR_001 preceded_by Process_Phase3BDA_001` AND `Process_RAR_001 preceded_by Process_MEA_001` — both inferable.
- **Information flow:** `ICE_UAV_Imagery_001` is `has_input` of both `Process_Phase1BDA_001` and `Process_MEA_001`. `ICE_Phase1_Report_001` is `has_output` of `Process_Phase1BDA_001` AND `has_input` of `Process_Phase2BDA_001`. Same chaining for Phase 2/3 reports.
- **CA completeness:** `Process_CombatAssessment_OpAlpha` has exactly 5 sub-processes via `cco:ont00001857 (is part of process)` — satisfies CQ-014.
- **Facility:** all five sub-processes `cco:ont00001918 (occurs at) Site_CENTCOM_JIOC`.
- **Type promotion:** `Analyst_Jane_001` is classified as `TargetAnalyst` (and transitively `IntelligenceAnalyst`) by virtue of bearing `Role_TargetAnalysis_Jane_001` — NOT by virtue of participating in BDA processes.
- **Doctrinal traceability:** every class instantiated above carries a `jio:derivedFrom` annotation citing JP 3-60 or JP 2-0 (T-Box property; verified by CQ-003 against the T-Box, not this A-Box).

---

## 8. Acceptance — Must-NOT-Infer

The reasoner must refuse these inferences (they are doctrinal absurdities):

- **`ICE_UAV_Imagery_001` must NOT be inferable as a Process** (`obo:BFO_0000015`) under any property chain. ICE/Process disjointness must hold via BFO continuant/occurrent partition. Same for all five report ICEs.
- **`Target_Bridge_42` must NOT be inferable as `IntelligenceAnalyst`, `TargetAnalyst`, or `cco:ont00001262 (Person)`** by virtue of its participation in BDA processes. A target is materially distinct from an agent.
- **`Site_CENTCOM_JIOC` must NOT be inferable as a `has_participant` of any process.** A facility is `occurs_at` (where the process happens), not a participant in it. Catches a common modeling error.
- **`ICE_*` instances must NOT be inferable as `has_participant` of the processes they're inputs/outputs of.** has_input and has_output are distinct from has_participant — collapsing them defeats the I/O modeling.
- **`Analyst_Jane_001` must NOT be inferable as `TargetAnalyst` purely from her participation in `Process_Phase1BDA_001`** if she did not also bear `Role_TargetAnalysis_Jane_001`. (See §9.2 adversarial variant for the test of this.)
- **No phase ordering reversals.** `Process_Phase2BDA_001 precedes Process_Phase1BDA_001` must NOT be inferable. (BFO_0000063 is transitive but not asymmetric — the adversarial probe in §9.1 verifies this doesn't accidentally close into a cycle.)
- **`Process_Phase1BDA_001 precedes Process_Phase2BDA_001`** must NOT be inferable as a T-Box-level requirement that every Phase 1 instance must have a successor. Phase 1 may exist without Phase 2 (analyst stops at Phase 1 if physical damage assessment is operationally sufficient). The asymmetry is intentional per JI-001 review.

---

## 9. Adversarial Variants

### 9.1 Variant — "Phase 2 without Phase 1"

**Breakage:** A degraded scenario where `Process_Phase2BDA_001` is instantiated without any preceding `Process_Phase1BDA_001` instance — simulating an incomplete reporting chain (e.g., Phase 1 report was lost in transit, or analyst skipped Phase 1 inappropriately).

**Expected behavior — DL/OWA-correct framing per Tester PR #10 review:** Under standard OWL DL with the open-world assumption, an orphan Phase 2 individual axiomatized as `subClassOf preceded_by some Phase1BattleDamageAssessment` does NOT fail at the reasoner — the reasoner satisfies the existential by inferring an anonymous predecessor exists somewhere. So this variant is **not** a DL-inference test.

It IS a **data-quality / reporting-chain integrity** check expressed in the query layer. A SPARQL closed-world query finding "Phase 2 BDA instances NOT `preceded_by` any asserted Phase 1 BDA in the A-Box" must return the orphan `Process_Phase2BDA_001` individual. The doctrinal concern (analyst left a gap in reporting) is detected via SPARQL closed-world enumeration outside DL semantics — this is the layer where reporting-chain integrity actually lives.

**Tester routing:** [tests/fixtures/adversarial/temporal_consistency_test/](../../tests/fixtures/adversarial/temporal_consistency_test/) with `expected.json` carrying a `sparql_violation` entry per Tester's PR #10 review proposal. Tester also expands the probe's stated scope from "cycles" to "temporal ordering integrity (cycles + incomplete chains)" via a separate `-trivial` JI-006 description tweak.

### 9.2 Variant — "Analyst without Role"

**Breakage:** A degraded scenario where `Analyst_Jane_001` participates in `Process_Phase1BDA_001` but `Role_TargetAnalysis_Jane_001` is omitted — simulating a missing role assertion (e.g., the role individual was never instantiated, or its `bearer_of` triple was never recorded).

**Expected behavior:** The reasoner must NOT classify `Analyst_Jane_001` as `TargetAnalyst` purely on the basis of `participates_in Process_Phase1BDA_001`. Class membership in `TargetAnalyst` requires bearing a `TargetAnalysisRole` — anti-rigidity. Without the role, Jane is at most an `IntelligenceAnalyst` (or even just a `Person`, depending on what other axioms hold).

**Tester routing:** [tests/fixtures/adversarial/role_stress_test/](../../tests/fixtures/adversarial/role_stress_test/). Tester translates this variant into a fixture file under that probe.

---

## 10. Out-of-Scope for This Scenario

- **Multi-target campaign behavior.** This scenario is single-target by design; multi-target stress lives in a future scenario ticket.
- **Discipline-specific sensor products beyond GEOINT.** Per scope §3.4, SIGINT/HUMINT/MASINT subtrees are declared but not axiomatized in v1.0; the imagery-only sensor input here matches that boundary.
- **Weapon employment data as a separately modeled ICE.** Doctrinally, MEA consumes both post-strike imagery AND weapon employment data (delivery accuracy, fuze function, etc.). v1.0 only models the imagery input; weapon employment data is operationally relevant but not enumerated as a class in scope §3.4. Reserved for v2.0.
- **Theater intelligence context as a Phase 3 input.** Per Onto C-5 and JI-001 review, Phase 3 BDA consumes broader theater context (logistics overlays, adversary order of battle, etc.) but v1.0 only models the Phase 2 Report input. The full theater-context input set is reserved for v2.0; an `iao:editor_note` records this on `ex:Phase3BattleDamageAssessment` per JI-005 implementation.
- **Re-attack execution.** The RAR is the analytical recommendation; whether the JFC orders a re-strike, and the subsequent re-engagement cycle, is a targeting-cycle concern (JP 3-60 chs. II–III) deferred to v2.0+.
- **Specific adversary or geographic detail.** Fictionalized framing.

---

## 11. Open Questions

For Onto:
- **Q-O-1:** ~~During IRI-fication, do you want me (SME) to author 2 additional CA scenarios (variant strike outcomes, multi-target) before JI-005 enters AXIOMATIZED, or is one canonical scenario sufficient for the first axiomatization pass and additional scenarios land post-JI-005?~~ **ANSWERED in PR #10 review:** one canonical scenario is sufficient for first axiomatization pass; additional scenarios land post-JI-005.
- **Q-O-2:** ~~The single-role-realized-in-multiple-processes design choice (§3.2) — confirm this is your preferred encoding under the anti-rigidity refactor, vs. minting a separate role individual per process. I lean toward single-role; this matches the doctrinal reality of an analyst owning the BDA chain.~~ **ANSWERED in PR #10 review:** single-role confirmed. Role is a continuant; exists across the time of all its realizations. Doctrine matches.
- **Q-O-3 (new — surfaced by Tester PR #10 review follow-on item #1):** During JI-005 IRI-fication of this narrative, please include **at least one untyped process individual** (typed only as `obo:BFO_0000015 Process` with all required Phase1BDA inputs/outputs) so CQ-009's positive classification has actual teeth. If the JI-005 A-Box only includes individuals explicitly typed as Phase1BDA etc., CQ-009 reduces to a tautology (testing whether an asserted type is asserted). Either inline this test individual in `src/instances/JI-005-canonical-ca.jsonld`, or author a sibling test-individuals file at your discretion. Recommend at least one untyped individual per CA leaf class (Phase1BDA, Phase2BDA, Phase3BDA, MEA, RAR) to give CQ-009-style positive classification full coverage.

For Tester:
- **Q-T-1:** ~~§9.1 and §9.2 adversarial variants are described narratively. Do you want SME to also draft minimal A-Box snippets for them, or do you prefer to author the fixtures from scratch given the narrative? Per scenario template, the fixture is your lane regardless — just asking about the input format that's most useful for your translation.~~ **ANSWERED in PR #10 review:** narrative is sufficient; A-Box snippet authoring is Tester's lane. Structured §3–§5 tables are the input format Tester needs. SME does not author JSON-LD for adversarial fixtures.
