-- Semantic PoC views

USE CATALOG cfascdodev_primary;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_lines_semantic_poc
COMMENT 'Semantic PoC view of invoice lines with curated measures and keys.'
AS
SELECT
  f.invoice_id AS invoice_id,
  f.line_id AS invoice_line_id,
  f.invoice_date AS invoice_date,
  f.supplier_id AS supplier_id,
  f.restaurant_id AS restaurant_id,
  f.dc_id AS distribution_center_id,
  f.item_id AS item_id,
  f.quantity AS line_quantity,
  f.unit_price AS unit_price,
  (coalesce(f.quantity,0) * coalesce(f.unit_price,0)) AS gross_line_amount,
  f.discount_amount AS discount_amount,
  f.line_amount AS net_line_amount,
  (f.line_amount + coalesce(f.freight_amount,0) + coalesce(f.tax_amount,0)) AS invoice_amount,
  f.freight_amount AS freight_cost,
  f.tax_amount AS tax_cost,
  f.currency_code AS currency_code
FROM `cfascdodev_primary`.`invoice_gold_semantic_poc`.fact_invoice_line_semantic_poc f;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_supplier_semantic_poc
COMMENT 'Semantic PoC invoice line measures with supplier attributes for spend analysis.'
AS
SELECT
  l.invoice_id,
  l.invoice_line_id,
  l.invoice_date,
  l.supplier_id,
  s.supplier_name,
  s.supplier_category,
  s.country_code AS supplier_country,
  s.active_flag AS supplier_active_flag,
  l.line_quantity,
  l.net_line_amount,
  l.invoice_amount,
  l.freight_cost,
  l.tax_cost,
  l.discount_amount,
  l.currency_code
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_lines_semantic_poc l
INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_supplier_semantic_poc s
  ON l.supplier_id = s.supplier_id;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_item_semantic_poc
COMMENT 'Semantic PoC invoice line measures with item attributes for product performance analysis.'
AS
SELECT
  l.invoice_id,
  l.invoice_line_id,
  l.invoice_date,
  l.item_id,
  i.item_name,
  i.item_category,
  i.uom,
  i.brand,
  i.active_flag AS item_active_flag,
  l.line_quantity,
  l.net_line_amount,
  l.invoice_amount,
  l.freight_cost,
  l.tax_cost,
  l.discount_amount,
  l.currency_code
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_lines_semantic_poc l
INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_item_semantic_poc i
  ON l.item_id = i.item_id;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_restaurant_semantic_poc
COMMENT 'Semantic PoC invoice line measures with restaurant attributes for operator insights.'
AS
SELECT
  l.invoice_id,
  l.invoice_line_id,
  l.invoice_date,
  l.restaurant_id,
  r.restaurant_name,
  r.location_number,
  r.region AS restaurant_region,
  r.timezone AS restaurant_timezone,
  r.open_date,
  r.active_flag AS restaurant_active_flag,
  l.line_quantity,
  l.net_line_amount,
  l.invoice_amount,
  l.freight_cost,
  l.tax_cost,
  l.discount_amount,
  l.currency_code
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_lines_semantic_poc l
INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_restaurant_semantic_poc r
  ON l.restaurant_id = r.restaurant_id;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_dc_semantic_poc
COMMENT 'Semantic PoC invoice line measures with distribution center attributes.'
AS
SELECT
  l.invoice_id,
  l.invoice_line_id,
  l.invoice_date,
  l.distribution_center_id AS dc_id,
  d.dc_name,
  d.dc_code,
  d.region AS dc_region,
  d.timezone AS dc_timezone,
  d.active_flag AS dc_active_flag,
  l.line_quantity,
  l.net_line_amount,
  l.invoice_amount,
  l.freight_cost,
  l.tax_cost,
  l.discount_amount,
  l.currency_code
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_lines_semantic_poc l
INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_dc_semantic_poc d
  ON l.distribution_center_id = d.dc_id;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_calendar_semantic_poc
COMMENT 'Semantic PoC invoice line measures joined to the corporate calendar for time intelligence.'
AS
SELECT
  l.invoice_id,
  l.invoice_line_id,
  l.invoice_date,
  c.date_key,
  c.year AS calendar_year,
  c.quarter AS calendar_quarter,
  c.month AS calendar_month,
  c.week AS calendar_week,
  c.day AS calendar_day,
  c.is_weekend,
  c.fiscal_year,
  c.fiscal_period,
  l.line_quantity,
  l.net_line_amount,
  l.invoice_amount,
  l.freight_cost,
  l.tax_cost,
  l.discount_amount,
  l.currency_code
FROM `cfascdodev_primary`.`invoice_semantic_poc`.v_invoice_lines_semantic_poc l
INNER JOIN `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_date_semantic_poc c
  ON l.invoice_date = c.date_key;
