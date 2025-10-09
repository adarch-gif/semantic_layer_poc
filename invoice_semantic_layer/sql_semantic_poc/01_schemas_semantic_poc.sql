-- Semantic PoC schema provisioning (run on General Purpose warehouse)

USE CATALOG cfascdodev_primary;

CREATE SCHEMA IF NOT EXISTS `cfascdodev_primary`.`invoice_gold_semantic_poc`
  COMMENT 'Gold schema for invoice analytics semantic PoC tables.';

CREATE SCHEMA IF NOT EXISTS `cfascdodev_primary`.`invoice_semantic_poc`
  COMMENT 'Semantic schema for invoice analytics PoC views and registries.';
