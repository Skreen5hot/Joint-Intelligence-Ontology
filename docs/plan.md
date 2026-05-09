# Standard Document: JP 2-0 Core Intelligence Ontology (v1.0)

---

## 1. Accepted Namespaces & Imports

- **BFO**: Basic Formal Ontology  
  http://purl.obolibrary.org/obo/bfo.owl  

- **CCO**: Common Core Ontologies  
  http://www.ontologyrepository.com/CommonCoreOntologies/  

- **RO**: Relations Ontology  
  http://purl.obolibrary.org/obo/ro.owl  

- **IAO**: Information Artifact Ontology  
  http://purl.obolibrary.org/obo/iao.owl  

---

## 2. Core Relation Set (“Tight Property Set”)

These object properties define the constrained relational backbone of the ontology.

- **obo:BFO_0000054 (realized in)**  
  Links a *Role* to the *Process* in which it is realized.

- **obo:BFO_0000056 (participates in)**  
  Links an *Entity* (typically Agent) to a *Process*.

- **obo:BFO_0000057 (has participant)**  
  Inverse of *participates in*; links a *Process* to participating entities.

- **obo:BFO_0000062 / obo:BFO_0000063 (preceded by / precedes)**  
  Defines strict temporal ordering between processes.

- **obo:RO_0000053 (bearer of)**  
  Links an entity (Agent) to a Role it bears.

- **cco:ont00001857 (is part of process)**  
  Decomposes a parent process into subprocesses.

- **cco:ont00001918 (occurs at)**  
  Links a Process to a Facility or Site.

- **cco:ont00001921 (has input)**  
  Links a Process to its input Information Content Entities.

- **cco:ont00001986 (has output)**  
  Links a Process to its output Information Content Entities.

---

## 3. Class Hierarchy (T-Box)

### 3.1 Agents & Roles

- cco:Person  
  └── ex:IntelligenceAnalyst  
      └── ex:TargetAnalyst  

- cco:OccupationRole  
  └── ex:TargetAnalysisRole  

---

### 3.2 Facilities (Sites)

- cco:Facility  
  └── ex:MilitaryFacility  
      └── ex:IntelligenceOperationsCenter  

---

### 3.3 Information Content Entities (ICE)

- obo:IAO_0000030 (Information Content Entity)  
  ├── ex:Imagery  
  │   └── ex:PostStrikeImagery  
  └── ex:Report  
      └── ex:Phase1BDAReport  

---

### 3.4 Material Entities & Processes

- obo:BFO_0000040 (Material Entity)  
  └── ex:Target  

- obo:BFO_0000015 (Process)  
  ├── ex:IntelligenceAnalysisProcess  
  ├── ex:TargetIntelligenceProduction  
  ├── ex:CombatAssessmentProcess  
  ├── ex:BattleDamageAssessmentProcess  
  ├── ex:Phase1BattleDamageAssessment  
  └── ex:Phase2BattleDamageAssessment  

---

## 4. SOP: Joint Intelligence Ontology Engineering Workflow

This procedure is applied iteratively to each major JP 2-0 doctrinal section (e.g., Collection Management, JIPOE, Dissemination).

---

## Phase 1: Doctrinal Decomposition

Extract structured meaning from the doctrine.

Identify:

- **Process**: Exact doctrinal activity name  
- **Parent Context**: Higher-level operational phase or intelligence cycle  
- **Actors**: Authorized participants (agents or systems)  
- **Inputs**: Required data, orders, or prior reports  
- **Outputs**: Resulting artifacts or decisions  

---

## Phase 2: Ontological Mapping

Map extracted elements into BFO / CCO / RO / IAO.

Rules:

- Prefer reuse of existing ontology terms over creation of new ones  
- Match closest semantic equivalent before introducing new classes  
- Maintain alignment with upper ontology structure (BFO as grounding model)

---

## Phase 3: Axiomatization (T-Box Generation)

Formalize ontology structure in OWL (Turtle syntax).

Requirements:

- Use `iao:IAO_0000115` for formal Aristotelian definitions  
- Define class as:  
  *“A [superclass] that [differentiating conditions]”*  
- Constrain relationships using OWL restrictions:
  - has input  
  - has output  
  - participates in  
  - occurs at  
  - preceded by / precedes  

Goal: Produce logically constrained, machine-reasonable class definitions.

---

## Phase 4: Instantiation (A-Box Generation)

Create a concrete scenario instance using JSON-LD.

Requirements:

- Every entity must be explicitly typed against T-Box classes  
- Include realistic operational context (fictionalized or anonymized)  
- Ensure valid JSON-LD structure and resolvable IRIs  
- Maintain full alignment with ontology constraints  

---

## Phase 5: Reasoner Validation

Load both T-Box and A-Box into an ontology reasoner (e.g., HermiT or Pellet via Protégé).

Validation checks:

- No logical inconsistencies  
- Correct inference of relationships  
- Proper class satisfiability  
- Temporal ordering consistency  
- Role realization correctness  

**Acceptance Criterion:**  
If the reasoner produces no contradictions and correctly infers expected relationships, the ontology module is considered validated and eligible for integration into the core model.

---

## End State

Validated ontology modules are integrated into the **Core Intelligence Ontology** as reusable, extensible components for intelligence process modeling.