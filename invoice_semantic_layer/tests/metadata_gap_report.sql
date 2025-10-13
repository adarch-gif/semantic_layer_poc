-- Metadata gap report for semantic PoC

USE CATALOG cfascdodev_primary;

WITH column_inventory AS (
  SELECT table_schema,
         table_name,
         column_name,
         comment,
         CASE WHEN comment IS NOT NULL AND comment <> '' THEN 1 ELSE 0 END AS has_comment
  FROM `cfascdodev_primary`.information_schema.columns
  WHERE table_schema IN ('invoice_gold_semantic_poc','invoice_semantic_poc')
), column_synonyms AS (
  SELECT LOWER(
           CASE
             WHEN scope_table IS NOT NULL AND scope_table <> '' THEN concat(scope_table,'.',split_part(canonical_name,'.',-1))
             ELSE canonical_name
           END
         ) AS canonical_column_key
  FROM `cfascdodev_primary`.`invoice_semantic_poc`.synonyms_semantic_poc
  WHERE object_type = 'column'
), metrics_registry AS (
  SELECT LOWER(metric_name) AS metric_name
  FROM `cfascdodev_primary`.`invoice_semantic_poc`.metrics_semantic_poc
), metric_synonyms AS (
  SELECT LOWER(canonical_name) AS canonical_metric
  FROM `cfascdodev_primary`.`invoice_semantic_poc`.synonyms_semantic_poc
  WHERE object_type = 'metric'
)
SELECT 'COLUMN_METADATA' AS record_type,
       table_schema,
       table_name,
       column_name,
       CASE WHEN has_comment = 1 THEN 'COMMENT_OK' ELSE 'MISSING_COMMENT' END AS comment_status,
       CASE WHEN cs.canonical_column_key IS NULL THEN 'MISSING_SYNONYM' ELSE 'SYNONYM_OK' END AS synonym_status
FROM column_inventory ci
LEFT JOIN column_synonyms cs
  ON LOWER(concat(table_name,'.',column_name)) = cs.canonical_column_key
WHERE has_comment = 0 OR cs.canonical_column_key IS NULL
UNION ALL
SELECT 'METRIC_METADATA' AS record_type,
       'invoice_semantic_poc' AS table_schema,
       'metrics_semantic_poc' AS table_name,
       metric_name AS column_name,
       'DEFINED' AS comment_status,
       CASE WHEN ms.canonical_metric IS NULL THEN 'MISSING_SYNONYM' ELSE 'SYNONYM_OK' END AS synonym_status
FROM metrics_registry mr
LEFT JOIN metric_synonyms ms
  ON mr.metric_name = ms.canonical_metric
WHERE ms.canonical_metric IS NULL
ORDER BY record_type, table_name, column_name;
