--------------------------
-- Case Study Questions --
--------------------------

-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS pizza_orders
FROM #customer_orders_clean

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS orders
FROM #customer_orders_clean

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id,
       COUNT(DISTINCT order_id) AS orders
FROM #runner_orders_clean
WHERE duration IS NOT NULL
GROUP BY runner_id

-- 4. How many of each type of pizza was delivered?
SELECT p.pizza_name,
       COUNT(c.pizza_id) AS pizza_delivered
FROM #runner_orders_clean r 
LEFT JOIN #customer_orders_clean c
       ON r.order_id = c.order_id
LEFT JOIN #pizza_names p
       ON c.pizza_id = p.pizza_id
WHERE r.duration IS NOT NULL
GROUP BY p.pizza_name

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT C.customer_id,
       p.pizza_name,
       COUNT(c.pizza_id) AS pizza_delivered
FROM #customer_orders_clean c
LEFT JOIN #pizza_names p
       ON c.pizza_id = p.pizza_id
GROUP BY p.pizza_name, C.customer_id

-- 6. What was the maximum number of pizzas delivered in a single order?
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- 8. How many pizzas were delivered that had both exclusions and extras?
-- 9. What was the total volume of pizzas ordered for each hour of the day?
-- 10. What was the volume of orders for each day of the week?
