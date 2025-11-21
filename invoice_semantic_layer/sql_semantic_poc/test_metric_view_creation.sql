-- ========================================
-- DIAGNOSTIC: Check Metric View Creation Status
-- ========================================

USE CATALOG cfascdodev_primary;

-- ========================================
-- TEST 1: Does the metric view exist?
-- ========================================
SHOW TABLES IN cfascdodev_primary.invoice_semantic_poc LIKE 'mv_invoice_supplier_semantic_poc';

-- ========================================
-- TEST 2: What type of object is it?
-- ========================================
DESCRIBE TABLE EXTENDED cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- ========================================
-- TEST 3: Check table properties
-- ========================================
SHOW TBLPROPERTIES cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- ========================================
-- TEST 4: Check columns (including data types)
-- ========================================
DESCRIBE TABLE cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- ========================================
-- TEST 5: Try querying the underlying semantic view
-- ========================================
-- This should work - it is not a metric view
SELECT
  supplier_name,
  SUM(invoice_amount) as total
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
LIMIT 5;

-- ========================================
-- DIAGNOSIS
-- ========================================
-- If TEST 5 works but metric view queries fail, the issue is with
-- how the metric view was created.
--
-- Possible causes:
-- 1. Databricks Metrics (Preview) not enabled in workspace
-- 2. Metric view YAML syntax error during creation
-- 3. Metric view created as regular view instead of metric view
-- 4. Incompatible Databricks runtime version
--
-- Solution:
-- Drop and recreate the metric view using script 10
-- ========================================
