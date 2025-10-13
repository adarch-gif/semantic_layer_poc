# Semantic Layer Presentation Deck

## Audience
- Executive sponsors (Finance, Operations, Analytics)
- Data engineering and governance stakeholders
- Genie (AI/BI) adoption leads

## Deck Structure & Content

### Slide 1 – Title & Context
- **Title**: "Invoice Analytics Semantic Layer on Databricks"
- **Subtitle**: "Enabling trusted AI/BI insights with Genie"
- **Content**: project team, date, objectives.
- **Talking Points**: Introduce purpose of session, highlight alignment with AI/BI strategy.

### Slide 2 – Business Challenge & Opportunity
- **Visual**: Problem statement graphic (e.g., disconnected reports, manual Excel joins).
- **Bullets**:
  - Fragmented invoice data across suppliers and restaurants.
  - Analysts recreate joins/metrics manually, risking errors.
  - Genie adoption requires curated semantic layer.
  - Opportunity: unify metrics, accelerate answers, embed governance.

### Slide 3 – Desired Outcomes
- **Bullets**:
  - Single source of truth for invoice spend, freight, tax, discounts.
  - Genie-ready semantic views with NLQ vocabulary.
  - Governance and documentation meeting >=95% comment coverage.
  - Repeatable deployment and ongoing monitoring.
- **Talking Points**: Link outcomes to business KPIs (cost control, supplier negotiations).

### Slide 4 – Medallion Architecture Recap
- **Visual**: Adapt the Bronze → Silver → Gold → Semantic diagram.
- **Narrative**: Highlight how gold tables feed semantic schema and Genie.
- **Callout**: semantic schema is the bridge between data engineering and analyst experience.

### Slide 5 – Semantic Components Overview
- **Visual**: Mermaid diagram showing fact/dim -> registries -> views -> Genie.
- **Talking Points**: For relationships, metrics, synonyms, views, describe metadata captured and benefits.
- **Table** summarising: Component | What it stores | Why it matters | Owner.

### Slide 6 – Relationship Registry Deep Dive
- **Content**:
  - Purpose: join logic for fact ↔ dimensions.
  - Sample row screenshot or schema.
  - Benefits: prevents incorrect joins, supports validations.
  - Risks if missing: cartesian products, Genie confusion.
- **Talking Points**: Governance of relationships, confidence scores.

### Slide 7 – Metrics Registry Deep Dive
- **Content**:
  - KPIs captured (`invoice_amount`, `total_spend`, etc.).
  - Expression example and owner.
  - Align with finance definitions.
  - Highlight metric reconciliation validation.

### Slide 8 – Synonym Registry Deep Dive
- **Content**:
  - Vocabulary mapping for NLQ: store → restaurant_name, spend → invoice_amount.
  - How analysts contribute synonyms and how we maintain them.
  - Benefits: improved Genie accuracy, common language.

### Slide 9 – Semantic Views (`v_invoice_*`)
- **Visual**: Table of views and key columns/measures.
- **Talking Points**:
  - Why we expose curated views instead of raw tables.
  - Example query before vs. after views.
  - Governance: analysts only receive view access.

### Slide 10 – Governance & Access Model
- **Content**:
  - Unity Catalog roles, `GROUP_ANALYSTS` permissions.
  - Comment coverage policy, documentation standards.
  - Diagram of access flows (analyst → Genie → views).

### Slide 11 – Deployment Journey
- **Visual**: Enhanced flow diagram with phases (Preparation, Build, Validate, Launch, Operate).
- **Bullets**: key scripts per phase (01_schemas.sql, etc.).
- **Talking Points**: Dependencies, automation via databricks.yml, nightly jobs.

### Slide 12 – Prerequisites & Stakeholder Responsibilities
- **Content**:
  - Summary from `PREREQUISITES.md` – data readiness, governance approvals, KPI catalogue, synonyms, warehouse readiness.
  - Table mapping domain → key question → owner → artefact.
  - Call to action: confirm readiness date.

### Slide 13 – Validation & Benchmarks
- **Content**:
  - Overview of validation queries (comment coverage, join reachability, metric reconciliation).
  - Benchmark notebook purpose and sample questions.
  - Success criteria (pass/fail thresholds).

### Slide 14 – Operational Model
- **Bullets**:
  - Databricks job schedule, alerting, runbooks.
  - Change management for metrics/synonyms.
  - Quarterly review of registries and benchmarks.

### Slide 15 – Roadmap & Next Steps
- **Content**:
  - Immediate actions (prereq intake workshop, finish documentation, schedule deployment).
  - Near-term (pilot Genie with analysts, gather feedback).
  - Future enhancements (ETL automation, additional KPIs, Genie API automation).

### Slide 16 – Decision & Ask
- **Content**:
  - Summarise key approvals needed (governance sign-off, metric definitions, resource commitments).
  - Proposed timeline (e.g., readiness review, deployment, go-live).
  - Request for stakeholder confirmation and support.

### Slide 17 – Appendix (Optional)
- Additional details: table schemas, sample SQL, glossary excerpts, contact list.

## Visual Assets to Embed
- Mermaid or exported diagrams from documentation: architecture overview, semantic components, deployment flow, prerequisite intake.
- Tables summarising registries, validations, roles.

## Presenter Notes (General)
- Highlight how each component mitigates a specific risk (join logic, metric drift, NLQ misinterpretation, governance).
- Reinforce the value of automation & monitoring for sustainable operations.
- Encourage stakeholder participation in maintaining registries and benchmarks.

## Follow-up Actions After Presentation
1. Schedule prerequisite intake workshop.
2. Collect outstanding artefacts (KPI catalogue, synonyms, governance approvals).
3. Confirm deployment timeline and resource availability.
4. Set up communication channel for ongoing updates.

Use this outline to build the slide deck (PowerPoint, Google Slides, or Databricks Notebook presentation). Each slide already includes suggested visuals and talking points to keep the narrative consistent.

