-- Project: E-Commerce Returns & Business Intelligence Analytics
-- Database: ecommerce_return_intelligence
-- Tool: PostgreSQL
-- Purpose: Data validation, sales analysis, return analysis,
-- customer analysis, and financial impact analysis.
-- Analysis Period: January 2022 - August 2025


create table ecommerce(
Order_ID varchar(20),
Product_ID varchar(20),
User_ID varchar(20),
Order_Date date,
Product_Category char(50),
Product_Price numeric(12,2),
Order_Quantity int,
Discount_Applied numeric(10,2),
Shipping_Method char(20),
Payment_Method char(20),
User_Age int,
User_Gender char(10),
User_Location varchar(30),
Return_Status char(20),
Return_Reason char(50),
Days_to_Return int,
Order_Value numeric(12,2),
Return_Cost numeric(12,2),
Profit_Loss numeric(12,2),
CO2_Emissions numeric(12,4),
Packaging_Waste numeric(12,4),
CO2_Saved numeric(12,4),
Waste_AVoided numeric(12,4)
)

-- ==========================================
-- E-COMMERCE RETURN INTELLIGENCE PROJECT
-- PostgreSQL Business Analysis
-- ==========================================
------------------------
-- 1. DATA QUALITY CHECKS
-------------------------

--Total Records
select count(*) from ecommerce;

select * from ecommerce limit 10;

--Checking missing values in ids
select 
	count(*) filter(where order_id is null) as missing_order_id,
	count(*) filter(where product_id is null) as missing_product_id,
	count(*) filter(where user_id is null) as missing_order_id
from ecommerce;

--Duplicate order_id, product_id, user_id
SELECT
    order_id,
    product_id,
    user_id,
    COUNT(*)
FROM ecommerce
GROUP BY order_id, product_id, user_id
HAVING COUNT(*) > 1;

--count and percentage of return and non-returned orders from all
SELECT
    return_status,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM ecommerce),
        2
    ) AS percentage
FROM ecommerce
GROUP BY return_status;

----------------------------
--Numerical Data validation
----------------------------

--is there ant negative product_price
select product_id, product_price from ecommerce where (product_price<0);

--is there any negative order_quantity
select order_id, order_quantity from ecommerce where (order_quantity<=0);

--finding average, maximum and minimum discount given to the customer,
select avg(discount_applied) as avg_discount, max(discount_applied) as max_discount,
min(discount_applied) as min_discount from ecommerce;

--negative value in day to return
select product_id, days_to_return from ecommerce where (days_to_return<0);

--negative order value
select * from ecommerce where (order_value<0);

--is there any return order having negative return cost
select order_id, return_cost from ecommerce where (return_cost<0);

select
     count(*) filter(where (profit_loss<0)) as negative_profit_loss,
	 count(*) filter(where (profit_loss>0)) as positive_profit_loss,
	 count(*) filter(where (profit_loss=0)) as zero_positive_loss
from ecommerce;

select co2_emissions from ecommerce where (co2_emissions<0);

SELECT
    order_id,
    co2_emissions,
    CASE
        WHEN co2_emissions < 0 THEN 'negative_co2_emissions'
        WHEN co2_emissions = 0 THEN 'zero_co2_emissions'
        ELSE 'positive_co2_emissions'
    END AS is_co2_emissions
FROM ecommerce;

----------------------------
--Business Logic Validation
----------------------------
--is there any which status is retuned but the reason is null
select * from ecommerce where (return_status='Returned' and return_reason=Null);

--non retuned orders
select order_id, return_status, return_cost from ecommerce where (return_status='Not Returned');

--returned order and the return cost is 0
select order_id, return_status, return_cost from ecommerce 
where (return_status='Returned' and return_cost=0);

--returned order and the day of return is 0
select order_id, return_status, days_to_return from ecommerce 
where (return_status='Returned' and days_to_return=0);

--correcting the order_value with calculated order value
SELECT
    order_id,
    product_price,
    order_quantity,
    discount_applied,
    order_value,
    ROUND(
        product_price * order_quantity *
        (1 - discount_applied / 100.0), 2
    ) AS calculated_order_value
FROM ecommerce
WHERE ABS(
    order_value -
    (product_price * order_quantity *
    (1 - discount_applied / 100.0))
) = 0;

select order_id, product_price, order_quantity, discount_applied, order_value, 
round(product_price * order_quantity* (1- discount_applied/100),2) as calculated_order_value,
case 
    when order_value= round(product_price * order_quantity* (1- discount_applied/100),2) then 'Match'
	else 'Mismatch'
   end as comparison_status
from ecommerce;

--order which retuned and profit loss is less than 0
select * from ecommerce where (return_status='Returned') and (profit_loss<0);

--------------------------------
--Data and Customer Validation
-------------------------------
--latest order and first order
select min(order_date) as earliest_order, max(order_date) as latest_order from ecommerce;

SELECT
    order_id,
    order_value,
    return_cost,
    profit_loss,
    order_value - return_cost AS calculated_profit_loss
FROM ecommerce
WHERE return_status = 'Returned';

SELECT COUNT(*) AS formula_mismatches
FROM ecommerce
WHERE profit_loss <> order_value - return_cost;

--avergae order_value, avergae return value, average profit_loss
select return_status,avg(order_value) as avg_order_value, avg(return_cost) as avg_return_value, 
avg(profit_loss) as avg_profit_loss from ecommerce group by return_status;

--number of total orders by month on each year
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    COUNT(*) AS total_orders
FROM 
    ecommerce
GROUP BY 
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY 
    order_year ASC,
    order_month ASC;

--finding user who's age below 18 and above 100
select * from ecommerce where (user_age<18) or (user_age>100); 

--finfing null and the unnessasary blanks in user_location column
select * from ecommerce where user_location=null or trim(user_location)= '';

--number of order by product category
select product_category, count(*) as total_orders 
from ecommerce group by product_category order by total_orders asc;

--number of orders by payment method
select payment_method, count(*) as total_orders 
from ecommerce group by payment_method order by total_orders asc;

--number of orders by product category which are returned
select count(*) filter(where return_status='Returned'), product_category
from ecommerce group by product_category;

#####################################################
--average profit loss and total profit loss by return status
with categorical_analysis as (
		select 
			product_category, 
			count(*) as total_orders,
			count(*) filter(where return_status='Returned') as returned_orders,
			round(100* count(*) filter(where return_status='Returned')/ count(*),2) as category_return_rate
		from ecommerce 
		group by product_category),

overall_analysis as(
select 
	round(100* count(*) filter(where return_status='Returned')/ count(*),2) as overall_return_rate 
from ecommerce
)

select ca.product_category,ca.total_orders,
ca.returned_orders,
ca.category_return_rate,
oa.overall_return_rate
from categorical_analysis ca cross join overall_analysis oa;


---------------------------
--Financial Impact Analysis
----------------------------
select return_status,
sum(profit_loss) as total_profit_loss,
avg(profit_loss) as average_profit_loss from ecommerce group by return_status;
##########################################
--Which product categories have the highest financial loss?
SELECT
    product_category,
    SUM(profit_loss) AS total_profit_loss,
    COUNT(*) FILTER (
        WHERE profit_loss < 0
    ) AS loss_records,
    SUM(
        CASE
            WHEN profit_loss < 0 THEN profit_loss
            ELSE 0
        END
    ) AS total_loss
FROM ecommerce
GROUP BY product_category
ORDER BY total_loss ASC;

--Which return reasons have the lowest average Profit_Loss?
SELECT
    return_reason,
    COUNT(*) AS total_returns,
    ROUND(AVG(profit_loss), 2) AS average_profit_loss,
    ROUND(AVG(return_cost), 2) AS average_return_cost
FROM ecommerce
WHERE return_status = 'Returned'
GROUP BY return_reason
ORDER BY average_profit_loss ASC;

------------------------------
---Advanced Customer Analytics
-------------------------------
---top 10 customers by total number of orders.
SELECT
    user_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_value) AS total_order_value,
    COUNT(DISTINCT order_id) FILTER (
        WHERE return_status = 'Return'
    ) AS total_returns
FROM ecommerce
GROUP BY user_id
ORDER BY total_orders DESC
LIMIT 10;

--customer with highest order value
SELECT
    user_id,
    product_category,
    COUNT(*) AS total_orders,
    SUM(order_value) AS total_order_value
FROM ecommerce
GROUP BY user_id, product_category
ORDER BY user_id, total_orders desc;


--top 10 customers with the highest return rate.
select user_id, 
count(*) as total_orders,
count(*) filter(where return_status='Returned') as total_returns,
round(100.0* count(*) filter(where return_status='Returned')/ count(*),2) as return_rate
from ecommerce group by user_id order by return_rate desc limit 10;

--Customers who returned products more than once
select user_id, 
count(*) filter(where return_status='Returned') as total_returns
from ecommerce group by user_id having count(*) filter(where return_status='Returned')>1
order by user_id desc;

--Average Order Value – Repeat vs One-Time Customers
with customer_orders as(
select user_id, 
count(*) as total_orders,
sum(order_value) as total_order_value
from ecommerce group by user_id),

customer_sagements as(
select 
user_id, 
total_orders,
total_order_value,
case when total_orders=1 then 'One time Customer'
else 'Repeat customer' end as customer_type,
total_order_value/total_orders as average_order_value from customer_orders
)

select customer_type, count(*) as total_orders,
ROUND(AVG(average_order_value), 2) AS avg_order_value
from customer_sagements group by customer_type;

--Customers contributing the highest total order value
SELECT
    user_id,
    COUNT(*) AS total_orders,
    SUM(order_value) AS total_order_value,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM ecommerce
GROUP BY user_id
ORDER BY total_order_value DESC
LIMIT 10;

---------------------
--Monthly Trend Analysis
---------------------
SELECT
    DATE_TRUNC('month', order_date)::DATE AS order_month,
    COUNT(*) AS total_orders,
    count(*) filter(where return_status='Returned') as return_orders,
    count(*) filter(where return_status='Not Returned') as non_return_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE return_status = 'Returned'
        ) / COUNT(*),
        2
    ) AS monthly_return_rate
FROM ecommerce
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;


--Month-over-Month Return Rate Change.
WITH monthly_returns AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE return_status = 'Returned'
            ) / COUNT(*),
            2
        ) AS monthly_return_rate
    FROM ecommerce
    GROUP BY DATE_TRUNC('month', order_date)
),

monthly_comparison AS (
    SELECT
        order_month,
        monthly_return_rate,
        LAG(monthly_return_rate) OVER (
            ORDER BY order_month
        ) AS previous_month_rate
    FROM monthly_returns
)

SELECT
    order_month,
    monthly_return_rate,
    previous_month_rate,
    ROUND(
        monthly_return_rate - previous_month_rate,
        2
    ) AS rate_change
FROM monthly_comparison
ORDER BY order_month;

--Monthly Financial Impact of Returns
SELECT
    DATE_TRUNC('month', order_date)::DATE AS order_month,

    COUNT(*) FILTER (
        WHERE return_status = 'Returned'
    ) AS total_returns,

    SUM(order_value) FILTER (
        WHERE return_status = 'Returned'
    ) AS returned_order_value,

    SUM(return_cost) FILTER (
        WHERE return_status = 'Returned'
    ) AS total_return_cost,

    SUM(profit_loss) FILTER (
        WHERE return_status = 'Returned'
    ) AS total_profit_loss,

    COUNT(*) FILTER (
        WHERE return_status = 'Returned'
        AND profit_loss < 0
    ) AS negative_profit_records

FROM ecommerce
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;

