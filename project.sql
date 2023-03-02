-- productLines has the product line, text and html descriptions, and an image of the item 
-- products has all of the information about a product, like its code, name, quantity in stock, buy price, and description
-- orderdetails contains information like the order number, quantity ordered, and price of each item
-- orders contains more information about an order than orderdetails, like the order number, ship date, required date, and customer number
-- payments contains the customer number, the check number, payment date, and the amount
-- customers contains all of the information about the customer, like first and last name, customer number, address, phone number, and sales rep employee number
-- offices contain the location about the information of offices, their phone number, and the office code
-- employees contains information about the employees, like the employee number, first and last names, email, job title, and who they report to

-- table descriptions and data
SELECT "Customers" AS table_name,
       (SELECT COUNT(*)
          FROM pragma_table_info('customers')) AS number_of_attributes, 
	   COUNT(*) AS number_of_rows
  FROM customers
  
UNION ALL

SELECT "Products" AS table_name,
       (SELECT COUNT(*)
          FROM pragma_table_info('products')) AS number_of_attributes,
       COUNT(*) AS number_of_rows
  FROM products

UNION ALL

SELECT "ProductLines" AS table_name,
       (SELECT COUNT(*)
          FROM pragma_table_info('productlines')) AS number_of_attributes,
       COUNT(*) AS number_of_rows
  FROM productlines
  
UNION ALL

SELECT "Orders" AS table_name,
       (SELECT COUNT(*)
          FROM pragma_table_info('orders')) AS number_of_attributes,
       COUNT(*) AS number_of_rows
  FROM orders
  
UNION ALL

SELECT "OrderDetails" AS table_name,
       (SELECT COUNT(*)
          FROM pragma_table_info('orderdetails')) AS number_of_attributes,
       COUNT(*) AS number_of_rows
  FROM orderdetails
  
UNION ALL

SELECT "Payments" AS table_name,
       (SELECT COUNT(*)
          FROM pragma_table_info('payments')) AS number_of_attributes,
       COUNT(*) AS number_of_rows
  FROM payments
  
UNION ALL

SELECT "Employees" AS table_name,
       (SELECT COUNT(*)
          FROM pragma_table_info('employees')) AS number_of_attributes,
       COUNT(*) AS number_of_rows
  FROM employees
  
UNION ALL

SELECT "Offices" AS table_name,
       (SELECT COUNT(*)
          FROM pragma_table_info('offices')) AS number_of_attributes,
       COUNT(*) AS number_of_rows
  FROM offices;
  
--low stock
SELECT productCode,
       ROUND(SUM(quantityOrdered)*1.0/(SELECT quantityInStock
	                                     FROM products AS p
										WHERE p.productCode=od.productCode), 2) AS low_stock
  FROM orderdetails AS od
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10;
 
 --product performance
SELECT productCode,
       SUM(quantityOrdered*priceEach) AS productPerformance
  FROM orderdetails
 GROUP BY productCode
 ORDER BY productPerformance DESC
 LIMIT 10;
 
 --priority products for restocking
 WITH 

 lowStockTable AS(
SELECT productCode,
       ROUND(SUM(quantityOrdered)*1.0/(SELECT quantityInStock
	                                     FROM products AS p
										WHERE p.productCode=od.productCode), 2) AS lowStock
  FROM orderdetails AS od
 GROUP BY productCode
 ORDER BY lowStock DESC
 LIMIT 10
 )
 
 SELECT productCode,
       SUM(quantityOrdered*priceEach) AS productPerformance
  FROM orderdetails
 WHERE productCode IN(SELECT productCode
                        FROM lowStockTable)
 GROUP BY productCode
 ORDER BY productPerformance DESC
 LIMIT 10;
 
 -- customer revenue
 SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
   FROM products AS p
   JOIN orderdetails AS od
     ON p.productCode=od.productCode
   JOIN orders AS o
     ON od.orderNumber=o.orderNumber
   GROUP BY o.orderNumber;
   
 -- top 5 VIP customers
WITH 

moneyByCustomerTable AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
 )
 
 SELECT c.contactLastName, c.contactFirstName, c.city, c.country, 
        m.profit
   FROM customers AS c
   JOIN moneyByCustomerTable AS m
     ON m.customerNumber=c.customerNumber
  ORDER BY m.profit DESC 
  LIMIT 5;
  
-- bottom 5 engaging customers
WITH 

moneyByCustomerTable AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
 )
 
 SELECT c.contactLastName, c.contactFirstName, c.city, c.country, 
        m.profit
   FROM customers AS c
   JOIN moneyByCustomerTable AS m
     ON m.customerNumber=c.customerNumber
  ORDER BY m.profit 
  LIMIT 5;
 
--Customer LTV(Lifetime Value)
WITH

moneyByCustomerTable AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
 )
 
SELECT AVG(mc.profit) AS CustomerLTV
  FROM moneyByCustomerTable AS mc;