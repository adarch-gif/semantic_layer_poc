# Databricks Asset Bundle (DAB) Flow – Semantic PoC

## How to Run the Bundle
1. Install/upgrade the Databricks CLI (v0.205+):
   ```bash
databricks --version
```
2. Authenticate (`databricks auth login`) with a PAT or Azure/GCP auth flow.
3. From the repo root (`c:\invoice_semantic_layer`), validate the bundle:
   ```bash
cd infra
databricks bundle validate
```
4. Deploy and run the job defined in the bundle:
   ```bash
databricks bundle deploy
# or run the job immediately
databricks bundle run semantic_layer_deploy
```
5. Monitor results in the Databricks UI (Jobs > Invoice Analytics Semantic Deploy).

## How This Changes the Semantic Layer Approach
- **Automation**: All SQL scripts (schemas → views → metric views → validation) run in order without manual execution, reducing human error.
- **Repeatability**: Promoting PoC → dev → prod is as simple as adjusting bundle vars (catalog, schemas) and redeploying.
- **Traceability**: Deployment history and logs live in Databricks Jobs, aiding audits and troubleshooting.
- **Extensibility**: Adding new steps (e.g., additional validations, notebooks) is just another task entry.
- **Shift-left Governance**: Permissions, validation, and benchmarks gate the deployment within the pipeline, ensuring quality before Genie access.

## Step-by-Step: What `infra/databricks.yml` Does

### 1. Bundle & Variables
```yaml
bundle:
  name: invoice-analytics-semantic

vars:
  catalog: cfa_demo
  schema_gold: gold
  schema_sem: semantic_analytics
  group_analysts: cfa_sc_analysts
  warehouse_name: serverless_sql_wh
```
- Names the bundle and declares variables used later (catalog, schemas, group, warehouse).
- In a PoC or prod setting, you update the vars block (or override via CLI) to point at the correct catalog and warehouse.

### 2. Workspace Block
```yaml
workspace:
  host: ${workspace.host}
```
- Placeholder resolved at deployment; ensures the bundle targets the current workspace host (set via CLI profile).

### 3. Resources → Jobs → `semantic_layer_deploy`
- Defines a Databricks job with ordered tasks.
- `max_concurrent_runs: 1` ensures deployments don’t interleave.

Each task:
1. **`sql_01_schemas`** – runs `sql/01_schemas.sql` on the warehouse target, creating catalog/schemas.
2. **`sql_02_gold_tables`** – depends on task 1; creates the fact/dim tables.
3. **`sql_03_seed_data`** – loads seed dataset.
4. **`sql_04_relationships`** – creates the relationship registry.
5. **`sql_05_metrics`** – creates metrics registry.
6. **`sql_06_synonyms`** – creates synonyms registry.
7. **`sql_07_views`** – builds semantic views.
8. **`sql_10_metric_views`** – publishes metric views so Databricks Metrics can surface curated KPIs.
9. **`sql_08_permissions`** – applies governance grants.
10. **`sql_09_validation`** – runs validation queries.
11. **`notebook_benchmarks`** – executes `notebooks/Benchmark_Questions.sql` on a one-node cluster for NLQ regression checks.

- Dependency chain ensures proper order: views run only after registries exist, metric views after views, permissions after metric views, validations after permissions, notebook after validation. If any step fails, the job stops.

### 4. Artifacts Block
- Lists files (SQL, notebooks, docs) to package with the bundle so deployment has the correct scripts.

## Running in Your PoC Environment
- Extend the YAML (or use CLI overrides) to set `vars.catalog`, `vars.schema_gold`, etc., to `cfascdodev_primary`, `invoice_gold_semantic_poc`, `invoice_semantic_poc`, and `General Purpose` if you want to align with the PoC naming. Example override:
  ```bash
databricks bundle deploy --var catalog=cfascdodev_primary --var schema_gold=invoice_gold_semantic_poc --var schema_sem=invoice_semantic_poc --var warehouse_name="General Purpose"
```
- Ensure your account has MANAGE/OFFERS privileges to run these steps (especially for the permissions task).

By moving to this configuration-driven deployment, manual SQL execution is replaced with a controlled, repeatable pipeline that can be promoted across environments and integrated into CI/CD.

