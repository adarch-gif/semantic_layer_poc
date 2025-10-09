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

CREATE CATALOG IF NOT EXISTS `${CATALOG}` COMMENT ''Demo catalog for invoice analytics semantic layer assets.'';
ALTER CATALOG `${CATALOG}` OWNER TO `account users`;

CREATE SCHEMA IF NOT EXISTS `${CATALOG}`.`${SCHEMA_GOLD}` COMMENT ''Gold schema hosting modeled invoice analytics tables.'';
ALTER SCHEMA `${CATALOG}`.`${SCHEMA_GOLD}` OWNER TO `account users`;

CREATE SCHEMA IF NOT EXISTS `${CATALOG}`.`${SCHEMA_SEM}` COMMENT ''Semantic schema exposing curated invoice analytics assets for Genie.'';
ALTER SCHEMA `${CATALOG}`.`${SCHEMA_SEM}` OWNER TO `account users`;
