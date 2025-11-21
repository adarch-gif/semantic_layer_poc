# Semantic Layer PoC Repository

All project assets live under invoice_semantic_layer/. Start with the documentation to understand the PoC structure.

## 🚀 Quick Start

**New to this POC? START HERE:** [invoice_semantic_layer/docs/00_README_START_HERE.md](invoice_semantic_layer/docs/00_README_START_HERE.md)

This master hub contains:
- Complete documentation index (18 numbered guides: 00-17)
- Role-based navigation paths (Executives, Analysts, Engineers, DevOps)
- Learning paths by experience level
- Quick deployment instructions

## 📖 Key Documentation

1. [00_README_START_HERE.md](invoice_semantic_layer/docs/00_README_START_HERE.md) - **Master navigation hub** - Complete documentation index
2. [01_QUICK_START_GUIDE.md](invoice_semantic_layer/docs/01_QUICK_START_GUIDE.md) - 5-minute quickstart for deployment and querying
3. [03_ARCHITECTURE_OVERVIEW.md](invoice_semantic_layer/docs/03_ARCHITECTURE_OVERVIEW.md) - High-level architecture summary
4. [10_DAB_DEPLOYMENT_README.md](invoice_semantic_layer/docs/10_DAB_DEPLOYMENT_README.md) - Automated deployment via Databricks Asset Bundle
5. [09_UI_DEPLOYMENT_README.md](invoice_semantic_layer/docs/09_UI_DEPLOYMENT_README.md) - Manual deployment via Databricks UI
6. [13_METRIC_VIEWS_YAML_GUIDE.md](invoice_semantic_layer/docs/13_METRIC_VIEWS_YAML_GUIDE.md) - YAML metric view authoring guide

## 📂 Repository Structure

- **SQL scripts**: invoice_semantic_layer/sql_semantic_poc/
- **Automation config**: invoice_semantic_layer/infra/databricks.yml
- **Databricks Metrics**: invoice_semantic_layer/sql_semantic_poc/10_metric_views_semantic_poc.sql publishes metric views that surface in the Metrics UI once the feature is enabled in your workspace
- **Genie benchmark notebook**: invoice_semantic_layer/notebooks/Benchmark_Questions.sql

Metric views (`mv_invoice_*_semantic_poc`) layer curated sums, counts, freight, tax, and discount measures on top of the semantic views. Once script 10 runs and Databricks Metrics (Preview) is enabled, stakeholders can build scorecards directly in the Metrics UI without additional SQL.

Every supporting document (architecture, deployment flow, Genie setup, runbook, etc.) is numbered in invoice_semantic_layer/docs/ for easy navigation (00-17 sequential order).
