# Deployment Walkthrough (Plain-English Guide)

This guide explains every step required to stand up the invoice analytics semantic layer POC on Databricks. It focuses on **what** happens, **why** it matters, and **when** to run each action.

---

## 0. Confirm Environment Placeholders

- **What**: Check the variables referenced at the top of every script.
  - `CATALOG=cfascdodev_primary`
  - `SCHEMA_GOLD=invoice_gold_semantic_poc`
  - `SCHEMA_SEM=invoice_semantic_poc`
  - `GROUP_ANALYSTS=account users` (default; can be swapped for a dedicated group)
  - `WAREHOUSE_NAME=General Purpose`
- **Why**: These placeholders keep the scripts reusable. Update them if your environment differs.
- **When**: Before running any SQL or notebook.

---

## 1. Foundation: `/sql_semantic_poc/01_schemas_semantic_poc.sql`

- **What happens**: Creates two schemas (`invoice_gold_semantic_poc`, `invoice_semantic_poc`) in the Unity Catalog (`cfascdodev_primary`) if they do not already exist.
- **Why**: The schemas are the landing zones for gold-layer objects and the semantic layer views/registries. Creating them first ensures later scripts have a home.
- **When**: Run first to guarantee the directory structure exists.
- **Objects Created**: 2 schemas

---

## 2. Data Model: `/sql_semantic_poc/02_gold_tables_semantic_poc.sql`

- **What happens**: Defines all gold tables needed for the star schema:
  - Fact: `fact_invoice_line_semantic_poc` with generated column `line_amount`.
  - Dimensions: `dim_supplier_semantic_poc`, `dim_item_semantic_poc`, `dim_restaurant_semantic_poc`, `dim_dc_semantic_poc`, `dim_date_semantic_poc`.
  Every table and column carries a detailed comment.
- **Why**: Establishes the curated data model used by downstream semantic assets. The comments make validation and data discovery easier and support the 95% comment coverage requirement.
- **When**: After schemas exist, before inserting any data.
- **Objects Created**: 6 Delta tables (1 fact + 5 dimensions)

---

## 3. Sample Data: `/sql_semantic_poc/03_seed_data_semantic_poc.sql`

- **What happens**: Loads tiny, realistic starter datasets into each dimension and the fact table using `INSERT OVERWRITE ... VALUES` statements.
- **Why**: Provides test data so analysts can run queries immediately—even without upstream ingestion pipelines. Overwrite ensures idempotency, so re-running keeps the data consistent.
- **When**: Immediately after the tables are created.
- **Data Loaded**:
  - 3 suppliers (Fresh Farms, Ocean Catch, Spice Route)
  - 3 items (lettuce, salmon, cumin)
  - 3 restaurants (Atlanta, Dallas, Los Angeles)
  - 3 distribution centers (ATL, DFW, LAX)
  - Date range: 2024-01-05 to 2024-01-08
  - ~12 fact invoice line rows

---

## 4. Relationship Registry: `/sql_semantic_poc/04_relationship_registry_semantic_poc.sql`

- **What happens**: Creates `invoice_semantic_poc.relationships_semantic_poc` and seeds join metadata for each fact-to-dimension relationship (supplier, item, restaurant, DC, date).
- **Why**: Genie and other semantic tools need explicit join rules when foreign keys are not enforced. The registry captures relationship type, preferred join, confidence, and documentation.
- **When**: After the gold tables/data exist so the joins are meaningful.
- **Objects Created**: 1 registry table with 5 relationship definitions

---

## 5. Metrics Registry: `/sql_semantic_poc/05_metrics_registry_semantic_poc.sql`

- **What happens**: Builds `invoice_semantic_poc.metrics_semantic_poc` with canonical metrics such as `invoice_amount`, `total_spend`, `freight_cost`, `tax_cost`, `line_count`, etc., including SQL expressions, aggregation defaults, allowed dimensions, owners, and tags.
- **Why**: Centralizes metric definitions for consistency across Genie, dashboards, and programmatic access. Prevents metric drift by giving every KPI a single source of truth.
- **When**: After relationships because metrics often reference fact columns that depend on correct joins.
- **Objects Created**: 1 registry table with metric definitions

---

## 6. Synonym Registry: `/sql_semantic_poc/06_synonyms_registry_semantic_poc.sql`

- **What happens**: Creates `invoice_semantic_poc.synonyms_semantic_poc` capturing how business users refer to tables, columns, and metrics (e.g., "store" → restaurant_name, "spend" → invoice_amount).
- **Why**: Supports natural-language querying in Genie by mapping everyday wording to canonical objects. This step boosts NLQ accuracy and analyst adoption.
- **When**: After metrics, since synonyms also cover metric names.
- **Objects Created**: 1 registry table with vocabulary mappings

---

## 7. Semantic Views: `/sql_semantic_poc/07_semantic_views_semantic_poc.sql`

- **What happens**: Builds six curated views with business-friendly columns, calculated measures, and column comments:
  - `v_invoice_lines_semantic_poc` - Base view with all invoice line measures
  - `v_invoice_supplier_semantic_poc` - Invoice lines joined with supplier dimension
  - `v_invoice_item_semantic_poc` - Invoice lines joined with item dimension
  - `v_invoice_restaurant_semantic_poc` - Invoice lines joined with restaurant dimension
  - `v_invoice_dc_semantic_poc` - Invoice lines joined with DC dimension
  - `v_invoice_calendar_semantic_poc` - Invoice lines joined with date dimension
- **Why**: Prevents direct access to raw gold tables while presenting a consistent, analytics-ready interface. Each view draws from the fact table with optional joins to dimensions, flattening the model for Genie.
- **When**: Once registries exist so the semantic layer references the latest definitions.
- **Objects Created**: 6 semantic views

---

## 8. Metric Views: `/sql_semantic_poc/10_metric_views_semantic_poc.sql`

- **What happens**: Creates five metric views (`mv_invoice_supplier_semantic_poc`, `mv_invoice_item_semantic_poc`, `mv_invoice_restaurant_semantic_poc`, `mv_invoice_dc_semantic_poc`, `mv_invoice_calendar_semantic_poc`) on top of the semantic views with predefined measures, dimensions, and a `TIMESTAMP invoice_date`.
- **Why**: Exposes curated spend metrics directly to Databricks Metrics so stakeholders can build scorecards without SQL. Measures include spend, quantity, freight, tax, discounts, and line counts.
- **When**: Immediately after semantic views are built; run it before permissions so the bundle can grant access to metric views alongside semantic views.
- **Prerequisite**: Databricks Metrics must be enabled in the workspace (Preview). Once enabled, the metric views appear under the semantic schema in the Metrics browser.
- **Objects Created**: 5 metric views
- **Note**: This is an optional enhancement for Databricks Metrics integration

---

## 9. Permissions: `/sql_semantic_poc/08_permissions_semantic_poc.sql`

- **What happens**: Grants catalog/schema usage and view-level SELECT to `account users` while explicitly revoking gold-layer access (both current and future tables).
- **Why**: Enforces governance by forcing analysts through semantic assets. Ensures data consumers see only approved views, matching Genie exposure.
- **When**: After the views are created to immediately lock down access.
- **Requirements**: Requires MANAGE or OWNERSHIP privileges on catalog `cfascdodev_primary`
- **Note**: Replace `account users` with your specific analyst group if needed

---

## 10. Validation: `/sql_semantic_poc/09_validation_semantic_poc.sql`

- **What happens**:
  1. Calculates column and table comment coverage, ensuring ≥95%.
  2. Confirms every relationship in the registry can successfully join (non-zero row counts).
  3. Reconciles metrics—e.g., `invoice_amount` equals net line + freight + tax—and provides sample aggregates for spot-checking Genie responses.
- **Why**: Acts as a quality gate before deploying to production or sharing with analysts. Detects metadata gaps, broken joins, or incorrect metrics early.
- **When**: After permissions; re-run whenever changes are made to models or comments.
- **Expected Result**: All checks show PASS status

---

## 11. Metadata Gap Audit: `/tests/metadata_gap_report.sql`

- **What happens**: Reports any table columns missing comments or synonyms, and metrics lacking synonym coverage.
- **Why**: Complements validation by pointing out remaining documentation tasks. Useful during development or governance reviews.
- **When**: After initial deployment and during maintenance cycles.
- **Note**: This script is now hard-coded to the POC catalog/schemas

---

## 12. Benchmark Notebook: `/notebooks/Benchmark_Questions.sql`

- **What happens**: Provides 18 "golden" questions with expected SQL/answer shapes to exercise Genie. It selects from semantic views only.
- **Why**: Serves as regression tests for NLQ behavior. Analysts and data engineers can confirm Genie understands the model and returns accurate results.
- **When**: Run after validation; also whenever metrics or synonyms change.
- **Example Questions**:
  - Which supplier generated the highest invoice spend in the PoC dataset?
  - Show total spend, freight, and tax by supplier
  - What is the average unit price for each item category?
  - How many invoice lines did each restaurant process?

---

## 13. Genie Setup: `/docs/16_GENIE_SPACE_SETUP.md`

- **What happens**: Walks through the Genie UI to trust the semantic views, recreate relationships/metrics/synonyms, and activate benchmarks. Includes API placeholders for future automation.
- **Why**: Bridges the SQL assets with Genie so analysts have an intuitive chat interface. Ensures only curated artifacts are exposed.
- **When**: Once all SQL and validation steps succeed.
- **Key Steps**:
  1. Trust ONLY semantic views (not gold tables)
  2. Configure relationships from registry
  3. Define metrics from registry
  4. Add synonyms from registry
  5. Configure benchmarks for NLQ testing

---

## 14. Run Book: `RUN_BOOK.md`

- **What happens**: Summarizes the execution order in six concise steps (SQL sequence, validation, metadata audit, benchmarks, Genie configuration, CI/CD).
- **Why**: Quick reference for operators who need a checklist without reading full documentation.
- **When**: Use anytime you need a refresher on the execution order.

---

## 15. CI/CD Automation: `/infra/databricks.yml`

- **What happens**: Defines a Databricks Asset Bundle job that executes the SQL scripts in order, runs validations, and executes the benchmark notebook on a lightweight cluster.
- **Why**: Enables repeatable deployments across environments (dev/test/prod) with a single command. Ensures validations gate the deployment.
- **When**: After manual verification, integrate this bundle into your deployment pipeline (e.g., `databricks bundle deploy`).
- **Job Name**: "Invoice Analytics Semantic PoC Deploy"
- **Tasks**: 11 sequential tasks (01_schemas through notebook_benchmarks)
- **Deployment Command**:
  ```bash
  cd /c/semantic_layer_poc_repo/invoice_semantic_layer/infra
  databricks bundle validate
  databricks bundle deploy
  databricks bundle run semantic_layer_deploy
  ```

---

## 16. Scheduled Monitoring: `/infra/jobs.json`

- **What happens**: Template for a Databricks Job that runs validation SQL nightly and the benchmark notebook afterward, with email alerts on failure.
- **Why**: Keeps the semantic layer healthy by detecting regressions, comment gaps, or Genie drift automatically.
- **When**: Once the solution is in production, schedule this job to catch issues proactively.
- **Schedule**: Daily at 5 AM UTC (configurable)
- **Alerts**: Email notifications on failure

---

## 17. Documentation Hub: `/docs/README.md`

- **What happens**: Provides a high-level overview, deployment order, validation instructions, Genie integration tips, CI/CD guidance, and future enhancements.
- **Why**: Serves as the landing page for new contributors or auditors seeking context.
- **When**: Share alongside the repository or bundle hand-off.

---

## 18. Ongoing Operations

- Re-run `/sql_semantic_poc/09_validation_semantic_poc.sql` and `/tests/metadata_gap_report.sql` after any schema or comment change.
- Update registries (relationships, metrics, synonyms) as new business requirements emerge.
- Refresh the benchmark notebook with additional questions when Genie usage expands.
- Keep permissions aligned with governance policies, especially when new groups need access.
- Monitor validation job results for any FAIL statuses
- Review Genie query patterns to identify missing synonyms or metrics

---

## Summary: Complete Deployment Sequence

| Step | Script/File | Objects Created | Time | Status Check |
|------|-------------|-----------------|------|--------------|
| 1 | 01_schemas_semantic_poc.sql | 2 schemas | <5s | `SHOW SCHEMAS` |
| 2 | 02_gold_tables_semantic_poc.sql | 6 tables | 10-20s | `SHOW TABLES IN invoice_gold_semantic_poc` |
| 3 | 03_seed_data_semantic_poc.sql | Sample data | 15-30s | `SELECT COUNT(*)` from tables |
| 4 | 04_relationship_registry_semantic_poc.sql | 1 registry | 5-10s | `SELECT * FROM relationships_semantic_poc` |
| 5 | 05_metrics_registry_semantic_poc.sql | 1 registry | 5-10s | `SELECT * FROM metrics_semantic_poc` |
| 6 | 06_synonyms_registry_semantic_poc.sql | 1 registry | 5-10s | `SELECT * FROM synonyms_semantic_poc` |
| 7 | 07_semantic_views_semantic_poc.sql | 6 views | 10-20s | `SHOW VIEWS IN invoice_semantic_poc` |
| 8 | 10_metric_views_semantic_poc.sql | 5 metric views | 10-20s | `SHOW VIEWS` (optional) |
| 9 | 08_permissions_semantic_poc.sql | Grants/Revokes | 5-10s | `SHOW GRANTS` |
| 10 | 09_validation_semantic_poc.sql | Validation results | 30-60s | Review output for PASS/FAIL |

**Total Objects**: 2 schemas + 6 tables + 3 registries + 6 views + 5 metric views = **22 objects**

**Total Time**: Manual: 30-60 minutes | Automated (DAB): 5-10 minutes

---

Following this sequence ensures the semantic layer POC is reliable, well-documented, and safe for analyst self-service via Genie.
