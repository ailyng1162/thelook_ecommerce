
-- For customers that purchase, where do they come from? 
-- how many per channel
SELECT  e.traffic_source, u.gender,
EXTRACT(YEAR FROM e.created_at) AS year,
count(e.user_id) as no_of_customers  
FROM `bigquery-public-data.thelook_ecommerce.events` e
JOIN`bigquery-public-data.thelook_ecommerce.users` u
ON e.user_id = u.id
where e.event_type = 'purchase' 
group by 1,2,3
having year = 2022
order by 2 desc;

-- Agregating users by age groups using CASE statements
SELECT count(e.user_id) no_of_customers,
EXTRACT(YEAR FROM e.created_at) AS year,
CASE
when u.age < 18 then 'Under 18'
when u.age >= 18 and u.age <= 24 then "Between 18 - 24"
when u.age > 24 and u.age <= 34 then "Between 25 - 34"
when u.age > 34 and u.age <= 45 then "Between 35 - 45"
when u.age > 45 and u.age <= 55 then "Between 35 - 45"
else"Older than 55" 
end as age_group
FROM `bigquery-public-data.thelook_ecommerce.events` e
JOIN`bigquery-public-data.thelook_ecommerce.users` u
ON e.user_id = u.id
group by 2, 3
having year = 2022
order by 2;

-- Total No of visits in 2022
select distinct EXTRACT(YEAR FROM created_at) AS year,  
count (session_id) as visits
FROM `bigquery-public-data.thelook_ecommerce.events`
group by 1
having year = 2022; 



-- Visitors by Region in 2022
-- Creating a new category (Region) using CASE statements in a CTE
with users as 
(
select distinct city, state, country,
case
when country in ('Australia','China','South Korea','Japan') then 'Asia & Pacific'
when country in ('Poland','United Kingdom','Belgium','France','Spain','Germany','Austria','Espa?a','Deutschland') then 'Europe'
when country in ('United States')  then 'North America'
when country in ('Brasil', 'Colombia')  then 'South/Latin America' 
else null
end as Region
from `bigquery-public-data.thelook_ecommerce.users` 
),
events as
(
select 
distinct EXTRACT(YEAR FROM created_at) AS year, city, state, 
count (session_id) as visits
FROM `bigquery-public-data.thelook_ecommerce.events`
group by 1,2, 3
having year = 2022
)
select 
e.YEAR, 
u.region, 
sum(visits) as visits
from events e, users u
where e.city = u.city and
e.state = u.state
group by 1,2; 


-- Total No of orders in 2022 
select EXTRACT(YEAR FROM created_at) AS year,
count(order_id) as no_of_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
group by 1
having year = 2022; 


-- Total Revenue for 2022
select 
extract(year from created_at) as year,
sum(sale_price) as revenue
FROM
  `bigquery-public-data.thelook_ecommerce.order_items` 
group by 1
having year = 2022;


-- Total No of customers in 2022
SELECT  
EXTRACT(YEAR FROM created_at) AS year,
count(user_id) as no_of_customers
FROM `bigquery-public-data.thelook_ecommerce.events` 
where EXTRACT(YEAR FROM created_at) = 2022
group by year;

-- Session duration in minutes
With my_time  as 
(
select distinct session_id, 
max(created_at)  ended, 
min(created_at) as started,
 EXTRACT(YEAR FROM created_at) as year
FROM `bigquery-public-data.thelook_ecommerce.events`
group by 1,4
having year = 2022
) 
select 
my_time.YEAR,
avg(extract(time from ended) - extract(time from started)) as avg_minutes_per_session
from my_time
group by 1;

--Revenue by region
with users as 
(
select distinct id, city, state, country, o.sale_price,
case
when country in ('Australia','China','South Korea','Japan') then 'Asia & Pacific'
when country in ('Poland','United Kingdom','Belgium','France','Spain','Germany','Austria','Espa?a','Deutschland') then 'Europe'
when country in ('United States')  then 'North America'
when country in ('Brasil', 'Colombia')  then 'South/Latin America' 
else null
end as Region
from `bigquery-public-data.thelook_ecommerce.users` ,
(
  select user_id, EXTRACT(YEAR FROM created_at) AS year,
  sum(sale_price) as sale_price
    FROM `bigquery-public-data.thelook_ecommerce.order_items`
group by 1,2
having year = 2022

) o
where o.user_id = id
),
events as
(
select 
distinct user_id, EXTRACT(YEAR FROM created_at) AS year, city, state
FROM `bigquery-public-data.thelook_ecommerce.events`
where EXTRACT(YEAR FROM created_at) = 2022
)
select distinct
u.region, 
sum(u.sale_price) as revenue
from events e, users u
where e.city = u.city and
e.state = u.state and 
e.user_id = u.id
group by 1;

------------------------------------------------------------------------------------------------------------


--Visits by country by month
with users as 
(
select distinct city, state, country,
case
when country in ('Australia','China','South Korea','Japan') then 'Asia & Pacific'
when country in ('Poland','United Kingdom','Belgium','France','Spain','Germany','Austria','Espa?a','Deutschland') then 'Europe'
when country in ('United States')  then 'North America'
when country in ('Brasil', 'Colombia')  then 'South/Latin America' 
else null
end as Region
from `bigquery-public-data.thelook_ecommerce.users` 
),
events as
(
select 
distinct EXTRACT(YEAR FROM created_at) AS year, 
EXTRACT(MONTH FROM created_at) AS month, 
city, state, 
count (session_id) as visits
FROM `bigquery-public-data.thelook_ecommerce.events`
group by 1,2, 3,4
having year = 2022
)
select 
e.YEAR, 
e.month,
u.country,
sum(visits) as visits
from events e, users u
where e.city = u.city and
e.state = u.state
group by 1,2,3; 


-- Orders By country by month
-- Introducing the month name using CASE statements for better analysis in Excel
with all_orders as
(
SELECT
  i.user_id, u.country,
  EXTRACT(YEAR FROM i.created_at) AS year,
    EXTRACT(MONTH FROM i.created_at) AS month,
  count(i.order_id) AS orders 
FROM
  `bigquery-public-data.thelook_ecommerce.order_items` i join
  `bigquery-public-data.thelook_ecommerce.users`u
on i.user_id = u.id
GROUP BY
  1, 2 ,3,4
)
select country, year, month, 
case
when month = 1 then 'Jan'
when month = 2 then 'Feb'
when month = 3 then 'Mar'
when month = 4 then 'Apr'
when month = 5 then 'May'
when month = 6 then 'Jun'
when month = 7 then 'Jul'
when month = 8 then 'Aug'
when month = 9 then 'Sep'
when month = 10 then 'Oct'
when month = 11 then 'Nov'
else 'Dec'
end as month_name,
sum(orders) as orders
 from all_orders t
where t.YEAR = 2022
group by 1,2,3,4
ORDER BY 1,3;
