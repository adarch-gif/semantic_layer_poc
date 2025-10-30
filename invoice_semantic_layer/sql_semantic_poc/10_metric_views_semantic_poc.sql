-- Metric views built on top of the semantic PoC perspectives using the YAML syntax.

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_supplier_semantic_poc
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
comment: "Supplier spend, freight, tax, discounts, and invoice line counts."
source: cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
timestamp: invoice_date
dimensions:
  - name: Supplier ID
    expr: supplier_id
  - name: Supplier Name
    expr: supplier_name
  - name: Supplier Category
    expr: supplier_category
  - name: Supplier Country
    expr: supplier_country
  - name: Supplier Active Flag
    expr: supplier_active_flag
  - name: Currency Code
    expr: currency_code
measures:
  - name: Total Net Spend
    expr: SUM(COALESCE(net_line_amount, 0))
  - name: Total Invoice Amount
    expr: SUM(COALESCE(invoice_amount, 0))
  - name: Total Line Quantity
    expr: SUM(COALESCE(line_quantity, 0))
  - name: Total Freight Cost
    expr: SUM(COALESCE(freight_cost, 0))
  - name: Total Tax Cost
    expr: SUM(COALESCE(tax_cost, 0))
  - name: Total Discount Amount
    expr: SUM(COALESCE(discount_amount, 0))
  - name: Invoice Line Count
    expr: COUNT(1)
owners:
  - name: Finance Analytics
    email: finance.analytics@example.com
tags:
  - supplier-insights
$$;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_item_semantic_poc
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
comment: "Item-level performance metrics for spend, quantity, freight, and tax."
source: cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc
timestamp: invoice_date
dimensions:
  - name: Item ID
    expr: item_id
  - name: Item Name
    expr: item_name
  - name: Item Category
    expr: item_category
  - name: Unit of Measure
    expr: uom
  - name: Brand
    expr: brand
  - name: Item Active Flag
    expr: item_active_flag
  - name: Currency Code
    expr: currency_code
measures:
  - name: Total Net Spend
    expr: SUM(COALESCE(net_line_amount, 0))
  - name: Total Invoice Amount
    expr: SUM(COALESCE(invoice_amount, 0))
  - name: Total Line Quantity
    expr: SUM(COALESCE(line_quantity, 0))
  - name: Total Discount Amount
    expr: SUM(COALESCE(discount_amount, 0))
  - name: Total Freight Cost
    expr: SUM(COALESCE(freight_cost, 0))
  - name: Total Tax Cost
    expr: SUM(COALESCE(tax_cost, 0))
  - name: Invoice Line Count
    expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_restaurant_semantic_poc
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
comment: "Restaurant spend and logistics performance by region, timezone, and location."
source: cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc
timestamp: invoice_date
dimensions:
  - name: Restaurant ID
    expr: restaurant_id
  - name: Restaurant Name
    expr: restaurant_name
  - name: Location Number
    expr: location_number
  - name: Restaurant Region
    expr: restaurant_region
  - name: Restaurant Timezone
    expr: restaurant_timezone
  - name: Restaurant Active Flag
    expr: restaurant_active_flag
  - name: Currency Code
    expr: currency_code
measures:
  - name: Total Net Spend
    expr: SUM(COALESCE(net_line_amount, 0))
  - name: Total Invoice Amount
    expr: SUM(COALESCE(invoice_amount, 0))
  - name: Total Line Quantity
    expr: SUM(COALESCE(line_quantity, 0))
  - name: Total Freight Cost
    expr: SUM(COALESCE(freight_cost, 0))
  - name: Total Tax Cost
    expr: SUM(COALESCE(tax_cost, 0))
  - name: Total Discount Amount
    expr: SUM(COALESCE(discount_amount, 0))
  - name: Invoice Line Count
    expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_dc_semantic_poc
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
comment: "Distribution center spend and logistics metrics."
source: cfascdodev_primary.invoice_semantic_poc.v_invoice_dc_semantic_poc
timestamp: invoice_date
dimensions:
  - name: Distribution Center ID
    expr: dc_id
  - name: Distribution Center Name
    expr: dc_name
  - name: Distribution Center Code
    expr: dc_code
  - name: Distribution Center Region
    expr: dc_region
  - name: Distribution Center Timezone
    expr: dc_timezone
  - name: Distribution Center Active Flag
    expr: dc_active_flag
  - name: Currency Code
    expr: currency_code
measures:
  - name: Total Net Spend
    expr: SUM(COALESCE(net_line_amount, 0))
  - name: Total Invoice Amount
    expr: SUM(COALESCE(invoice_amount, 0))
  - name: Total Line Quantity
    expr: SUM(COALESCE(line_quantity, 0))
  - name: Total Freight Cost
    expr: SUM(COALESCE(freight_cost, 0))
  - name: Total Tax Cost
    expr: SUM(COALESCE(tax_cost, 0))
  - name: Total Discount Amount
    expr: SUM(COALESCE(discount_amount, 0))
  - name: Invoice Line Count
    expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `cfascdodev_primary`.`invoice_semantic_poc`.mv_invoice_calendar_semantic_poc
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
comment: "Calendar and fiscal trend metrics for invoice spend and quantity."
source: cfascdodev_primary.invoice_semantic_poc.v_invoice_calendar_semantic_poc
timestamp: invoice_date
dimensions:
  - name: Date Key
    expr: date_key
  - name: Calendar Year
    expr: calendar_year
  - name: Calendar Quarter
    expr: calendar_quarter
  - name: Calendar Month
    expr: calendar_month
  - name: Calendar Week
    expr: calendar_week
  - name: Calendar Day
    expr: calendar_day
  - name: Weekend Flag
    expr: is_weekend
  - name: Fiscal Year
    expr: fiscal_year
  - name: Fiscal Period
    expr: fiscal_period
  - name: Currency Code
    expr: currency_code
measures:
  - name: Total Net Spend
    expr: SUM(COALESCE(net_line_amount, 0))
  - name: Total Invoice Amount
    expr: SUM(COALESCE(invoice_amount, 0))
  - name: Total Line Quantity
    expr: SUM(COALESCE(line_quantity, 0))
  - name: Total Freight Cost
    expr: SUM(COALESCE(freight_cost, 0))
  - name: Total Tax Cost
    expr: SUM(COALESCE(tax_cost, 0))
  - name: Total Discount Amount
    expr: SUM(COALESCE(discount_amount, 0))
  - name: Invoice Line Count
    expr: COUNT(1)
$$;
