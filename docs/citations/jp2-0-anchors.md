# JP 2-0 Doctrinal Citation Index

| Field | Value |
|---|---|
| Owner | SME |
| Purpose | Pre-staged paragraph-level citations for `jio:derivedFrom` annotation values during JI-005 axiomatization |
| Source | [docs/jp2_0.pdf](../jp2_0.pdf) (JP 2-0, *Joint Intelligence*, 22 October 2013) |
| Companion | [docs/relation-mapping.md](../relation-mapping.md) (IRI mapping); [docs/scope.md](../scope.md) (class enumeration) |
| Output convention | `jio:derivedFrom "JP 2-0 §<chapter>-<page> ¶<paragraph-id>"` per ADR-001 |

---

## Purpose & methodology

Onto's JI-005 axiomatization needs paragraph-level doctrinal anchors on every `ex:*` class. This document pre-stages those anchors for classes derivable from JP 2-0, so JI-005 doesn't need a separate doctrinal-extraction pass.

**Citation precision:** §<chapter>-<page> is JP 2-0's native page numbering (e.g., `III-7` is Chapter III, page 7). Paragraph identifiers follow JP 2-0's own conventions: top-level numbered sections (1, 2, 3...), lettered sub-paragraphs (a, b, c...), nested numbered points ((1), (2), (3)...), and lettered nested points ((a), (b), (c)...).

**What this document does NOT cover:** classes whose primary anchor is JP 3-60 (Combat Assessment / BDA / MEA / RAR / targets). Those classes have *secondary* anchors in JP 2-0 (cross-references to JP 3-60), which are noted here for completeness, but JI-005's primary annotation should cite JP 3-60 once paragraph-level extraction is performed there. JP 3-60 PDF is not currently in the repo; that extraction is a forward task.

**What "derivable from JP 2-0" means here:** the class concept appears in JP 2-0's text with sufficient specificity to ground the class definition. Some classes (e.g., `ex:Target`) appear in JP 2-0 only via cross-reference to JP 3-60; those are flagged.

---

## Citations — classes primarily derived from JP 2-0

### Agents and roles

| Class | Primary anchor | Secondary anchors | Notes |
|---|---|---|---|
| `ex:IntelligenceAnalyst` | **JP 2-0 §I-15 ¶3.d** ("Analysis and Production" — defines all-source analysts as the role that "fuse[s] together information from all intelligence disciplines") | JP 2-0 §I-2 ¶1.c (analyst uncertainty/judgment); JP 2-0 §I-14 ¶3.a(e) (analyst-targeteer collaboration); JP 2-0 §II-11 ¶10 ("Collaboration—Leverage Expertise of Diverse Analytic Resources") | The §I-15 anchor is the strongest functional definition of the analyst role in JP 2-0. The §II-11 anchor gives the doctrinal principle context. |
| `ex:AnalyticalRole` (structural) | **JP 2-0 §I-15 ¶3.d** (same as IntelligenceAnalyst — analyst function as an occupational role) | JP 2-0 §III-9 ¶4 ("Command and Staff Intelligence Responsibilities") | Structural class enabling the anti-rigidity Person/Role pattern (per [ADR-005-pending — patterns.md doc]); the doctrinal anchor establishes "analytical role" as a recognized occupational concept under JP 2-0. |
| `ex:TargetAnalyst` | JP 3-60 ch.II (targeting cell roles — primary, JP 3-60 anchor pending) | **JP 2-0 §I-19 ¶3.b(d)** ("Target Intelligence" — establishes target-analytic specialization within the analyst function) | JP 2-0 has a secondary anchor; the strong primary anchor lives in JP 3-60. |
| `ex:TargetAnalysisRole` | JP 3-60 ch.II (primary, JP 3-60 anchor pending) | **JP 2-0 §I-19 ¶3.b(d)** (same) | Same as TargetAnalyst — secondary in JP 2-0, primary in JP 3-60. |

### Facilities

| Class | Primary anchor | Secondary anchors | Notes |
|---|---|---|---|
| `ex:IntelligenceOperationsCenter` (JIOC) | **JP 2-0 §III-7 ¶2.b** ("CCMD JIOC. The CCMD JIOCs are the primary intelligence organizations providing support to joint forces.") | JP 2-0 §III-6 ¶2 (intro to "Defense and Joint Intelligence Organizations"); JP 2-0 GL-7 ("joint intelligence operations center" formal definition) | The §III-7 ¶2.b anchor is the definitive class description. The Glossary anchor provides the formal definition for `iao:IAO_0000115` if SME prefers a quoted definition. |
| `ex:MilitaryFacility` | JP 1 (out of scope of this index, but referenced in scope §3.3) | JP 2-0 §III-6 to §III-8 (CCMD/JTF intelligence infrastructure context) | JP 2-0 alone is a weak anchor for the abstract "military facility" concept. Recommend citing JP 1 as primary in JI-005. |

### Information Content Entities (sensor products)

| Class | Primary anchor | Secondary anchors | Notes |
|---|---|---|---|
| `ex:IntelligenceProduct` | **JP 2-0 §I-18 ¶3.a-f** ("Categories of Intelligence Products" — Figure I-6 plus surrounding paragraphs enumerating product categories) | JP 2-0 §I-15 ¶3.d ("intelligence products can be presented in many forms"); JP 2-0 Appendix B (Intelligence Disciplines) | Figure I-6 provides a doctrinal taxonomy from which our `IntelligenceProduct` hierarchy derives. |
| `ex:GEOINTProduct` | **JP 2-0 Appendix B** (Intelligence Disciplines — GEOINT subsection) | JP 2-0 §I-19 ¶3.b(d) (GEOINT in target intelligence context) | Appendix B is JP 2-0's discipline-by-discipline reference. JI-005's GEOINT-product axiomatization should cite the GEOINT subsection of App B. |
| `ex:Imagery` | **JP 2-0 Appendix B** (GEOINT subsection — imagery as a GEOINT product) | JP 2-0 §I-14 ¶3.a(d) (imagery in multidiscipline collection); JP 2-0 §I-19 ¶3.b(d) (imagery in target detection) | The App B anchor establishes imagery as a sensor product class. |
| `ex:PostStrikeImagery` | **JP 2-0 §IV-15 ¶10.a(1)** (Phase I BDA — "post-attack target analysis" with imagery sources enumerated) | None | Strongly anchored: PostStrikeImagery is described as a Phase I BDA input. |
| `ex:GeospatialAnalysisReport` | **JP 2-0 Appendix B** (GEOINT subsection — analytical products of GEOINT) | JP 2-0 §I-15 ¶3.d (analysis and production of all-source products) | The App B anchor establishes GEOINT analytical reports as a recognized product type. |
| `ex:Report` (generic) | **JP 2-0 §I-15 ¶3.d** ("Intelligence products can be presented in many forms... oral presentations, hard copy publications, or electronic media") | JP 2-0 §I-18 Figure I-6 (Categories of Intelligence Products) | Generic Report class anchored in the analysis-and-production section. |

---

## Citations — classes secondarily anchored in JP 2-0 (primary in JP 3-60)

These classes have **secondary** anchors in JP 2-0 but their **primary** doctrinal source is JP 3-60. Use the JP 2-0 secondary anchor only if JP 3-60 paragraph-level extraction is unavailable; otherwise cite JP 3-60 as primary.

### Combat Assessment process tree

| Class | JP 2-0 secondary anchor | JP 3-60 primary (TBD pending JP 3-60 PDF) |
|---|---|---|
| `ex:CombatAssessmentProcess` | **JP 2-0 §IV-15 ¶10** ("Combat assessment is an example of a tactical-level assessment... Combat assessments consist of a BDA, munitions effectiveness assessment (MEA), and reattack recommendation.") | JP 3-60 App C (forward) |
| `ex:BattleDamageAssessmentProcess` | **JP 2-0 §IV-15 ¶10.a** ("BDA. BDA should be a timely and accurate estimate of damage or degradation resulting from the application of military force...") | JP 3-60 App C (forward) |
| `ex:Phase1BattleDamageAssessment` | **JP 2-0 §IV-15 ¶10.a(1)** ("Phase I—Physical Damage/Change Assessment. A physical damage assessment is an estimate of the quantitative extent of physical damage...") | JP 3-60 App C (forward) |
| `ex:Phase2BattleDamageAssessment` | **JP 2-0 §IV-15 ¶10.a(2)** ("Phase II—Functional Damage/Change Assessment. The functional damage assessment is an estimate of the effect of military force to degrade or destroy the functional/operational capability...") | JP 3-60 App C (forward) |
| `ex:Phase3BattleDamageAssessment` | **JP 2-0 §IV-16 ¶10.a(3)** ("Phase III—Functional Assessment of the Higher-Level Target System") with sub-points **(a)** functional assessment definition and **(b)** target system assessment for theater of operations | JP 3-60 App C (forward) |
| `ex:MunitionsEffectivenessAssessment` | **JP 2-0 §IV-16 ¶10.b** ("MEA. MEA is an assessment of the military force applied in terms of the weapon system and munitions effectiveness to determine and recommend any required changes...") | JP 3-60 App C (forward) |
| `ex:ReAttackRecommendation` | **JP 2-0 §IV-16 ¶10.c** ("Future Targeting and Reattack Recommendations. BDA and MEA provide systematic advice on reattacking targets. This culminates in a reattack recommendation and guides further target development.") | JP 3-60 App C (forward) |

### Combat Assessment report types

JP 2-0 describes the report content within each phase's paragraph but does not name distinct report classes. Cite the parent-process anchor:

| Class | Anchor inheritance |
|---|---|
| `ex:Phase1BDAReport` | Cite same as `ex:Phase1BattleDamageAssessment`: **JP 2-0 §IV-15 ¶10.a(1)** ("Phase I BDA reporting contains an initial physical damage assessment...") |
| `ex:Phase2BDAReport` | Cite same as `ex:Phase2BattleDamageAssessment`: **JP 2-0 §IV-15 ¶10.a(2)** ("Phase II BDA reporting builds upon the phase I initial report and is a fused, all-source product addressing a more detailed description of physical damage...") |
| `ex:Phase3BDAReport` | Cite same as `ex:Phase3BattleDamageAssessment`: **JP 2-0 §IV-16 ¶10.a(3)(b)** ("BDA phase III produces a target system assessment for the theater of operations.") — NOTE: the alias `ex:TargetSystemAssessmentReport` per scope §3.4 matches this paragraph's wording almost verbatim |
| `ex:MEAReport` | Cite same as `ex:MunitionsEffectivenessAssessment`: **JP 2-0 §IV-16 ¶10.b** (MEA section's report description) |
| `ex:RARReport` | Cite same as `ex:ReAttackRecommendation`: **JP 2-0 §IV-16 ¶10.c** (RAR section) |

### Material entities

| Class | JP 2-0 secondary anchor | JP 3-60 primary |
|---|---|---|
| `ex:Target` | **JP 2-0 §I-19 ¶3.b(d)** ("Target Intelligence portrays and locates the components of a target or target complex...") | JP 3-60 ch.II (forward) |

---

## Citations — classes whose primary anchor is JP 3-60 (no JP 2-0 grounding worth citing)

These classes are introduced or specialized only in JP 3-60. JP 2-0 does not have grounding sufficient for primary citation. Defer entirely to JP 3-60 paragraph extraction.

- (None at v1.0; all v1.0 ex:* classes have at least secondary JP 2-0 grounding per the tables above.)

---

## Recommended JI-005 annotation pattern

For each `ex:*` class, JI-005 should produce a `jio:derivedFrom` annotation. **Single-source vs multi-source:**

- **Single-source** (most classes): one `jio:derivedFrom` triple citing the strongest available anchor.
- **Multi-source** (where primary is JP 3-60 but a JP 2-0 secondary adds context): two `jio:derivedFrom` triples — one for each. This is permitted under ADR-001's pattern; it does not violate the reuse-first principle since `jio:derivedFrom` is the sanctioned property.

**Example (single-source):**

```turtle
ex:IntelligenceOperationsCenter
    rdfs:subClassOf ex:MilitaryFacility ;
    iao:IAO_0000115 "A Military Facility that serves as the central node for gathering, analyzing, and disseminating intelligence in support of joint forces." ;
    jio:derivedFrom "JP 2-0 §III-7 ¶2.b" .
```

**Example (multi-source where JP 2-0 has a secondary anchor):**

```turtle
ex:Phase1BattleDamageAssessment
    rdfs:subClassOf ex:BattleDamageAssessmentProcess ;
    iao:IAO_0000115 "A Battle Damage Assessment Process that estimates the quantitative extent of physical damage sustained by a target entity using post-strike observational inputs." ;
    jio:derivedFrom "JP 3-60 App C ¶<TBD>" ,
                    "JP 2-0 §IV-15 ¶10.a(1)" .
```

---

## Forward work

1. **JP 3-60 paragraph extraction.** Once a JP 3-60 PDF is available in the repo, perform a parallel extraction producing `docs/citations/jp3-60-anchors.md`. The classes in §"Citations — classes secondarily anchored in JP 2-0" become the highest-priority targets.
2. **JP 1 anchor for `ex:MilitaryFacility`.** scope §3.3 cites JP 1 as primary; that PDF is also out of repo. Forward task.
3. **Glossary-derived definitions.** JP 2-0's Glossary (Part II) contains formal definitions for several terms used in our class hierarchy. JI-005's `iao:IAO_0000115` annotations should consider quoting Glossary definitions verbatim where applicable (e.g., the JIOC Glossary definition at JP 2-0 GL-7 for `ex:IntelligenceOperationsCenter`).
4. **Identity intelligence subtree.** JP 2-0 introduces "identity intelligence" as a recognized category. Not in v1.0 scope but reserved as a v2.0 extension if discipline-specific analyst roles are added.

---

## Provenance & verification

This index was extracted by the SME from `docs/jp2_0.pdf` using `pdftotext -layout`. Page references were validated against in-text page footers (e.g., line 4074 of the extracted text contains the "IV-15" page-number marker, confirming that lines preceding it are on page IV-15). Paragraph identifiers (1, a, (1), (a)) are JP 2-0's own; not introduced by this document.

Re-run on every UPSTREAM-DOCTRINE-BUMP (JP 2-0 revision releases) — JP 2-0's current revision is 22 October 2013. Note: this is older than the v0 plan's original assumption; verify currency before relying on these anchors for any operational claim outside JI-Onto v1.0's modeling scope.
