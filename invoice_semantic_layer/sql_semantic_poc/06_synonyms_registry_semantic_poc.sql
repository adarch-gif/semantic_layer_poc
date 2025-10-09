-- Synonym registry for semantic PoC

USE CATALOG cfascdodev_primary;

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_semantic_poc`.synonyms_semantic_poc (
  term STRING COMMENT 'Natural language term supplied by business users.',
  object_type STRING COMMENT 'Type of object referenced by the term (column, table, metric).',
  canonical_name STRING COMMENT 'Canonical object name understood by the semantic layer.',
  scope_table STRING COMMENT 'Optional table context to disambiguate column synonyms.',
  notes STRING COMMENT 'Additional guidance about how or when to use the synonym.'
)
USING DELTA
COMMENT 'Semantic PoC synonym registry aligning business language with model objects.'
TBLPROPERTIES ('delta.autoOptimize.autoCompact' = 'true');

INSERT OVERWRITE `cfascdodev_primary`.`invoice_semantic_poc`.synonyms_semantic_poc
SELECT * FROM VALUES
  ('store','column','dim_restaurant_semantic_poc.restaurant_name','dim_restaurant_semantic_poc','Operations shorthand for restaurant name.'),
  ('restaurant','table','dim_restaurant_semantic_poc',NULL,'Natural language reference for restaurant dimension.'),
  ('supplier','column','dim_supplier_semantic_poc.supplier_name','dim_supplier_semantic_poc','Common business term for supplier name.'),
  ('vendor','table','dim_supplier_semantic_poc',NULL,'Procurement often refers to suppliers as vendors.'),
  ('dc','column','dim_dc_semantic_poc.dc_name','dim_dc_semantic_poc','Abbreviation for distribution center name.'),
  ('distribution center','table','dim_dc_semantic_poc',NULL,'Full phrase used for distribution center lookups.'),
  ('item','column','dim_item_semantic_poc.item_name','dim_item_semantic_poc','Generic term for item description.'),
  ('product','table','dim_item_semantic_poc',NULL,'Merchandising synonym for item dimension.'),
  ('spend','metric','invoice_amount',NULL,'Finance shorthand for total invoice spend metric.'),
  ('cost','metric','invoice_amount',NULL,'Finance often equates cost with invoice amount.'),
  ('freight','metric','freight_cost',NULL,'Logistics term for freight cost metric.'),
  ('tax','metric','tax_cost',NULL,'Finance shorthand for tax cost metric.'),
  ('discounts','metric','discount_total',NULL,'Plural form referencing discount total metric.'),
  ('qty','metric','quantity_total',NULL,'Abbreviation for quantity total metric.'),
  ('line count','metric','line_count',NULL,'Phrase analysts use for counting invoice lines.')
AS v(term,object_type,canonical_name,scope_table,notes);
