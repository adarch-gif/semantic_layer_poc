# Semantic Layer PoC Repository

All project assets live under invoice_semantic_layer/. Start with the documentation to understand the PoC structure.

Recommended reading:
1. [invoice_semantic_layer/docs/README.md](invoice_semantic_layer/docs/README.md) - master deployment guide and document map.
2. [invoice_semantic_layer/docs/01_ARCHITECTURE_OVERVIEW.md](invoice_semantic_layer/docs/01_ARCHITECTURE_OVERVIEW.md) - high-level architecture summary.
3. [invoice_semantic_layer/docs/10_DAB_DEPLOYMENT_README.md](invoice_semantic_layer/docs/10_DAB_DEPLOYMENT_README.md) - step-by-step instructions for executing infra/databricks.yml.
4. [invoice_semantic_layer/docs/11_UI_DEPLOYMENT_README.md](invoice_semantic_layer/docs/11_UI_DEPLOYMENT_README.md) - how to run the PoC directly from the Databricks UI.

For a quick run:
- SQL scripts: invoice_semantic_layer/sql_semantic_poc/
- Automation config: invoice_semantic_layer/infra/databricks.yml
- Databricks Metrics opt-in: invoice_semantic_layer/sql_semantic_poc/10_metric_views_semantic_poc.sql publishes metric views that surface in the Metrics UI once the feature is enabled in your workspace.
- Genie benchmark notebook: invoice_semantic_layer/notebooks/Benchmark_Questions.sql

Metric views (`mv_invoice_*_semantic_poc`) layer curated sums, counts, freight, tax, and discount measures on top of the semantic views. Once script 10 runs and Databricks Metrics (Preview) is enabled, stakeholders can build scorecards directly in the Metrics UI without additional SQL.

Every supporting document (architecture, deployment flow, Genie setup, runbook, etc.) is numbered in invoice_semantic_layer/docs/ for easy navigation.
