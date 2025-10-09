# Semantic PoC SQL Runbook

## Improved Prompt
Document a stakeholder-ready explanation of each semantic PoC SQL script, detailing purpose, prerequisites, execution order, objects created, and downstream impact, so the team can articulate the overall flow end-to-end.

## Environment Overview
- **Catalog**: `cfascdodev_primary`
- **Gold schema**: `invoice_gold_semantic_poc`
- **Semantic schema**: `invoice_semantic_poc`
- **Warehouse**: `General Purpose`
- **Analyst access principal**: `account users` (can be swapped for a dedicated group when available)

## Execution Sequence
Run the SQL scripts in numeric order; each builds on the previous. After initial deployment, the same order applies when re-running to refresh objects.

### 01_schemas_semantic_poc.sql – Provision Schemas
- **Goal**: Ensure the gold and semantic schemas exist inside the catalog.
- **Actions**: `USE CATALOG` then `CREATE SCHEMA IF NOT EXISTS` for `invoice_gold_semantic_poc` and `invoice_semantic_poc` with descriptive comments.
- **Why**: All subsequent tables, views, and registries land in these schemas; schema creation is idempotent.

### 02_gold_tables_semantic_poc.sql – Create Gold Tables
- **Goal**: Define the star-schema tables for the PoC dataset.
- **Objects**:
  - Fact: `fact_invoice_line_semantic_poc`
  - Dimensions: `dim_supplier_semantic_poc`, `dim_item_semantic_poc`, `dim_restaurant_semantic_poc`, `dim_dc_semantic_poc`, `dim_date_semantic_poc`
- **Key details**: Comments on every column, generated `line_amount` with explicit casting, Delta table properties enabled.
- **Why**: These tables are the single source of truth for the semantic views and registries.

### 03_seed_data_semantic_poc.sql – Load PoC Dataset
- **Goal**: Seed each dimension and fact with a small but representative dataset.
- **Action**: `INSERT OVERWRITE` statements populate suppliers, items, restaurants, distribution centers, calendar dates, and invoice lines.
- **Why**: Provides immediate data for validation, demos, and Genie testing without waiting on production pipelines.

### 04_relationship_registry_semantic_poc.sql – Register Joins
- **Goal**: Persist the join rules Genie needs between fact and dimension tables.
- **Object**: `invoice_semantic_poc.relationships_semantic_poc` (Delta table).
- **Content**: One row per relationship with from/to tables, keys, relationship shape, join type, confidence score, and notes.
- **Why**: Genie uses this metadata to auto-build joins; validation queries also rely on it to verify reachability.

### 05_metrics_registry_semantic_poc.sql – Register Metrics
- **Goal**: Publish canonical KPI definitions for Genie and documentation.
- **Object**: `invoice_semantic_poc.metrics_semantic_poc`.
- **Content**: Metric name, SQL expression, default aggregation, time grain, allowed dimensions, description, owner, tags.
- **Why**: Prevents metric drift and ensures natural-language queries return business-approved values.

### 06_synonyms_registry_semantic_poc.sql – Register Vocabulary
- **Goal**: Map business terms to canonical tables, columns, and metrics.
- **Object**: `invoice_semantic_poc.synonyms_semantic_poc`.
- **Content**: Terms such as “store”, “spend”, “freight” tied to the semantic objects they reference, plus usage notes.
- **Why**: Enables Genie to understand real analyst language and disambiguates requests.

### 07_semantic_views_semantic_poc.sql – Create Views
- **Goal**: Expose business-friendly views that join the fact to each dimension and compute key measures.
- **Objects**: `v_invoice_lines_semantic_poc`, `v_invoice_supplier_semantic_poc`, `v_invoice_item_semantic_poc`, `v_invoice_restaurant_semantic_poc`, `v_invoice_dc_semantic_poc`, `v_invoice_calendar_semantic_poc`.
- **Features**: Standardized column names, calculated invoice amount, freight/tax/discount measures, joined attributes.
- **Why**: Views form the trusted layer analysts and Genie will query; they hide raw schema complexity.

### 08_permissions_semantic_poc.sql – Apply Governance
- **Goal**: Grant access to semantic assets while shielding gold tables.
- **Actions**: Using the `account users` principal, grant catalog/schema usage and SELECT on semantic views; revoke all privileges on the gold schema tables.
- **Why**: Upholds “semantic layer only” access policy; adapt principal once a dedicated analyst group exists.
- **Note**: Requires the caller to have MANAGE/OWNERSHIP on the catalog to run successfully.

### 09_validation_semantic_poc.sql – Validate Model Quality
- **Goal**: Run automated checks before exposing the model.
- **Checks**:
  - Column comment coverage ≥95% per table and overall.
  - Relationship reachability (fact joins to each dimension return rows).
  - Metric reconciliation (semantic invoice amount matches base fact sums) plus sample aggregations.
- **Why**: Serves as a quality gate; any FAIL result should be investigated prior to sharing with stakeholders.

## Recommended Operational Flow
1. Execute scripts 01–09 in order on the `General Purpose` warehouse.
2. Review validation output; remediate any FAIL status.
3. Optionally configure Genie Space (outside scope of SQL scripts) trusting the semantic views and registries.
4. Schedule re-runs of validation after data/model changes to ensure ongoing quality.

## Talking Points for Stakeholders
- We create isolated schemas with PoC naming to avoid polluting production.
- Gold tables and seed data simulate the invoice domain; registries capture additional metadata Genie requires.
- Semantic views are the only surfaces analysts touch, ensuring consistent metrics and governance.
- The permissions script enforces that only the semantic schema is visible to analysts.
- Validation script proves we meet documentation and metric standards before release.

This runbook can accompany the scripts during walkthroughs to explain what each step accomplishes, why it matters, and how the workflow ties together.

## Tables Created by the PoC Scripts
- `cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc` – Invoice line fact table containing measures (line, freight, tax, discounts).
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_supplier_semantic_poc` – Supplier dimension with descriptive attributes and active flags.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_item_semantic_poc` – Item/product dimension including category, UOM, and brand info.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_restaurant_semantic_poc` – Restaurant dimension detailing locations and regional metadata.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_dc_semantic_poc` – Distribution center dimension with codes, regions, and status.
- `cfascdodev_primary.invoice_gold_semantic_poc.dim_date_semantic_poc` – Calendar/fiscal date dimension for time intelligence.
- `cfascdodev_primary.invoice_semantic_poc.relationships_semantic_poc` – Registry capturing fact-to-dimension join metadata for Genie.
- `cfascdodev_primary.invoice_semantic_poc.metrics_semantic_poc` – Registry of KPI definitions and expressions exposed to Genie.
- `cfascdodev_primary.invoice_semantic_poc.synonyms_semantic_poc` – Business vocabulary mapping terms to canonical tables/columns/metrics.

## NLQ Demo Questions for Genie (Seed Data)
1. Which supplier generated the highest invoice spend in the PoC dataset?
   - Insight: Rank suppliers (Fresh Farms, Ocean Catch, Spice Route) by `invoice_amount`.
2. Show total spend, freight, and tax by supplier for this sample.
   - Insight: Compare `invoice_amount`, `freight_cost`, `tax_cost` across suppliers.
3. What is the average unit price for each item category?
   - Insight: Use item attributes to compute `net_line_amount / quantity` per category.
4. How many invoice lines did each restaurant process?
   - Insight: Count lines (`line_count` metric) grouped by restaurant.
5. List distribution centers with total spend and freight cost.
   - Insight: Summarize `invoice_amount` and `freight_cost` by DC.
6. What is the total quantity purchased by item?
   - Insight: Aggregate `quantity_total` per item name.
7. Break down total spend by restaurant region.
   - Insight: Group `invoice_amount` by `restaurant_region`.
8. Show total discounts by supplier.
   - Insight: Sum `discount_total` for each supplier.
9. How much did we spend on January 6th, 2024?
   - Insight: Filter by `invoice_date = 2024-01-06`, sum `invoice_amount`.
10. Compare freight versus tax charges for each supplier.
    - Insight: Parallel view of `freight_cost` vs `tax_cost` per supplier.
11. Which restaurant has the highest average unit price?
    - Insight: Compute `net_line_amount / quantity` per restaurant, rank descending.
12. Provide spend trend by invoice date.
    - Insight: Daily totals of `invoice_amount` across the seed dates.
13. Show total spend and quantity for each distribution center.
    - Insight: Combine `invoice_amount` and `quantity_total` by DC.
14. How many active suppliers contributed to spend?
    - Insight: Count distinct suppliers where `active_flag = true`.
15. What is the spend split by currency?
    - Insight: Group `invoice_amount` by `currency_code` (should be all USD in seed data).

## Semantic Views Created
| View | Source Tables | Key Columns / Measures | Purpose |
|------|---------------|------------------------|---------|
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_lines_semantic_poc` | `fact_invoice_line_semantic_poc` | Core IDs, quantity, unit_price, gross/net amounts, freight, tax, invoice_amount, currency | Base semantic view; exposes the fact table with curated naming and calculated measures for other views and Genie. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_supplier_semantic_poc` | Supplier attributes, spend measures | Supplier-focused perspective for NLQ and dashboards; used to analyze spend, freight, tax by supplier. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_item_semantic_poc` | Item attributes, spend/quantity metrics | Product-facing lens for average price, quantity, and spend by item category or brand. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_restaurant_semantic_poc` | Restaurant details (name, region, timezone), spend metrics | Restaurant performance analysis; supports questions about stores/locations. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_dc_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_dc_semantic_poc` | Distribution center attributes, spend/freight/tax | Supply-chain lens to evaluate DC contribution to spend and logistics costs. |
| `cfascdodev_primary.invoice_semantic_poc.v_invoice_calendar_semantic_poc` | `v_invoice_lines_semantic_poc` + `dim_date_semantic_poc` | Date keys, calendar & fiscal fields, spend/quantity | Time intelligence; used for trends, time-series slicing, and fiscal reporting. |

**How They Are Created (07_semantic_views_semantic_poc.sql)**
1. `USE CATALOG cfascdodev_primary` to scope the session.
2. `CREATE OR REPLACE VIEW` statements build each semantic view using the gold schema tables and existing views. Column aliases provide business-friendly naming.
3. Each view references `v_invoice_lines_semantic_poc` where possible to keep computed measures consistent.

**How They Are Used**
- Genie Space trusts these views as the primary semantic assets; NLQ queries resolve against them.
- Analysts are granted SELECT on only these views (via `08_permissions_semantic_poc.sql`), ensuring governance.
- Metric and synonym registries reference column names exposed by these views, enabling accurate join paths and vocabulary mapping.
- Validation script queries these views to confirm metric reconciliation and sample outputs.
