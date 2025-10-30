# Semantic Layer Architecture Overview

## Audience & Intent
- **Who**: Product owners, analytics leaders, and engineering stakeholders who need the "big picture" view.
- **What**: High-level structure of the semantic layer, how data moves, and the major control points.
- **Why**: Establish shared understanding before diving into detailed design or implementation documents.

## Visual 1 - Layered Architecture (What lives where)
```mermaid
graph TB
  subgraph Platform
    UC[Unity Catalog]
    WH[SQL Warehouse]
  end

  subgraph Data_Layers
    Bronze[Bronze Ingestion]
    Silver[Silver Curation]
    Gold[Gold Star Schema]
  end

  subgraph Semantic_Layer
    Registries((Relationship / Metric / Synonym Registries))
    SemanticViews[[Semantic Views]]
    Validation[(Validation & Metadata Tests)]
  end

  subgraph Consumption
    Genie[Genie Space]
    Dashboards[Dashboards / BI]
  end

  Bronze --> Silver
  Silver --> Gold
  Gold --> SemanticViews
  Registries --> Genie
  SemanticViews --> Genie
  Genie --> Dashboards
  UC --> Gold
  UC --> SemanticViews
  UC --> Registries
  WH --> Validation
  WH --> Genie
  Validation --> UC
  Validation --> WH
```
**Explanation**: Raw data lands in medallion layers (bronze -> silver -> gold). The semantic schema layers curated views and registries on top, all governed by Unity Catalog. Genie consumes only semantic assets so analysts see clean data.

## Visual 2 - Data Flow at a Glance (How information travels)
```mermaid
graph LR
  RawFiles[Supplier Invoice Files] --> BronzeETL[Ingestion Jobs]
  BronzeETL --> BronzeDelta[Bronze Tables]
  BronzeDelta --> SilverJobs[Standardisation Jobs]
  SilverJobs --> SilverDelta[Silver Tables]
  SilverDelta --> GoldModeling[Dimensional Modeling]
  GoldModeling --> Fact[fact_invoice_line]
  GoldModeling --> DimSupplier[dim_supplier]
  GoldModeling --> DimItem[dim_item]
  GoldModeling --> DimRestaurant[dim_restaurant]
  GoldModeling --> DimDC[dim_dc]
  GoldModeling --> DimDate[dim_date]
  Fact --> SemanticBuild[Semantic Views & Registries]
  DimSupplier --> SemanticBuild
  DimItem --> SemanticBuild
  DimRestaurant --> SemanticBuild
  DimDC --> SemanticBuild
  DimDate --> SemanticBuild
  SemanticBuild --> GenieConfig[Genie Space]
  GenieConfig --> Analysts
```
**Explanation**: Once gold tables exist, semantic scripts project business-friendly views and registries. Genie is configured over those assets, giving analysts curated access without touching raw tables.

## Visual 3 - Deployment Flow (Step-by-step execution order)
```mermaid
flowchart TD
  A[Start] --> B[Validate environment placeholders]
  B --> C[01_schemas.sql]
  C --> D[02_gold_tables.sql]
  D --> E[03_seed_data.sql]
  E --> F[04_relationship_registry.sql]
  F --> G[05_metrics_registry.sql]
  G --> H[06_synonyms_registry.sql]
  H --> I[07_semantic_views.sql]
  I --> J[10_metric_views.sql]
  J --> K[08_permissions.sql]
  K --> L[09_validation.sql]
  L --> M[metadata_gap_report.sql]
  M --> N[Benchmark_Questions.sql]
  N --> O[Configure Genie Space]
  O --> P[Deploy databricks.yml]
  P --> Q[Schedule jobs.json]
  Q --> R[Operate & iterate]
```
**Explanation**: The flow highlights when each asset is applied and the dependencies between them. Validation and automation steps provide the control gates.

## Pillars & Benefits
| Pillar | Components | Why it Matters |
|--------|------------|----------------|
| Governance by design | Unity Catalog, permissions script, comment standards | Ensures analysts only access curated assets and every object is documented. |
| Semantic intelligence | Views, relationship registry, metrics registry, synonyms | Gives Genie (and analysts) consistent joins, definitions, and NLQ vocabulary. |
| Quality assurance | Validation SQL, metadata gap report, benchmarks | Catches issues early-missing comments, broken joins, metric drift-before analysts are impacted. |
| Automation & longevity | Databricks Asset Bundle, scheduled jobs | Keeps environments aligned, automates validations, and supports production operations. |

## Key Takeaways
- All analyst queries should flow through semantic views; direct gold access is intentionally blocked.
- Registries (relationships, metrics, synonyms) are the "brains" enabling NLQ accuracy and consistent KPIs.
- Validation, automation, and documentation are not optional extras-they protect trust and speed.

For deeper technical detail, owners can refer to `ARCHITECTURE_DETAILED.md`.

