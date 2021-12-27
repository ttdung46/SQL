
--1. Total revenue, total quantity, total order, Average revenue per month, Average revenue per order, Average revenue per quantity
WITH summarize AS
        (SELECT total_price,
                quantity,
                order_date,
                o.order_id
        FROM sales s 
        INNER JOIN orders o
        ON s.order_id = o.order_id)
SELECT  SUM(total_price) total_revenue,
        SUM(quantity) total_quantity,
        COUNT(DISTINCT order_id) total_order,
        SUM(total_price) / COUNT(DISTINCT MONTH(order_date)) avg_revenue_per_month,
        SUM(total_price) / SUM(quantity) avg_revenue_per_quantity,
        SUM(total_price) / COUNT(DISTINCT order_id) avg_revenue_per_order
FROM summarize;


-- 2. Monthly revenue & Month over Month (MoM) Growth rate(%)
SELECT  MONTH(order_date) month_sales,
        SUM(total_price) revenue,
        LAG(SUM(total_price)) OVER(ORDER BY MONTH(order_date)) revenue_pre_month,
        ROUND((CAST(SUM(total_price) AS float) - LAG(SUM(total_price)) OVER(ORDER BY MONTH(order_date))) *100 / LAG(SUM(total_price)) OVER(ORDER BY MONTH(order_date)),2) MoM_growth_rate
FROM    sales s 
INNER JOIN orders o 
    ON s.order_id = o.order_id
GROUP BY MONTH(order_date)
ORDER BY month_sales

--3. Total customers & average order per customer
SELECT  
        COUNT(customer_id) total_customer,
        ROUND(SUM(number_order)/ CAST(COUNT(customer_id) AS float),2) avg_order_per_customer
FROM 
    (
        SELECT  customer_id,
                COUNT(DISTINCT order_id) number_order
        FROM orders
        GROUP BY customer_id
    ) as customer_order


--4. Number of new customers per month & running total new customers each month
WITH first_order as
        (
            SELECT  customer_id,
                    MIN(order_date) first_reg
            FROM orders
            GROUP BY customer_id
        ),
    new_customers as 
        (
            SELECT  MONTH(first_reg) month_deliver,
                    COUNT(customer_id) new_customers
            FROM first_order
            GROUP BY MONTH(first_reg)
        )
SELECT month_deliver,
        new_customers,
        SUM(new_customers) OVER(ORDER BY month_deliver) running_total_new_customer
FROM new_customers
ORDER BY month_deliver;



--5. Monthly active customers(MAU) & Monht over Month (MoM) growth rate(%)
SELECT  month_order,
        number_users,
        LAG(number_users) OVER(ORDER BY month_order) pre_month,
        ROUND((CAST(number_users AS float) - LAG(number_users) OVER(ORDER BY month_order)) * 100/ LAG(number_users) OVER(ORDER BY month_order),2) MoM_Growth_rate
FROM 
    (
        SELECT  
            MONTH(order_date) month_order,
            COUNT(DISTINCT customer_id) number_users
        FROM orders
        GROUP BY  MONTH(order_date)
    ) as userMoM


--6. Customer Cohort

SELECT  start_month,
        SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END) AS month_0,
        SUM(CASE WHEN month_number = 1 THEN 1 ELSE 0 END) AS month_1,
        SUM(CASE WHEN month_number = 2 THEN 1 ELSE 0 END) AS month_2,
        SUM(CASE WHEN month_number = 3 THEN 1 ELSE 0 END) AS month_3,
        SUM(CASE WHEN month_number = 4 THEN 1 ELSE 0 END) AS month_4,
        SUM(CASE WHEN month_number = 5 THEN 1 ELSE 0 END) AS month_5,
        SUM(CASE WHEN month_number = 6 THEN 1 ELSE 0 END) AS month_6,
        SUM(CASE WHEN month_number = 7 THEN 1 ELSE 0 END) AS month_7,
        SUM(CASE WHEN month_number = 8 THEN 1 ELSE 0 END) AS month_8,
        SUM(CASE WHEN month_number = 9 THEN 1 ELSE 0 END) AS month_9
    
FROM  ( 
        SELECT  a.customer_id,
                a.start_month as start_month,
                b.month_order,
                b.month_order - a.start_month as month_number
        
        FROM   
            (
                SELECT
                        customer_id,
                        MIN(MONTH(order_date)) AS start_month
                FROM orders
                GROUP BY customer_id
            ) AS a,
            (
                SELECT
                        customer_id,
                        MONTH(order_date) AS month_order
                FROM orders
                GROUP BY customer_id,MONTH(order_date)    
            )AS b
        WHERE a.customer_id=b.customer_id
        ) as with_month_number
    
GROUP BY start_month
ORDER BY start_month;

--7. Customer Retention by Cohort
SELECT  start_month,
        (SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END) /SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))*100 AS month_0,
        ROUND((CAST(SUM(CASE WHEN month_number = 1 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_1,
        ROUND((CAST(SUM(CASE WHEN month_number = 2 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_2,
        ROUND((CAST(SUM(CASE WHEN month_number = 3 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_3,
        ROUND((CAST(SUM(CASE WHEN month_number = 4 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_4,
        ROUND((CAST(SUM(CASE WHEN month_number = 5 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_5,
        ROUND((CAST(SUM(CASE WHEN month_number = 6 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_6,
        ROUND((CAST(SUM(CASE WHEN month_number = 7 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_7,
        ROUND((CAST(SUM(CASE WHEN month_number = 8 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_8,
        ROUND((CAST(SUM(CASE WHEN month_number = 9 THEN 1 ELSE 0 END) AS float) / SUM(CASE WHEN month_number = 0 THEN 1 ELSE 0 END))* 100,2) AS month_9
    
FROM  ( 
        SELECT  a.customer_id,
                a.start_month as start_month,
                b.month_order,
                b.month_order - a.start_month as month_number
        
        FROM   
            (
                SELECT
                        customer_id,
                        MIN(MONTH(order_date)) AS start_month
                FROM orders
                GROUP BY customer_id
            ) AS a,
            (
                SELECT
                        customer_id,
                        MONTH(order_date) AS month_order
                FROM orders
                GROUP BY customer_id,MONTH(order_date)    
            )AS b
        WHERE a.customer_id=b.customer_id
        ) as with_month_number
    
GROUP BY start_month
ORDER BY start_month;






