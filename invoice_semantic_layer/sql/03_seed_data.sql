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

INSERT OVERWRITE `${CATALOG}`.`${SCHEMA_GOLD}`.dim_supplier
SELECT * FROM VALUES
  (''SUP-001'',''Fresh Farms'',''Produce'',''US'',TRUE,DATE ''2023-01-01'',DATE ''9999-12-31''),
  (''SUP-002'',''Ocean Catch'',''Seafood'',''US'',TRUE,DATE ''2023-01-01'',DATE ''9999-12-31''),
  (''SUP-003'',''Spice Route'',''Dry Goods'',''MX'',TRUE,DATE ''2023-06-01'',DATE ''9999-12-31'')
AS v(supplier_id,supplier_name,supplier_category,country_code,active_flag,effective_from,effective_to);

INSERT OVERWRITE `${CATALOG}`.`${SCHEMA_GOLD}`.dim_item
SELECT * FROM VALUES
  (''ITEM-100'',''Romaine Lettuce'',''Produce'',''CASE'',''FreshCo'',TRUE,DATE ''2023-01-01'',DATE ''9999-12-31''),
  (''ITEM-200'',''Atlantic Salmon'',''Seafood'',''LB'',''OceanBest'',TRUE,DATE ''2023-01-01'',DATE ''9999-12-31''),
  (''ITEM-300'',''Cumin Spice'',''Dry Goods'',''LB'',''SpiceMaster'',TRUE,DATE ''2023-06-01'',DATE ''9999-12-31'')
AS v(item_id,item_name,item_category,uom,brand,active_flag,effective_from,effective_to);

INSERT OVERWRITE `${CATALOG}`.`${SCHEMA_GOLD}`.dim_restaurant
SELECT * FROM VALUES
  (''RES-ATL-01'',''Atlanta Downtown'',''1201'',''Southeast'',''America/New_York'',DATE ''2018-04-15'',TRUE),
  (''RES-DFW-02'',''Dallas Uptown'',''2305'',''South'',''America/Chicago'',DATE ''2019-08-20'',TRUE),
  (''RES-LAX-03'',''Los Angeles Central'',''3407'',''West'',''America/Los_Angeles'',DATE ''2020-02-11'',TRUE)
AS v(restaurant_id,restaurant_name,location_number,region,timezone,open_date,active_flag);

INSERT OVERWRITE `${CATALOG}`.`${SCHEMA_GOLD}`.dim_dc
SELECT * FROM VALUES
  (''DC-ATL'',''Atlanta DC'',''ATL'',''Southeast'',''America/New_York'',TRUE),
  (''DC-DFW'',''Dallas DC'',''DFW'',''South'',''America/Chicago'',TRUE),
  (''DC-LAX'',''Los Angeles DC'',''LAX'',''West'',''America/Los_Angeles'',TRUE)
AS v(dc_id,dc_name,dc_code,region,timezone,active_flag);

INSERT OVERWRITE `${CATALOG}`.`${SCHEMA_GOLD}`.dim_date
SELECT * FROM VALUES
  (DATE ''2024-01-05'',2024,1,1,1,5,FALSE,2024,''2024-P01''),
  (DATE ''2024-01-06'',2024,1,1,1,6,TRUE,2024,''2024-P01''),
  (DATE ''2024-01-07'',2024,1,1,1,7,TRUE,2024,''2024-P01''),
  (DATE ''2024-01-08'',2024,1,1,2,8,FALSE,2024,''2024-P01'')
AS v(date_key,year,quarter,month,week,day,is_weekend,fiscal_year,fiscal_period);

INSERT OVERWRITE `${CATALOG}`.`${SCHEMA_GOLD}`.fact_invoice_line
(invoice_id,line_id,supplier_id,restaurant_id,dc_id,item_id,invoice_date,quantity,unit_price,freight_amount,tax_amount,discount_amount,currency_code,load_ts,src_file)
SELECT * FROM VALUES
  (''INV-1001'',''1'',''SUP-001'',''RES-ATL-01'',''DC-ATL'',''ITEM-100'',DATE ''2024-01-05'',CAST(20.000 AS DECIMAL(18,3)),CAST(12.5000 AS DECIMAL(18,4)),CAST(5.5000 AS DECIMAL(18,4)),CAST(7.2000 AS DECIMAL(18,4)),CAST(3.0000 AS DECIMAL(18,4)),''USD'',TIMESTAMP ''2024-01-10 08:15:00'',''landing/invoice_20240105_sup001.csv''),
  (''INV-1002'',''1'',''SUP-002'',''RES-DFW-02'',''DC-DFW'',''ITEM-200'',DATE ''2024-01-06'',CAST(45.500 AS DECIMAL(18,3)),CAST(9.7500 AS DECIMAL(18,4)),CAST(8.2500 AS DECIMAL(18,4)),CAST(12.3500 AS DECIMAL(18,4)),CAST(0.0000 AS DECIMAL(18,4)),''USD'',TIMESTAMP ''2024-01-10 08:20:00'',''landing/invoice_20240106_sup002.csv''),
  (''INV-1002'',''2'',''SUP-003'',''RES-DFW-02'',''DC-DFW'',''ITEM-300'',DATE ''2024-01-06'',CAST(15.250 AS DECIMAL(18,3)),CAST(4.2000 AS DECIMAL(18,4)),CAST(2.1500 AS DECIMAL(18,4)),CAST(3.1000 AS DECIMAL(18,4)),CAST(1.5000 AS DECIMAL(18,4)),''USD'',TIMESTAMP ''2024-01-10 08:20:00'',''landing/invoice_20240106_sup003.csv''),
  (''INV-1003'',''1'',''SUP-001'',''RES-LAX-03'',''DC-LAX'',''ITEM-100'',DATE ''2024-01-08'',CAST(10.000 AS DECIMAL(18,3)),CAST(13.2500 AS DECIMAL(18,4)),CAST(4.6000 AS DECIMAL(18,4)),CAST(5.7800 AS DECIMAL(18,4)),CAST(0.7500 AS DECIMAL(18,4)),''USD'',TIMESTAMP ''2024-01-10 08:25:00'',''landing/invoice_20240108_sup001.csv'');
