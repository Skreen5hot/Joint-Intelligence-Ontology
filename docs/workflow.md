# JI-Onto Project Workflow (v1.0)

**Status:** Ratified
**Owner:** PM (Aaron Damiano)
**Amendment:** Three-signoff (SME + Ontologist + Logic Tester) + ADR
**Last revised:** 2026-05-09

---

## 1. Purpose & Scope

This document governs how the SME, Ontologist, and Logic Tester route work, hand off artifacts, and ship validated ontology modules for the JP 2-0 / JP 3-60 Joint Intelligence Ontology.

**In scope:** lane discipline, ticket lifecycle, handoff contracts, file ownership, conflict resolution, cadence, CI gates, amendment process.

**Out of scope:** doctrinal content (lives in [scope](scope.md) and [doctrine-index](doctrine-index.md)), modeling patterns ([patterns.md](patterns.md)), test specifics ([../tests/](../tests/)).

This doc is the source-of-truth for *process*. When any other artifact contradicts it, this doc wins until amended.

---

## 2. Roles & RACI

R = Responsible, A = Accountable, C = Consulted, I = Informed.

| Concern | SME | Onto | Tester |
|---|:-:|:-:|:-:|
| Doctrinal scope & citations (JP 2-0/3-60) | R/A | C | I |
| Competency Questions (text form, structured) | R/A | C | C |
| CQ → SPARQL translation pattern | C | R/A | C |
| CQ execution, scoring, negative tests, CI | I | C | R/A |
| Doctrinal A-Box scenarios (narrative) | R/A | C | I |
| Doctrinal A-Box IRI-fication ([src/instances/](../src/instances/)) | C | R/A | I |
| Adversarial test fixtures ([tests/fixtures/adversarial/](../tests/fixtures/adversarial/)) | I | I | R/A |
| Probe T-Box deltas ([tests/fixtures/probes/](../tests/fixtures/probes/)) | I | C | R/A |
| T-Box class hierarchy & axioms | C | R/A | C |
| OWL profile choice (DL/EL/RL) | C | R/A | C |
| `owl:imports` + `catalog-v001.xml` | I | R/A | C |
| Build pipeline (Makefile, `robot.sh`, GH Actions) | I | C | R/A |
| Patterns doc ([patterns.md](patterns.md)) | C | R/A | C (veto, ADR-overridable) |
| IRI registry ([iri-registry.md](iri-registry.md)) | I | R/A | C |
| Relation mapping ([relation-mapping.md](relation-mapping.md)) | C | R/A | C |
| Inferred-hierarchy baseline | I | C | R/A |
| Doctrinal sign-off on shipped module | R/A | C | C |
| Logical sign-off on shipped module | I | R/A | C |
| Reasoning sign-off on shipped module | I | C | R/A |

**Three signoffs required to ship a doctrinal module.** No one ships alone.

**Tester veto on patterns** is overridable by ADR — it forces a conversation, not a unilateral block.

---

## 3. Ticket Lifecycle

```
[BACKLOG] ──SME──> [DOCTRINE-READY] ──Onto──> [AXIOMATIZED] ──auto──> [SMOKE-CLEAN]
                          ▲                          ▲                      │
                          │                          │                      │
                          │                          └──── reject ──────────┤
                          │                                                 │
                          │                                              ──Tester──> [REASONED] ──SME──> [ACCEPTED] ──merge──> [FROZEN]
                          │                                                              │                    │
                          └─────── Onto triage (CQ bug) ──────────────────────────────────┤                    │
                                                                                          │                    │
                                                                                          └── (model bug) ──> back to AXIOMATIZED
                          ◄────────────── post-ACCEPTED CQ-wrong kickback ────────────────────────────────────┘
```

### State Definitions & DoR

| State | Definition of Ready (entry criteria) | Exit Artifact |
|---|---|---|
| **BACKLOG** | Ticket exists with title + 1-line goal | — |
| **DOCTRINE-READY** | Doctrinal anchor (JP + paragraph), in/out scope, ≥3 CQs in [cq-template.yaml](templates/cq-template.yaml) format with `must_infer` AND `must_not_infer`, scenario sketch (no IRIs), ≥1 broken/ambiguous A-Box variant | `docs/tickets/JI-###.md` |
| **AXIOMATIZED** | Turtle module, `iao:IAO_0000115` definitions, all cited IRIs verified against [relation-mapping.md](relation-mapping.md), class/property delta table | PR with `.ttl` + import update |
| **SMOKE-CLEAN** | (Auto-gate, CI step, ~1 min) `owl:imports` resolve via catalog, HermiT loads merged ontology without error, no unsatisfiable named classes | Green CI badge |
| **REASONED** | Reasoner clean, all CQ SPARQL queries pass, regression suite green, counterexample trace authored if any probe fired | [`tests/competency/JI-###/`](../tests/competency/) + CI log |
| **ACCEPTED** | SME confirms inferences match doctrinal expectation; doctrinal sign-off recorded | Merge to `main` |
| **FROZEN** | Post-merge state. SemVer applied. Module is immutable except via new ticket. | Tagged commit |

### Reject Paths

- **AXIOMATIZED → SMOKE-CLEAN fails:** Onto fixes; auto-gate re-runs. No human routing.
- **REASONED fails:** Tester writes **neutral failure report** + counterexample trace. Onto triages and routes:
  - Model bug → back to **AXIOMATIZED**
  - CQ bug → back to **DOCTRINE-READY** (SME owns)
  - Tester does not edit T-Box. Tester does not edit CQs.
- **ACCEPTED kickback:** If SME at acceptance review identifies the CQ itself was wrong, kicks back to **DOCTRINE-READY**. The PR does not get re-edited in place — a new ticket is opened referencing the original.

### Module SemVer (FROZEN state policy)

| Bump | Trigger | Required regression scope |
|---|---|---|
| PATCH | Annotation-only, no axiom change | None |
| MINOR | Additive axioms, no breaking changes | Module's own CQs |
| MAJOR | Breaking change (rename, removed axiom, narrowed restriction) | Full suite + dependents |

**Decider:** Onto proposes bump level in PR. Tester validates by running the corresponding regression scope. Disagreement escalates to PM. **Default to MAJOR if uncertain** — under-bumping is the dangerous failure mode.

### UPSTREAM-BUMP Ticket Type

Separate lifecycle. Triggered by CCO / BFO / IAO / RO release.

1. Tester opens UPSTREAM-BUMP ticket.
2. Onto bumps imports, regenerates relation-mapping and IRI registry.
3. Tester runs full regression + baseline diff + IRI-drift audit.
4. Any drift triggers child tickets in normal lifecycle.
5. Three-signoff to merge the bump itself.

---

## 4. Handoff Contracts

Each role hands the next a file in a known shape. **This is the anti-collision mechanism. No bypassing.**

### SME → Ontologist

File: `docs/tickets/JI-###.md`. Required sections:

- **Doctrinal anchor** (e.g., `JP 3-60 App C, ¶3`)
- **In-scope / out-of-scope**
- **Competency Questions** in [cq-template.yaml](templates/cq-template.yaml) format, ≥3, each with `must_infer` and `must_not_infer`
- **Scenario sketch** (narrative A-Box, no IRIs)
- **≥1 broken/ambiguous A-Box variant** (the "what should the reasoner refuse to infer" case)
- **Acceptance: what inferences must hold**

### Ontologist → Tester

PR contents:

- Turtle module under [src/ontology/](../src/ontology/)
- Updated [src/instances/JI-###.jsonld](../src/instances/) (mechanical IRI-fication of SME narrative)
- Updated `docs/tickets/JI-###.md` with **class/property delta table** (added / changed / deprecated; renames especially)
- Updated [relation-mapping.md](relation-mapping.md) and [iri-registry.md](iri-registry.md) entries
- **Green CI** on `tbox-consistency` and `imports-resolve` (replaces self-attestation; CI is the gate)

### Tester → SME

Deliverables:

- [`tests/competency/JI-###/*.sparql`](../tests/competency/) — one query per CQ
- [`tests/regression/JI-###/`](../tests/regression/) — backward-compat tests
- CI run log (pass/fail per CQ, runtime metrics)
- **Counterexample A-Box trace** when any CQ fails or any probe fires (minimal A-Box demonstrating the failure)

---

## 5. File Ownership Map

**Hard rule: single-owner files. No co-authoring on the same PR.**

| Path | Owner | Edit Rule |
|---|---|---|
| [docs/](.) (general) | SME | PR + SME approval |
| [docs/scenarios/JI-###.md](scenarios/) | SME | SME-only |
| [config/SME.yaml](../config/SME.yaml) | SME | Self-owned |
| [src/ontology/](../src/ontology/) | Onto | PR + Onto approval |
| [src/imports/](../src/imports/) | Onto | PR + Onto approval |
| [src/instances/JI-###.jsonld](../src/instances/) | Onto | Mechanical IRI-fication of SME narrative |
| [docs/relation-mapping.md](relation-mapping.md) | Onto | PR + Onto approval |
| [docs/iri-registry.md](iri-registry.md) | Onto | Updated each AXIOMATIZED→REASONED transition |
| [docs/patterns.md](patterns.md) | Onto | SME C, Tester C-with-veto |
| [config/ontologist.yaml](../config/ontologist.yaml) | Onto | Self-owned |
| [tests/](../tests/) | Tester | PR + Tester approval |
| [tests/fixtures/adversarial/](../tests/fixtures/adversarial/) | Tester | Tester-only |
| [tests/fixtures/probes/](../tests/fixtures/probes/) | Tester | Harness-only, never imported into [src/ontology/](../src/ontology/) |
| [tests/baselines/inferred-hierarchy.txt](../tests/baselines/) | Tester | Regenerated each merge |
| `.github/workflows/`, `Makefile`, `robot.sh` | Tester | PR + Tester approval |
| [config/logic_ontologist_tester.yaml](../config/logic_ontologist_tester.yaml) | Tester | Self-owned |
| [docs/workflow.md](workflow.md) (this doc) | PM | Three-signoff + ADR |
| [docs/decisions/ADR-###.md](decisions/) | Author of decision | Three-signoff to ratify |

### Branch Naming

`ji-###-<slug>-<role>` — e.g., `ji-007-workflow-pm`, `ji-005-anti-rigidity-onto`.

The role suffix tells everyone whose lane the branch lives in and who can review-block.

### Signoff Paths

| Path | Required signoffs | Trigger |
|---|---|---|
| **Three-signoff (default)** | SME + Onto + Tester | Any ticket naming a doctrinal class, relation, or paragraph in its diff |
| **Two-signoff (infra)** | Onto + Tester | Ticket diff names no doctrinal classes/relations/paragraphs (catalog, imports, CI, build, IRI policy) |
| **Single-signoff (`-trivial`)** | Author only | Branch suffix `-trivial-<role>`. Restricted to: docs typos, comment-only edits, dependency bumps with green CI, content-preserving file moves. **Anything touching `src/` or `tests/` semantics is three-signoff regardless of perceived size.** |

---

## 6. Conflict Resolution

### Rule 1 — Doctrinally right but logically problematic

When doctrine and OWL DL semantics conflict:

1. Ontologist proposes **≥2 logically valid modeling patterns** that preserve the doctrinal claim, with annotated trade-offs. Time bound: **5 working days** from triage.
2. SME selects.
3. **If no logically-valid representation of the doctrine exists, that is an ADR-worthy escalation** — not a default Onto win. The ADR records the divergence; the doctrinal claim is annotated `iao:editor_note` on the relevant class.

Under BFO realism, the world is the truth condition. The ontologist's job is to find a logically valid representation *of* the doctrine — not a representation that overrides it.

### Rule 2 — Model bug or CQ bug

Tester writes a **neutral failure report** with counterexample trace. Onto triages and routes (per §3 reject paths). If Onto and SME disagree on which side is wrong, PM tiebreaks.

**The PM tiebreak basis is doctrinal traceability — i.e., SME judgment.** Stating this explicitly so it is not perceived as PM-flavor decision-making.

### Rule 3 — New term proposal

1. SME proposes candidate domain term with doctrinal anchor.
2. Onto evaluates against reuse-first principle: BFO → RO → IAO → CCO → existing domain ontologies.
3. Decision recorded in ADR **either way** (term created or reuse adopted).
4. SMEs propose; only the Ontologist mints IRIs.

### Rule 4 — Pattern testability veto

Tester may veto a pattern in [patterns.md](patterns.md) on testability grounds (property chains vs materialized triples, role-as-individual vs role-as-class, OWA/CWA assumptions, profile-impacting choices). Veto forces an ADR; the ADR can override the veto with documented rationale.

---

## 7. Cadence

| Meeting | Frequency | Owner | Duration |
|---|---|---|---|
| Async standup (rolling thread) | Daily | All | 1 line each: yesterday / today / blocked |
| Ticket triage | Weekly | PM | 30 min |
| **SME ↔ Onto pairing** | Weekly | SME + Onto | 30 min |
| Module kickoff | Per-module | SME | 15 min — walk the doctrine |
| Module shipping review | Per-module | Tester | 15 min — walk the CQ results |

**No other meetings.** Technical disagreement on PRs.

### The SME ↔ Onto Pairing Principle

> The weekly SME↔Ontologist pairing is the cheapest bug-finder this project has. It is not optional and is not droppable for time pressure. If it is, the doctrinal mapping degrades silently and we don't catch it until reasoner output looks wrong months later.

This principle is not a calendar entry. It is a commitment. Removing or rescheduling the pairing requires three-signoff and an ADR.

---

## 8. CI Gates

CI runs on every PR. Two severity tiers:

### Blocking (PR cannot merge)

- T-Box satisfiability (no unsatisfiable named classes)
- A-Box consistency (HermiT loads merged ontology without error)
- `owl:imports` resolve via catalog
- CQ pass rate ≥ acceptance set defined in ticket
- No new unsatisfiable named classes vs prior baseline

### Warning (PR comment, non-blocking)

- Inferred-hierarchy diff over threshold (vs [tests/baselines/inferred-hierarchy.txt](../tests/baselines/))
- Reasoner runtime regression > 2× prior baseline

### Test Categories (Tester-owned, separate directories)

| Directory | Purpose | Direction |
|---|---|---|
| [tests/competency/](../tests/competency/) | "Module must answer X" | Forward-looking |
| [tests/regression/](../tests/regression/) | "Prior behavior must not change silently" | Backward-looking |
| [tests/fixtures/adversarial/](../tests/fixtures/adversarial/) | Degenerate A-Boxes that must fail | Negative |
| [tests/fixtures/probes/](../tests/fixtures/probes/) | Probe T-Box deltas, harness-only | Negative |
| [tests/baselines/](../tests/baselines/) | Regenerated each merge | Snapshot |

---

## 9. Templates Index

Forward references — templates fill in as tickets close.

| Template | Path | Owner | Source ticket |
|---|---|---|---|
| Competency Question | [templates/cq-template.yaml](templates/cq-template.yaml) | Tester | JI-002a |
| Scenario narrative | [templates/scenario-template.md](templates/scenario-template.md) | SME | JI-001 |
| Ticket | [templates/ticket-template.md](templates/ticket-template.md) | PM | This doc closes JI-007 |
| ADR | [templates/adr-template.md](templates/adr-template.md) | PM | This doc closes JI-007 |
| PR description | `.github/pull_request_template.md` | PM | This doc closes JI-007 |

ADR template must include a **"Tester impact"** section: does this change the test surface? Require a CQ rewrite? Force a baseline reset?

---

## 10. Amendment Process

This doc is amended only via:

1. A retro identifies a workflow defect (post-JI-007 ratification, retros run after Phase 0 and at the close of each subsequent phase).
2. PM drafts the amendment as a PR.
3. Three-signoff (SME + Onto + Tester) required to merge.
4. An ADR records the rationale at [docs/decisions/](decisions/).

**Workflow refinements do not land via PR comments on Phase 0 tickets, ad-hoc Slack threads, or unilateral edits.** The retro is the channel.

The "critical-only escalation" rule applies to active phases: an objection is critical iff (a) a v1.x rule contradicts itself, (b) executing a ticket as specified would fail the gate that ticket has to pass, or (c) a doctrinal/logical/test claim is factually wrong with citation. Anything else waits for the retro.

---

## 11. Phase 0 Backlog (current)

Tracking pointer — authoritative state lives in `docs/tickets/`.

| Ticket | Owner | Deliverable | Blocks |
|---|---|---|---|
| JI-001 | SME | [scope.md](scope.md), [templates/scenario-template.md](templates/scenario-template.md) | All downstream |
| JI-002a | Tester | [templates/cq-template.yaml](templates/cq-template.yaml) | JI-002 |
| JI-002 | SME | First 15 CQs in template format | Onto axiomatization |
| JI-003 | Onto | Repo restructure, fix [intelligenceAnalysisProcess.ttl](../src/ontology/intelligenceAnalysisProcess.ttl) duplication, catalog | Two-signoff |
| JI-004a | Tester | [tests/](../tests/) layout + ROBOT/reasoner/SPARQL stub CI | Onto sees gate |
| JI-004b | Tester | Adversarial fixture skeleton (one stub per probe) | — |
| JI-005 | Onto + SME | Anti-rigidity pattern adoption + [patterns.md](patterns.md) | Phase 1 readiness |
| JI-006 | Tester | Revise [logic_ontologist_tester.yaml](../config/logic_ontologist_tester.yaml) to align with v1.0 | Persona consistency |
| JI-007 | All | Ratify v1.0 (this doc) | Phase 0 close |
| JI-008 | Onto | [relation-mapping.md](relation-mapping.md) | JI-005, all axiomatization |

**Hard dependency:** JI-008 blocks JI-005 and any axiomatization ticket. Opaque IRIs (e.g., `cco:ont00001857`) are an audit landmine without the registry.

---

*End of v1.0.*
