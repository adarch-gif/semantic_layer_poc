# Run Book

1. Execute SQL scripts `/sql/01_schemas.sql` through `/sql/09_validation.sql` sequentially on `${WAREHOUSE_NAME}`, inserting `/sql/10_metric_views.sql` immediately after `/sql/07_semantic_views.sql` so Databricks Metrics surfaces are ready before governance locks down access.
2. Review `/sql/09_validation.sql` output and remediate any `FAIL` statuses.
3. Run `/tests/metadata_gap_report.sql` to ensure no outstanding metadata gaps.
4. Execute `/notebooks/Benchmark_Questions.sql` to confirm benchmark answers and populate Genie.
5. Configure the Genie Space using `/docs/GENIE_SPACE_SETUP.md` and grant `${GROUP_ANALYSTS}` access.
6. Deploy CI/CD automation via `/infra/databricks.yml`, then schedule `/infra/jobs.json` for ongoing validation.
