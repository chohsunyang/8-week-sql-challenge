-- 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS node_count
FROM #customer_nodes

-- 2. What is the number of nodes per region?
SELECT c.region_id,
       r.region_name,
       COUNT(node_id) AS node_count
FROM #customer_nodes c
JOIN #regions r
  ON c.region_id = r.region_id
GROUP BY c.region_id, r.region_name
ORDER BY c.region_id

-- 3. How many customers are allocated to each region?
SELECT c.region_id,
       r.region_name,
       COUNT(DISTINCT customer_id) AS customer_count
FROM #customer_nodes c
JOIN #regions r
  ON c.region_id = r.region_id
GROUP BY c.region_id, r.region_name
ORDER BY c.region_id

-- 4. How many days on average are customers reallocated to a different node?
SELECT AVG(DATEDIFF(DAY, start_date, end_date)) AS avg_day
FROM #customer_nodes c
JOIN #regions r
  ON c.region_id = r.region_id
WHERE end_date <> '9999-12-31'

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH day_diff AS (
		SELECT c.region_id,
               r.region_name,
			   c.customer_id,
		       DATEDIFF(DAY, start_date, end_date) AS diff_day
		FROM #customer_nodes c
		JOIN #regions r
		  ON c.region_id = r.region_id
		WHERE end_date <> '9999-12-31'
)

SELECT DISTINCT
       region_id,
       region_name,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff_day) OVER (PARTITION BY region_name) AS median,
	   PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY diff_day) OVER (PARTITION BY region_name) AS percetile_80,
	   PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY diff_day) OVER (PARTITION BY region_name) AS percetile_95
FROM day_diff
