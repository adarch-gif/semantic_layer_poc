# Invoice Analytics Semantic PoC – Deployment Guide

## 1. Purpose
This guide explains how to deploy and demo the invoice analytics semantic layer proof-of-concept on Databricks. It consolidates the SQL scripts, automation options, tables/views, NLQ questions for Genie, and operational steps you need to showcase the semantic layer end-to-end.

## 2. Environment Configuration
## 2a. Document Map
1. [01_ARCHITECTURE_OVERVIEW.md](../docs/01_ARCHITECTURE_OVERVIEW.md) - High-level architecture summary.
2. [02_ARCHITECTURE_DETAILED.md](../docs/02_ARCHITECTURE_DETAILED.md) - Detailed playbook with diagrams/personas.
3. [03_SEMANTIC_COMPONENTS.md](../docs/03_SEMANTIC_COMPONENTS.md) - Explanation of registries and semantic views.
4. [04_DEPLOYMENT_WALKTHROUGH.md](../docs/04_DEPLOYMENT_WALKTHROUGH.md) - Narrative walkthrough of SQL scripts.
5. [05_DEPLOYMENT_FLOW_DETAILS.md](../docs/05_DEPLOYMENT_FLOW_DETAILS.md) - Flowchart and step-by-step deployment detail.
6. [06_SQL_RUNBOOK.md](../docs/06_SQL_RUNBOOK.md) - Script-level explanations, tables/views, and NLQ prompts.
7. [07_GENIE_SPACE_SETUP.md](../docs/07_GENIE_SPACE_SETUP.md) - Genie Space configuration steps.
8. [08_DAB_FLOW.md](../docs/08_DAB_FLOW.md) - Asset Bundle automation flow.
9. [09_PRESENTATION_DECK.md](../docs/09_PRESENTATION_DECK.md) - Slide outline and stakeholder talking points.
10. [10_DAB_DEPLOYMENT_README.md](../docs/10_DAB_DEPLOYMENT_README.md) - Detailed steps for running the bundle.
11. [11_UI_DEPLOYMENT_README.md](../docs/11_UI_DEPLOYMENT_README.md) - Run the PoC via the Databricks UI.
- **Catalog**: `cfascdodev_primary`
- **Gold schema**: `invoice_gold_semantic_poc`
- **Semantic schema**: `invoice_semantic_poc`
- **SQL warehouse**: `General Purpose`
- **Governance principal**: `account users` (swap for the desired analyst group once created)

## 3. Deployment Options
### 3.1 Manual SQL Execution
Run the scripts in `sql_semantic_poc/` sequentially (Databricks SQL editor or `%sql` notebook cells):
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
1. Authenticate with the Databricks CLI (`databricks auth login`).
2. Navigate to `infra/`.
3. Validate and deploy the bundle using the PoC variables:
   ```bash
   databricks bundle validate
   databricks bundle deploy \
     --var catalog=cfascdodev_primary \
     --var schema_gold=invoice_gold_semantic_poc \
     --var schema_sem=invoice_semantic_poc \
     --var warehouse_name="General Purpose"
   databricks bundle run semantic_layer_deploy
   ```
4. Monitor the job **Invoice Analytics Semantic PoC Deploy** in the Workflows UI.

*Tip*: override the `--var` values when promoting to other environments.

## 4. Objects Created
### 4.1 Delta Tables
- `cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc` – invoice line fact with spend measures.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_supplier_semantic_poc` – supplier attributes and status.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_item_semantic_poc` – item/product dimension (category, UOM, brand).
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_restaurant_semantic_poc` – restaurant locations, region, timezone, active flag.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_dc_semantic_poc` – distribution centers with regions and status.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_date_semantic_poc` – calendar/fiscal date attributes.
- `cfascdodev_primary.invoice_semantic_poc.relationships_semantic_poc` – fact-to-dimension join registry.
- `cfascdodev_primary.invoice_semantic_poc.metrics_semantic_poc` – KPI definitions and expressions.
- `cfascdodev_primary.invoice_semantic_poc.synonyms_semantic_poc` – business vocabulary mappings for Genie.

### 4.2 Semantic Views
| View | Source Tables | Highlights | Usage |
|------|---------------|------------|-------|
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_lines_semantic_poc` | `fact_invoice_line_semantic_poc` | Quantity, unit price, gross/net line amounts, freight, tax, invoice amount, currency | Base semantic view feeding all others. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_supplier_semantic_poc` | Supplier metadata and spend metrics | Supplier analytics & Genie queries. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_item_semantic_poc` | Item attributes, spend, quantity | Product and pricing insights. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_restaurant_semantic_poc` | Restaurant region, timezone, spend | Store/operator performance. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_dc_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_dc_semantic_poc` | Distribution center metrics (spend, freight, tax) | Supply chain analysis. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_calendar_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_date_semantic_poc` | Calendar + fiscal fields with spend/quantity | Time-series and fiscal reporting. |

## 5. Seed Data Snapshot
- 3 suppliers (Fresh Farms, Ocean Catch, Spice Route)
- 3 items (lettuce, salmon, cumin)
- 3 restaurants (Atlanta, Dallas, Los Angeles)
- 3 distribution centers (ATL, DFW, LAX)
- 4 invoice dates (2024-01-05 to 2024-01-08) with corresponding fact rows

## 6. Validation & Benchmarks
- `09_validation_semantic_poc.sql` – enforces ≥95% comment coverage, checks join reachability, reconciles spend metrics, and outputs sample aggregates.
- `notebooks/Benchmark_Questions.sql` – 18 reference queries for Genie NLQ regression; run after each deployment.
- `tests/metadata_gap_report.sql` – highlights missing comments or synonyms (now hard-coded to the PoC catalog/schemas).

## 7. Genie NLQ Demo Questions
Use these in Genie to showcase NLQ accuracy:
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

## 8. Genie Space Setup (High Level)
1. Trust the semantic views only (`v_invoice_*_semantic_poc`).
2. Load relationships, metrics, synonyms registries to guide NLQ joins and vocabulary.
3. Configure benchmarks from the notebook for regression testing.
4. Grant analysts access once validation succeeds.

Refer to `docs/07_GENIE_SPACE_SETUP.md` for detailed UI steps.

## 9. Operations & Governance
- Rerun validation whenever models or documentation change.
- Permissions script requires `MANAGE`/`OWNERSHIP` on catalog `cfascdodev_primary`.
- Keep metric/synonym registries up to date and rerun benchmarks for NLQ regression.
- Use the DAB pipeline for repeatable promotions across environments.

## 10. Supporting Documents
## 10. Supporting Documents
- `docs/06_SQL_RUNBOOK.md` - Deep dive into SQL script behavior and NLQ question rationale.
- `docs/03_SEMANTIC_COMPONENTS.md` - Relationship/metrics/synonyms semantics overview.
- `docs/04_DEPLOYMENT_WALKTHROUGH.md` - Narrative walkthrough of each SQL script.
- `docs/08_DAB_FLOW.md` - How the Asset Bundle configuration works.
## 11. Next Steps
- Swap seed data with production ETL once ready.
- Automate Genie configuration when APIs become available.
- Extend the validation suite with additional data-quality checks.
- Add alerting for validation/benchmark failures in production environments.
