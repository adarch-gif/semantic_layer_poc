# Genie Space Setup Guide

Environment placeholders (confirm before running any script):
```
CATALOG=cfa_demo
SCHEMA_GOLD=gold
SCHEMA_SEM=semantic_analytics
GROUP_ANALYSTS=cfa_sc_analysts
WAREHOUSE_NAME=serverless_sql_wh
```

## Prerequisites
- Run SQL scripts `/sql/01_schemas.sql` through `/sql/08_permissions.sql` in order.
- Ensure `WAREHOUSE_NAME` points to an available SQL warehouse with access to `CATALOG`.

## Step-by-step Space Creation (UI)
1. Open **AI/BI (Genie) Spaces** in the Databricks workspace and click **Create Space**.
2. Provide a name such as `Invoice Analytics Semantic Space` and optional description referencing this semantic model. Choose the `serverless_sql_wh` warehouse (or alternate) for query execution.
3. In the **Trusted Assets** section, select only the semantic views under `${CATALOG}.${SCHEMA_SEM}`:
   - `v_invoice_lines`
   - `v_invoice_supplier`
   - `v_invoice_item`
   - `v_invoice_restaurant`
   - `v_invoice_dc`
   - `v_invoice_calendar`
   Confirm no raw/gold tables are trusted.
4. Navigate to **Relationships** within the space:
   - Reproduce each relationship from `${CATALOG}.${SCHEMA_SEM}.relationships`, e.g. `fact_invoice_line.supplier_id → dim_supplier.supplier_id (many-to-one)`.
   - Set join type to `inner` and note confidence descriptions for documentation.
5. Configure **Metrics**:
   - Add each metric from `${CATALOG}.${SCHEMA_SEM}.metrics`.
   - Supply SQL expressions exactly as defined (copy from table) and map available dimensions (`dim_supplier`, `dim_item`, `dim_restaurant`, `dim_dc`, `dim_date`).
   - Mark `invoice_amount` as default spend KPI and assign owners.
6. Populate **Synonyms**:
   - Enter natural language terms from `${CATALOG}.${SCHEMA_SEM}.synonyms`, linking to the canonical object.
   - Include scope when applicable (e.g., `store` scoped to `dim_restaurant` → `restaurant_name`).
7. Add **Benchmarks**:
   - Import the prompts and expected patterns from `/notebooks/Benchmark_Questions.sql`.
   - For each benchmark, specify the expected SQL and answer pattern (range, ordering).
   - Validate each benchmark by running in the Space to establish pass criteria.
8. Review **Access Controls**:
   - Ensure only `${GROUP_ANALYSTS}` (and admins) have access. Analysts should rely on semantic views; deny direct gold access.
9. Publish the Space so analysts can discover it via Genie.

## (Optional) API Placeholders
When programmatic APIs become available, adapt the following pattern:
```bash
# Placeholder only: adjust once AI/BI Space APIs are published
curl -X POST https://<workspace-host>/api/2.0/genie/spaces \
  -H "Authorization: Bearer <PAT>" \
  -d '{
        "name": "Invoice Analytics Semantic Space",
        "warehouse_name": "serverless_sql_wh",
        "trusted_assets": ["cfa_demo.semantic_analytics.v_invoice_lines", "..."],
        "relationships": [...],
        "metrics": [...],
        "synonyms": [...],
        "benchmarks": [...]
      }'
```
Document the request/response once endpoints are formally released.

## Suggested Screenshots
Capture the following to embed within internal docs or Space description:
- Trusted assets selection screen showing only semantic views.
- Relationship graph linking `fact_invoice_line` to dimensions.
- Metrics configuration page for `invoice_amount`.
- Benchmark execution summary indicating pass/fail.

## Post-setup Validation
1. Trigger `/sql/09_validation.sql` via the warehouse to ensure metadata standards remain ≥95%.
2. Run `/notebooks/Benchmark_Questions.sql` inside Genie to confirm NLQ answers align with expected patterns.
3. Share the Space URL with `${GROUP_ANALYSTS}` and collect feedback for continuous improvement.
