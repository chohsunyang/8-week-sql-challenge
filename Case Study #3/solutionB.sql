-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS unique_customer
FROM #subscriptions

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT MONTH(start_date) AS start_month,
       COUNT(DISTINCT customer_id) AS customer_count
FROM #subscriptions
WHERE plan_id = 0
GROUP BY MONTH(start_date)

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT s.plan_id,
       p.plan_name,
       COUNT(DISTINCT customer_id) AS customer_count
FROM #subscriptions s
JOIN #plans p
  ON s.plan_id = p.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY s.plan_id, p.plan_name

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(CASE WHEN plan_id = 4 THEN 1 END) AS customer_churn_count,
       CAST(COUNT(CASE WHEN plan_id = 4 THEN 1 END) AS FLOAT) / CAST(COUNT(DISTINCT customer_id) AS FLOAT) * 100 AS customer_churn_percentage
FROM #subscriptions

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
SELECT COUNT(*) AS customer_churn_count,
       ROUND(COUNT(*) / CAST((SELECT COUNT(DISTINCT customer_id) FROM #subscriptions) AS FLOAT) * 100,0) AS customer_churn_percentage
FROM(
SELECT plan_id, 
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS plan_order
FROM #subscriptions) t
WHERE plan_order = 2
  AND plan_id = 4

-- 6. What is the number and percentage of customer plans after their initial free trial?
SELECT p.plan_name,
       COUNT(*) AS customer_count,
       ROUND(COUNT(*) / CAST((SELECT COUNT(DISTINCT customer_id) FROM #subscriptions) AS FLOAT) * 100,0) AS customer_percentage
FROM(
SELECT plan_id, 
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS plan_order
FROM #subscriptions) t
JOIN #plans p
  ON t.plan_id = p.plan_id
WHERE plan_order = 2
GROUP BY p.plan_name

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT p.plan_name,
       COUNT(*) AS customer_count,
       ROUND(COUNT(*) / CAST((SELECT COUNT(DISTINCT customer_id) FROM #subscriptions) AS FLOAT) * 100,0) AS customer_churn_percentage
FROM(
SELECT plan_id, 
       start_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS plan_order
FROM #subscriptions
WHERE start_date <= '2020-12-31') t
JOIN #plans p
  ON t.plan_id = p.plan_id
WHERE plan_order = 1
GROUP BY p.plan_name

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT plan_id,
       COUNT(DISTINCT customer_id) AS customer_count
FROM #subscriptions s
WHERE YEAR(start_date) = 2020
  AND plan_id = 3
GROUP BY plan_id

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
SELECT AVG(day_to_sub) AS avg_day_to_sub
FROM(
SELECT s.customer_id,
       s.start_date AS cus_start_date,
	   t.start_date AS annual_start_date,
	   DATEDIFF(DAY, s.start_date, t.start_date) AS day_to_sub
FROM #subscriptions s
JOIN (SELECT customer_id,
             start_date
      FROM #subscriptions s
      WHERE plan_id = 3) t 
  ON s.customer_id = t.customer_id
WHERE plan_id = 0) a

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
SELECT SUM(downgrade) AS downgrade_cus
FROM(
SELECT (CASE WHEN plan_id = 2 AND LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 2 THEN 1 ELSE 0 END) AS downgrade
FROM #subscriptions) t
