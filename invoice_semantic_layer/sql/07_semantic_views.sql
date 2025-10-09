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

CREATE OR REPLACE VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines
COMMENT ''Business-friendly view of invoice lines with curated measures and keys.''
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
FROM `${CATALOG}`.`${SCHEMA_GOLD}`.fact_invoice_line f;

ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN invoice_id COMMENT ''Invoice document identifier provided by the supplier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN invoice_line_id COMMENT ''Unique line identifier within the invoice document.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN invoice_date COMMENT ''Date the invoice line is effective for reporting and time slicing.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN supplier_id COMMENT ''Supplier key used to join to supplier attributes.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN restaurant_id COMMENT ''Restaurant key used to join to restaurant attributes.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN distribution_center_id COMMENT ''Distribution center key used to join to fulfillment attributes.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN item_id COMMENT ''Item key used to join to product attributes.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN line_quantity COMMENT ''Quantity purchased on the invoice line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN unit_price COMMENT ''Unit price charged by the supplier for this line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN gross_line_amount COMMENT ''Merchandise amount before applying any discounts.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN discount_amount COMMENT ''Discount applied to the line (positive reduces spend).'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN net_line_amount COMMENT ''Net line amount after discounts but before freight and tax.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN invoice_amount COMMENT ''Total line amount including freight and tax.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN freight_cost COMMENT ''Freight charges allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN tax_cost COMMENT ''Tax charges allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines ALTER COLUMN currency_code COMMENT ''Currency code for monetary values on the line.'';

CREATE OR REPLACE VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier
COMMENT ''Invoice line measures with supplier attributes for spend analysis.''
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
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines l
INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_supplier s
  ON l.supplier_id = s.supplier_id;

ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN invoice_id COMMENT ''Source invoice identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN invoice_line_id COMMENT ''Invoice line identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN invoice_date COMMENT ''Invoice line effective date.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN supplier_id COMMENT ''Supplier key for joining to other supplier data.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN supplier_name COMMENT ''Supplier display name.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN supplier_category COMMENT ''Supplier category segmentation label.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN supplier_country COMMENT ''Supplier country code for geographic analysis.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN supplier_active_flag COMMENT ''Indicator showing whether the supplier is active.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN line_quantity COMMENT ''Quantity purchased on the invoice line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN net_line_amount COMMENT ''Net merchandise amount after discounts.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN invoice_amount COMMENT ''Total line amount including freight and tax.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN freight_cost COMMENT ''Freight cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN tax_cost COMMENT ''Tax cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN discount_amount COMMENT ''Discount applied to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier ALTER COLUMN currency_code COMMENT ''Currency used on the invoice line.'';

CREATE OR REPLACE VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item
COMMENT ''Invoice line measures with item attributes for product performance analysis.''
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
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines l
INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_item i
  ON l.item_id = i.item_id;

ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN invoice_id COMMENT ''Source invoice identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN invoice_line_id COMMENT ''Invoice line identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN invoice_date COMMENT ''Date of the invoice line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN item_id COMMENT ''Item key for joining to other product data.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN item_name COMMENT ''Item description presented to analysts.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN item_category COMMENT ''Item category grouping.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN uom COMMENT ''Unit of measure captured on the invoice line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN brand COMMENT ''Brand associated with the item.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN item_active_flag COMMENT ''Indicator showing whether the item is active.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN line_quantity COMMENT ''Quantity purchased on the invoice line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN net_line_amount COMMENT ''Net merchandise amount after discounts.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN invoice_amount COMMENT ''Total line amount including freight and tax.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN freight_cost COMMENT ''Freight cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN tax_cost COMMENT ''Tax cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN discount_amount COMMENT ''Discount applied to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item ALTER COLUMN currency_code COMMENT ''Currency used on the invoice line.'';

CREATE OR REPLACE VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant
COMMENT ''Invoice line measures with restaurant attributes for operator insights.''
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
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines l
INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_restaurant r
  ON l.restaurant_id = r.restaurant_id;

ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN invoice_id COMMENT ''Source invoice identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN invoice_line_id COMMENT ''Invoice line identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN invoice_date COMMENT ''Invoice line effective date.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN restaurant_id COMMENT ''Restaurant key for joining to restaurant attributes.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN restaurant_name COMMENT ''Restaurant name displayed to analysts.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN location_number COMMENT ''Internal restaurant location number.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN restaurant_region COMMENT ''Region assigned to the restaurant.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN restaurant_timezone COMMENT ''Time zone used for the restaurant operations.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN open_date COMMENT ''Restaurant opening date.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN restaurant_active_flag COMMENT ''Indicator showing whether the restaurant is active.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN line_quantity COMMENT ''Quantity purchased on the invoice line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN net_line_amount COMMENT ''Net merchandise amount after discounts.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN invoice_amount COMMENT ''Total line amount including freight and tax.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN freight_cost COMMENT ''Freight cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN tax_cost COMMENT ''Tax cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN discount_amount COMMENT ''Discount applied to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant ALTER COLUMN currency_code COMMENT ''Currency used on the invoice line.'';

CREATE OR REPLACE VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc
COMMENT ''Invoice line measures with distribution center attributes for supply chain insights.''
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
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines l
INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_dc d
  ON l.distribution_center_id = d.dc_id;

ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN invoice_id COMMENT ''Source invoice identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN invoice_line_id COMMENT ''Invoice line identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN invoice_date COMMENT ''Invoice line effective date.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN dc_id COMMENT ''Distribution center key.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN dc_name COMMENT ''Distribution center name.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN dc_code COMMENT ''Distribution center operational code.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN dc_region COMMENT ''Region served by the distribution center.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN dc_timezone COMMENT ''Time zone for the distribution center.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN dc_active_flag COMMENT ''Indicator showing whether the distribution center is active.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN line_quantity COMMENT ''Quantity purchased on the invoice line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN net_line_amount COMMENT ''Net merchandise amount after discounts.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN invoice_amount COMMENT ''Total line amount including freight and tax.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN freight_cost COMMENT ''Freight cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN tax_cost COMMENT ''Tax cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN discount_amount COMMENT ''Discount applied to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc ALTER COLUMN currency_code COMMENT ''Currency used on the invoice line.'';

CREATE OR REPLACE VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar
COMMENT ''Invoice line measures joined to the corporate calendar for time intelligence.''
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
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines l
INNER JOIN `${CATALOG}`.`${SCHEMA_GOLD}`.dim_date c
  ON l.invoice_date = c.date_key;

ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN invoice_id COMMENT ''Source invoice identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN invoice_line_id COMMENT ''Invoice line identifier.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN invoice_date COMMENT ''Invoice date used for joining to the calendar.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN date_key COMMENT ''Calendar date key from the corporate calendar.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN calendar_year COMMENT ''Calendar year for the invoice.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN calendar_quarter COMMENT ''Calendar quarter for the invoice.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN calendar_month COMMENT ''Calendar month number for the invoice.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN calendar_week COMMENT ''ISO week number for the invoice.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN calendar_day COMMENT ''Day of month for the invoice.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN is_weekend COMMENT ''Indicator showing if the invoice date is a weekend.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN fiscal_year COMMENT ''Fiscal year aligned to finance reporting.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN fiscal_period COMMENT ''Fiscal period identifier for finance reporting.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN line_quantity COMMENT ''Quantity purchased on the invoice line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN net_line_amount COMMENT ''Net merchandise amount after discounts.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN invoice_amount COMMENT ''Total line amount including freight and tax.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN freight_cost COMMENT ''Freight cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN tax_cost COMMENT ''Tax cost allocated to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN discount_amount COMMENT ''Discount applied to the line.'';
ALTER VIEW `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar ALTER COLUMN currency_code COMMENT ''Currency used on the invoice line.'';
