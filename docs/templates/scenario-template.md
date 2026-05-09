# Scenario Narrative — JI-### `<short slug>`

**Owner of this template:** SME (per workflow §5)
**Filename convention:** `docs/scenarios/JI-###-<short-slug>.md`
**Companion artifacts:** `src/instances/JI-###.jsonld` (Onto-owned; mechanical IRI-fication of this narrative), `docs/scenarios/JI-###-cqs.yaml` (SME-owned; CQs in the locked template format), `tests/fixtures/adversarial/JI-###/` (Tester-owned; adversarial variants)

---

## How to use this template

This file is the **authoritative narrative** for the scenario. The Onto-produced JSON-LD A-Box ([src/instances/JI-###.jsonld](../../src/instances/)) is mechanically derived from this narrative. **If JSON-LD ever drifts from this narrative, this narrative wins** and the JSON-LD is regenerated. (Workflow §5 file ownership.)

The narrative deliberately uses **no IRIs**. Named entities are referenced by short, capitalized handles (`Bridge_42`, `Analyst_Jane`, `Imagery_001`); Onto translates handles → IRIs during JSON-LD authoring per the IRI registry ([docs/iri-registry.md](../iri-registry.md)).

Sections marked **REQUIRED** are DOCTRINE-READY entry criteria per workflow §3. Tickets cannot exit BACKLOG without all required sections populated.

Delete this "How to use" section after copying the template into a real scenario file.

---

## 1. Header

| Field | Value |
|---|---|
| Ticket | JI-### |
| Author (SME) | <name> |
| Date | YYYY-MM-DD |
| Doctrinal anchor | <e.g., JP 3-60 App C ¶3 — Phase II BDA> |
| Scope reference | [docs/scope.md §<section>](../scope.md) |
| Related ADRs | <e.g., ADR-001 if doctrinal-source annotations are involved> |

---

## 2. Operational Context **(REQUIRED)**

One paragraph. Where does this scenario sit in operational reality? What CCMD or JTF, what phase of operations, what target type, what time horizon? Do not invent classified detail; use fictionalized but plausible operational framing.

> *Example:* "USCENTCOM JTF-Alpha conducting Phase II of a deliberate strike campaign against an adversary IADS network. Target Bridge_42 is a road-rail bridge serving as a logistical chokepoint. Strike was conducted at H+0; this scenario covers the Combat Assessment cycle from H+2 (post-strike imagery) through H+24 (RAR delivered to JFC)."

---

## 3. Participants **(REQUIRED)**

List every named entity by handle. Group by ontological category. Each entity gets one row.

### Agents

| Handle | Class | Bearing role(s) | Notes |
|---|---|---|---|
| `Analyst_<name>` | `IntelligenceAnalyst` ∨ `TargetAnalyst` | <role handle> | <e.g., assigned to JIOC, sub-discipline> |

### Roles

| Handle | Class | Realized in | Borne by |
|---|---|---|---|
| `Role_<name>_<process>` | <RoleClass> | `Process_<handle>` | `Analyst_<name>` |

### Material Entities

| Handle | Class | Notes |
|---|---|---|
| `<Target_handle>` | `Target` | <description> |

### Facilities

| Handle | Class | Notes |
|---|---|---|
| `Site_<handle>` | `IntelligenceOperationsCenter` ∨ `MilitaryFacility` | <e.g., USCENTCOM JIOC> |

---

## 4. Information Content Entities **(REQUIRED)**

Inputs and outputs of every process in the scenario. No IRIs.

| Handle | Class | Origin | Consumed by |
|---|---|---|---|
| `ICE_<handle>` | <e.g., PostStrikeImagery, Phase1BDAReport> | <process that produced it, or external> | <process(es) that consume it> |

---

## 5. Processes **(REQUIRED)**

Every process instance in the scenario. The narrative below this table walks the flow in prose; the table is the structured summary.

| Handle | Class | Inputs | Outputs | Participants | Occurs at | Preceded by | Precedes |
|---|---|---|---|---|---|---|---|
| `Process_<handle>` | <e.g., Phase1BattleDamageAssessment> | <ICE handles> | <ICE handles> | <agent + target handles> | `Site_<handle>` | <process handle ∨ —> | <process handle ∨ —> |

---

## 6. Narrative Walkthrough **(REQUIRED)**

Prose telling of the scenario from start to finish. Must reference every entity by handle. Must surface every relation captured in §5 implicitly through the storytelling. Aim for ~200–400 words.

> *Example:* "At H+2, post-strike imagery (`Imagery_001`) of Bridge_42 is acquired by a UAV platform and transmitted to USCENTCOM JIOC (`Site_CENTCOM_JIOC`). Target Analyst Jane (`Analyst_Jane`), bearing the TargetAnalysisRole (`Role_Jane_Phase1BDA`) realized in this process, conducts Phase I BDA (`Process_Phase1BDA`), consuming the imagery and producing a Phase I BDA Report (`ICE_Phase1Report`)..."

---

## 7. Acceptance — Must-Infer **(REQUIRED)**

What inferences MUST hold when the reasoner processes this scenario? Bullet list, expressed in prose. These become CQs in the companion `JI-###-cqs.yaml`.

- *Example:* "Analyst_Jane must be inferable as a participant in both Process_Phase1BDA and Process_Phase2BDA."
- *Example:* "Process_Phase2BDA must be inferable as preceded by Process_Phase1BDA via the temporal relation BFO_0000062."
- *Example:* "ICE_Phase1Report must be inferable as a `has_input` of Process_Phase2BDA."

---

## 8. Acceptance — Must-NOT-Infer **(REQUIRED)**

What inferences must the reasoner refuse to draw? This is the SME's anti-brittleness contribution — what would be doctrinally absurd if it appeared in the inferred model. Bullet list.

- *Example:* "ICE_Phase1Report must NOT be inferable as a Process under any property chain."
- *Example:* "Target_Bridge_42 must NOT be inferable as an Agent or Analyst by virtue of its participation in BDA processes."
- *Example:* "Analyst_Jane must NOT be inferable as a TargetAnalyst by virtue of `participates in` alone, without bearing a `TargetAnalysisRole` (anti-rigidity check)."

---

## 9. Adversarial Variants **(REQUIRED — at least one)**

What broken or ambiguous inputs should the reasoner degrade gracefully on, rather than producing false but plausible inferences? Each variant gets a sub-section.

### 9.1 Variant — `<short name>`

**Breakage:** what's missing, malformed, or ambiguous in this variant relative to §3–§5.
**Expected behavior:** what the reasoner should NOT conclude despite the missing/broken input.
**Tester routing:** which adversarial probe under [tests/fixtures/adversarial/](../../tests/fixtures/adversarial/) this variant pairs with (e.g., `temporal_consistency_test`, `role_stress_test`).

> *Example:* Variant — "Phase 2 without Phase 1." Breakage: `Process_Phase2BDA` exists with no preceding `Process_Phase1BDA` instance (simulating an incomplete reporting chain). Expected: the reasoner should NOT infer that Phase 2 is the first or only BDA conducted; should not satisfy the existential restriction on `BFO_0000062 some Phase1BattleDamageAssessment`. Tester routing: `temporal_consistency_test`.

---

## 10. Out-of-Scope for this Scenario

Bullets for things this scenario deliberately does NOT exercise, with a one-line "why." Helps reviewers understand what's not being claimed.

- *Example:* "Multi-target campaign behavior (this scenario is single-target by design; multi-target stress lives in JI-###)."
- *Example:* "Discipline-specific sensor products beyond GEOINT (per scope §3.4 — declared but not axiomatized in v1.0)."

---

## 11. Open Questions

Things the SME wants Onto or Tester to flag during review. Optional.

- *Example for Onto:* "Should Phase 3 BDA's input include both Phase 2 BDA Report AND broader theater context, or is the theater context an out-of-scope detail for v1.0?"
- *Example for Tester:* "The 'partial sensor data' adversarial variant — does this fit `underconstraint_test` or warrant a new probe?"

---

## Notes for SME authoring discipline

- **No IRIs.** This file is doctrinal narrative. Onto IRI-fies under their own ticket.
- **Every named entity in §3–§5 must appear in §6.** If a handle is in the structured tables but not in the prose walkthrough, delete it from the tables. The narrative is the truth condition.
- **Must-infer (§7) and must-not-infer (§8) are both required.** Negative expectations are how brittleness is detected (workflow §3 DoR).
- **At least one adversarial variant (§9).** The SME persona explicitly values "ensuring the reasoner degrades gracefully rather than drawing false, brittle conclusions" — this section is where that mandate lives.
- **Doctrinal anchor must be paragraph-level.** "JP 3-60" alone is too coarse; "JP 3-60 App C ¶3" is correct. If you can't find a paragraph-level anchor, the scenario may be reaching beyond the doctrinal record — escalate to PM.
