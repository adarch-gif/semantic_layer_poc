-- Environment placeholders
SET CATALOG = ''cfa_demo'';
SET SCHEMA_GOLD = ''gold'';
SET SCHEMA_SEM = ''semantic_analytics'';
SET GROUP_ANALYSTS = ''cfa_sc_analysts'';
SET WAREHOUSE_NAME = ''serverless_sql_wh'';

SELECT ''${CATALOG}'' AS catalog,
       ''${SCHEMA_GOLD}'' AS schema_gold,
       ''${SCHEMA_SEM}'' AS schema_sem,
       ''${GROUP_ANALYSTS}'' AS group_analysts,
       ''${WAREHOUSE_NAME}'' AS warehouse_name;

USE CATALOG `${CATALOG}`;

WITH column_inventory AS (
  SELECT table_schema,
         table_name,
         column_name,
         comment,
         LOWER(
           CASE
             WHEN LOCATE(''.'', column_name) > 0 THEN column_name
             ELSE concat(table_name,''.'',column_name)
           END
         ) AS canonical_column_key
  FROM `${CATALOG}`.information_schema.columns
  WHERE table_schema IN (''${SCHEMA_GOLD}'',''${SCHEMA_SEM}'')
),
column_synonyms AS (
  SELECT LOWER(
           CASE
             WHEN scope_table IS NOT NULL AND scope_table <> '''' THEN concat(scope_table,''.'',split_part(canonical_name,''.'',-1))
             ELSE canonical_name
           END
         ) AS canonical_column_key
  FROM `${CATALOG}`.`${SCHEMA_SEM}`.synonyms
  WHERE object_type = ''column''
),
metrics_registry AS (
  SELECT LOWER(metric_name) AS metric_name
  FROM `${CATALOG}`.`${SCHEMA_SEM}`.metrics
),
metric_synonyms AS (
  SELECT LOWER(canonical_name) AS canonical_metric
  FROM `${CATALOG}`.`${SCHEMA_SEM}`.synonyms
  WHERE object_type = ''metric''
)
SELECT ''COLUMN_METADATA'' AS record_type,
       table_schema,
       table_name,
       column_name,
       CASE WHEN comment IS NULL OR comment = '''' THEN ''MISSING_COMMENT'' ELSE ''COMMENT_OK'' END AS comment_status,
       CASE WHEN cs.canonical_column_key IS NULL THEN ''MISSING_SYNONYM'' ELSE ''SYNONYM_OK'' END AS synonym_status
FROM column_inventory ci
LEFT JOIN column_synonyms cs
  ON ci.canonical_column_key = cs.canonical_column_key
WHERE (comment IS NULL OR comment = '''' OR cs.canonical_column_key IS NULL)
UNION ALL
SELECT ''METRIC_METADATA'' AS record_type,
       ''${SCHEMA_SEM}'' AS table_schema,
       ''metrics'' AS table_name,
       metric_name AS column_name,
       CASE WHEN metric_name IS NULL THEN ''MISSING'' ELSE ''DEFINED'' END AS comment_status,
       CASE WHEN ms.canonical_metric IS NULL THEN ''MISSING_SYNONYM'' ELSE ''SYNONYM_OK'' END AS synonym_status
FROM metrics_registry mr
LEFT JOIN metric_synonyms ms
  ON mr.metric_name = ms.canonical_metric
WHERE ms.canonical_metric IS NULL
ORDER BY record_type, table_name, column_name;
