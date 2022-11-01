## 1. How many unique transactions were there?
``` sql
SELECT COUNT(DISTINCT txn_id) AS total_txn
FROM #sales
```

## 2. What is the average unique products purchased in each transaction?
``` sql
SELECT COUNT(prod_id) / COUNT(DISTINCT txn_id) AS avg_prod_per_order
FROM #sales
```

## 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
``` sql
WITH #revenue AS(
SELECT txn_id,
       SUM(qty * price) AS revenue
FROM #sales
GROUP BY txn_id
)

SELECT DISTINCT
       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) OVER () AS percentile_25,
       PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue) OVER () AS percentile_50,
	   PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) OVER () AS percentile_75
FROM #revenue
```

## 4. What is the average discount value per transaction?
``` sql
SELECT ROUND(SUM(qty * price * (CAST(discount AS FLOAT)/100)) / COUNT(DISTINCT txn_id), 2) AS avg_disc_per_order
FROM #sales
```

## 5. What is the percentage split of all transactions for members vs non-members?
``` sql
WITH #member AS (
SELECT DISTINCT txn_id,
       member,
	   qty * price AS revenue
FROM #sales
)

SELECT COUNT(CASE WHEN member = 1 THEN 1 END) / CAST(COUNT(*) AS FLOAT) * 100 AS member_percent,
       COUNT(CASE WHEN member = 0 THEN 1 END) / CAST(COUNT(*) AS FLOAT) * 100 AS non_member_percent
FROM #member
```

## 6. What is the average revenue for member transactions and non-member transactions?
``` sql
WITH #member AS (
SELECT DISTINCT txn_id,
       member,
	   SUM(qty * price) AS revenue
FROM #sales
GROUP BY txn_id, member
)

SELECT ROUND(SUM(CASE WHEN member = 1 THEN revenue END) / CAST(COUNT(CASE WHEN member = 1 THEN 1 END) AS FLOAT), 2) AS member_percent,
       ROUND(SUM(CASE WHEN member = 0 THEN revenue END) / CAST(COUNT(CASE WHEN member = 0 THEN 1 END) AS FLOAT), 2) AS non_member_percent
FROM #member
```
