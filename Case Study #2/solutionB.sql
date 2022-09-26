--------------------------
-- Case Study Questions --
--------------------------
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATEADD(dd,6-DATEPART(dw,registration_date),registration_date) AS week_start,
       COUNT(runner_id) AS runner_count
FROM #runners
GROUP BY DATEADD(dd,6-DATEPART(dw,registration_date),registration_date)

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT r.runner_id,
	   AVG(DATEDIFF(MINUTE, c.order_time, r.pickup_time)) AS avg_time_HQ
FROM #customer_orders_clean c
JOIN #runner_orders_clean r
	ON c.order_id = r.order_id
WHERE r.duration IS NOT NULL
GROUP BY runner_id

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT c.order_id,
	   COUNT(c.pizza_id) AS pizza_count,
	   DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS time_per_order,
	   (DATEDIFF(MINUTE, c.order_time, r.pickup_time) / COUNT(c.pizza_id)) AS time_per_pizza
FROM #customer_orders_clean c
JOIN #runner_orders_clean r
	ON c.order_id = r.order_id
WHERE r.duration IS NOT NULL
GROUP BY c.order_id, DATEDIFF(MINUTE, c.order_time, r.pickup_time)
ORDER BY COUNT(c.pizza_id)
-- it takes ~10 min to make a pizza

-- 4. What was the average distance travelled for each customer?
SELECT c.customer_id,
	   ROUND(AVG(r.distance),0) AS avg_distance
FROM #customer_orders_clean c
JOIN #runner_orders_clean r
	ON c.order_id = r.order_id
WHERE r.duration IS NOT NULL
GROUP BY c.customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS diff
FROM #runner_orders_clean r
WHERE r.duration IS NOT NULL

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,
       distance,
	   duration,
	   ROUND(distance / (duration/60),0) AS speed
FROM #runner_orders_clean r
WHERE r.duration IS NOT NULL
ORDER BY distance DESC, duration
-- Everyone is way to fast for running

-- 7. What is the successful delivery percentage for each runner?
SELECT runner_id,
       COUNT(order_id) AS total_order,
	   COUNT(duration) AS success_order,
       CAST(COUNT(duration) AS FLOAT) / CAST(COUNT(order_id) AS FLOAT) * 100 AS success_rate
FROM #runner_orders_clean r
GROUP BY runner_id
