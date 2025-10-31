# Databricks Semantic Metric Layer Whitepaper

## Executive Summary
Data teams are shifting from last-mile dashboarding to reusable, governed metrics. Databricks' Semantic Metric Layer (SML) unifies business logic, relationships, and documentation directly on the lakehouse, making metrics discoverable through SQL, visual tools, and natural language. This paper describes an end-to-end architecture, governance model, implementation pattern, and operating model for building a metric layer on Databricks, illustrated with the invoice analytics PoC.

## 1. Background: Why a Semantic Metric Layer?
- **Metric Drift**: Teams redefine KPIs in each BI tool, producing conflicting results.
- **Slow Time to Insight**: Ad-hoc SQL is needed even for basic questions.
- **Governance & Trust**: Hard to prove where numbers come from or who owns them.
- **Machine-Assisted Analytics**: GenAI tools like Databricks Genie need curated metadata to answer questions reliably.

The metric layer abstracts raw tables into business-centric perspectives augmented with metadata—relationships, synonyms, governance rules—so humans and AI share the same definitions.

## 2. Lakehouse Architecture at a Glance
1. **Bronze/Silver layers** (outside scope) stage raw data.
2. **Gold layer**: curated fact and dimension tables with tight schema and documentation.
3. **Semantic Views**: SQL views that join facts to dimensions and compute measures.
4. **Semantic Metric Layer**: Databricks metric views (`CREATE METRIC VIEW`) and registries storing relationships, synonyms, and KPI definitions.
5. **Consumption**: SQL notebooks, BI tools, Metrics UI, Genie, or external APIs.

Key Databricks capabilities:
- Unity Catalog for governance/lineage.
- Delta Lake for ACID storage with metadata constraints.
- Databricks SQL Warehouse for serving.
- Databricks Metrics (Preview) to surface metric views in a drag-and-drop UI.
- Genie (AI/BI) for natural-language interactions powered by the semantic metadata.

## 3. Metric Layer Components

| Component | Purpose | Databricks Artifact |
|-----------|---------|---------------------|
| **Metric Views** | Declarative measure/dimension definitions accessible to Metrics UI and SQL | `CREATE METRIC VIEW` |
| **Semantic Views** | Business-friendly data foundations reused across metric views and NLQ | `CREATE VIEW` |
| **Relationship Registry** | Stores canonical join paths for NLQ & automated SQL generation | Delta table |
| **Metrics Registry** | Business-approved KPI definitions, owners, allowed dimensions | Delta table |
| **Synonyms Registry** | Vocabulary mapping ("store" → `restaurant_name`) for Genie | Delta table |
| **Governance Script** | Grants, revokes so analysts only read semantic assets | SQL script |
| **Validation Suite** | Tests comment coverage, join reachability, metric reconciliation | SQL script |
| **Documentation** | Architecture, deployment guides, runbooks, and benchmarks | Markdown, notebooks |

## 4. Workflow and Automation

### 4.1 Development Flow
1. **Model Gold Tables** with rich comments.
2. **Seed/Load Data** for testing.
3. **Populate Registries** with join, metric, synonym metadata.
4. **Create Semantic Views** referencing gold tables.
5. **Publish Metric Views** that wrap semantic views with measure/dimension declarations.
6. **Apply Permissions** to enforce semantic-only access.
7. **Validate** for documentation coverage and metric consistency.
8. **Deploy Notebook Benchmarks** for NLQ regression.
9. **Document** and communicate the workflow.

### 4.2 Databricks Asset Bundle
Automation uses `infra/databricks.yml` spotlighting sequential tasks:
- `sql_01_schemas` … `sql_07_views` build foundation.
- `sql_10_metric_views` publishes metric layer.
- `sql_08_permissions`, `sql_09_validation`, notebook tasks for governance and benchmarks.
- Bundle packaging includes SQL scripts, docs, tests.

### 4.3 Production Deployment
- Run `databricks bundle deploy/run` with environment-specific catalog/schema overrides.
- Configure Jobs for nightly validation and benchmark runs.
- Integrate with CI/CD systems for continuous promotion.

## 5. Metric View Design

Each metric view:
- Casts the existing time field to `TIMESTAMP` for time-series slicing.
- Declares measures with default aggregations (`SUM`, `COUNT`).
- Lists reusable dimensions for segmentation.
- References curated semantic views ensuring consistent calculations.

Example (`10_metric_views_semantic_poc.sql`):

```sql
CREATE OR REPLACE METRIC VIEW cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
COMMENT 'Metrics for supplier spend...'
MEASURES (
  total_invoice_amount DECIMAL(38,6) DEFAULT SUM(coalesce(invoice_amount, 0)),
  invoice_line_count BIGINT DEFAULT COUNT(*)
)
DIMENSIONS (
  supplier_id STRING,
  supplier_name STRING,
  supplier_category STRING,
  currency_code STRING
)
TIMESTAMP invoice_date
AS
SELECT
  CAST(invoice_date AS TIMESTAMP) AS invoice_date,
  supplier_id,
  supplier_name,
  supplier_category,
  currency_code,
  invoice_amount
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;
```

## 6. Governance & Security
- Unity Catalog schemas (`invoice_gold_semantic_poc`, `invoice_semantic_poc`) isolate curated assets.
- Permissions script grants `SELECT` on views/metric views but revokes gold-layer tables.
- Metric view access is controlled like regular views; rely on catalog-level policies.
- Document owner fields in metric registry and set data steward responsibilities.

## 7. Genie and NLQ Enablement
- Genie trusts only semantic views to avoid raw table ambiguity.
- Relationship and synonym registries guide join resolution and vocabulary.
- Benchmark notebook provides canonical questions ensuring NLQ consistency.
- Metric views align Genie responses with Metrics UI, preventing different answers by tool.

## 8. Operational Excellence

### 8.1 Validation
- Enforce comment coverage ≥95% to improve discoverability.
- Check join reachability (fact ↔ dimension).
- Reconcile aggregated measures vs. base facts.

### 8.2 Monitoring
- Schedule jobs to rerun validation and NLQ benchmarks.
- Evaluate Metrics adoption and usage patterns.
- Create alerting on validation failures or permission drift.

### 8.3 Change Management
- Update metric registry and metric views when KPIs change.
- Version documentation alongside code.
- Communicate changes via runbook updates and stakeholder briefings.

## 9. Implementation Blueprint
1. Clone repo (`c:\semantic_layer_poc_repo`) and explore docs for context.
2. Modify or extend gold tables/registries according to business needs.
3. Add new semantic views and metric views as needed.
4. Update bundle tasks and documentation (doc numbering is important).
5. Run validation locally.
6. Use `databricks.yml` for automated deployments across environments.
7. Engage stakeholders—finance, operations—to verify metric definitions.

## 10. Future Enhancements
- Automate registry updates via Data Catalog APIs.
- Adopt streaming pipelines (Delta Live Tables) for real-time metric layers.
- Build observability dashboards for validation metrics.
- Integrate across business domains with a central metrics catalog.
- Implement programmatic Genie configuration (API is emerging).

## 11. Conclusion
A Databricks semantic metric layer over the lakehouse consolidates metric logic, documentation, and governance, enabling analytics teams to deliver trustworthy, AI-ready insights. Whether exposing data to Genie, Databricks Metrics, or downstream tools, metric views ensure consistent definitions and rapid adoption across stakeholders.
