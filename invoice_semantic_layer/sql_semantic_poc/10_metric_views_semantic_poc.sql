-- Metric views built on top of the semantic PoC perspectives.

USE CATALOG cfascdodev_primary;

CREATE OR REPLACE METRIC VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_supplier_semantic_poc
COMMENT 'Metrics for supplier spend, discounts, and logistics costs sourced from the semantic supplier view.'
MEASURES (
  total_net_spend DECIMAL(38,6) DEFAULT SUM(coalesce(net_line_amount, 0)),
  total_invoice_amount DECIMAL(38,6) DEFAULT SUM(coalesce(invoice_amount, 0)),
  total_line_quantity DECIMAL(38,6) DEFAULT SUM(coalesce(line_quantity, 0)),
  total_freight_cost DECIMAL(38,6) DEFAULT SUM(coalesce(freight_cost, 0)),
  total_tax_cost DECIMAL(38,6) DEFAULT SUM(coalesce(tax_cost, 0)),
  total_discount_amount DECIMAL(38,6) DEFAULT SUM(coalesce(discount_amount, 0)),
  invoice_line_count BIGINT DEFAULT COUNT(*)
)
DIMENSIONS (
  supplier_id STRING,
  supplier_name STRING,
  supplier_category STRING,
  supplier_country STRING,
  supplier_active_flag BOOLEAN,
  currency_code STRING
)
TIMESTAMP invoice_date
AS
SELECT
  CAST(invoice_date AS TIMESTAMP) AS invoice_date,
  supplier_id,
  supplier_name,
  supplier_category,
  supplier_country,
  supplier_active_flag,
  currency_code,
  net_line_amount,
  invoice_amount,
  line_quantity,
  freight_cost,
  tax_cost,
  discount_amount
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_supplier_semantic_poc;

CREATE OR REPLACE METRIC VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_item_semantic_poc
COMMENT 'Metrics for item-level performance and spend sourced from the semantic item view.'
MEASURES (
  total_net_spend DECIMAL(38,6) DEFAULT SUM(coalesce(net_line_amount, 0)),
  total_invoice_amount DECIMAL(38,6) DEFAULT SUM(coalesce(invoice_amount, 0)),
  total_line_quantity DECIMAL(38,6) DEFAULT SUM(coalesce(line_quantity, 0)),
  total_discount_amount DECIMAL(38,6) DEFAULT SUM(coalesce(discount_amount, 0)),
  total_freight_cost DECIMAL(38,6) DEFAULT SUM(coalesce(freight_cost, 0)),
  total_tax_cost DECIMAL(38,6) DEFAULT SUM(coalesce(tax_cost, 0)),
  invoice_line_count BIGINT DEFAULT COUNT(*)
)
DIMENSIONS (
  item_id STRING,
  item_name STRING,
  item_category STRING,
  uom STRING,
  brand STRING,
  item_active_flag BOOLEAN,
  currency_code STRING
)
TIMESTAMP invoice_date
AS
SELECT
  CAST(invoice_date AS TIMESTAMP) AS invoice_date,
  item_id,
  item_name,
  item_category,
  uom,
  brand,
  item_active_flag,
  currency_code,
  net_line_amount,
  invoice_amount,
  line_quantity,
  discount_amount,
  freight_cost,
  tax_cost
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_item_semantic_poc;

CREATE OR REPLACE METRIC VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_restaurant_semantic_poc
COMMENT 'Metrics for restaurant spend and activity sourced from the semantic restaurant view.'
MEASURES (
  total_net_spend DECIMAL(38,6) DEFAULT SUM(coalesce(net_line_amount, 0)),
  total_invoice_amount DECIMAL(38,6) DEFAULT SUM(coalesce(invoice_amount, 0)),
  total_line_quantity DECIMAL(38,6) DEFAULT SUM(coalesce(line_quantity, 0)),
  total_freight_cost DECIMAL(38,6) DEFAULT SUM(coalesce(freight_cost, 0)),
  total_tax_cost DECIMAL(38,6) DEFAULT SUM(coalesce(tax_cost, 0)),
  total_discount_amount DECIMAL(38,6) DEFAULT SUM(coalesce(discount_amount, 0)),
  invoice_line_count BIGINT DEFAULT COUNT(*)
)
DIMENSIONS (
  restaurant_id STRING,
  restaurant_name STRING,
  location_number STRING,
  restaurant_region STRING,
  restaurant_timezone STRING,
  restaurant_active_flag BOOLEAN,
  currency_code STRING
)
TIMESTAMP invoice_date
AS
SELECT
  CAST(invoice_date AS TIMESTAMP) AS invoice_date,
  restaurant_id,
  restaurant_name,
  location_number,
  restaurant_region,
  restaurant_timezone,
  restaurant_active_flag,
  currency_code,
  net_line_amount,
  invoice_amount,
  line_quantity,
  freight_cost,
  tax_cost,
  discount_amount
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_restaurant_semantic_poc;

CREATE OR REPLACE METRIC VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_dc_semantic_poc
COMMENT 'Metrics for distribution center spend and logistics sourced from the semantic DC view.'
MEASURES (
  total_net_spend DECIMAL(38,6) DEFAULT SUM(coalesce(net_line_amount, 0)),
  total_invoice_amount DECIMAL(38,6) DEFAULT SUM(coalesce(invoice_amount, 0)),
  total_line_quantity DECIMAL(38,6) DEFAULT SUM(coalesce(line_quantity, 0)),
  total_freight_cost DECIMAL(38,6) DEFAULT SUM(coalesce(freight_cost, 0)),
  total_tax_cost DECIMAL(38,6) DEFAULT SUM(coalesce(tax_cost, 0)),
  total_discount_amount DECIMAL(38,6) DEFAULT SUM(coalesce(discount_amount, 0)),
  invoice_line_count BIGINT DEFAULT COUNT(*)
)
DIMENSIONS (
  dc_id STRING,
  dc_name STRING,
  dc_code STRING,
  dc_region STRING,
  dc_timezone STRING,
  dc_active_flag BOOLEAN,
  currency_code STRING
)
TIMESTAMP invoice_date
AS
SELECT
  CAST(invoice_date AS TIMESTAMP) AS invoice_date,
  dc_id,
  dc_name,
  dc_code,
  dc_region,
  dc_timezone,
  dc_active_flag,
  currency_code,
  net_line_amount,
  invoice_amount,
  line_quantity,
  freight_cost,
  tax_cost,
  discount_amount
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_dc_semantic_poc;

CREATE OR REPLACE METRIC VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_calendar_semantic_poc
COMMENT 'Metrics for calendar and fiscal trend analysis sourced from the semantic calendar view.'
MEASURES (
  total_net_spend DECIMAL(38,6) DEFAULT SUM(coalesce(net_line_amount, 0)),
  total_invoice_amount DECIMAL(38,6) DEFAULT SUM(coalesce(invoice_amount, 0)),
  total_line_quantity DECIMAL(38,6) DEFAULT SUM(coalesce(line_quantity, 0)),
  total_freight_cost DECIMAL(38,6) DEFAULT SUM(coalesce(freight_cost, 0)),
  total_tax_cost DECIMAL(38,6) DEFAULT SUM(coalesce(tax_cost, 0)),
  total_discount_amount DECIMAL(38,6) DEFAULT SUM(coalesce(discount_amount, 0)),
  invoice_line_count BIGINT DEFAULT COUNT(*)
)
DIMENSIONS (
  date_key DATE,
  calendar_year INT,
  calendar_quarter INT,
  calendar_month INT,
  calendar_week INT,
  calendar_day INT,
  is_weekend BOOLEAN,
  fiscal_year INT,
  fiscal_period STRING,
  currency_code STRING
)
TIMESTAMP invoice_date
AS
SELECT
  CAST(invoice_date AS TIMESTAMP) AS invoice_date,
  date_key,
  calendar_year,
  calendar_quarter,
  calendar_month,
  calendar_week,
  calendar_day,
  is_weekend,
  fiscal_year,
  fiscal_period,
  currency_code,
  net_line_amount,
  invoice_amount,
  line_quantity,
  freight_cost,
  tax_cost,
  discount_amount
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_calendar_semantic_poc;
