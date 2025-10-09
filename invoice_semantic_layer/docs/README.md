# Invoice Analytics Semantic Layer

This repository scaffolds a production-ready semantic layer for invoice analytics on Databricks with Unity Catalog and Delta Lake. It provisions gold tables, semantic views, registries (relationships, metrics, synonyms), governance, validations, CI/CD automation, and Genie Space guidance.

## Assumptions
- Databricks SQL warehouse `${WAREHOUSE_NAME}` exists and has permission to access `${CATALOG}`.
- Unity Catalog is enabled and you have privileges to create catalogs/schemas, tables, views, and grants.
- Analysts are grouped in `${GROUP_ANALYSTS}`; they require semantic-only access.

## Deployment Order
1. `/sql/01_schemas.sql`
2. `/sql/02_gold_tables.sql`
3. `/sql/03_seed_data.sql`
4. `/sql/04_relationship_registry.sql`
5. `/sql/05_metrics_registry.sql`
6. `/sql/06_synonyms_registry.sql`
7. `/sql/07_semantic_views.sql`
8. `/sql/08_permissions.sql`
9. `/sql/09_validation.sql`

Use the Databricks SQL UI or automation via Databricks Asset Bundles (`/infra/databricks.yml`) to execute in sequence.

## Validation & Benchmarks
- `/sql/09_validation.sql` verifies metadata coverage, join reachability, and metric sanity.
- `/notebooks/Benchmark_Questions.sql` contains 15+ benchmark prompts with expected SQL and answer patterns for Genie regression testing.
- `/tests/metadata_gap_report.sql` highlights metadata gaps (missing comments, synonyms, metrics) for remediation.

## Genie Integration
- Trust only the semantic views residing in `${CATALOG}.${SCHEMA_SEM}`.
- Recreate relationships, metrics, synonyms, and benchmarks inside the Genie Space using `/docs/GENIE_SPACE_SETUP.md`.

## CI/CD
- `/infra/databricks.yml` defines a Databricks Asset Bundle to deploy all SQL scripts (ordered) and execute validation plus benchmarks.
- `/infra/jobs.json` provides a scheduled job template to run validations and benchmarks regularly.

## Next Steps / Evolutions
- Replace seed data with ingestion pipelines feeding the gold tables.
- Extend metrics registry with additional KPIs (e.g., margin) and attach data quality checks.
- Version-control Genie Space configuration once APIs are available.
- Integrate automated alerts when validation status fails or benchmark answers drift.
