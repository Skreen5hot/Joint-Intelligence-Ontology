# JP 2-0 Core Intelligence Ontology (v1.0)

A BFO/CCO-aligned ontology framework for modeling intelligence processes derived from JP 2-0 doctrine.

---

## Overview

This ontology provides a formal semantic model for representing intelligence processes, roles, facilities, and information artifacts using:

- **BFO (Basic Formal Ontology)** as the upper ontology
- **CCO (Common Core Ontologies)** for domain structure
- **IAO (Information Artifact Ontology)** for information objects
- **RO (Relations Ontology)** for standardized relations

The goal is to enable machine-reasonable modeling of intelligence workflows such as BDA, targeting, and assessment processes.

---

## 1. Namespace Imports

- **BFO**  
  http://purl.obolibrary.org/obo/bfo.owl  

- **CCO**  
  http://www.ontologyrepository.com/CommonCoreOntologies/  

- **RO**  
  http://purl.obolibrary.org/obo/ro.owl  

- **IAO**  
  http://purl.obolibrary.org/obo/iao.owl  

---

## 2. Core Relation Set (Tight Property Set)

These object properties define the minimal relational backbone of the ontology.

### Participation & Role Realization

- **realized in (BFO_0000054)**  
  Links a role to the process in which it is realized.

- **participates in (BFO_0000056)**  
  Links an entity to a process.

- **has participant (BFO_0000057)**  
  Inverse of participates in.

- **bearer of (RO_0000053)**  
  Links an entity to the role it bears.

---

### Process Structure & Temporal Ordering

- **preceded by / precedes (BFO_0000062 / BFO_0000063)**  
  Defines temporal ordering between processes.

- **is part of process (CCO_ont00001857)**  
  Decomposes processes into subprocesses.

---

### Information Flow

- **has input (CCO_ont00001921)**  
  Links a process to its input data or information artifacts.

- **has output (CCO_ont00001986)**  
  Links a process to its outputs.

---

### Location

- **occurs at (CCO_ont00001918)**  
  Links a process to a facility or operational site.

---

## 3. Core Class Hierarchy (T-Box)

### Agents & Roles


cco:Person
└── ex:IntelligenceAnalyst
└── ex:TargetAnalyst

cco:OccupationRole
└── ex:TargetAnalysisRole


---

### Facilities


cco:Facility
└── ex:MilitaryFacility
└── ex:IntelligenceOperationsCenter


---

### Information Content Entities (ICE)


IAO:InformationContentEntity
├── ex:Imagery
│ └── ex:PostStrikeImagery
└── ex:Report
└── ex:Phase1BDAReport


---

### Material Entities


BFO:MaterialEntity
└── ex:Target


---

### Processes


BFO:Process
├── ex:IntelligenceAnalysisProcess
├── ex:TargetIntelligenceProduction
├── ex:CombatAssessmentProcess
├── ex:BattleDamageAssessmentProcess
├── ex:Phase1BattleDamageAssessment
└── ex:Phase2BattleDamageAssessment


---

## 4. Ontology Engineering Workflow (SOP)

This workflow is used to systematically model each JP 2-0 doctrinal section.

---

### Phase 1: Doctrinal Decomposition

Identify:

- Process name
- Parent operational context
- Actors (agents/systems)
- Inputs (data, reports, orders)
- Outputs (artifacts, decisions)

---

### Phase 2: Ontological Mapping

Map extracted elements to BFO/CCO/IAO/RO:

- Prefer reuse of existing ontology terms
- Avoid unnecessary new classes
- Align all entities with upper ontology structure

---

### Phase 3: Axiomatization (T-Box)

Formalize classes in OWL:

- Use `IAO_0000115` for formal definitions
- Define Aristotelian structure:
  > A [class] that [differentiating condition]
- Add OWL restrictions for:
  - inputs
  - outputs
  - participants
  - temporal ordering
  - location

---

### Phase 4: Instantiation (A-Box)

Create JSON-LD instance data:

- Fully typed entities
- Realistic operational scenario
- Valid IRIs and structure
- Compliance with T-Box constraints

---

### Phase 5: Reasoner Validation

Run ontology reasoner (Protégé, HermiT, Pellet):

Validate:

- No logical inconsistencies
- Correct inferred relations
- Proper class satisfiability
- Temporal and role consistency

**Acceptance Criteria:**  
If reasoning completes without contradiction and expected inferences are produced, the model is valid.

---

## 5. End State

Validated modules are integrated into the **Core Intelligence Ontology**, forming a reusable semantic framework for intelligence process modeling.

---

## 6. Design Principles

- Reuse before creation (CCO/IAO priority)
- BFO compliance as structural backbone
- Minimal but expressive relation set
- Strict separation of:
  - T-Box (schema)
  - A-Box (instances)
- Reasoner-verifiable consistency required