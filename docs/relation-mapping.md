# JI-008 — Relation & Term IRI Mapping (Verified)

**Ticket:** JI-008
**Owner:** Ontologist
**Status:** First pass — every cited term verified against the local file in [src/imports/](../src/imports/).
**Blocks:** JI-005 (anti-rigidity refactor), JI-003 (catalog wiring).
**Source-of-truth:** the four files in [src/imports/](../src/imports/). When this doc disagrees with the imports, the imports win.

---

## Critical findings (act on these before any axiomatization ticket)

### F-1. CCO namespace prefix is wrong project-wide

Project uses `cco: <http://www.ontologyrepository.com/CommonCoreOntologies/>` and treats opaque IDs (`ont00001857`, `Person`, `Facility`, `OccupationRole`) as if they live there. They do not. The actual CCO file at [src/imports/CommonCoreOntologiesMerged.ttl](../src/imports/CommonCoreOntologiesMerged.ttl) uses `https://www.commoncoreontologies.org/`.

Every CCO-prefixed term in [src/ontology/intelligenceAnalysisProcess.ttl](../src/ontology/intelligenceAnalysisProcess.ttl), [src/instances/Phase1Report.jsonld](../src/instances/Phase1Report.jsonld), [README.md](../README.md), and [docs/plan.md](../docs/plan.md) currently resolves to **dangling IRIs** under reasoner load.

Required correction: change the prefix declaration to
`@prefix cco: <https://www.commoncoreontologies.org/> .`
Class references that use a *symbolic* short name (`cco:Person`, `cco:Facility`, `cco:OccupationRole`) must additionally be replaced with the opaque IRIs — see CCO classes table below.

### F-2. CCO ontology import IRI is wrong

[src/ontology/intelligenceAnalysisProcess.ttl](../src/ontology/intelligenceAnalysisProcess.ttl#L18) imports:
`<http://www.ontologyrepository.com/CommonCoreOntologies/Mid/AllCoreOntology>`

The actual ontology IRI declared at [src/imports/CommonCoreOntologiesMerged.ttl:9](../src/imports/CommonCoreOntologiesMerged.ttl#L9) is:
`<https://www.commoncoreontologies.org/CommonCoreOntologiesMerged>`

Required correction: replace the import line. SMOKE-CLEAN will fail until this is fixed.

### F-3. `cco:Person`, `cco:Facility`, `cco:OccupationRole` are not actual CCO IRIs

CCO does not use symbolic short names — only opaque `ont00xxxxxxx` IRIs. Our T-Box uses `cco:Person`, `cco:Facility`, `cco:OccupationRole` as if they did. After F-1 fixes the prefix, those references are still wrong; they must be replaced with opaque IRIs (see CCO Classes table). This affects JI-005 directly: the anti-rigidity refactor must be done against the right Person IRI.

### F-4. BFO label convention divergence (minor, document only)

Project's [src/ontology/intelligenceAnalysisProcess.ttl:24](../src/ontology/intelligenceAnalysisProcess.ttl#L24) declares `obo:BFO_0000054` with `rdfs:label "realized in"`. The canonical BFO label is `"has realization"` ([bfo-core.ttl:107](../src/imports/bfo-core.ttl#L107)); `"realized in"` is the `skos:altLabel`. Functionally identical predicate; reading direction is the same. Recommendation: keep the alt-label convention but annotate the source so reasoner output that emits `has realization` is recognizable. Not blocking.

---

## Verified terms — BFO

Source: [src/imports/bfo-core.ttl](../src/imports/bfo-core.ttl) · Ontology IRI: `<http://purl.obolibrary.org/obo/bfo.owl>` · Project import line: ✓ matches.

| Prefixed | Full IRI | Type | Canonical Label | Domain | Range | Notes | ✓ |
|---|---|---|---|---|---|---|---|
| `obo:BFO_0000015` | http://purl.obolibrary.org/obo/BFO_0000015 | Class | "process" | — | — | alt: "event" | ✓ |
| `obo:BFO_0000040` | http://purl.obolibrary.org/obo/BFO_0000040 | Class | "material entity" | — | — | | ✓ |
| `obo:BFO_0000054` | http://purl.obolibrary.org/obo/BFO_0000054 | ObjectProperty | "has realization" (alt: "realized in") | BFO_0000017 (realizable entity) | BFO_0000015 (process) | inverse of BFO_0000055 (realizes) | ✓ |
| `obo:BFO_0000056` | http://purl.obolibrary.org/obo/BFO_0000056 | ObjectProperty | "participates in" | SDC ∪ GDC ∪ (IC ∖ spatial region) | BFO_0000015 | inverse of 0000057 | ✓ |
| `obo:BFO_0000057` | http://purl.obolibrary.org/obo/BFO_0000057 | ObjectProperty | "has participant" | BFO_0000015 | SDC ∪ GDC ∪ (IC ∖ spatial region) | inverse of 0000056 | ✓ |
| `obo:BFO_0000062` | http://purl.obolibrary.org/obo/BFO_0000062 | ObjectProperty | "preceded by" | BFO_0000003 (occurrent) | BFO_0000003 | Transitive; inverse of 0000063 | ✓ |
| `obo:BFO_0000063` | http://purl.obolibrary.org/obo/BFO_0000063 | ObjectProperty | "precedes" | BFO_0000003 | BFO_0000003 | Transitive | ✓ |

**Range note for `has participant` (0000057):** Targets (`ex:Target ⊑ BFO_0000040`) and Persons (CCO Person ⊑ ... ⊑ BFO_0000040) both fit the range as independent continuants that are not spatial regions. Current axioms in `Phase1BattleDamageAssessment` (`has_participant some Target`, `has_participant some TargetAnalyst`) are range-clean.

---

## Verified terms — RO

Source: [src/imports/ro.owl](../src/imports/ro.owl) · Version IRI: `http://purl.obolibrary.org/obo/ro/releases/2025-06-24/ro.owl` · Project import line: ✓ matches.

| Prefixed | Full IRI | Type | Canonical Label | Domain | Range | Notes | ✓ |
|---|---|---|---|---|---|---|---|
| `obo:RO_0000053` | http://purl.obolibrary.org/obo/RO_0000053 | ObjectProperty | "bearer of" | (none stated) | BFO_0000020 (specifically dependent continuant) | InverseFunctional; inverse of RO_0000052 (inheres in) | ✓ |

**Implication:** `ex:TargetAnalysisRole` must be inferable as a `BFO_0000020` (SDC). Today `ex:TargetAnalysisRole ⊑ cco:OccupationRole` (with the IRI corrections above) → `ont00000984 ⊑ BFO_0000023 (role) ⊑ ... ⊑ BFO_0000020`. Once F-1/F-3 are fixed, the chain holds.

---

## Verified terms — IAO

Source: [src/imports/iao.owl](../src/imports/iao.owl) · Version IRI: `http://purl.obolibrary.org/obo/iao/2026-03-30/iao.owl` · Project import line: `<http://purl.obolibrary.org/obo/iao.owl>` ✓ matches; production release vendored, self-contained (zero `owl:imports`).

**Switched from dev-edit to production release.** The previously vendored `iao-edit.owl` declared 10 transitive `owl:imports` (BFO, OMO, RO, plus seven `iao/dev/*.owl` files that 404 on PURL), which hard-failed B1 in CI. The production release at the canonical PURL is self-contained and resolves cleanly offline via this catalog. All 18 cited IAO term IRIs (`IAO_0000030`, `IAO_0000115`, `IAO_0000119`, etc.) exist unchanged in the production release; no re-verification of term-level metadata required.

| Prefixed | Full IRI | Type | Canonical Label | Notes | ✓ |
|---|---|---|---|---|---|
| `obo:IAO_0000030` | http://purl.obolibrary.org/obo/IAO_0000030 | Class | "information content entity" | GDC subclass; satisfies range of `has input`/`has output` | ✓ |
| `obo:IAO_0000115` | http://purl.obolibrary.org/obo/IAO_0000115 | AnnotationProperty | "definition" | textual definition, used throughout T-Box | ✓ |
| `obo:IAO_0000119` | http://purl.obolibrary.org/obo/IAO_0000119 | AnnotationProperty | "definition source" | used for `"JP 2-0"` / `"JP 3-60"` provenance — semantically a *definition source*, not arbitrary provenance. See note below. | ✓ |

**Caveat on `IAO_0000119` usage:** the .ttl currently uses `obo:IAO_0000119 "JP 2-0"` on classes like `ex:Phase1BattleDamageAssessment` to record doctrinal source. `IAO_0000119` is for the *source of the definition itself*, not general provenance. If the intent is "this class was derived from JP 2-0," that's the right property. If the intent is "this entity is described in JP 2-0 doctrine," consider `IAO_0000118` (alternative term) or a custom annotation property declared in our ontology. Worth an ADR before scaling this annotation across all doctrinal classes.

---

## Verified terms — CCO

Source: [src/imports/CommonCoreOntologiesMerged.ttl](../src/imports/CommonCoreOntologiesMerged.ttl) · Ontology IRI: `<https://www.commoncoreontologies.org/CommonCoreOntologiesMerged>` · Version: 2.1 (2026-04-04).

### CCO Object Properties

| Project Reference | **Correct Full IRI** | Label | Domain | Range | subPropertyOf | ✓ |
|---|---|---|---|---|---|---|
| `cco:ont00001857` | https://www.commoncoreontologies.org/ont00001857 | "is part of process" | (process w/ temporal-region constraint) | (process w/ corresponding constraint) | `obo:BFO_0000132` | ✓ |
| `cco:ont00001918` | https://www.commoncoreontologies.org/ont00001918 | "occurs at" | `obo:BFO_0000015` (process) | `obo:BFO_0000029` (site) | `obo:BFO_0000066` | ✓ |
| `cco:ont00001921` | https://www.commoncoreontologies.org/ont00001921 | "has input" | `obo:BFO_0000015` | SDC ∪ GDC ∪ (IC ∖ spatial region) | `obo:BFO_0000057` | ✓ |
| `cco:ont00001986` | https://www.commoncoreontologies.org/ont00001986 | "has output" | `obo:BFO_0000015` | SDC ∪ GDC ∪ (IC ∖ spatial region) | `obo:BFO_0000057` | ✓ |

### CCO Classes — name-to-IRI mapping (F-3)

| Project Reference | **Correct Full IRI** | Label | Parent (in CCO) | ✓ |
|---|---|---|---|---|
| `cco:Person` | https://www.commoncoreontologies.org/ont00001262 | "Person" | ont00000562 (Animal) | ✓ |
| `cco:Facility` | https://www.commoncoreontologies.org/ont00000192 | "Facility" | ont00000995 (Material Artifact) | ✓ |
| `cco:OccupationRole` | https://www.commoncoreontologies.org/ont00000984 | "Occupation Role" | `obo:BFO_0000023` (role) | ✓ |

---

## Required corrections (mechanical, deferred to JI-003 / JI-005)

1. **Prefix correction** in `.ttl`, `.jsonld`, `README.md`, `plan.md`:
   `cco: <http://www.ontologyrepository.com/CommonCoreOntologies/>` →
   `cco: <https://www.commoncoreontologies.org/>`

2. **Import IRI correction** in `.ttl`:
   `<http://www.ontologyrepository.com/CommonCoreOntologies/Mid/AllCoreOntology>` →
   `<https://www.commoncoreontologies.org/CommonCoreOntologiesMerged>`

3. **Symbolic-name → opaque IRI rewrites** (project's T-Box and A-Box):
   - `cco:Person` → `cco:ont00001262`
   - `cco:Facility` → `cco:ont00000192`
   - `cco:OccupationRole` → `cco:ont00000984`

4. **Catalog mapping** (JI-003): `src/imports/catalog-v001.xml` must include
   - `<http://purl.obolibrary.org/obo/bfo.owl>` → `bfo-core.ttl`
   - `<http://purl.obolibrary.org/obo/ro.owl>` → `ro.owl`
   - `<http://purl.obolibrary.org/obo/iao.owl>` → `iao-edit.owl`
   - `<https://www.commoncoreontologies.org/CommonCoreOntologiesMerged>` → `CommonCoreOntologiesMerged.ttl`

---

## Open items for the team

- **For SME (JI-002):** the structured CQ format must allow specifying inferred relations *by canonical IRI*, not by short name, to avoid recreating F-3 inside the test surface. Tester's CQ template should require IRIs from this table.
- **For Tester (JI-004a):** SMOKE-CLEAN gate should explicitly check (a) no dangling external IRIs and (b) every external IRI used in `src/ontology/` appears in this table. That auto-catches future drift.
- **For ADR queue:** `IAO_0000119` semantic mismatch (see IAO caveat above) needs an ADR before JI-005 scales the doctrinal annotation pattern.

## Verification method

For each term: ripgrep against the source file with surrounding context, confirm `rdf:type` (Class / ObjectProperty / AnnotationProperty), capture canonical `rdfs:label`, capture `rdfs:domain`/`rdfs:range` where applicable, capture `skos:definition` or `IAO_0000115`. CCO class IRIs identified by reverse-lookup on `rdfs:label "Person"@en` / `"Facility"@en` / `"Occupation Role"@en`. Re-run on every CCO/BFO/IAO/RO upstream bump (UPSTREAM-BUMP ticket type per workflow v1.0).
