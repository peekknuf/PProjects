
---Create the necessary tables for the Customers, Orders, and Order Details

CREATE TABLE Customers (
Customer_ID INT,
Customer_Name VARCHAR(50),
Customer_Segment VARCHAR(20),
Region VARCHAR(20),
State_or_Province VARCHAR(50),
City VARCHAR(50),
Postal_Code VARCHAR(20)
);

CREATE TABLE Orders (
Order_ID INT,
Customer_ID INT,
Order_Priority VARCHAR(20),
Order_Date DATE,
Ship_Date DATE,
Quantity_Ordered_New INT,
Sales DECIMAL(10, 2),
Discount DECIMAL(10, 2),
Profit DECIMAL(10, 2),
Shipping_Cost DECIMAL(10, 2),
Ship_Mode VARCHAR(20)
);

CREATE TABLE Order_Details (
Order_ID INT,
Product_Category VARCHAR(20),
Product_Sub_Category VARCHAR(20),
Product_Container VARCHAR(20),
Product_Name VARCHAR(50),
Product_Base_Margin DECIMAL(10, 2),
Unit_Price DECIMAL(10, 2)
);

---A profit and sales view that might come in handy later for a dashboard and just generally give a nice overview of what's going on.

CREATE VIEW Sales_Profit
AS
		SELECT c.Customer_ID, 
				c.Customer_Name ,
				ROUND(SUM(sales),2) as Sales, 
				ROUND(SUM(profit),2) AS Profit, 
				ROUND(SUM(Profit)/SUM(Sales)*100.0, 2) as Perc_Profit
		FROM Orders o 
		JOIN Customers c 
			ON o.Customer_ID = c.Customer_ID 
		GROUP BY c.Customer_ID 
		ORDER BY Perc_Profit DESC


---2.	Display total sales value from customers who made their first purchase in 2012
--We're using substr because SQLite is retarded and doesn't know neither extract nor year, 
--more so it doesn't understand any other date formats except those that are stored YYYY-MM-DD
--It is annoying, and somewhat counterintuitive but it works and allows us to progress so it will do.

--It's just easier with a view, might be useful for later
		
CREATE VIEW Yearss
AS
SELECT Customer_ID , substr(Order_Date, 7, 4) year_of_order
FROM Orders

--Getting the answer

SELECT ROUND(SUM(o.Sales),2) as total_sales
FROM Orders o 
JOIN (SELECT Customer_ID, MIN(year_of_order) AS first_purchase
		FROM Yearss
		GROUP BY Customer_ID) AS min_customers
		ON o.Customer_ID = min_customers.Customer_ID
WHERE min_customers.first_purchase = '2012'



---Display how many customers ordered 1-6 times

SELECT COUNT(CASE WHEN number_of_orders BETWEEN 1 AND 6 THEN customer_id END) AS "Number of Customers"
FROM (SELECT customer_id, COUNT(order_id) AS number_of_orders
      FROM orders
      GROUP BY customer_id) AS customer_orders;
     
     
---Display how many customers there are in total
     
     
SELECT COUNT(DISTINCT Customer_ID)
FROM Orders o 


---4.	Display total profit for items ordered on Friday in 2010 with product name containing the word ‘phone’.


SELECT od.Product_Name, profit
FROM Orders o 
JOIN Order_Details od 
	ON o.Order_ID = od.Order_ID 
WHERE DAYNAME(Order_Date) = 'Friday' AND YEAR(o.order_date) = 2010 AND od.product_name LIKE '%phone%'

--IN any other sql dialect that'd give us an answer which then would be aggregated


---Profits and Sales


SELECT Order_Priority ,ROUND(SUM(Profit),0) as totprof, ROUND(SUM(Sales),0) as totsales
FROM Orders o 
GROUP BY Order_Priority 
ORDER BY 2 DESC

---

---TOP1 profit by category.

SELECT Product_Category, Product_Sub_Category ,ROUND(SUM(Profit),0) as totprof, ROUND(SUM(Sales),0) as totsales,
       RANK() OVER (PARTITION BY Product_Category ORDER BY SUM(Profit) DESC) as ranking
FROM Order_Details od 
JOIN Orders o 
    ON o.Order_ID = od.Order_ID
GROUP BY Product_Category, Product_Sub_Category
HAVING ranking = 1;
