
---1. Provide the LIST OF markets IN which customer "Atliq Exclusive" operates its business IN the APAC region.

SELECT market FROM gdb023.dim_customer  WHERE customer='Atliq Exclusive' AND region='APAC'
market       
-------------
India        
Indonesia    
Japan        
Philiphines  
South Korea  
Australia    
Newzealand   
Bangladesh   
India   
     
---2.What IS the percentage OF UNIQUE product increase IN 2021 vs. 2020? 

WITH unique_products_2020 AS
(SELECT COUNT(DISTINCT product_code) AS unique_products_2020 FROM gdb023.fact_sales_monthly WHERE fiscal_year=2020),
unique_products_2021 AS
(SELECT COUNT(DISTINCT product_code) AS unique_products_2021 FROM gdb023.fact_sales_monthly WHERE fiscal_year=2021 )

SELECT *, ((unique_products_2021-unique_products_2020)/ unique_products_2020)*100 AS percentage_chg 
FROM unique_products_2020,unique_products_2021

unique_products_2020  unique_products_2021  percentage_chg  
--------------------  --------------------  ----------------
                 245                   334           36.3265


---3. Provide a report WITH ALL the UNIQUE product counts FOR EACH segment AND sort them IN descending ORDER OF product counts. 

SELECT segment ,COUNT(DISTINCT product_code) AS product_count  FROM gdb023.dim_product GROUP BY segment
ORDER BY product_count DESC ;
segment      product_count  
-----------  ---------------
Notebook                 129
Accessories              116
Peripherals               84
Desktop                   32
STORAGE                   27
Networking                 9

---4.Follow-up: Which segment had the most increase IN UNIQUE products IN 2021 vs 2020? 

WITH unique_products_2020 AS
(SELECT p.segment, COUNT(DISTINCT p.product_code) AS unique_products_2020 FROM gdb023.dim_product  p
INNER JOIN gdb023.fact_sales_monthly s WHERE p.product_code= s.product_code
AND s.fiscal_year=2020 GROUP BY p.segment ORDER BY unique_products_2020 DESC),
unique_products_2021 AS
(SELECT p.segment, COUNT(DISTINCT p.product_code) AS unique_products_2021 FROM gdb023.dim_product  p
INNER JOIN gdb023.fact_sales_monthly s WHERE p.product_code= s.product_code
AND s.fiscal_year=2021 GROUP BY p.segment ORDER BY unique_products_2021 DESC)
SELECT *, (pc_2021.unique_products_2021-pc_2020.unique_products_2020) AS difference
FROM  unique_products_2020 AS pc_2020 
JOIN unique_products_2021   AS pc_2021 ON pc_2020.segment= pc_2021.segment  ORDER BY difference DESC

segment      unique_products_2020  segment      unique_products_2021  difference  
-----------  --------------------  -----------  --------------------  ------------
Accessories                    69  Accessories                   103            34
Notebook                       92  Notebook                      108            16
Peripherals                    59  Peripherals                    75            16
Desktop                         7  Desktop                        22            15
STORAGE                        12  STORAGE                        17             5
Networking                      6  Networking                      9             3

---5. Get the products that have the highest AND lowest manufacturing costs. 

SELECT p.product_code,p.product,mc.manufacturing_cost
FROM gdb023.dim_product AS p   JOIN 
gdb023.fact_manufacturing_cost AS  mc  ON p.product_code= mc.product_code 
WHERE mc.manufacturing_cost = (SELECT MAX(manufacturing_cost) AS manufacturing_cost FROM gdb023.fact_manufacturing_cost)
UNION
SELECT p.product_code,p.product,mc.manufacturing_cost
FROM gdb023.dim_product AS p   JOIN 
gdb023.fact_manufacturing_cost AS  mc  ON p.product_code= mc.product_code 
WHERE mc.manufacturing_cost = (SELECT MIN(manufacturing_cost) AS manufacturing_cost FROM gdb023.fact_manufacturing_cost)

product_code  product                manufacturing_cost  
------------  ---------------------  --------------------
A6120110206   AQ HOME Allin1 Gen 2               240.5364
A2118150101   AQ MASTER wired x1 Ms                0.8920

---6. Generate a report which CONTAINS the top 5 customers who received an average high pre_invoice_discount_pct

SELECT c.customer_code,c.customer, ROUND(AVG(i.pre_invoice_discount_pct) * 100 ,2)AS average_discount_percentage FROM gdb023.dim_customer AS c
INNER JOIN 
gdb023.fact_pre_invoice_deductions AS i  ON c.customer_code= i.customer_code
WHERE  c.market='India' AND i.fiscal_year= 2021  
GROUP BY c.customer,c.customer_code ORDER BY i.pre_invoice_discount_pct DESC LIMIT 5

customer_code  customer  average_discount_percentage  
-------------  --------  -----------------------------
     90002009  Flipkart                     0.30830000
     90002006  Viveks                       0.30380000
     90002003  Ezone                        0.30280000
     90002002  Croma                        0.30250000
     90002016  Amazon                       0.29330000


---7. Get the complete report OF the Gross sales amount FOR the customer “Atliq Exclusive” FOR EACH MONTH . 

SELECT MONTHNAME(fsm.date) AS MONTH,YEAR(fsm.date) AS YEAR,ROUND(SUM(fgp.gross_price* fsm.sold_quantity) ,2)AS Gross_sale_Amount FROM gdb023.dim_customer AS c 
INNER JOIN gdb023.fact_sales_monthly AS  fsm ON fsm.customer_code= c.customer_code
INNER JOIN gdb023.fact_gross_price AS  fgp ON fgp.product_code= fsm.product_code
WHERE c.customer='Atliq Exclusive' GROUP BY MONTH,YEAR  ORDER BY YEAR

MONTH        YEAR  Gross_sale_Amount  
---------  ------  -------------------
November     2019          15231894.97
October      2019          10378637.60
September    2019           9092670.34
December     2019           9755795.06
January      2020           9584951.94
March        2020            766976.45
April        2020            800071.95
May          2020           1586964.48
July         2020           5151815.40
August       2020           5638281.83
September    2020          19530271.30
November     2020          32247289.79
December     2020          20409063.18
October      2020          21016218.21
June         2020           3429736.57
February     2020           8083995.55
February     2021          15986603.89
June         2021          15457579.66
August       2021          11324548.34
July         2021          19044968.82
May          2021          19204309.41
April        2021          11483530.30
March        2021          19149624.92
January      2021          19570701.71

---8.In which QUARTER OF 2020, got the maximum total_sold_quantity? 

SELECT  
CASE 
WHEN MONTH(fsm.date) IN (9,10,11) THEN 'Q1'
WHEN MONTH(fsm.date) IN (12,1,2) THEN 'Q2'
WHEN MONTH(fsm.date) IN (3,4,5) THEN 'Q3'
WHEN MONTH(fsm.date) IN (6,7,8) THEN 'Q4'
END AS  QUARTER,
SUM(fsm.sold_quantity) AS total_sold_quantity
FROM gdb023.fact_sales_monthly AS fsm WHERE fsm.fiscal_year= 2020
GROUP BY QUARTER ORDER BY total_sold_quantity DESC

QUARTER  total_sold_quantity  
-------  ---------------------
Q1                     7005619
Q2                     6649642
Q4                     5042541
Q3                     2075087

---9. Which CHANNEL helped TO bring more gross sales IN the fiscal YEAR 2021 AND the percentage OF contribution? 

WITH gsm AS
(SELECT c. CHANNEL,SUM(fgp.gross_price * fsm.sold_quantity) AS gross_sales 
FROM gdb023.dim_customer c
INNER JOIN  gdb023.fact_sales_monthly AS fsm ON c.customer_code= fsm.customer_code
INNER JOIN gdb023.fact_gross_price AS  fgp ON fsm.product_code= fgp.product_code
WHERE fsm.fiscal_year= 2021 GROUP BY c.channel ORDER BY gross_sales DESC)
SELECT CHANNEL, ROUND(gross_sales/1000000,2) AS gross_sales_mln, 
ROUND(gross_sales/(SELECT SUM(gross_sales) FROM gsm)* 100,2) AS percentage
FROM gsm;

CHANNEL      gross_sales_mln  percentage  
-----------  ---------------  ------------
Retailer             1924.17         73.22
Direct                406.69         15.47
Distributor           297.18         11.31

---10.Get the Top 3 products IN EACH division that have a high total_sold_quantity IN the fiscal_year 2021? 

SELECT p.product_code, SUM(fsm.sold_quantity) OVER (PARTITION  BY P.division) AS total_quantity
FROM gdb023.dim_product AS p
INNER JOIN  gdb023.fact_sales_monthly AS fsm WHERE fsm.fiscal_year= 2021

WITH CTE AS
(SELECT p.product_code,p.division,SUM(fsm.sold_quantity) AS total_quantity,
RANK() OVER(PARTITION BY p.division ORDER BY SUM(fsm.sold_quantity)DESC ) AS rank_order
FROM gdb023.dim_product AS p
INNER JOIN  gdb023.fact_sales_monthly AS fsm ON p.product_code= fsm.product_code  
WHERE fsm.fiscal_year= 2021 GROUP BY p.division,p.product_code)
SELECT * FROM CTE WHERE rank_order <=3

product_code  division  total_quantity  rank_order  
------------  --------  --------------  ------------
A6720160103   N & S             701373             1
A6818160202   N & S             688003             2
A6819160203   N & S             676245             3
A2319150302   P & A             428498             1
A2520150501   P & A             419865             2
A2520150504   P & A             419471             3
A4218110202   PC                 17434             1
A4319110306   PC                 17280             2
A4218110208   PC                 17275             3