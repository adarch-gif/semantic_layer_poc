# Databricks Semantic Layer & Metric Layer – Field Guide

## 1. Executive Summary
- **Purpose**: Describe what the semantic layer is, why it matters, and how to deliver it quickly on Databricks.
- **Outcome**: Business-ready metrics exposed through Databricks Metrics UI, powered by governed semantic views.

## 2. The Need for a Semantic Layer
- Analysts rebuild the same KPIs in every tool ? inconsistent numbers.
- AI/BI assistants (Genie) need curated joins and definitions to answer correctly.
- Executives want a single version of truth with auditable lineage.

## 3. Databricks Foundations (What / Where)
| Capability | Role in the Semantic Layer |
|------------|----------------------------|
| **Unity Catalog** | Central catalog + governance for schemas, permissions, lineage |
| **Delta Lake** | Stores gold fact/dimension tables with ACID reliability |
| **Semantic Views** | SQL views that expose friendly columns and derived measures |
| **Metric Views (YAML)** | Package measures & dimensions for Databricks Metrics UI |
| **Databricks Asset Bundles** | Automate deployment of SQL scripts (schemas ? tables ? views ? metrics) |
| **Databricks Metrics UI / Genie** | Consumption layer (dashboards, natural language) |

## 4. High-Level Architecture
```
[Gold Tables] -> [Semantic Views] -> [Metric Views]
       |              |                |
       v              v                v
   Unity Catalog   Metrics UI     Genie / SQL clients
```
- Gold tables deliver the curated data model (fact + dimensions).
- Semantic views hide modeling complexity and standardise naming.
- Metric views expose reusable measures/dimensions; Metrics UI reads them directly.

## 5. Implementation Blueprint (How)
1. **Provision Schemas** (`sql/01_schemas.sql`)
   - Create gold + semantic schemas in Unity Catalog.
2. **Build Tables** (`sql/02_tables.sql`)
   - Define fact + dimension tables with comments.
   - Load minimal seed data (optional but helpful for demos).
3. **Author Semantic Views** (`sql/03_semantic_views.sql`)
   - Join fact to dimensions; calculate measures such as merchandise amount.
4. **Define Metric Views in YAML** (`sql/04_metric_views.sql`)
   - Use `CREATE OR REPLACE VIEW ... WITH METRICS LANGUAGE YAML`.
   - List measures (`SUM(total_invoice_amount)`) and dimensions (`supplier_name`).
5. **Deploy via Asset Bundle** (`infra/databricks.yml`)
   - Tasks run 01 ? 04 in order using your SQL warehouse.
6. **Consume**
   - Metrics UI: open catalog/schema and drag measures/dimensions onto charts.
   - SQL: `SELECT * FROM catalog.schema.mv_invoice_supplier_quickstart`.
   - Genie: point Genie at the semantic views for NLQ (optionally add registries later).

## 6. Governance Snapshot (Why it Works)
- Use Unity Catalog privileges to grant `SELECT` on metric views and restrict underlying tables.
- Comments in tables/views document every field.</n- YAML metric views can include owners/tags to clarify stewardship.
- Add validation/registries later as the solution matures.

## 7. Adoption Checklist
- **Stakeholders**: Data engineering (build), analytics (consume), business sponsor (approve KPIs).
- **Training**: Show analysts how to access Metric Views in the Metrics UI and run example queries.
- **Success Metrics**: Number of dashboards using metric views, consistency between Metric UI and manual SQL checks.

## 8. Roadmap (Next Steps)
- Extend tables/views with real data sources.
- Add metadata registries (relationships, metrics, synonyms) for Genie integration.
- Introduce validation scripts and CI/CD gates for production.
- Layer in monitoring/alerting for nightly deployments.

## 9. Appendix
- **Key Assets**:
  - `sql/01_schemas.sql`
  - `sql/02_tables.sql`
  - `sql/03_semantic_views.sql`
  - `sql/04_metric_views.sql`
  - `infra/databricks.yml`
- **Glossary**:
  - *Semantic View*: A curated SQL view joining fact and dimensions.
  - *Metric View*: Databricks view (YAML) exposing measures/dimensions for Metrics UI.
  - *Unity Catalog*: Databricks governance plane for assets and permissions.
