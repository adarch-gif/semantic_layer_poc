# 11. Databricks UI Deployment Guide

This guide explains how to deploy the semantic PoC entirely through the Databricks workspace UI. It covers importing the repository, running the helper notebooks, and scheduling repeatable Jobs—no local CLI required.

## 1. Prerequisites
- Databricks workspace with Unity Catalog enabled and access to catalog `cfascdodev_primary`.
- Permission to create Repos, run notebooks, and manage Jobs.
- SQL warehouse `General Purpose` (or equivalent) available to your user.
- Service principal or user with `MANAGE` (or `OWNERSHIP`) on the catalog so the permissions script can run.
- Databricks Metrics (Preview) enabled if you plan to surface the new metric views inside the Metrics UI.

## 2. Import the Repository into Databricks Repos
1. In the Databricks UI, open **Repos** → **Add Repo**.
2. Enter the Git URL: `https://github.com/apurva-arch/semantic_layer_poc.git`.
3. Choose the branch `main` and click **Create**.
4. After cloning, the repo will appear at a path like `/Repos/<user>/semantic_layer_poc`.

> Tip: If you already have the repo, pull the latest changes from `main` before continuing.

## 3. Attach a Cluster / SQL Warehouse
1. Create or select a Databricks cluster with Python support for running notebooks (or attach a SQL warehouse if using `%sql`).
2. Ensure the cluster user has access to the `General Purpose` warehouse (the scripts use it by default). If you prefer a different warehouse, you can override it via widgets in the bundle notebook (section 4).

## 4. Deploy via the `run_bundle` Notebook
The repo contains helper notebooks that execute `infra/databricks.yml` directly from the workspace.

1. Navigate to `/Repos/<user>/semantic_layer_poc/invoice_semantic_layer/notebooks/run_bundle`.
2. At the top of the notebook, review the widgets:
   - **Bundle Directory** – defaults to `/Repos/<user>/semantic_layer_poc/invoice_semantic_layer/infra`.
   - **Catalog** – defaults to `cfascdodev_primary`.
   - **Gold Schema** – defaults to `invoice_gold_semantic_poc`.
   - **Semantic Schema** – defaults to `invoice_semantic_poc`.
   - **SQL Warehouse** – defaults to `General Purpose`.
3. Adjust any values if you plan to target another environment.
4. Run the entire notebook. It calls `run_bundle_internal`, which executes:
   - `databricks bundle validate`
   - `databricks bundle deploy` (with the widget values)
   - `databricks bundle run semantic_layer_deploy`
5. Monitor the cell output. Each CLI command prints the `%sh` invocation along with the Databricks bundle logs. Success indicates the PoC assets were deployed.

## 5. Verify the Deployment
- Open **Workflows** → **Jobs**. You should see a job named **Invoice Analytics Semantic PoC Deploy** (created by the bundle). Check that the latest run succeeded.
- In SQL Editor, verify that schemas `invoice_gold_semantic_poc` and `invoice_semantic_poc` now exist under catalog `cfascdodev_primary` with the expected tables and views.
- If Databricks Metrics is enabled, open the Metrics UI and confirm the metric views `mv_invoice_*_semantic_poc` are available for building dashboards.
- Optional: run `/Repos/<user>/semantic_layer_poc/invoice_semantic_layer/notebooks/Benchmark_Questions.sql` to validate Genie NLQ results.

## 6. Schedule via Databricks Jobs (Optional)
To keep the deployment automated, you can schedule the notebook itself:

1. Go to **Workflows** → **Jobs** → **Create Job**.
2. Name the job (e.g., *Semantic PoC Deployment Notebook*).
3. Add a notebook task pointing to `invoice_semantic_layer/notebooks/run_bundle`.
4. Assign the same cluster/warehouse used earlier.
5. Configure a schedule if you want regular refreshes. The notebook’s widgets can be pre-set in the task configuration.

Alternatively, schedule the existing job **Invoice Analytics Semantic PoC Deploy** created by the bundle to rerun on a cadence:
1. In **Jobs**, open **Invoice Analytics Semantic PoC Deploy**.
2. Click **Edit** → **Schedule** and set the desired frequency.

## 7. Running Table / View Validation
The bundle runs `sql_semantic_poc/09_validation_semantic_poc.sql` automatically, but you can re-run it manually:
1. Open a SQL notebook (or the Databricks SQL editor).
2. Execute the script from `sql_semantic_poc/09_validation_semantic_poc.sql` to confirm comment coverage, join reachability, and metric reconciliation remain in PASS status.

## 8. Updating Warehouse or Schemas
If you need to target different schemas or warehouse:
1. Re-open the `run_bundle` notebook.
2. Update the widgets with the new catalog/schema/warehouse values.
3. Re-run the notebook; the bundle will recreate objects in the new locations.

## 9. Troubleshooting
| Issue | Likely Cause | Resolution |
|-------|--------------|------------|
| **Permission Denied** when running the permissions script | User lacks `MANAGE` on catalog | Request catalog admin to grant the privilege or execute the script on your behalf. |
| CLI command not found inside notebook | Cluster image missing Databricks CLI | Install CLI via cluster init script or choose a DBR runtime that bundles it. |
| Job fails during `bundle run` | Upstream tasks encountered SQL errors | Review run logs in Workflows → Job → Run details, fix SQL issues, re-run notebook. |

## 10. Next Steps
- Share the resulting Genie Space (after following guide 07) with stakeholders.
- Schedule the job to run nightly for continuous validation.
- When promoting to other environments, adjust the widget values or create environment-specific Jobs using the same notebook.

This UI-focused workflow lets stakeholders deploy and manage the semantic layer without leaving the Databricks interface.
