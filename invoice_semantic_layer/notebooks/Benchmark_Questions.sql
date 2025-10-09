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

-- Q1: Which suppliers generated the highest total spend this week?
-- Expected SQL: SUM(invoice_amount) grouped by supplier_name filtered to current week.
-- Expected Answer Pattern: Supplier name with total spend sorted descending.
SELECT supplier_name,
       SUM(invoice_amount) AS total_spend
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier
GROUP BY supplier_name
ORDER BY total_spend DESC;

-- Q2: What is the average unit price by item category?
-- Expected SQL: AVG(unit_price) grouped by item_category.
-- Expected Answer Pattern: Item category with average unit price sorted descending.
SELECT item_category,
       AVG(unit_price) AS avg_unit_price
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item
GROUP BY item_category
ORDER BY avg_unit_price DESC;

-- Q3: How many invoice lines did each distribution center process?
-- Expected SQL: SUM(line_count) using invoice_amount view grouped by dc_name.
-- Expected Answer Pattern: Distribution center with line count sorted descending.
SELECT dc_name,
       COUNT(DISTINCT invoice_line_id) AS line_count
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc
GROUP BY dc_name
ORDER BY line_count DESC;

-- Q4: What was the total freight cost by distribution center region?
-- Expected SQL: SUM(freight_cost) grouped by dc_region.
-- Expected Answer Pattern: Region with freight total descending.
SELECT dc_region,
       SUM(freight_cost) AS total_freight_cost
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc
GROUP BY dc_region
ORDER BY total_freight_cost DESC;

-- Q5: Show total spend per restaurant region.
-- Expected SQL: SUM(invoice_amount) grouped by restaurant_region.
-- Expected Answer Pattern: Region with spend descending.
SELECT restaurant_region,
       SUM(invoice_amount) AS total_spend
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant
GROUP BY restaurant_region
ORDER BY total_spend DESC;

-- Q6: Which suppliers applied the largest discounts?
-- Expected SQL: SUM(discount_amount) grouped by supplier_name.
-- Expected Answer Pattern: Supplier with total discounts descending.
SELECT supplier_name,
       SUM(discount_amount) AS total_discounts
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier
GROUP BY supplier_name
ORDER BY total_discounts DESC;

-- Q7: For each item, what is the total quantity purchased?
-- Expected SQL: SUM(line_quantity) grouped by item_name.
-- Expected Answer Pattern: Item with quantity descending.
SELECT item_name,
       SUM(line_quantity) AS total_quantity
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item
GROUP BY item_name
ORDER BY total_quantity DESC;

-- Q8: Provide total spend and freight cost per supplier category.
-- Expected SQL: SUM(invoice_amount), SUM(freight_cost) grouped by supplier_category.
-- Expected Answer Pattern: Supplier category with spend and freight columns.
SELECT supplier_category,
       SUM(invoice_amount) AS total_spend,
       SUM(freight_cost) AS total_freight
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier
GROUP BY supplier_category
ORDER BY total_spend DESC;

-- Q9: How much tax was paid per fiscal period?
-- Expected SQL: SUM(tax_cost) grouped by fiscal_period.
-- Expected Answer Pattern: Fiscal period with total tax sorted chronologically.
SELECT fiscal_period,
       SUM(tax_cost) AS total_tax_cost
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar
GROUP BY fiscal_period
ORDER BY fiscal_period;

-- Q10: Which restaurant has the highest average unit price?
-- Expected SQL: AVG(unit_price) grouped by restaurant_name.
-- Expected Answer Pattern: Restaurant with avg unit price descending.
SELECT restaurant_name,
       AVG(unit_price) AS avg_unit_price
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant
GROUP BY restaurant_name
ORDER BY avg_unit_price DESC;

-- Q11: What is the spend split by currency?
-- Expected SQL: SUM(invoice_amount) grouped by currency_code.
-- Expected Answer Pattern: Currency with total spend.
SELECT currency_code,
       SUM(invoice_amount) AS total_spend
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines
GROUP BY currency_code
ORDER BY total_spend DESC;

-- Q12: Show spend trend by invoice date.
-- Expected SQL: SUM(invoice_amount) grouped by invoice_date ordered ascending.
-- Expected Answer Pattern: Date with spend, verifying continuous coverage.
SELECT invoice_date,
       SUM(invoice_amount) AS total_spend
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_lines
GROUP BY invoice_date
ORDER BY invoice_date;

-- Q13: Compare freight vs tax for each supplier.
-- Expected SQL: SUM(freight_cost), SUM(tax_cost) grouped by supplier_name.
-- Expected Answer Pattern: Supplier with both cost columns.
SELECT supplier_name,
       SUM(freight_cost) AS total_freight_cost,
       SUM(tax_cost) AS total_tax_cost
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier
GROUP BY supplier_name
ORDER BY supplier_name;

-- Q14: Identify top items by spend in each restaurant region.
-- Expected SQL: SUM(invoice_amount) grouped by restaurant_region, item_name with ranking.
-- Expected Answer Pattern: Region, item, spend sorted by region then spend desc.
SELECT restaurant_region,
       item_name,
       SUM(invoice_amount) AS total_spend
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant r
JOIN `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_item i
  ON r.invoice_id = i.invoice_id AND r.invoice_line_id = i.invoice_line_id
GROUP BY restaurant_region, item_name
ORDER BY restaurant_region, total_spend DESC;

-- Q15: How many active suppliers contributed to spend?
-- Expected SQL: COUNT DISTINCT suppliers with spend >0.
-- Expected Answer Pattern: Single row count.
SELECT COUNT(DISTINCT CASE WHEN supplier_active_flag THEN supplier_id END) AS active_supplier_count
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_supplier;

-- Q16: What is the average unit price by fiscal period?
-- Expected SQL: AVG(unit_price) grouped by fiscal_period.
-- Expected Answer Pattern: Fiscal period with average unit price.
SELECT fiscal_period,
       AVG(unit_price) AS avg_unit_price
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_calendar
GROUP BY fiscal_period
ORDER BY fiscal_period;

-- Q17: Provide total quantity and spend for each distribution center.
-- Expected SQL: SUM(line_quantity), SUM(invoice_amount) grouped by dc_name.
-- Expected Answer Pattern: DC name with quantity and spend.
SELECT dc_name,
       SUM(line_quantity) AS total_quantity,
       SUM(invoice_amount) AS total_spend
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_dc
GROUP BY dc_name
ORDER BY total_spend DESC;

-- Q18: Show total discounts by restaurant.
-- Expected SQL: SUM(discount_amount) grouped by restaurant_name.
-- Expected Answer Pattern: Restaurant with discount total descending.
SELECT restaurant_name,
       SUM(discount_amount) AS total_discounts
FROM `${CATALOG}`.`${SCHEMA_SEM}`.v_invoice_restaurant
GROUP BY restaurant_name
ORDER BY total_discounts DESC;
