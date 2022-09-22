## Data Cleaning

We have to clean the data before analysis. I have done this by creating temp tables in SQL server.


``` sql
DROP TABLE IF EXISTS #customer_orders_clean;
SELECT
	order_id,
	customer_id,
	pizza_id,
	CASE WHEN exclusions LIKE '' OR exclusions LIKE 'null' THEN NULL
	     ELSE exclusions END AS exclusions,
	CASE WHEN extras LIKE '' OR extras LIKE 'null' THEN NULL
	     ELSE extras END AS extras,
	order_time
INTO #customer_orders_clean
FROM #customer_orders

DROP TABLE IF EXISTS #runner_orders_clean;
SELECT 
	order_id,
	runner_id,
	CAST(CASE WHEN pickup_time = 'null' THEN NULL
	     ELSE pickup_time END AS DATETIME) AS pickup_time,
	CAST(CASE WHEN distance = 'null' THEN NULL
	     ELSE TRIM('km' FROM distance) END AS FLOAT) AS distance,
	CAST(CASE WHEN duration = 'null' THEN NULL
	     ELSE SUBSTRING(duration, 1, 2) END AS FLOAT) AS duration
INTO #runner_orders_clean
FROM #runner_orders
```
