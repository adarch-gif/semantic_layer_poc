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

CREATE OR REPLACE TABLE `${CATALOG}`.`${SCHEMA_SEM}`.relationships (
  from_table STRING COMMENT ''Table name where the foreign key originates.'',
  from_column STRING COMMENT ''Column in the source table participating in the relationship.'',
  to_table STRING COMMENT ''Target table providing the dimension lookup.'',
  to_column STRING COMMENT ''Column in the target table providing the lookup key.'',
  relationship_type STRING COMMENT ''Shape of the relationship (e.g., many_to_one).'',
  join_type STRING COMMENT ''Preferred join type when relating the tables.'',
  confidence DECIMAL(3,2) COMMENT ''Confidence score (0-1) expressing trust in the relationship.'',
  notes STRING COMMENT ''Additional guidance or caveats for the relationship.''
)
USING DELTA
COMMENT ''Registry defining joins between fact and dimension tables for semantic resolution.''
TBLPROPERTIES (''delta.autoOptimize.autoCompact'' = ''true'');

INSERT OVERWRITE `${CATALOG}`.`${SCHEMA_SEM}`.relationships
SELECT * FROM VALUES
  (''fact_invoice_line'',''supplier_id'',''dim_supplier'',''supplier_id'',''many_to_one'',''inner'',0.95,''Supplier key sourced from procurement master.''),
  (''fact_invoice_line'',''item_id'',''dim_item'',''item_id'',''many_to_one'',''inner'',0.95,''Item key sourced from product master.''),
  (''fact_invoice_line'',''restaurant_id'',''dim_restaurant'',''restaurant_id'',''many_to_one'',''inner'',0.95,''Restaurant key sourced from restaurant master data.''),
  (''fact_invoice_line'',''dc_id'',''dim_dc'',''dc_id'',''many_to_one'',''inner'',0.95,''Distribution center key sourced from supply chain master.''),
  (''fact_invoice_line'',''invoice_date'',''dim_date'',''date_key'',''many_to_one'',''inner'',0.99,''Invoice date references canonical date dimension.'')
AS v(from_table,from_column,to_table,to_column,relationship_type,join_type,confidence,notes);
