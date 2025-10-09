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

CREATE OR REPLACE TABLE `${CATALOG}`.`${SCHEMA_SEM}`.synonyms (
  term STRING COMMENT ''Natural language term supplied by business users.'',
  object_type STRING COMMENT ''Type of object referenced by the term (column, table, metric).'',
  canonical_name STRING COMMENT ''Canonical object name understood by the semantic layer.'',
  scope_table STRING COMMENT ''Optional table context to disambiguate column synonyms.'',
  notes STRING COMMENT ''Additional guidance about how or when to use the synonym.''
)
USING DELTA
COMMENT ''Synonym registry aligning business vernacular with semantic model objects for Genie.''
TBLPROPERTIES (''delta.autoOptimize.autoCompact'' = ''true'');

INSERT OVERWRITE `${CATALOG}`.`${SCHEMA_SEM}`.synonyms
SELECT * FROM VALUES
  (''store'',''column'',''dim_restaurant.restaurant_name'',''dim_restaurant'',''Operations shorthand for restaurant name.''),
  (''restaurant'',''table'',''dim_restaurant'',NULL,''Natural language reference for restaurant dimension.''),
  (''supplier'',''column'',''dim_supplier.supplier_name'',''dim_supplier'',''Common business term for supplier name.''),
  (''vendor'',''table'',''dim_supplier'',NULL,''Procurement often refers to suppliers as vendors.''),
  (''dc'',''column'',''dim_dc.dc_name'',''dim_dc'',''Abbreviation for distribution center name.''),
  (''distribution center'',''table'',''dim_dc'',NULL,''Full phrase used for distribution center lookups.''),
  (''item'',''column'',''dim_item.item_name'',''dim_item'',''Generic term for item description.''),
  (''product'',''table'',''dim_item'',NULL,''Merchandising synonym for item dimension.''),
  (''spend'',''metric'',''invoice_amount'',NULL,''Finance shorthand for total invoice spend metric.''),
  (''cost'',''metric'',''invoice_amount'',NULL,''Finance often equates cost with invoice amount.''),
  (''freight'',''metric'',''freight_cost'',NULL,''Logistics term for freight cost metric.''),
  (''tax'',''metric'',''tax_cost'',NULL,''Finance shorthand for tax cost metric.''),
  (''discounts'',''metric'',''discount_total'',NULL,''Plural form referencing discount total metric.''),
  (''qty'',''metric'',''quantity_total'',NULL,''Abbreviation for quantity total metric.''),
  (''line count'',''metric'',''line_count'',NULL,''Phrase analysts use for counting invoice lines.'')
AS v(term,object_type,canonical_name,scope_table,notes);
