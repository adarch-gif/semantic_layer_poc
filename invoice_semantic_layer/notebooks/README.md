# Notebooks Overview

| Notebook | Purpose | How to Use |
|----------|---------|------------|
| `Benchmark_Questions.sql` | Reference SQL queries that validate Genie NLQ against the PoC dataset. | Run after deployment to confirm answers; queries point directly to the PoC catalog and views. |
| `run_bundle` | Main entrypoint that invokes the Databricks Asset Bundle from a notebook. | Review/override the widgets (bundle directory, catalog, schemas, warehouse) and click Run; it calls `run_bundle_internal`. |
| `run_bundle_internal` | Executes `databricks bundle validate/deploy/run` using the CLI via `%sh`. | Called automatically by `run_bundle`; examine output to confirm success. |
| `sh_run` | Helper notebook that executes a single shell command (used by the bundle notebooks). | Not run directly; kept for modularity. |

Ensure the Databricks CLI is available on the cluster and authenticated before running the bundle notebooks.
