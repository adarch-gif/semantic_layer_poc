# Databricks.yml Deployment Guide

## Updated Prompt
Provide a detailed, step-by-step guide so stakeholders can deploy the semantic PoC using `infra/databricks.yml`—including prerequisites, CLI setup, override options, running from notebooks or Jobs, and validation of results.

## 1. Overview
`infra/databricks.yml` is a Databricks Asset Bundle (DAB) configuration. When executed, it sequentially runs all PoC SQL scripts (schemas → tables → registries → views → metric views → permissions → validation) and then the benchmark notebook.

## 2. Prerequisites
- Databricks workspace with Unity Catalog enabled.
- Access rights: ability to `MANAGE`/`OWN` catalog `cfascdodev_primary`, create schemas, and run Jobs.
- Databricks SQL warehouse `General Purpose` (or override).
- Databricks CLI v0.205+ installed and authenticated (`databricks auth login`).
- Databricks Metrics (Preview) enabled in the workspace so metric views appear in the Metrics browser after deployment.
- Repo `semantic_layer_poc` cloned locally or via workspace Git (paths in this guide assume local clone).

## 3. Directory Structure
```
invoice_semantic_layer/
  infra/
    databricks.yml
  sql_semantic_poc/
    01_schemas_semantic_poc.sql
    ...
  notebooks/
    Benchmark_Questions.sql
    run_bundle (optional execution helper)
```

## 4. Deploy via Databricks CLI
1. Open terminal; navigate to `invoice_semantic_layer/infra`.
2. Validate configuration:
   ```bash
   databricks bundle validate
   ```
3. Deploy with PoC variables (override defaults):
   ```bash
   databricks bundle deploy \
     --var catalog=cfascdodev_primary \
     --var schema_gold=invoice_gold_semantic_poc \
     --var schema_sem=invoice_semantic_poc \
     --var warehouse_name="General Purpose"
   ```
4. Run the job defined in the bundle:
   ```bash
   databricks bundle run semantic_layer_deploy
   ```
5. Monitor output in terminal; also check Databricks UI → Workflows → Jobs → “Invoice Analytics Semantic PoC Deploy”.

## 5. Deploy from a Databricks Notebook
Use the helper notebooks in `notebooks/`:
1. Import/attach repo to workspace.
2. Open `notebooks/run_bundle`.
3. Adjust widgets (bundle path defaults to repo `/infra`) if needed.
4. Run the notebook. It will call `run_bundle_internal`, which executes:
   - `databricks bundle validate`
   - `databricks bundle deploy` with widget values
   - `databricks bundle run semantic_layer_deploy`

(Ensure the CLI is available and authenticated on the cluster.)

## 6. Deploy via Databricks Job
1. Workspace → Workflows → Jobs → Create Job.
2. Create a notebook task pointing to `notebooks/run_bundle` (or inline `%sh` commands).
3. Configure cluster/permissions.
4. Run the job to execute the bundle automatically.

## 7. Post-Deployment Validation
- Check Job run: all tasks (schemas, tables, registries, views, metric views, permissions, validation, benchmark notebook) should succeed.
- Review validation output in `sql_semantic_poc/09_validation_semantic_poc.sql` (stored in job logs) for PASS statuses.
- Optional: rerun `notebooks/Benchmark_Questions.sql` to confirm NLQ answers against the PoC dataset.

## 8. Overrides and Promotion
- Override variables (`--var`) for other environments (e.g., dev/test/prod) to change catalog, schemas, warehouse.
- Keep the same bundle but point to environment-specific assets; run `databricks bundle deploy/run` for each environment.

## 9. Troubleshooting
- **Permission Denied**: ensure your principal has `MANAGE` on the catalog, or ask an admin.
- **CLI Authentication**: rerun `databricks auth login` if the bundle fails early.
- **Warehouse errors**: update `--var warehouse_name` to a warehouse you can access.
- **Bundle path**: if repo path differs, adjust `bundle_dir` (widgets or CLI working directory).

## 10. Related Documentation
- [04_DEPLOYMENT_WALKTHROUGH.md](../docs/04_DEPLOYMENT_WALKTHROUGH.md)
- [08_DAB_FLOW.md](../docs/08_DAB_FLOW.md)
- [06_SQL_RUNBOOK.md](../docs/06_SQL_RUNBOOK.md)
- [07_GENIE_SPACE_SETUP.md](../docs/07_GENIE_SPACE_SETUP.md)

This README can be handed directly to stakeholders who prefer configuration-driven deployment over individual SQL scripts.
