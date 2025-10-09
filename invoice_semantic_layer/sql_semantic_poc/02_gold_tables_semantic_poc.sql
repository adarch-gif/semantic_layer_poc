-- Semantic PoC gold tables definition

USE CATALOG cfascdodev_primary;

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_gold_semantic_poc`.fact_invoice_line_semantic_poc (
  invoice_id STRING COMMENT 'Unique invoice header identifier issued by the supplier.',
  line_id STRING COMMENT 'Unique identifier for the line within the invoice document.',
  supplier_id STRING COMMENT 'Business key referencing the supplier that issued the invoice.',
  restaurant_id STRING COMMENT 'Business key referencing the restaurant receiving goods.',
  dc_id STRING COMMENT 'Business key referencing the distribution center fulfilling the order.',
  item_id STRING COMMENT 'Business key referencing the purchased item.',
  invoice_date DATE COMMENT 'Calendar date when the invoice was issued.',
  quantity DECIMAL(18,3) COMMENT 'Number of item units invoiced on the line.',
  unit_price DECIMAL(18,4) COMMENT 'Unit price charged by the supplier for the item.',
  freight_amount DECIMAL(18,4) COMMENT 'Allocated freight or delivery cost for this line.',
  tax_amount DECIMAL(18,4) COMMENT 'Tax amount applied to the line.',
  discount_amount DECIMAL(18,4) COMMENT 'Discount amount applied to the line (positive values reduce spend).',
  currency_code STRING COMMENT 'ISO 4217 currency code applied to monetary amounts.',
  line_amount DECIMAL(18,4) GENERATED ALWAYS AS (CAST(coalesce(quantity,0) * coalesce(unit_price,0) - coalesce(discount_amount,0) AS DECIMAL(18,4))) COMMENT 'Net merchandise amount for the line after discounts.',
  load_ts TIMESTAMP COMMENT 'Timestamp when the record landed in the gold layer.',
  src_file STRING COMMENT 'Source file or upstream system that supplied the record.'
)
USING DELTA
COMMENT 'Semantic PoC fact table capturing supplier invoice line level measures.'
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
);

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_supplier_semantic_poc (
  supplier_id STRING COMMENT 'Natural key identifying the supplier in source systems.',
  supplier_name STRING COMMENT 'Supplier display name as recognized by procurement.',
  supplier_category STRING COMMENT 'Supplier segmentation category (e.g., Produce, Dry Goods).',
  country_code STRING COMMENT 'ISO 3166-1 alpha-2 country where the supplier is registered.',
  active_flag BOOLEAN COMMENT 'Flag indicating whether the supplier is currently active.',
  effective_from DATE COMMENT 'Date when the supplier record became effective in this dimension.',
  effective_to DATE COMMENT 'Date when the supplier record expired; 9999-12-31 indicates current.',
  CONSTRAINT pk_dim_supplier_semantic_poc PRIMARY KEY (supplier_id) NOT ENFORCED
)
USING DELTA
COMMENT 'Semantic PoC supplier dimension containing descriptive attributes for invoice analysis.'
TBLPROPERTIES ('delta.autoOptimize.optimizeWrite' = 'true');

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_item_semantic_poc (
  item_id STRING COMMENT 'Natural key identifying the purchased item.',
  item_name STRING COMMENT 'Business-friendly name of the item.',
  item_category STRING COMMENT 'Categorization of the item for reporting (e.g., Produce).',
  uom STRING COMMENT 'Unit of measure used for the item (e.g., CASE, LB).',
  brand STRING COMMENT 'Brand associated with the item when available.',
  active_flag BOOLEAN COMMENT 'Flag indicating whether the item is active for purchasing.',
  effective_from DATE COMMENT 'Date when the item attributes became effective.',
  effective_to DATE COMMENT 'Date when the item attributes expired; 9999-12-31 indicates current.',
  CONSTRAINT pk_dim_item_semantic_poc PRIMARY KEY (item_id) NOT ENFORCED
)
USING DELTA
COMMENT 'Semantic PoC item dimension describing purchasable products for invoice analytics.'
TBLPROPERTIES ('delta.autoOptimize.optimizeWrite' = 'true');

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_restaurant_semantic_poc (
  restaurant_id STRING COMMENT 'Natural key identifying the restaurant location.',
  restaurant_name STRING COMMENT 'Display name of the restaurant location.',
  location_number STRING COMMENT 'Internal restaurant location number used in operations.',
  region STRING COMMENT 'Geographic or operating region for the restaurant.',
  timezone STRING COMMENT 'IANA time zone used for local business reporting.',
  open_date DATE COMMENT 'Date when the restaurant opened for business.',
  active_flag BOOLEAN COMMENT 'Flag indicating whether the restaurant is currently operating.',
  CONSTRAINT pk_dim_restaurant_semantic_poc PRIMARY KEY (restaurant_id) NOT ENFORCED
)
USING DELTA
COMMENT 'Semantic PoC restaurant dimension with descriptive attributes for buying locations.'
TBLPROPERTIES ('delta.autoOptimize.optimizeWrite' = 'true');

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_dc_semantic_poc (
  dc_id STRING COMMENT 'Natural key identifying the distribution center.',
  dc_name STRING COMMENT 'Business-friendly name of the distribution center.',
  dc_code STRING COMMENT 'Operational code used internally for the distribution center.',
  region STRING COMMENT 'Geographic or responsibility region served by the distribution center.',
  timezone STRING COMMENT 'Primary time zone of the distribution center operations.',
  active_flag BOOLEAN COMMENT 'Flag indicating whether the distribution center is active.',
  CONSTRAINT pk_dim_dc_semantic_poc PRIMARY KEY (dc_id) NOT ENFORCED
)
USING DELTA
COMMENT 'Semantic PoC distribution center dimension describing fulfillment locations.'
TBLPROPERTIES ('delta.autoOptimize.autoCompact' = 'true');

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_gold_semantic_poc`.dim_date_semantic_poc (
  date_key DATE COMMENT 'Calendar date serving as the primary key of the date dimension.',
  year INT COMMENT 'Calendar year number.',
  quarter INT COMMENT 'Calendar quarter number (1-4).',
  month INT COMMENT 'Calendar month number (1-12).',
  week INT COMMENT 'ISO week number within the year.',
  day INT COMMENT 'Day of month number (1-31).',
  is_weekend BOOLEAN COMMENT 'Flag indicating whether the date falls on a weekend.',
  fiscal_year INT COMMENT 'Fiscal year aligned to finance calendar.',
  fiscal_period STRING COMMENT 'Fiscal period identifier aligned to finance reporting.',
  CONSTRAINT pk_dim_date_semantic_poc PRIMARY KEY (date_key) NOT ENFORCED
)
USING DELTA
COMMENT 'Semantic PoC date dimension containing calendar and fiscal attributes for time-based analysis.'
TBLPROPERTIES ('delta.autoOptimize.autoCompact' = 'true');
