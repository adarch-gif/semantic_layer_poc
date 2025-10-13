# Invoice Analytics Semantic PoC – Full Readme

## 1. Purpose
This README consolidates every artefact required to deploy and demo the invoice analytics semantic layer PoC on Databricks. It covers environment settings, SQL scripts, tables/views, NLQ questions for Genie, automation via Databricks Asset Bundles, and operational guidance.

## 2. Environment Configuration
- **Catalog:** `cfascdodev_primary`
- **Gold Schema:** `invoice_gold_semantic_poc`
- **Semantic Schema:** `invoice_semantic_poc`
- **SQL Warehouse:** `General Purpose`
- **Semantic Views & Registries:** Created in `invoice_semantic_poc`
- **Governance Principal:** `account users` (replace with target group when available)

## 3. Deployment Options
### 3.1 Manual SQL Execution
Run the scripts in `sql_semantic_poc/` sequentially using `%sql` or the SQL editor:
1. `01_schemas_semantic_poc.sql`
2. `02_gold_tables_semantic_poc.sql`
3. `03_seed_data_semantic_poc.sql`
4. `04_relationship_registry_semantic_poc.sql`
5. `05_metrics_registry_semantic_poc.sql`
6. `06_synonyms_registry_semantic_poc.sql`
7. `07_semantic_views_semantic_poc.sql`
8. `08_permissions_semantic_poc.sql`
9. `09_validation_semantic_poc.sql`

### 3.2 Databricks Asset Bundle (Automated)
1. Ensure Databricks CLI is authenticated (`databricks auth login`).
2. Navigate to `infra/`.
3. Deploy and run:
   ```bash
   databricks bundle validate
   databricks bundle deploy --var catalog=cfascdodev_primary --var schema_gold=invoice_gold_semantic_poc --var schema_sem=invoice_semantic_poc --var warehouse_name="General Purpose"
   databricks bundle run semantic_layer_deploy
   ```
4. Monitor the job **Invoice Analytics Semantic PoC Deploy** for task results (schema → views → validation → benchmark notebook).

## 4. Objects Created
### 4.1 Tables (Delta)
- `cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc` – Invoice line fact with spend measures.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_supplier_semantic_poc` – Supplier dimension and stewardship attributes.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_item_semantic_poc` – Item/product dimension with category and brand.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_restaurant_semantic_poc` – Restaurant dimension (location, region, timezone, status).
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_dc_semantic_poc` – Distribution center dimension for supply chain analysis.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_date_semantic_poc` – Calendar/fiscal date dimension.
- `cfascdodev_primary.invoice_semantic_poc.relationships_semantic_poc` – Fact-to-dimension join metadata.
- `cfascdodev_primary.invoice_semantic_poc.metrics_semantic_poc` – Canonical KPI registry.
- `cfascdodev_primary.invoice_semantic_poc.synonyms_semantic_poc` – Business vocabulary mapping.

### 4.2 Semantic Views
| View | Source Tables | Key Columns / Measures | Purpose |
|------|---------------|------------------------|---------|
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_lines_semantic_poc` | `fact_invoice_line_semantic_poc` | quantity, unit price, gross/net line amounts, freight, tax, invoice amount, currency | Base semantic layer view for all other joins and NLQ. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_supplier_semantic_poc` | Supplier metadata, spend/freight/tax | Analyze suppliers and procurement KPIs. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_item_semantic_poc` | Item details, spend, quantity | Product and pricing insights. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_restaurant_semantic_poc` | Restaurant region/timezone, spend | Operator/store performance. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_dc_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_dc_semantic_poc` | Distribution center attributes, logistics metrics | Supply chain analysis. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_calendar_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_date_semantic_poc` | Calendar & fiscal fields, spend, quantity | Time-series and fiscal reporting. |

## 5. Seed Data Summary
- 3 suppliers (Fresh Farms, Ocean Catch, Spice Route).
- 3 items (lettuce, salmon, cumin) across categories (Produce, Seafood, Dry Goods).
- 3 restaurants (Atlanta, Dallas, Los Angeles).
- 3 distribution centers (ATL, DFW, LAX).
- 4 invoice dates (2024-01-05 to 2024-01-08) with small fact set supporting demos.

## 6. Validation & Benchmarks
- `09_validation_semantic_poc.sql` checks comment coverage (>=95%), join reachability, and metric reconciliation, plus sample reporting queries.
- Benchmark notebook (`notebooks/Benchmark_Questions.sql`) runs 18 NLQ reference queries for Genie; use after each deployment to ensure NLQ reliability.

## 7. NLQ Demo Questions (use in Genie)
1. Which supplier generated the highest invoice spend in the PoC dataset?
2. Show total spend, freight, and tax by supplier for this sample.
3. What is the average unit price for each item category?
4. How many invoice lines did each restaurant process?
5. List distribution centers with total spend and freight cost.
6. What is the total quantity purchased by item?
7. Break down total spend by restaurant region.
8. Show total discounts by supplier.
9. How much did we spend on January 6th, 2024?
10. Compare freight versus tax charges for each supplier.
11. Which restaurant has the highest average unit price?
12. Provide spend trend by invoice date.
13. Show total spend and quantity for each distribution center.
14. How many active suppliers contributed to spend?
15. What is the spend split by currency?

Each question is aligned with synonyms/metrics so Genie can translate them into SQL against the semantic views.

## 8. Genie Space Setup Highlights
1. Trust semantic views only (`v_invoice_*_semantic_poc`).
2. Load the relationships/metrics/synonyms registries to guide NLQ joins and vocabulary.
3. Import benchmark prompts from the notebook to create Genie evaluation cases.
4. Share access with the analyst group once validation passes.

## 9. Operations & Governance
- Run validation script after any model or comment change.
- Re-deploy via DAB to refresh views/registries in a consistent manner.
- Review governance policies before running `08_permissions_semantic_poc.sql` (requires `MANAGE`/`OWNERSHIP` on the catalog).
- Update metrics/synonyms when business definitions evolve; re-run validation and benchmark notebook.

## 10. Supporting Docs
- `docs/SQL_RUNBOOK.md` – Deep breakdown of SQL scripts, tables, views, NLQ questions.
- `docs/DAB_FLOW.md` – Detailed explanation of the DAB configuration and execution flow.

## 11. Next Steps
- Replace seed data with production ETL once ready.
- Configure Genie space and share with stakeholders.
- Establish CI/CD pipeline invoking `databricks bundle deploy` across environments.
- Extend metrics registry and validation suite as new KPIs surface.
