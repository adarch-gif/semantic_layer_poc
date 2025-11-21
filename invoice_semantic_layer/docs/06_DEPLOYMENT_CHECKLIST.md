# Invoice Analytics Semantic Layer POC - Deployment Checklist

## Purpose

This checklist ensures all stakeholders can successfully deploy the Invoice Analytics Semantic Layer POC on Databricks without missing critical steps. Print this document and check off items as they are completed.

---

## Pre-Deployment Phase

### Access & Permissions Verification

- [ ] **Databricks Workspace Access Confirmed**
  - Workspace URL: _______________________________
  - User ID/Email: _______________________________
  - Login successful

- [ ] **Catalog Access Verified**
  ```sql
  USE CATALOG cfascdodev_primary;
  SELECT current_catalog(), current_user();
  ```
  - Result shows correct catalog and user

- [ ] **SQL Warehouse Access Confirmed**
  ```sql
  SHOW WAREHOUSES;
  ```
  - `General Purpose` warehouse exists and is running
  - Warehouse ID: _______________________________

- [ ] **Permission Level Verified**
  - Can CREATE SCHEMA on catalog: ☐ Yes ☐ No
  - Can USE CATALOG: ☐ Yes ☐ No
  - Has MANAGE/OWNERSHIP (for permissions script): ☐ Yes ☐ No

### Environment Configuration Review

- [ ] **Reviewed Default Environment Variables**

| Variable | Default Value | Your Value (if different) |
|----------|---------------|---------------------------|
| CATALOG | `cfascdodev_primary` | _________________ |
| SCHEMA_GOLD | `invoice_gold_semantic_poc` | _________________ |
| SCHEMA_SEM | `invoice_semantic_poc` | _________________ |
| GROUP_ANALYSTS | `account users` | _________________ |
| WAREHOUSE_NAME | `General Purpose` | _________________ |

- [ ] **Decided on Environment Strategy**
  - ☐ Using default values (no changes needed)
  - ☐ Customizing values (update all SQL scripts before running)

- [ ] **If Customizing: Updated SQL Scripts**
  - [ ] 01_schemas_semantic_poc.sql
  - [ ] 02_gold_tables_semantic_poc.sql
  - [ ] 03_seed_data_semantic_poc.sql
  - [ ] 04_relationship_registry_semantic_poc.sql
  - [ ] 05_metrics_registry_semantic_poc.sql
  - [ ] 06_synonyms_registry_semantic_poc.sql
  - [ ] 07_semantic_views_semantic_poc.sql
  - [ ] 08_permissions_semantic_poc.sql
  - [ ] 09_validation_semantic_poc.sql
  - [ ] 10_metric_views_semantic_poc.sql
  - [ ] databricks.yml (if using DAB)

### Deployment Method Selection

- [ ] **Chosen Deployment Method**
  - ☐ Manual UI Deployment (15 minutes, more control)
  - ☐ Automated DAB Deployment (5 minutes, repeatable)

#### If Manual UI Selected:
- [ ] Databricks SQL Editor open and ready
- [ ] SQL scripts downloaded/accessible
- [ ] Copy/paste method tested

#### If Automated DAB Selected:
- [ ] Databricks CLI installed locally
  ```bash
  databricks --version
  ```
- [ ] CLI authenticated to workspace
  ```bash
  databricks auth login
  ```
- [ ] Repository cloned locally
  ```bash
  git clone https://github.com/adarch-gif/semantic_layer_poc.git
  ```
- [ ] DAB configuration validated
  ```bash
  cd semantic_layer_poc/infra
  databricks bundle validate
  ```

### Documentation Readiness

- [ ] **Read Required Documentation**
  - [ ] [00_README_START_HERE.md](00_README_START_HERE.md) - Master navigation
  - [ ] [01_QUICK_START_GUIDE.md](01_QUICK_START_GUIDE.md) - Quickstart overview
  - [ ] [02_UNDERSTANDING_VIEWS_AND_QUERIES.md](02_UNDERSTANDING_VIEWS_AND_QUERIES.md) - CREATE VIEW behavior

- [ ] **Bookmarked Reference Documentation**
  - [ ] [08_SQL_RUNBOOK.md](08_SQL_RUNBOOK.md) - Script sequence and purpose
  - [ ] [14_METRIC_VIEWS_TROUBLESHOOTING.md](14_METRIC_VIEWS_TROUBLESHOOTING.md) - Error resolution
  - [ ] [17_CLEANUP_AND_REDEPLOY_GUIDE.md](17_CLEANUP_AND_REDEPLOY_GUIDE.md) - Cleanup procedures

### Optional Features Planning

- [ ] **Databricks Metrics Configuration**
  - [ ] Verified Metrics feature is enabled in workspace
  - [ ] Identified contact for enabling if not available
  - [ ] Accepted that metric views may fail if feature unavailable

- [ ] **Genie Space Planning**
  - [ ] Reviewed [16_GENIE_SPACE_SETUP.md](16_GENIE_SPACE_SETUP.md)
  - [ ] Planned to configure Genie post-deployment
  - [ ] Identified sample questions to test

- [ ] **Consumption Layer Planning**
  - [ ] Identified BI tool (PowerBI/Tableau/Other): _________________
  - [ ] Planned connection method to semantic views
  - [ ] Identified initial dashboard requirements

---

## Deployment Phase

### Manual Deployment Sequence

If using manual UI deployment, execute scripts in this exact order:

- [ ] **Step 1: Create Schemas**
  - Script: `01_schemas_semantic_poc.sql`
  - Expected: 2 schemas created
  - Verification: `SHOW SCHEMAS LIKE '*semantic_poc*';`
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

- [ ] **Step 2: Create Gold Tables**
  - Script: `02_gold_tables_semantic_poc.sql`
  - Expected: 6 tables created (1 fact + 5 dimensions)
  - Verification: `SHOW TABLES IN invoice_gold_semantic_poc;`
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

- [ ] **Step 3: Load Sample Data**
  - Script: `03_seed_data_semantic_poc.sql`
  - Expected: ~12 invoice lines, 3 suppliers, 3 items, 3 restaurants
  - Verification: `SELECT COUNT(*) FROM fact_invoice_line_semantic_poc;`
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

- [ ] **Step 4: Create Relationship Registry**
  - Script: `04_relationship_registry_semantic_poc.sql`
  - Expected: Relationship metadata table created
  - Verification: `SELECT COUNT(*) FROM relationships_semantic_poc;`
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

- [ ] **Step 5: Create Metrics Registry**
  - Script: `05_metrics_registry_semantic_poc.sql`
  - Expected: Metrics metadata table created
  - Verification: `SELECT COUNT(*) FROM metrics_semantic_poc;`
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

- [ ] **Step 6: Create Synonyms Registry**
  - Script: `06_synonyms_registry_semantic_poc.sql`
  - Expected: Synonyms metadata table created
  - Verification: `SELECT COUNT(*) FROM synonyms_semantic_poc;`
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

- [ ] **Step 7: Create Semantic Views**
  - Script: `07_semantic_views_semantic_poc.sql`
  - Expected: 6 semantic views created
  - Verification: `SHOW VIEWS IN invoice_semantic_poc LIKE 'v_%';`
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

- [ ] **Step 8: Create Metric Views** (BEFORE permissions!)
  - Script: `10_metric_views_semantic_poc.sql`
  - Expected: 5 metric views created
  - Verification: `SHOW VIEWS IN invoice_semantic_poc LIKE 'mv_%';`
  - Result: ☐ PASS ☐ FAIL
  - Troubleshooting: If YAML errors occur, see [14_METRIC_VIEWS_TROUBLESHOOTING.md](14_METRIC_VIEWS_TROUBLESHOOTING.md)
  - Notes: _______________________________

- [ ] **Step 9: Apply Permissions**
  - Script: `08_permissions_semantic_poc.sql`
  - Expected: Grants applied to semantic schema, revokes on gold schema
  - Verification: `SHOW GRANTS ON SCHEMA invoice_semantic_poc;`
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

- [ ] **Step 10: Run Validation**
  - Script: `09_validation_semantic_poc.sql`
  - Expected: All checks show PASS status
  - Verification: Review query output for PASS/FAIL
  - Result: ☐ PASS ☐ FAIL
  - Notes: _______________________________

**Manual Deployment Total Time**: _________ minutes

### Automated Deployment Sequence

If using Databricks Asset Bundle (DAB):

- [ ] **Deploy Bundle**
  ```bash
  cd semantic_layer_poc/infra
  databricks bundle deploy
  ```
  - Deployment ID: _______________________________
  - Result: ☐ Success ☐ Failed
  - Notes: _______________________________

- [ ] **Run Deployment Job**
  ```bash
  databricks bundle run semantic_layer_deploy
  ```
  - Job Run ID: _______________________________
  - Result: ☐ Success ☐ Failed
  - Notes: _______________________________

- [ ] **Monitor Job Execution**
  - All 10 SQL tasks completed: ☐ Yes ☐ No
  - Benchmark notebook completed: ☐ Yes ☐ No
  - Total runtime: _________ minutes
  - Notes: _______________________________

**Automated Deployment Total Time**: _________ minutes

---

## Post-Deployment Verification Phase

### Schema Verification

- [ ] **Confirm Schemas Exist**
  ```sql
  SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
  ```
  - Expected: 2 schemas
  - Actual count: _______
  - Result: ☐ PASS ☐ FAIL

### Gold Layer Verification

- [ ] **Confirm Gold Tables Exist**
  ```sql
  SHOW TABLES IN cfascdodev_primary.invoice_gold_semantic_poc;
  ```
  - Expected: 6 tables
  - Actual count: _______
  - Result: ☐ PASS ☐ FAIL

- [ ] **Verify Sample Data Loaded**
  ```sql
  SELECT COUNT(*) FROM cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc;
  ```
  - Expected: ~12 rows
  - Actual count: _______
  - Result: ☐ PASS ☐ FAIL

### Semantic Layer Verification

- [ ] **Confirm Semantic Views Exist**
  ```sql
  SHOW VIEWS IN cfascdodev_primary.invoice_semantic_poc LIKE 'v_%';
  ```
  - Expected: 6 views
  - Actual count: _______
  - Result: ☐ PASS ☐ FAIL

- [ ] **Test Semantic View Query**
  ```sql
  SELECT
    invoice_date,
    supplier_name,
    SUM(invoice_amount) as total_spend
  FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
  GROUP BY invoice_date, supplier_name
  ORDER BY invoice_date, total_spend DESC;
  ```
  - Returns data: ☐ Yes ☐ No
  - Row count: _______
  - Result: ☐ PASS ☐ FAIL

### Metric Views Verification

- [ ] **Confirm Metric Views Exist**
  ```sql
  SHOW VIEWS IN cfascdodev_primary.invoice_semantic_poc LIKE 'mv_%';
  ```
  - Expected: 5 views
  - Actual count: _______
  - Result: ☐ PASS ☐ FAIL

- [ ] **Test Metric View Query**
  ```sql
  SELECT
    `Invoice Date`,
    `Supplier Name`,
    `Total Invoice Amount`,
    `Invoice Line Count`
  FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
  WHERE `Invoice Date` >= '2024-01-05'
  ORDER BY `Invoice Date`, `Total Invoice Amount` DESC;
  ```
  - Returns data: ☐ Yes ☐ No
  - Row count: _______
  - Result: ☐ PASS ☐ FAIL

### Metadata Registries Verification

- [ ] **Verify Relationships Registry**
  ```sql
  SELECT COUNT(*) FROM cfascdodev_primary.invoice_semantic_poc.relationships_semantic_poc;
  ```
  - Expected: 5+ rows
  - Actual count: _______
  - Result: ☐ PASS ☐ FAIL

- [ ] **Verify Metrics Registry**
  ```sql
  SELECT COUNT(*) FROM cfascdodev_primary.invoice_semantic_poc.metrics_semantic_poc;
  ```
  - Expected: 10+ rows
  - Actual count: _______
  - Result: ☐ PASS ☐ FAIL

- [ ] **Verify Synonyms Registry**
  ```sql
  SELECT COUNT(*) FROM cfascdodev_primary.invoice_semantic_poc.synonyms_semantic_poc;
  ```
  - Expected: 20+ rows
  - Actual count: _______
  - Result: ☐ PASS ☐ FAIL

### Permissions Verification

- [ ] **Run Permission Verification Script**
  ```sql
  -- Execute: sql_semantic_poc/verify_permissions.sql
  ```
  - All sections returned results: ☐ Yes ☐ No
  - Result: ☐ PASS ☐ FAIL

- [ ] **Verify Gold Schema Restricted**
  - Analysts cannot SELECT from gold tables: ☐ Confirmed
  - Admins can SELECT from gold tables: ☐ Confirmed
  - Result: ☐ PASS ☐ FAIL

- [ ] **Verify Semantic Schema Accessible**
  - Analysts can SELECT from semantic views: ☐ Confirmed
  - Result: ☐ PASS ☐ FAIL

### Validation Script Results

- [ ] **Comment Coverage Check**
  - Overall comment coverage ≥95%: ☐ Yes ☐ No
  - Actual coverage: _______%
  - Result: ☐ PASS ☐ FAIL

- [ ] **Relationship Reachability Check**
  - All dimension joins return rows: ☐ Yes ☐ No
  - Failed relationships (if any): _______________________________
  - Result: ☐ PASS ☐ FAIL

- [ ] **Metric Reconciliation Check**
  - Semantic view totals match fact table: ☐ Yes ☐ No
  - Variance (if any): _______________________________
  - Result: ☐ PASS ☐ FAIL

---

## Post-Deployment Configuration Phase (Optional)

### Genie Space Setup

- [ ] **Created Genie Space**
  - Space name: _______________________________
  - Space URL: _______________________________

- [ ] **Added Data Sources to Genie**
  - [ ] v_invoice_supplier_semantic_poc
  - [ ] v_invoice_item_semantic_poc
  - [ ] v_invoice_restaurant_semantic_poc
  - [ ] v_invoice_dc_semantic_poc
  - [ ] v_invoice_calendar_semantic_poc

- [ ] **Uploaded Metadata Registries**
  - [ ] relationships_semantic_poc
  - [ ] metrics_semantic_poc
  - [ ] synonyms_semantic_poc

- [ ] **Tested Sample Questions**
  - "What is total spend by supplier?": ☐ Answered correctly
  - "Show invoice trends over time": ☐ Answered correctly
  - "Which restaurant has highest spend?": ☐ Answered correctly

See: [16_GENIE_SPACE_SETUP.md](16_GENIE_SPACE_SETUP.md)

### BI Tool Connection

- [ ] **Connected BI Tool to Semantic Layer**
  - Tool: _______________________________
  - Connection type: _______________________________
  - Connection successful: ☐ Yes ☐ No

- [ ] **Created Sample Dashboard**
  - Dashboard name: _______________________________
  - Dashboard URL: _______________________________

---

## Troubleshooting Phase

### Common Issues Encountered

#### Issue Log

| Issue # | Description | Script/Step | Resolution | Resolved? |
|---------|-------------|-------------|------------|-----------|
| 1 | | | | ☐ |
| 2 | | | | ☐ |
| 3 | | | | ☐ |

### Reference Documentation Used

- [ ] [14_METRIC_VIEWS_TROUBLESHOOTING.md](14_METRIC_VIEWS_TROUBLESHOOTING.md) - YAML parsing errors
- [ ] [02_UNDERSTANDING_VIEWS_AND_QUERIES.md](02_UNDERSTANDING_VIEWS_AND_QUERIES.md) - CREATE VIEW confusion
- [ ] [17_CLEANUP_AND_REDEPLOY_GUIDE.md](17_CLEANUP_AND_REDEPLOY_GUIDE.md) - Starting over

---

## Cleanup Phase (If Needed)

### Complete Cleanup Procedure

Only perform if redeployment is required:

- [ ] **Backup Important Data** (if any customizations made)
  - Backup location: _______________________________

- [ ] **Drop Schemas CASCADE**
  ```sql
  USE CATALOG cfascdodev_primary;
  DROP SCHEMA IF EXISTS invoice_semantic_poc CASCADE;
  DROP SCHEMA IF EXISTS invoice_gold_semantic_poc CASCADE;
  ```
  - Execution successful: ☐ Yes ☐ No

- [ ] **Verify Complete Cleanup**
  ```sql
  SHOW SCHEMAS LIKE '*semantic_poc*';
  ```
  - Result returns 0 rows: ☐ Yes ☐ No

- [ ] **Ready to Redeploy**
  - Return to Deployment Phase above

See: [17_CLEANUP_AND_REDEPLOY_GUIDE.md](17_CLEANUP_AND_REDEPLOY_GUIDE.md)

---

## Deployment Summary

### Final Status

**Deployment Date**: __________________
**Deployed By**: __________________
**Deployment Method Used**: ☐ Manual ☐ Automated (DAB)
**Total Deployment Time**: __________ minutes

### Objects Created

| Object Type | Expected Count | Actual Count | Status |
|-------------|----------------|--------------|--------|
| Schemas | 2 | _____ | ☐ ✓ ☐ ✗ |
| Gold Tables | 6 | _____ | ☐ ✓ ☐ ✗ |
| Metadata Registries | 3 | _____ | ☐ ✓ ☐ ✗ |
| Semantic Views | 6 | _____ | ☐ ✓ ☐ ✗ |
| Metric Views | 5 | _____ | ☐ ✓ ☐ ✗ |
| **Total Objects** | **22** | **_____** | ☐ ✓ ☐ ✗ |

### Success Criteria

- [ ] All 22 objects created without errors
- [ ] Semantic views return data when queried
- [ ] Metric views return data when queried (or Metrics feature confirmed unavailable)
- [ ] Permissions properly restrict gold table access
- [ ] Validation script shows all PASS results
- [ ] Comment coverage ≥95%
- [ ] (Optional) Genie can answer benchmark questions

**Overall Deployment Status**: ☐ SUCCESS ☐ PARTIAL SUCCESS ☐ FAILED

### Notes and Observations

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

### Next Steps

- [ ] Share deployment results with team
- [ ] Schedule demo/walkthrough session
- [ ] Plan production deployment (if POC successful)
- [ ] Document lessons learned
- [ ] Update environment-specific configuration

---

## Stakeholder Sign-Off

**Technical Lead**: ______________________ Date: __________

**Business Sponsor**: ______________________ Date: __________

**Data Governance**: ______________________ Date: __________

---

**Document Version**: 1.0
**Last Updated**: 2025-01-20
**Purpose**: Comprehensive deployment checklist for stakeholder-led POC deployment

---

**For questions or issues, refer to**:
- Master Documentation: [00_README_START_HERE.md](00_README_START_HERE.md)
- Quick Start Guide: [01_QUICK_START_GUIDE.md](01_QUICK_START_GUIDE.md)
- Troubleshooting: [14_METRIC_VIEWS_TROUBLESHOOTING.md](14_METRIC_VIEWS_TROUBLESHOOTING.md)
