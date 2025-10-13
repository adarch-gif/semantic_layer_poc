-- Benchmark questions for semantic PoC

USE CATALOG cfascdodev_primary;

-- Q1
SELECT supplier_name,
       SUM(invoice_amount) AS total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY total_spend DESC;

-- Q2
SELECT supplier_name,
       SUM(invoice_amount) AS total_spend,
       SUM(freight_cost) AS total_freight,
       SUM(tax_cost) AS total_tax
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY supplier_name;

-- Q3
SELECT item_category,
       AVG(net_line_amount / NULLIF(line_quantity,0)) AS avg_unit_price
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc
GROUP BY item_category
ORDER BY avg_unit_price DESC;

-- Q4
SELECT restaurant_name,
       COUNT(*) AS invoice_lines
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc
GROUP BY restaurant_name
ORDER BY invoice_lines DESC;

-- Q5
SELECT dc_name,
       SUM(invoice_amount) AS total_spend,
       SUM(freight_cost) AS total_freight
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_dc_semantic_poc
GROUP BY dc_name
ORDER BY total_spend DESC;

-- Q6
SELECT item_name,
       SUM(line_quantity) AS total_quantity
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc
GROUP BY item_name
ORDER BY total_quantity DESC;

-- Q7
SELECT restaurant_region,
       SUM(invoice_amount) AS total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc
GROUP BY restaurant_region
ORDER BY total_spend DESC;

-- Q8
SELECT supplier_name,
       SUM(discount_amount) AS total_discounts
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY total_discounts DESC;

-- Q9
SELECT invoice_date,
       SUM(invoice_amount) AS total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_lines_semantic_poc
WHERE invoice_date = DATE '2024-01-06'
GROUP BY invoice_date;

-- Q10
SELECT supplier_name,
       SUM(freight_cost) AS total_freight,
       SUM(tax_cost) AS total_tax
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY supplier_name;

-- Q11
SELECT restaurant_name,
       AVG(net_line_amount / NULLIF(line_quantity,0)) AS avg_unit_price
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc
GROUP BY restaurant_name
ORDER BY avg_unit_price DESC;

-- Q12
SELECT invoice_date,
       SUM(invoice_amount) AS total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_lines_semantic_poc
GROUP BY invoice_date
ORDER BY invoice_date;

-- Q13
SELECT dc_name,
       SUM(invoice_amount) AS total_spend,
       SUM(line_quantity) AS total_quantity
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_dc_semantic_poc
GROUP BY dc_name
ORDER BY total_spend DESC;

-- Q14
SELECT COUNT(DISTINCT supplier_id) AS active_suppliers
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
WHERE supplier_active_flag;

-- Q15
SELECT currency_code,
       SUM(invoice_amount) AS total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_lines_semantic_poc
GROUP BY currency_code;

-- Q16
SELECT supplier_name,
       SUM(line_quantity) AS total_quantity,
       SUM(invoice_amount) AS total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY total_spend DESC;

-- Q17
SELECT item_category,
       SUM(discount_amount) AS total_discounts
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc
GROUP BY item_category
ORDER BY total_discounts DESC;

-- Q18
SELECT fiscal_period,
       SUM(invoice_amount) AS total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_calendar_semantic_poc
GROUP BY fiscal_period
ORDER BY fiscal_period;
