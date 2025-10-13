# Deployment Walkthrough (Plain-English Guide)

This guide explains every step required to stand up the invoice analytics semantic layer on Databricks. It focuses on **what** happens, **why** it matters, and **when** to run each action.

---

## 0. Confirm Environment Placeholders
- **What**: Check the variables referenced at the top of every script.
  - `CATALOG=cfa_demo`
  - `SCHEMA_GOLD=gold`
  - `SCHEMA_SEM=semantic_analytics`
  - `GROUP_ANALYSTS=cfa_sc_analysts`
  - `WAREHOUSE_NAME=serverless_sql_wh`
- **Why**: These placeholders keep the scripts reusable. Update them if your environment differs.
- **When**: Before running any SQL or notebook.

---

## 1. Foundation: `/sql/01_schemas.sql`
- **What happens**: Creates the Unity Catalog catalog (`cfa_demo`) and two schemas (`gold`, `semantic_analytics`) if they do not already exist. Ownership is set to the workspace default (`account users`).
- **Why**: The catalog and schemas are the landing zones for gold-layer objects and the semantic layer views/registries. Creating them first ensures later scripts have a home.
- **When**: Run first to guarantee the directory structure exists.

---

## 2. Data Model: `/sql/02_gold_tables.sql`
- **What happens**: Defines all gold tables needed for the star schema:
  - Fact: `fact_invoice_line` with generated column `line_amount`.
  - Dimensions: `dim_supplier`, `dim_item`, `dim_restaurant`, `dim_dc`, `dim_date`.
  Every table and column carries a detailed comment.
- **Why**: Establishes the curated data model used by downstream semantic assets. The comments make validation and data discovery easier and support the 95% comment coverage requirement.
- **When**: After schemas exist, before inserting any data.

---

## 3. Sample Data: `/sql/03_seed_data.sql`
- **What happens**: Loads tiny, realistic starter datasets into each dimension and the fact table using `INSERT OVERWRITE ... VALUES` statements.
- **Why**: Provides test data so analysts can run queries immediately—even without upstream ingestion pipelines. Overwrite ensures idempotency, so re-running keeps the data consistent.
- **When**: Immediately after the tables are created.

---

## 4. Relationship Registry: `/sql/04_relationship_registry.sql`
- **What happens**: Creates `${SCHEMA_SEM}.relationships` and seeds join metadata for each fact-to-dimension relationship (supplier, item, restaurant, DC, date).
- **Why**: Genie and other semantic tools need explicit join rules when foreign keys are not enforced. The registry captures relationship type, preferred join, confidence, and documentation.
- **When**: After the gold tables/data exist so the joins are meaningful.

---

## 5. Metrics Registry: `/sql/05_metrics_registry.sql`
- **What happens**: Builds `${SCHEMA_SEM}.metrics` with canonical metrics such as `invoice_amount`, `total_spend`, `avg_price`, etc., including SQL expressions, aggregation defaults, allowed dimensions, owners, and tags.
- **Why**: Centralizes metric definitions for consistency across Genie, dashboards, and programmatic access. Prevents metric drift by giving every KPI a single source of truth.
- **When**: After relationships because metrics often reference fact columns that depend on correct joins.

---

## 6. Synonym Registry: `/sql/06_synonyms_registry.sql`
- **What happens**: Creates `${SCHEMA_SEM}.synonyms` capturing how business users refer to tables, columns, and metrics (e.g., "store" → restaurant name).
- **Why**: Supports natural-language querying in Genie by mapping everyday wording to canonical objects. This step boosts NLQ accuracy and analyst adoption.
- **When**: After metrics, since synonyms also cover metric names.

---

## 7. Semantic Views: `/sql/07_semantic_views.sql`
- **What happens**: Builds six curated views (`v_invoice_lines`, `v_invoice_supplier`, `v_invoice_item`, `v_invoice_restaurant`, `v_invoice_dc`, `v_invoice_calendar`) with business-friendly columns, calculated measures, and column comments.
- **Why**: Prevents direct access to raw gold tables while presenting a consistent, analytics-ready interface. Each view draws from the fact table with optional joins to dimensions, flattening the model for Genie.
- **When**: Once registries exist so the semantic layer references the latest definitions.

---

## 8. Permissions: `/sql/08_permissions.sql`
- **What happens**: Grants catalog/schema usage and view-level SELECT to `${GROUP_ANALYSTS}` while explicitly revoking gold-layer access (both current and future tables).
- **Why**: Enforces governance by forcing analysts through semantic assets. Ensures data consumers see only approved views, matching Genie exposure.
- **When**: After the views are created to immediately lock down access.

---

## 9. Validation: `/sql/09_validation.sql`
- **What happens**:
  1. Calculates column and table comment coverage, ensuring ≥95%.
  2. Confirms every relationship in the registry can successfully join (non-zero row counts).
  3. Reconciles metrics—e.g., `invoice_amount` equals net line + freight + tax—and provides sample aggregates for spot-checking Genie responses.
- **Why**: Acts as a quality gate before deploying to production or sharing with analysts. Detects metadata gaps, broken joins, or incorrect metrics early.
- **When**: After permissions; re-run whenever changes are made to models or comments.

---

## 10. Metadata Gap Audit: `/tests/metadata_gap_report.sql`
- **What happens**: Reports any table columns missing comments or synonyms, and metrics lacking synonym coverage.
- **Why**: Complements validation by pointing out remaining documentation tasks. Useful during development or governance reviews.
- **When**: After initial deployment and during maintenance cycles.

---

## 11. Benchmark Notebook: `/notebooks/Benchmark_Questions.sql`
- **What happens**: Provides 18 "golden" questions with expected SQL/answer shapes to exercise Genie. It selects from semantic views only.
- **Why**: Serves as regression tests for NLQ behavior. Analysts and data engineers can confirm Genie understands the model and returns accurate results.
- **When**: Run after validation; also whenever metrics or synonyms change.

---

## 12. Genie Setup: `/docs/08_GENIE_SPACE_SETUP.md`
- **What happens**: Walks through the Genie UI to trust the semantic views, recreate relationships/metrics/synonyms, and activate benchmarks. Includes API placeholders for future automation.
- **Why**: Bridges the SQL assets with Genie so analysts have an intuitive chat interface. Ensures only curated artifacts are exposed.
- **When**: Once all SQL and validation steps succeed.

---

## 13. Run Book: `RUN_BOOK.md`
- **What happens**: Summarizes the execution order in six concise steps (SQL sequence, validation, metadata audit, benchmarks, Genie configuration, CI/CD).
- **Why**: Quick reference for operators who need a checklist without reading full documentation.
- **When**: Use anytime you need a refresher on the execution order.

---

## 14. CI/CD Automation: `/infra/databricks.yml`
- **What happens**: Defines a Databricks Asset Bundle job that executes the SQL scripts in order, runs validations, and executes the benchmark notebook on a lightweight cluster.
- **Why**: Enables repeatable deployments across environments (dev/test/prod) with a single command. Ensures validations gate the deployment.
- **When**: After manual verification, integrate this bundle into your deployment pipeline (e.g., `databricks bundle deploy`).

---

## 15. Scheduled Monitoring: `/infra/jobs.json`
- **What happens**: Template for a Databricks Job that runs validation SQL nightly and the benchmark notebook afterward, with email alerts on failure.
- **Why**: Keeps the semantic layer healthy by detecting regressions, comment gaps, or Genie drift automatically.
- **When**: Once the solution is in production, schedule this job to catch issues proactively.

---

## 16. Documentation Hub: `/docs/README.md`
- **What happens**: Provides a high-level overview, deployment order, validation instructions, Genie integration tips, CI/CD guidance, and future enhancements.
- **Why**: Serves as the landing page for new contributors or auditors seeking context.
- **When**: Share alongside the repository or bundle hand-off.

---

## 17. Ongoing Operations
- Re-run `/sql/09_validation.sql` and `/tests/metadata_gap_report.sql` after any schema or comment change.
- Update registries (relationships, metrics, synonyms) as new business requirements emerge.
- Refresh the benchmark notebook with additional questions when Genie usage expands.
- Keep permissions aligned with governance policies, especially when new groups need access.

---

Following this sequence ensures the semantic layer is reliable, well-documented, and safe for analyst self-service via Genie.
