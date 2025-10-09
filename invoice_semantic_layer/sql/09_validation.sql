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

-- 1. Comment coverage validation (should be >=95% for tables and columns)
WITH table_inventory AS (
  SELECT table_catalog,
         table_schema,
         table_name,
         comment,
         CASE WHEN comment IS NOT NULL AND comment <> '''' THEN 1 ELSE 0 END AS has_comment
  FROM `${CATALOG}`.information_schema.tables
  WHERE table_schema IN (''${SCHEMA_GOLD}'',''${SCHEMA_SEM}'')
    AND table_name IN (
      ''fact_invoice_line'',''dim_supplier'',''dim_item'',''dim_restaurant'',''dim_dc'',''dim_date'',
      ''relationships'',''metrics'',''synonyms'',
      ''v_invoice_lines'',''v_invoice_supplier'',''v_invoice_item'',''v_invoice_restaurant'',''v_invoice_dc'',''v_invoice_calendar''
    )
),
column_inventory AS (
  SELECT table_schema,
         table_name,
         column_name,
         comment,
         CASE WHEN comment IS NOT NULL AND comment <> '''' THEN 1 ELSE 0 END AS has_comment
  FROM `${CATALOG}`.information_schema.columns
  WHERE table_schema IN (''${SCHEMA_GOLD}'',''${SCHEMA_SEM}'')
    AND table_name IN (
      ''fact_invoice_line'',''dim_supplier'',''dim_item'',''dim_restaurant'',''dim_dc'',''dim_date'',
      ''relationships'',''metrics'',''synonyms'',
      ''v_invoice_lines'',''v_invoice_supplier'',''v_invoice_item'',''v_invoice_restaurant'',''v_invoice_dc'',''v_invoice_calendar''
    )
),
comment_summary AS (
  SELECT table_schema,
         table_name,
         SUM(has_comment) AS commented_columns,
         COUNT(*) AS total_columns,
         ROUND(100.0 * SUM(has_comment) / COUNT(*), 2) AS comment_pct
  FROM column_inventory
  GROUP BY table_schema, table_name
)
SELECT table_schema,
       table_name,
       commented_columns,
       total_columns,
       comment_pct,
       CASE WHEN comment_pct >= 95 THEN ''PASS'' ELSE ''FAIL'' END AS comment_status
FROM comment_summary
ORDER BY table_schema, table_name;

SELECT ''OVERALL_COLUMN_COMMENT_COVERAGE'' AS metric_name,
       ROUND(100.0 * SUM(commented_columns) / SUM(total_columns), 2) AS overall_comment_pct,
       CASE WHEN ROUND(100.0 * SUM(commented_columns) / SUM(total_columns), 2) >= 95 THEN ''PASS'' ELSE ''FAIL'' END AS status
FROM comment_summary;

SELECT ''TABLE_COMMENT_COVERAGE'' AS metric_name,
       ROUND(100.0 * SUM(has_comment) / COUNT(*), 2) AS table_comment_pct,
       CASE WHEN ROUND(100.0 * SUM(has_comment) / COUNT(*), 2) >= 95 THEN ''PASS'' ELSE ''FAIL'' END AS status
FROM table_inventory;

-- 2. Relationship reachability validation driven by relationship registry
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
      WHEN r.to_table = ''dim_supplier'' THEN (
        SELECT COUNT(*) FROM `${CATALOG}`.`${SCHEMA_GOLD}`.fact_invoice_line f
        INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_supplier s ON f.supplier_id = s.supplier_id
      )
      WHEN r.to_table = ''dim_item'' THEN (
        SELECT COUNT(*) FROM `${CATALOG}`.`${SCHEMA_GOLD}`.fact_invoice_line f
        INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_item i ON f.item_id = i.item_id
      )
      WHEN r.to_table = ''dim_restaurant'' THEN (
        SELECT COUNT(*) FROM `${CATALOG}`.`${SCHEMA_GOLD}`.fact_invoice_line f
        INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_restaurant r2 ON f.restaurant_id = r2.restaurant_id
      )
      WHEN r.to_table = ''dim_dc'' THEN (
        SELECT COUNT(*) FROM `${CATALOG}`.`${SCHEMA_GOLD}`.fact_invoice_line f
        INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_dc d ON f.dc_id = d.dc_id
      )
      WHEN r.to_table = ''dim_date'' THEN (
        SELECT COUNT(*) FROM `${CATALOG}`.`${SCHEMA_GOLD}`.fact_invoice_line f
        INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_date c ON f.invoice_date = c.date_key
      )
      ELSE NULL
    END AS join_row_count
  FROM `${CATALOG}`.`${SCHEMA_SEM}`.relationships r
)
SELECT from_table,
       from_column,
       to_table,
       to_column,
       relationship_type,
       join_type,
       confidence,
       join_row_count,
       CASE WHEN join_row_count > 0 THEN ''PASS'' ELSE ''FAIL'' END AS join_status
FROM relationship_checks
ORDER BY from_table, to_table;

-- 3. Metric sanity checks using fact and semantic views
WITH base AS (
  SELECT
    SUM(coalesce(line_amount,0)) AS sum_net_line_amount,
    SUM(coalesce(freight_amount,0)) AS sum_freight,
    SUM(coalesce(tax_amount,0)) AS sum_tax,
    SUM(coalesce(discount_amount,0)) AS sum_discount,
    SUM(coalesce(quantity,0)) AS sum_quantity
  FROM `${CATALOG}`.`${SCHEMA_GOLD}`.fact_invoice_line
),
view_totals AS (
  SELECT
    SUM(invoice_amount) AS total_invoice_amount,
    SUM(net_line_amount) AS total_net_line_amount,
    SUM(freight_cost) AS total_freight_cost,
    SUM(tax_cost) AS total_tax_cost
  FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines
)
SELECT
  base.sum_net_line_amount + base.sum_freight + base.sum_tax AS expected_total_spend,
  view_totals.total_invoice_amount AS semantic_total_spend,
  base.sum_discount AS total_discount,
  base.sum_quantity AS total_quantity,
  view_totals.total_freight_cost AS semantic_total_freight,
  view_totals.total_tax_cost AS semantic_total_tax,
  CASE
    WHEN ABS((base.sum_net_line_amount + base.sum_freight + base.sum_tax) - view_totals.total_invoice_amount) < 0.0001 THEN ''PASS''
    ELSE ''FAIL''
  END AS spend_reconciliation_status
FROM base
CROSS JOIN view_totals;

-- Metric example outputs for Genie benchmarking
SELECT invoice_date,
       SUM(invoice_amount) AS total_invoice_amount,
       SUM(line_quantity) AS total_quantity
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines
GROUP BY invoice_date
ORDER BY invoice_date;

SELECT supplier_name,
       SUM(invoice_amount) AS total_spend,
       SUM(freight_cost) AS total_freight,
       SUM(tax_cost) AS total_tax
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier
GROUP BY supplier_name
ORDER BY total_spend DESC;

SELECT item_category,
       AVG(unit_price) AS avg_unit_price,
       SUM(line_quantity) AS total_quantity,
       SUM(invoice_amount) AS total_invoice_amount
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item
GROUP BY item_category
ORDER BY total_invoice_amount DESC;
