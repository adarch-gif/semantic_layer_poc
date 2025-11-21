# Semantic Layer POC - Complete Deployment Flowchart

This document contains visual flowcharts showing the complete deployment process from scratch to a fully functional semantic layer POC.

---

## 📋 Table of Contents

1. [High-Level Overview](#high-level-overview)
2. [Detailed Deployment Flow](#detailed-deployment-flow)
3. [Architecture Layers](#architecture-layers)
4. [Decision Tree: Which Deployment Method?](#decision-tree-which-deployment-method)
5. [Validation Flow](#validation-flow)
6. [Troubleshooting Decision Tree](#troubleshooting-decision-tree)

---

## High-Level Overview

```mermaid
graph TD
    A[Start: Clone Repository] --> B{Choose Deployment Method}
    B -->|Automated| C[DAB Deployment<br/>5 minutes]
    B -->|Manual| D[UI Deployment<br/>15 minutes]

    C --> E[Run databricks bundle deploy]
    E --> F[Run databricks bundle run]

    D --> G[Execute SQL Scripts 01-10<br/>in Databricks SQL Editor]

    F --> H[Validation]
    G --> H

    H --> I{All Tests Pass?}
    I -->|Yes| J[Configure Genie Space]
    I -->|No| K[Troubleshoot]
    K --> H

    J --> L[POC Ready for Stakeholders!]

    style A fill:#e1f5ff
    style L fill:#c8e6c9
    style K fill:#ffcdd2
    style B fill:#fff9c4
```

---

## Detailed Deployment Flow

```mermaid
graph TB
    subgraph "Phase 1: Prerequisites"
        A1[Verify Databricks Access] --> A2[Check Permissions:<br/>- CREATE SCHEMA<br/>- USE CATALOG<br/>- SQL Warehouse Access]
        A2 --> A3[Clone GitHub Repository]
        A3 --> A4{Databricks CLI<br/>Installed?}
        A4 -->|No| A5[Install CLI:<br/>pip install databricks-cli]
        A4 -->|Yes| A6[Authenticate:<br/>databricks auth login]
        A5 --> A6
    end

    subgraph "Phase 2: Data Layer (Scripts 01-03)"
        B1[01: Create Schemas<br/>- invoice_gold_semantic_poc<br/>- invoice_semantic_poc]
        B1 --> B2[02: Create Gold Tables<br/>- fact_invoice_line<br/>- 5 dimension tables]
        B2 --> B3[03: Load Seed Data<br/>~12 sample invoice lines]
    end

    subgraph "Phase 3: Metadata Layer (Scripts 04-06)"
        C1[04: Relationships Registry<br/>Define FK relationships]
        C1 --> C2[05: Metrics Registry<br/>Define business metrics]
        C2 --> C3[06: Synonyms Registry<br/>Natural language mappings]
    end

    subgraph "Phase 4: Semantic Layer (Script 07)"
        D1[07: Create Semantic Views<br/>6 views with curated measures]
        D1 --> D2[v_invoice_lines<br/>Base fact view]
        D1 --> D3[v_invoice_supplier<br/>Supplier dimension]
        D1 --> D4[v_invoice_item<br/>Item dimension]
        D1 --> D5[v_invoice_restaurant<br/>Restaurant dimension]
        D1 --> D6[v_invoice_dc<br/>DC dimension]
        D1 --> D7[v_invoice_calendar<br/>Time dimension]
    end

    subgraph "Phase 5: Security (Script 08)"
        E1[08: Apply Permissions<br/>- Grant access to semantic views<br/>- Restrict gold tables]
    end

    subgraph "Phase 6: Validation (Script 09)"
        F1[09: Run Validation Suite<br/>- Comment coverage check<br/>- Registry completeness<br/>- Data quality tests]
        F1 --> F2{All Validations Pass?}
        F2 -->|No| F3[Review Errors]
        F2 -->|Yes| F4[Proceed to Metric Views]
    end

    subgraph "Phase 7: Metric Views (Script 10)"
        G1[10: Create Metric Views<br/>5 pre-aggregated views]
        G1 --> G2[mv_invoice_supplier<br/>Supplier metrics]
        G1 --> G3[mv_invoice_item<br/>Item metrics]
        G1 --> G4[mv_invoice_restaurant<br/>Restaurant metrics]
        G1 --> G5[mv_invoice_dc<br/>DC metrics]
        G1 --> G6[mv_invoice_calendar<br/>Time-series metrics]
    end

    subgraph "Phase 8: Configure & Test"
        H1[Configure Genie Space<br/>Enable natural language queries]
        H1 --> H2[Test Queries<br/>- SQL queries<br/>- Genie questions<br/>- Dashboard creation]
        H2 --> H3[POC Complete!]
    end

    A6 --> B1
    B3 --> C1
    C3 --> D1
    D7 --> E1
    E1 --> F1
    F4 --> G1
    G6 --> H1

    style A6 fill:#e1f5ff
    style B3 fill:#fff9c4
    style C3 fill:#fff9c4
    style D7 fill:#c8e6c9
    style E1 fill:#ffcdd2
    style F4 fill:#c8e6c9
    style G6 fill:#c8e6c9
    style H3 fill:#4caf50,color:#fff
```

---

## Architecture Layers

```mermaid
graph TB
    subgraph "User Layer"
        U1[Business Analysts]
        U2[Data Engineers]
        U3[Executives]
    end

    subgraph "Query Interface Layer"
        Q1[Databricks Genie<br/>Natural Language]
        Q2[Databricks SQL Editor<br/>SQL Queries]
        Q3[Databricks Metrics UI<br/>No-Code Dashboards]
        Q4[BI Tools<br/>Tableau, Power BI, etc.]
    end

    subgraph "Semantic Layer (invoice_semantic_poc schema)"
        S1[Metric Views<br/>mv_*<br/>Pre-aggregated<br/>MEASURE function]
        S2[Semantic Views<br/>v_*<br/>Detail-level<br/>Enriched with dimensions]
        S3[Metadata Registries<br/>- Relationships<br/>- Metrics<br/>- Synonyms]
    end

    subgraph "Data Layer (invoice_gold_semantic_poc schema)"
        D1[Gold Tables<br/>- Fact: invoice lines<br/>- Dims: supplier, item, etc.]
    end

    subgraph "Unity Catalog"
        UC[Catalog: cfascdodev_primary<br/>Permissions & Governance]
    end

    U1 --> Q1
    U1 --> Q3
    U2 --> Q2
    U3 --> Q3

    Q1 --> S2
    Q2 --> S1
    Q2 --> S2
    Q3 --> S1
    Q4 --> S1
    Q4 --> S2

    S1 --> S2
    S2 --> S3
    S2 --> D1

    D1 --> UC
    S2 --> UC
    S1 --> UC

    style U1 fill:#e3f2fd
    style U2 fill:#e3f2fd
    style U3 fill:#e3f2fd
    style S1 fill:#c8e6c9
    style S2 fill:#fff9c4
    style D1 fill:#ffecb3
    style UC fill:#f3e5f5
```

---

## Decision Tree: Which Deployment Method?

```mermaid
graph TD
    A[Ready to Deploy?] --> B{Do you have<br/>Databricks CLI<br/>installed?}

    B -->|Yes| C{Comfortable with<br/>command line?}
    B -->|No| D[Manual UI Deployment<br/>docs/09_UI_DEPLOYMENT_README.md]

    C -->|Yes| E[Automated DAB Deployment<br/>docs/10_DAB_DEPLOYMENT_README.md]
    C -->|No| D

    E --> E1[cd invoice_semantic_layer/infra]
    E1 --> E2[databricks bundle deploy]
    E2 --> E3[databricks bundle run<br/>semantic_layer_deploy]
    E3 --> E4[✅ All 10 scripts run automatically]

    D --> D1[Open Databricks SQL Editor]
    D1 --> D2[Run scripts 01-10 manually<br/>one at a time]
    D2 --> D3[✅ Complete after ~15 minutes]

    E4 --> F[Validation]
    D3 --> F

    F --> G{Tests Pass?}
    G -->|Yes| H[Configure Genie]
    G -->|No| I[Check Troubleshooting Guide<br/>docs/14_METRIC_VIEWS_TROUBLESHOOTING.md]

    I --> J{Issue Resolved?}
    J -->|Yes| F
    J -->|No| K[Contact Support]

    H --> L[✅ POC Ready!]

    style E fill:#c8e6c9
    style D fill:#fff9c4
    style L fill:#4caf50,color:#fff
    style K fill:#ffcdd2
```

---

## Validation Flow

```mermaid
graph TB
    A[Run Validation Scripts] --> B[Check Deployment Status<br/>check_deployment_status.sql]

    B --> C{All Objects<br/>Created?}

    C -->|No| D[Missing Objects Found]
    D --> D1{Missing Schemas?}
    D --> D2{Missing Tables?}
    D --> D3{Missing Views?}
    D --> D4{Missing Metric Views?}

    D1 -->|Yes| E1[Run Script 01]
    D2 -->|Yes| E2[Run Scripts 02-03]
    D3 -->|Yes| E3[Run Script 07]
    D4 -->|Yes| E4[Run Script 10]

    E1 --> B
    E2 --> B
    E3 --> B
    E4 --> B

    C -->|Yes| F[Verify Permissions<br/>verify_permissions_select_only.sql]

    F --> G{Permissions<br/>Correct?}

    G -->|No| H[Run Script 08<br/>08_permissions_semantic_poc.sql]
    H --> F

    G -->|Yes| I[Validate Metric Views<br/>validate_metric_views.sql]

    I --> J{Metric Views<br/>Queryable?}

    J -->|No| K{Error Type?}
    K -->|MEASURE function| L[Use MEASURE syntax<br/>METRIC_VIEWS_CORRECT_SYNTAX.md]
    K -->|Column not found| M[Check column names<br/>Use backticks for spaces]
    K -->|View not found| N[Recreate metric views<br/>Run script 10]

    J -->|Yes| O[Test Sample Queries<br/>Run all validation steps]

    L --> I
    M --> I
    N --> I

    O --> P{All Queries<br/>Return Data?}

    P -->|No| Q[Review Query Syntax<br/>Check documentation]
    P -->|Yes| R[✅ Validation Complete!]

    Q --> O

    style R fill:#4caf50,color:#fff
    style D fill:#ffcdd2
    style K fill:#fff9c4
```

---

## Troubleshooting Decision Tree

```mermaid
graph TD
    A[Issue Encountered] --> B{What's the Problem?}

    B -->|Permission Denied| C1[Check Permissions<br/>Run verify_permissions.sql]
    C1 --> C2{Have SELECT<br/>on semantic views?}
    C2 -->|No| C3[Run Script 08<br/>Grant permissions]
    C2 -->|Yes| C4[Contact Admin<br/>Check catalog access]

    B -->|Views Not Found| D1[Check if views exist<br/>SHOW VIEWS command]
    D1 --> D2{Views Exist?}
    D2 -->|No| D3[Run Script 07<br/>Create semantic views]
    D2 -->|Yes| D4[Check schema name<br/>Use correct catalog.schema]

    B -->|Metric View Query Error| E1{Error Message?}
    E1 -->|MEASURE function| E2[Use MEASURE syntax<br/>MEASURE column]
    E1 -->|Column not found| E3[Use backticks<br/>Column Name]
    E1 -->|Feature not enabled| E4[Check Databricks Metrics<br/>Contact support]

    B -->|No Data Returned| F1[Check seed data loaded<br/>Script 03]
    F1 --> F2{Gold tables<br/>have data?}
    F2 -->|No| F3[Run Script 03<br/>Load seed data]
    F2 -->|Yes| F4[Check view definitions<br/>Verify joins]

    B -->|Validation Failures| G1[Review validation output<br/>Script 09]
    G1 --> G2{Comment coverage<br/>< 95%?}
    G2 -->|Yes| G3[Acceptable for POC<br/>Proceed anyway]
    G2 -->|No| G4[Check other validations<br/>Fix specific issues]

    B -->|DAB Deployment Failed| H1[Check CLI authentication<br/>databricks auth login]
    H1 --> H2{Authenticated?}
    H2 -->|No| H3[Run auth login<br/>Retry deployment]
    H2 -->|Yes| H4[Check bundle syntax<br/>databricks bundle validate]

    C3 --> Z[Retry Operation]
    C4 --> Z
    D3 --> Z
    D4 --> Z
    E2 --> Z
    E3 --> Z
    E4 --> Z
    F3 --> Z
    F4 --> Z
    G3 --> Z
    G4 --> Z
    H3 --> Z
    H4 --> Z

    Z --> AA{Issue Resolved?}
    AA -->|Yes| AB[✅ Continue Deployment]
    AA -->|No| AC[Check Documentation<br/>docs/14_METRIC_VIEWS_TROUBLESHOOTING.md]

    style AB fill:#4caf50,color:#fff
    style AC fill:#fff9c4
```

---

## Script Execution Order

```mermaid
graph LR
    subgraph "Required Order"
        S01[01_schemas] --> S02[02_gold_tables]
        S02 --> S03[03_seed_data]
        S03 --> S04[04_relationships]
        S04 --> S05[05_metrics]
        S05 --> S06[06_synonyms]
        S06 --> S07[07_semantic_views]
        S07 --> S10[10_metric_views]
        S10 --> S08[08_permissions]
        S08 --> S09[09_validation]
    end

    style S01 fill:#e3f2fd
    style S03 fill:#fff9c4
    style S07 fill:#c8e6c9
    style S10 fill:#c8e6c9
    style S09 fill:#4caf50,color:#fff
```

**Why this order?**
- **01-03**: Data layer must exist first
- **04-06**: Metadata registries reference tables from step 2
- **07**: Semantic views reference gold tables and registries
- **10**: Metric views reference semantic views
- **08**: Permissions applied after all objects created
- **09**: Validation runs last to verify everything

---

## Query Pattern Flow

```mermaid
graph TB
    A[User Question:<br/>What is total spend by supplier?] --> B{Query Method}

    B -->|Natural Language| C[Databricks Genie]
    C --> D[Genie translates to SQL]
    D --> E[Query semantic views]

    B -->|SQL Direct| F{Experience Level}

    F -->|Beginner| G[Use metric views<br/>Pre-aggregated data]
    G --> G1[SELECT Supplier Name,<br/>MEASURE Total Invoice Amount<br/>FROM mv_invoice_supplier<br/>GROUP BY Supplier Name]

    F -->|Advanced| H[Use semantic views<br/>Flexible aggregation]
    H --> H1[SELECT supplier_name,<br/>SUM invoice_amount<br/>FROM v_invoice_supplier<br/>GROUP BY supplier_name]

    F -->|No-Code| I[Databricks Metrics UI]
    I --> I1[Browse metric views<br/>Drag-and-drop visualization]

    G1 --> J[Results]
    H1 --> J
    E --> J
    I1 --> J

    J --> K[Ocean Catch: $464.23<br/>Fresh Farms: $401.83<br/>Spice Route: $67.80]

    style K fill:#c8e6c9
```

---

## Data Flow Architecture

```mermaid
graph LR
    subgraph "Source (Example)"
        A[Invoice System<br/>ERP/Billing]
    end

    subgraph "Bronze Layer (Not in POC)"
        B[Raw Data<br/>Landing Zone]
    end

    subgraph "Silver Layer (Not in POC)"
        C[Cleansed Data<br/>Standardized]
    end

    subgraph "Gold Layer (POC Starts Here)"
        D[Fact: invoice_line<br/>Dims: supplier, item, etc.]
    end

    subgraph "Semantic Layer"
        E[Semantic Views<br/>v_invoice_*<br/>Business-friendly names]
        F[Metric Views<br/>mv_invoice_*<br/>Pre-aggregated]
    end

    subgraph "Consumption Layer"
        G[Dashboards]
        H[Reports]
        I[Genie Q&A]
    end

    A -.-> B
    B -.-> C
    C -.-> D
    D --> E
    E --> F
    F --> G
    E --> G
    F --> H
    E --> H
    E --> I

    style D fill:#ffecb3
    style E fill:#fff9c4
    style F fill:#c8e6c9
    style G fill:#e1f5ff
    style H fill:#e1f5ff
    style I fill:#e1f5ff
```

**Note**: This POC starts at the Gold layer with pre-prepared sample data.

---

## Complete POC Timeline

```mermaid
gantt
    title Semantic Layer POC Deployment Timeline
    dateFormat mm:ss
    axisFormat %M:%S

    section Prerequisites
    Verify Access           :00:00, 02:00
    Clone Repository        :02:00, 01:00
    Install CLI (Optional)  :03:00, 02:00

    section Data Layer
    Create Schemas          :05:00, 00:30
    Create Gold Tables      :05:30, 01:00
    Load Seed Data          :06:30, 00:30

    section Metadata
    Relationships Registry  :07:00, 00:30
    Metrics Registry        :07:30, 00:30
    Synonyms Registry       :08:00, 00:30

    section Semantic Layer
    Create Semantic Views   :08:30, 01:00

    section Security
    Apply Permissions       :09:30, 00:30

    section Validation
    Run Validation Suite    :10:00, 01:00

    section Metric Views
    Create Metric Views     :11:00, 01:00

    section Testing
    Configure Genie         :12:00, 02:00
    Test Queries            :14:00, 01:00
```

**Total Time**: ~15 minutes (manual) or ~5 minutes (automated)

---

## Documentation Navigation Map

```mermaid
graph TB
    START[00_README_START_HERE.md<br/>Master Hub] --> QUICK[01_QUICK_START_GUIDE.md<br/>5-min overview]

    START --> ARCH[Architecture Docs]
    ARCH --> A1[03_ARCHITECTURE_OVERVIEW.md]
    ARCH --> A2[04_ARCHITECTURE_DETAILED.md]
    ARCH --> A3[05_SEMANTIC_COMPONENTS.md]

    START --> DEPLOY[Deployment Docs]
    DEPLOY --> D1[06_DEPLOYMENT_CHECKLIST.md]
    DEPLOY --> D2[07_DEPLOYMENT_WALKTHROUGH.md]
    DEPLOY --> D3[08_SQL_RUNBOOK.md]
    DEPLOY --> D4[09_UI_DEPLOYMENT_README.md]
    DEPLOY --> D5[10_DAB_DEPLOYMENT_README.md]
    DEPLOY --> D6[11_DAB_FLOW.md]

    START --> METRIC[Metric Views Docs]
    METRIC --> M1[12_METRIC_VIEWS_EXPLAINED.md]
    METRIC --> M2[13_METRIC_VIEWS_YAML_GUIDE.md]
    METRIC --> M3[14_METRIC_VIEWS_TROUBLESHOOTING.md]
    METRIC --> M4[METRIC_VIEWS_CORRECT_SYNTAX.md]
    METRIC --> M5[METRIC_VIEWS_QUERY_GUIDE.md]

    START --> POST[Post-Deployment]
    POST --> P1[16_GENIE_SPACE_SETUP.md]
    POST --> P2[17_CLEANUP_AND_REDEPLOY_GUIDE.md]

    START --> VALID[Validation Scripts]
    VALID --> V1[check_deployment_status.sql]
    VALID --> V2[verify_permissions_select_only.sql]
    VALID --> V3[validate_metric_views.sql]

    style START fill:#4caf50,color:#fff
    style QUICK fill:#c8e6c9
```

---

## Summary

This flowchart document provides:

✅ **7 different diagrams** showing:
1. High-level overview
2. Detailed step-by-step flow
3. Architecture layers
4. Decision tree for deployment method
5. Validation workflow
6. Troubleshooting decision tree
7. Script execution order

✅ **Additional diagrams** for:
- Query pattern flow
- Data flow architecture
- Complete timeline (Gantt chart)
- Documentation navigation map

---

## How to Use These Diagrams

1. **New stakeholders**: Start with "High-Level Overview"
2. **Deploying**: Follow "Detailed Deployment Flow" or "Decision Tree"
3. **Troubleshooting**: Use "Troubleshooting Decision Tree"
4. **Understanding architecture**: Review "Architecture Layers" and "Data Flow"
5. **Validating**: Follow "Validation Flow"

---

## Viewing on GitHub

These Mermaid diagrams will render automatically when you view this file on GitHub. For local viewing, use a Mermaid-compatible markdown viewer or the [Mermaid Live Editor](https://mermaid.live/).

---

## Related Documentation

- [00_README_START_HERE.md](invoice_semantic_layer/docs/00_README_START_HERE.md) - Master documentation hub
- [01_QUICK_START_GUIDE.md](invoice_semantic_layer/docs/01_QUICK_START_GUIDE.md) - Quick start guide
- [06_DEPLOYMENT_CHECKLIST.md](invoice_semantic_layer/docs/06_DEPLOYMENT_CHECKLIST.md) - Printable checklist
- [10_DAB_DEPLOYMENT_README.md](invoice_semantic_layer/docs/10_DAB_DEPLOYMENT_README.md) - Automated deployment
