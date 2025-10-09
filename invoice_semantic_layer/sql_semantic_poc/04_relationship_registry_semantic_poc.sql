-- Relationship registry for semantic PoC

USE CATALOG cfascdodev_primary;

CREATE OR REPLACE TABLE `cfascdodev_primary`.`invoice_semantic_poc`.relationships_semantic_poc (
  from_table STRING COMMENT 'Table name where the foreign key originates.',
  from_column STRING COMMENT 'Column in the source table participating in the relationship.',
  to_table STRING COMMENT 'Target table providing the dimension lookup.',
  to_column STRING COMMENT 'Column in the target table providing the lookup key.',
  relationship_type STRING COMMENT 'Shape of the relationship (e.g., many_to_one).',
  join_type STRING COMMENT 'Preferred join type when relating the tables.',
  confidence DECIMAL(3,2) COMMENT 'Confidence score (0-1) expressing trust in the relationship.',
  notes STRING COMMENT 'Additional guidance or caveats for the relationship.'
)
USING DELTA
COMMENT 'Semantic PoC registry defining joins between fact and dimension tables.'
TBLPROPERTIES ('delta.autoOptimize.autoCompact' = 'true');

INSERT OVERWRITE `cfascdodev_primary`.`invoice_semantic_poc`.relationships_semantic_poc
SELECT * FROM VALUES
  ('fact_invoice_line_semantic_poc','supplier_id','dim_supplier_semantic_poc','supplier_id','many_to_one','inner',0.95,'Supplier key sourced from procurement master.'),
  ('fact_invoice_line_semantic_poc','item_id','dim_item_semantic_poc','item_id','many_to_one','inner',0.95,'Item key sourced from product master.'),
  ('fact_invoice_line_semantic_poc','restaurant_id','dim_restaurant_semantic_poc','restaurant_id','many_to_one','inner',0.95,'Restaurant key sourced from restaurant master data.'),
  ('fact_invoice_line_semantic_poc','dc_id','dim_dc_semantic_poc','dc_id','many_to_one','inner',0.95,'Distribution center key sourced from supply chain master.'),
  ('fact_invoice_line_semantic_poc','invoice_date','dim_date_semantic_poc','date_key','many_to_one','inner',0.99,'Invoice date references canonical date dimension.')
AS v(from_table,from_column,to_table,to_column,relationship_type,join_type,confidence,notes);
