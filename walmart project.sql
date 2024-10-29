create database walmart;

use walmart

select*from dbo.sheet1$
exec sp_rename 'dbo.sheet1$','walmart'

select*from walmart

--1. Find the lowest rating of each products? 

select [product line], min(rating) as min_rating
from walmart
group by [product line]

--2. Find Top 2 cities with highest Rating?

select top 2 [city],rating
from walmart
order by [rating] desc

--3. find the city with highest number of products.

select top 1 [city], count([product line]) as cnt_
from walmart
group by [city]
order by cnt_

--4. Find top 5 Best proudcts?
SELECT TOP 5 [product line], 
             SUM([gross income]) AS total_income
FROM walmart
GROUP BY [product line]
ORDER BY total_income DESC;


--5.Find the product line with most users are female?

with cte as(
	select [product line], count(1) as order_cn
	from walmart
	where [gender]='female'
	group by [product line]) 

select top 1 [product line]
from cte 
order by order_cn desc 

--6. Find 2nd best product line with gross income?

select [product line], [gross income]
from(
     select [product line], [gross income], ROW_NUMBER() over( order by [gross income] desc) rnk
	 from walmart) as e
where e.rnk=2

--7. Which product lines have consecutive purchases that are exactly 2 days apart?

with cte as( 
			select [product line],
				[date],
				LEAD(date) over(partition by [product line] order by [date]) rnk
				from walmart)

select distinct [product line]
from cte 
where DATEDIFF(day,[date],rnk)=2

--8. Find most used payment method and the corresponding count for each city?

WITH cte AS (
    SELECT [city], [payment], COUNT(1) AS count_of_payments
    FROM walmart
    GROUP BY [city], [payment]
)
SELECT [city], [payment], count_of_payments
FROM (
    SELECT [city], [payment], count_of_payments,
           ROW_NUMBER() OVER (PARTITION BY [city] ORDER BY count_of_payments DESC) AS rnk
    FROM cte
) AS e
WHERE e.rnk = 1;

--9. How has the usage of different payment methods changed month over month?

WITH payment_trends AS (
    SELECT 
       DATENAME(MONTH,[date]) AS month,  
        [payment], 
        COUNT(1) AS payment_count
    FROM walmart
    GROUP BY DATENAME(MONTH,[date]), [payment]
)
SELECT 
    month, 
    [payment], 
    payment_count,
    LAG(payment_count) OVER (PARTITION BY [payment] ORDER BY month) AS previous_month_count,
    (payment_count - LAG(payment_count) OVER (PARTITION BY [payment] ORDER BY month)) AS change_in_count
FROM payment_trends
ORDER BY month;

--10. find the maximum tax %?
 select *from 
 walmart 
 where [tax 5%]>=(select max([tax 5%])
 from walmart)



