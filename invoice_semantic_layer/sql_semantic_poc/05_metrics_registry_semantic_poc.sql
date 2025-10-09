-- Metrics registry for semantic PoC

USE CATALOG cfascdodev_primary;

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_semantic_poc`.metrics_semantic_poc (
  metric_name STRING COMMENT 'Canonical metric identifier exposed to Genie.',
  sql_expression STRING COMMENT 'SQL expression resolving the metric at the fact grain.',
  default_agg STRING COMMENT 'Default aggregation function Genie should apply.',
  time_grain STRING COMMENT 'Temporal dimension key used for time series analysis.',
  valid_dims ARRAY<STRING> COMMENT 'List of dimension tables that can safely slice this metric.',
  description STRING COMMENT 'Business description of the metric for analysts.',
  owner STRING COMMENT 'Primary owner or steward of the metric.',
  tags ARRAY<STRING> COMMENT 'Curated tags supporting discovery and governance.'
)
USING DELTA
COMMENT 'Semantic PoC metrics registry providing curated definitions for Genie.'
TBLPROPERTIES ('delta.autoOptimize.autoCompact' = 'true');

INSERT OVERWRITE `cfascdodev_primary`.`invoice_semantic_poc`.metrics_semantic_poc
SELECT * FROM VALUES
  ('invoice_amount','coalesce(line_amount,0) + coalesce(freight_amount,0) + coalesce(tax_amount,0)','sum','invoice_date',array('dim_supplier_semantic_poc','dim_item_semantic_poc','dim_restaurant_semantic_poc','dim_dc_semantic_poc','dim_date_semantic_poc'),'Total invoiced spend including freight and tax, net of discounts.','finops@databricks.com',array('finance','spend','invoice')),
  ('total_spend','coalesce(line_amount,0) + coalesce(freight_amount,0) + coalesce(tax_amount,0)','sum','invoice_date',array('dim_supplier_semantic_poc','dim_item_semantic_poc','dim_restaurant_semantic_poc','dim_dc_semantic_poc','dim_date_semantic_poc'),'Alias for overall invoice spend used in finance dashboards.','finops@databricks.com',array('finance','kpi')),
  ('avg_price','CASE WHEN coalesce(quantity,0) <> 0 THEN unit_price END','avg','invoice_date',array('dim_supplier_semantic_poc','dim_item_semantic_poc','dim_restaurant_semantic_poc','dim_dc_semantic_poc','dim_date_semantic_poc'),'Average unit price charged per line item.','sourcing@databricks.com',array('pricing','supplier')),
  ('line_count','1','sum','invoice_date',array('dim_supplier_semantic_poc','dim_item_semantic_poc','dim_restaurant_semantic_poc','dim_dc_semantic_poc','dim_date_semantic_poc'),'Count of invoice lines processed.','analytics@databricks.com',array('volume','quality')),
  ('freight_cost','coalesce(freight_amount,0)','sum','invoice_date',array('dim_supplier_semantic_poc','dim_item_semantic_poc','dim_restaurant_semantic_poc','dim_dc_semantic_poc','dim_date_semantic_poc'),'Total freight charges allocated to invoice lines.','logistics@databricks.com',array('logistics','cost')),
  ('tax_cost','coalesce(tax_amount,0)','sum','invoice_date',array('dim_supplier_semantic_poc','dim_item_semantic_poc','dim_restaurant_semantic_poc','dim_dc_semantic_poc','dim_date_semantic_poc'),'Total tax collected on invoice lines.','tax@databricks.com',array('finance','tax')),
  ('discount_total','coalesce(discount_amount,0)','sum','invoice_date',array('dim_supplier_semantic_poc','dim_item_semantic_poc','dim_restaurant_semantic_poc','dim_dc_semantic_poc','dim_date_semantic_poc'),'Total discounts applied at the line level (positive values).','finops@databricks.com',array('finance','discount')),
  ('quantity_total','coalesce(quantity,0)','sum','invoice_date',array('dim_supplier_semantic_poc','dim_item_semantic_poc','dim_restaurant_semantic_poc','dim_dc_semantic_poc','dim_date_semantic_poc'),'Total quantity purchased on invoice lines.','sourcing@databricks.com',array('volume','supply'))
AS v(metric_name,sql_expression,default_agg,time_grain,valid_dims,description,owner,tags);
