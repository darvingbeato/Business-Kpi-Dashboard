
Use WideWorldImporters;

-- -- Select top 1 * from BusinessData;
/*=====================================================
  Are there nulls ?
=====================================================*/

SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS Null_Order_ID
	,SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS Null_Order_Date
	,SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS Null_Customer_ID
	,SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS Null_Region
	,SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) AS Null_Product_Category	
	,SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS Null_Product_Name
	,SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS Null_Revenue
	,SUM(CASE WHEN customer_segment IS NULL THEN 1 ELSE 0 END) AS Null_customer_segment
    
FROM BusinessData;


/*=====================================================
    Data Cleaning: Remove Duplicate Records
=====================================================*/
SELECT COUNT(*) AS TotalRows FROM BusinessData; ---- Check before

WITH DuplicateCheck AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY order_id, product_name, customer_id, order_date ORDER BY order_id) AS row_num
    FROM BusinessData
)

DELETE FROM DuplicateCheck
WHERE row_num > 1;

SELECT COUNT(*) AS TotalRowsAfterCleanup FROM BusinessData; ---- Check after


/*=====================================================
KPIs
=====================================================*/

SELECT
    ROUND(SUM(revenue), 2) AS TotalRevenue,
    ROUND(SUM(profit), 2) AS TotalProfit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS ProfitMargin,
    COUNT(DISTINCT order_id) AS TotalOrders,
    COUNT(DISTINCT customer_id) AS TotalCustomers,
    ROUND(SUM(revenue) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS AvgOrderValue
FROM BusinessData;


/*=====================================================
Monthly Revenue Trend
=====================================================*/

	Select 
		DATEFROMPARTS(Year(order_date),Month(order_date),1) as MonthlyDate
		,round(sum(revenue),2) as TotalRevenue 
	from BusinessData
	group by 
		DATEFROMPARTS(Year(order_date),Month(order_date),1)
	order by 
		DATEFROMPARTS(Year(order_date),Month(order_date),1) asc;


/*=====================================================
Revenue by Region
=====================================================*/


	Select 
		Region
		,round(sum(revenue),2) as TotalRevenue 
	from BusinessData
	group by 
		Region
	order by 
		TotalRevenue desc;


/*=====================================================
Top Products
=====================================================*/

	Select top 5
		product_name
		,round(sum(revenue),2) as TotalRevenue 
	from BusinessData
	group by 
		product_name
	order by 
		TotalRevenue desc;



/*=====================================================
Profit Margin
=====================================================*/
	Select 
		DATEFROMPARTS(Year(order_date),Month(order_date),1) as MonthlyDate
		,round(sum(revenue),2) as TotalRevenue
		,round(sum(profit),2) as TotalProfit
		,ROUND(CAST(SUM(profit) AS decimal(10,2)) / NULLIF(SUM(revenue), 0), 2) as ProfitMargin -- -- -- to prevent divition by 0
	from BusinessData	
	group by 
		DATEFROMPARTS(Year(order_date),Month(order_date),1)
	order by 
		DATEFROMPARTS(Year(order_date),Month(order_date),1) asc;


/*=====================================================
Customer Growth
=====================================================*/
----Finding first purchase date per customer >> groups those first purchases by month >> counts customers who appeared for the first time that month


	WITH FirstPurchase AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM BusinessData
    GROUP BY customer_id
)

SELECT
    DATEFROMPARTS(YEAR(first_order_date), MONTH(first_order_date), 1) AS MonthlyDate,
    COUNT(customer_id) AS NewCustomers
FROM FirstPurchase
GROUP BY DATEFROMPARTS(YEAR(first_order_date), MONTH(first_order_date), 1)
ORDER BY MonthlyDate ASC;


/*=====================================================
Revenue by Sales Channel
=====================================================*/
SELECT 
    sales_channel,
    ROUND(SUM(revenue), 2) AS TotalRevenue
FROM BusinessData
GROUP BY sales_channel
ORDER BY TotalRevenue DESC;

/*=====================================================
Revenue by Product Category
=====================================================*/

SELECT 
    product_category,
    ROUND(SUM(revenue), 2) AS TotalRevenue
FROM BusinessData
GROUP BY product_category
ORDER BY TotalRevenue DESC;


/*=====================================================
Sales Rep Performance
=====================================================*/
SELECT 
    sales_rep,
    ROUND(SUM(revenue), 2) AS TotalRevenue
FROM BusinessData
GROUP BY sales_rep
ORDER BY TotalRevenue DESC;

