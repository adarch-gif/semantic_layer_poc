-- Semantic PoC permissions
-- Update ANALYST_PRINCIPAL if you need a specific group; default grants to `account users`.

USE CATALOG cfascdodev_primary;

GRANT USAGE ON CATALOG cfascdodev_primary TO `account users`;
GRANT USAGE ON SCHEMA `cfascdodev_primary`.`invoice_semantic_poc` TO `account users`;

REVOKE ALL PRIVILEGES ON SCHEMA `cfascdodev_primary`.`invoice_gold_semantic_poc` FROM `account users`;
REVOKE SELECT ON ALL TABLES IN SCHEMA `cfascdodev_primary`.`invoice_gold_semantic_poc` FROM `account users`;
REVOKE SELECT ON FUTURE TABLES IN SCHEMA `cfascdodev_primary`.`invoice_gold_semantic_poc` FROM `account users`;

GRANT SELECT ON ALL VIEWS IN SCHEMA `cfascdodev_primary`.`invoice_semantic_poc` TO `account users`;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA `cfascdodev_primary`.`invoice_semantic_poc` TO `account users`;
