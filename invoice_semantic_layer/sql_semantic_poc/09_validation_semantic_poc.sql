-- Semantic PoC validation queries

USE CATALOG cfascdodev_primary;

-- 1. Column comment coverage (per table)
WITH target_tables AS (
  SELECT 'fact_invoice_line_semantic_poc' AS table_name UNION ALL
  SELECT 'dim_supplier_semantic_poc' UNION ALL
  SELECT 'dim_item_semantic_poc' UNION ALL
  SELECT 'dim_restaurant_semantic_poc' UNION ALL
  SELECT 'dim_dc_semantic_poc' UNION ALL
  SELECT 'dim_date_semantic_poc' UNION ALL
  SELECT 'relationships_semantic_poc' UNION ALL
  SELECT 'metrics_semantic_poc' UNION ALL
  SELECT 'synonyms_semantic_poc' UNION ALL
  SELECT 'v_invoice_lines_semantic_poc' UNION ALL
  SELECT 'v_invoice_supplier_semantic_poc' UNION ALL
  SELECT 'v_invoice_item_semantic_poc' UNION ALL
  SELECT 'v_invoice_restaurant_semantic_poc' UNION ALL
  SELECT 'v_invoice_dc_semantic_poc' UNION ALL
  SELECT 'v_invoice_calendar_semantic_poc'
), column_inventory AS (
  SELECT c.table_schema,
         c.table_name,
         c.column_name,
         c.comment,
         CASE WHEN c.comment IS NOT NULL AND c.comment <> '' THEN 1 ELSE 0 END AS has_comment
  FROM `cfascdodev_primary`.information_schema.columns c
  JOIN target_tables tt ON c.table_name = tt.table_name
  WHERE c.table_schema IN ('invoice_gold_semantic_poc','invoice_semantic_poc')
)
SELECT table_schema,
       table_name,
       SUM(has_comment) AS commented_columns,
       COUNT(*) AS total_columns,
       ROUND(100.0 * SUM(has_comment) / COUNT(*), 2) AS comment_pct,
       CASE WHEN ROUND(100.0 * SUM(has_comment) / COUNT(*), 2) >= 95 THEN 'PASS' ELSE 'FAIL' END AS comment_status
FROM column_inventory
GROUP BY table_schema, table_name
ORDER BY table_schema, table_name;

-- 1b. Overall column comment coverage
WITH target_tables AS (
  SELECT 'fact_invoice_line_semantic_poc' AS table_name UNION ALL
  SELECT 'dim_supplier_semantic_poc' UNION ALL
  SELECT 'dim_item_semantic_poc' UNION ALL
  SELECT 'dim_restaurant_semantic_poc' UNION ALL
  SELECT 'dim_dc_semantic_poc' UNION ALL
  SELECT 'dim_date_semantic_poc' UNION ALL
  SELECT 'relationships_semantic_poc' UNION ALL
  SELECT 'metrics_semantic_poc' UNION ALL
  SELECT 'synonyms_semantic_poc' UNION ALL
  SELECT 'v_invoice_lines_semantic_poc' UNION ALL
  SELECT 'v_invoice_supplier_semantic_poc' UNION ALL
  SELECT 'v_invoice_item_semantic_poc' UNION ALL
  SELECT 'v_invoice_restaurant_semantic_poc' UNION ALL
  SELECT 'v_invoice_dc_semantic_poc' UNION ALL
  SELECT 'v_invoice_calendar_semantic_poc'
), comment_summary AS (
  SELECT c.table_schema,
         c.table_name,
         SUM(CASE WHEN c.comment IS NOT NULL AND c.comment <> '' THEN 1 ELSE 0 END) AS commented_columns,
         COUNT(*) AS total_columns
  FROM `cfascdodev_primary`.information_schema.columns c
  JOIN target_tables tt ON c.table_name = tt.table_name
  WHERE c.table_schema IN ('invoice_gold_semantic_poc','invoice_semantic_poc')
  GROUP BY c.table_schema, c.table_name
)
SELECT 'OVERALL_COLUMN_COMMENT_COVERAGE' AS metric_name,
       ROUND(100.0 * SUM(commented_columns) / SUM(total_columns), 2) AS overall_comment_pct,
       CASE WHEN ROUND(100.0 * SUM(commented_columns) / SUM(total_columns), 2) >= 95 THEN 'PASS' ELSE 'FAIL' END AS status
FROM comment_summary;

-- 1c. Table comment coverage
WITH target_tables AS (
  SELECT 'fact_invoice_line_semantic_poc' AS table_name UNION ALL
  SELECT 'dim_supplier_semantic_poc' UNION ALL
  SELECT 'dim_item_semantic_poc' UNION ALL
  SELECT 'dim_restaurant_semantic_poc' UNION ALL
  SELECT 'dim_dc_semantic_poc' UNION ALL
  SELECT 'dim_date_semantic_poc' UNION ALL
  SELECT 'relationships_semantic_poc' UNION ALL
  SELECT 'metrics_semantic_poc' UNION ALL
  SELECT 'synonyms_semantic_poc' UNION ALL
  SELECT 'v_invoice_lines_semantic_poc' UNION ALL
  SELECT 'v_invoice_supplier_semantic_poc' UNION ALL
  SELECT 'v_invoice_item_semantic_poc' UNION ALL
  SELECT 'v_invoice_restaurant_semantic_poc' UNION ALL
  SELECT 'v_invoice_dc_semantic_poc' UNION ALL
  SELECT 'v_invoice_calendar_semantic_poc'
), table_inventory AS (
  SELECT t.table_schema,
         t.table_name,
         CASE WHEN t.comment IS NOT NULL AND t.comment <> '' THEN 1 ELSE 0 END AS has_comment
  FROM `cfascdodev_primary`.information_schema.tables t
  JOIN target_tables tt ON t.table_name = tt.table_name
  WHERE t.table_schema IN ('invoice_gold_semantic_poc','invoice_semantic_poc')
)
SELECT 'TABLE_COMMENT_COVERAGE' AS metric_name,
       ROUND(100.0 * SUM(has_comment) / COUNT(*), 2) AS table_comment_pct,
       CASE WHEN ROUND(100.0 * SUM(has_comment) / COUNT(*), 2) >= 95 THEN 'PASS' ELSE 'FAIL' END AS status
FROM table_inventory;

-- 2. Relationship reachability
WITH relationship_checks AS (
  SELECT
    r.from_table,
    r.from_column,
    r.to_table,
    r.to_column,
    r.relationship_type,
    r.join_type,
    r.confidence,
    CASE
      WHEN r.to_table = 'dim_supplier_semantic_poc' THEN (
        SELECT COUNT(*) FROM `cfascdodev_primary`.`invoice_gold_semantic_poc`.fact_invoice_line_semantic_poc f
        INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_supplier_semantic_poc s ON f.supplier_id = s.supplier_id
      )
      WHEN r.to_table = 'dim_item_semantic_poc' THEN (
        SELECT COUNT(*) FROM `cfascdodev_primary`.`invoice_gold_semantic_poc`.fact_invoice_line_semantic_poc f
        INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_item_semantic_poc i ON f.item_id = i.item_id
      )
      WHEN r.to_table = 'dim_restaurant_semantic_poc' THEN (
        SELECT COUNT(*) FROM `cfascdodev_primary`.`invoice_gold_semantic_poc`.fact_invoice_line_semantic_poc f
        INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_restaurant_semantic_poc r2 ON f.restaurant_id = r2.restaurant_id
      )
      WHEN r.to_table = 'dim_dc_semantic_poc' THEN (
        SELECT COUNT(*) FROM `cfascdodev_primary`.`invoice_gold_semantic_poc`.fact_invoice_line_semantic_poc f
        INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_dc_semantic_poc d ON f.dc_id = d.dc_id
      )
      WHEN r.to_table = 'dim_date_semantic_poc' THEN (
        SELECT COUNT(*) FROM `cfascdodev_primary`.`invoice_gold_semantic_poc`.fact_invoice_line_semantic_poc f
        INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_date_semantic_poc c ON f.invoice_date = c.date_key
      )
      ELSE NULL
    END AS join_row_count
  FROM `cfascdodev_primary`.`invoice_semantic_poc`.relationships_semantic_poc r
)
SELECT from_table,
       from_column,
       to_table,
       to_column,
       relationship_type,
       join_type,
       confidence,
       join_row_count,
       CASE WHEN join_row_count > 0 THEN 'PASS' ELSE 'FAIL' END AS join_status
FROM relationship_checks
ORDER BY from_table, to_table;

-- 3. Metric reconciliation
WITH base AS (
  SELECT
    SUM(coalesce(line_amount,0)) AS sum_net_line_amount,
    SUM(coalesce(freight_amount,0)) AS sum_freight,
    SUM(coalesce(tax_amount,0)) AS sum_tax,
    SUM(coalesce(discount_amount,0)) AS sum_discount,
    SUM(coalesce(quantity,0)) AS sum_quantity
  FROM `cfascdodev_primary`.`invoice_gold_semantic_poc`.fact_invoice_line_semantic_poc
), view_totals AS (
  SELECT
    SUM(invoice_amount) AS total_invoice_amount,
    SUM(net_line_amount) AS total_net_line_amount,
    SUM(freight_cost) AS total_freight_cost,
    SUM(tax_cost) AS total_tax_cost
  FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_lines_semantic_poc
)
SELECT
  base.sum_net_line_amount + base.sum_freight + base.sum_tax AS expected_total_spend,
  view_totals.total_invoice_amount AS semantic_total_spend,
  base.sum_discount AS total_discount,
  base.sum_quantity AS total_quantity,
  view_totals.total_freight_cost AS semantic_total_freight,
  view_totals.total_tax_cost AS semantic_total_tax,
  CASE
    WHEN ABS((base.sum_net_line_amount + base.sum_freight + base.sum_tax) - view_totals.total_invoice_amount) < 0.0001 THEN 'PASS'
    ELSE 'FAIL'
  END AS spend_reconciliation_status
FROM base
CROSS JOIN view_totals;

SELECT invoice_date,
       SUM(invoice_amount) AS total_invoice_amount,
       SUM(line_quantity) AS total_quantity
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_lines_semantic_poc
GROUP BY invoice_date
ORDER BY invoice_date;

SELECT supplier_name,
       SUM(invoice_amount) AS total_spend,
       SUM(freight_cost) AS total_freight,
       SUM(tax_cost) AS total_tax
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY total_spend DESC;

SELECT item_category,
       AVG(net_line_amount / NULLIF(line_quantity,0)) AS avg_unit_price,
       SUM(line_quantity) AS total_quantity,
       SUM(invoice_amount) AS total_invoice_amount
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_item_semantic_poc
GROUP BY item_category
ORDER BY total_invoice_amount DESC;
