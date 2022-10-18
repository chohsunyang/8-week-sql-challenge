-- 1. What is the unique count and total amount for each transaction type?
SELECT txn_type,
       COUNT(*) AS unique_count,
	   SUM(txn_amount) AS total_amount
FROM #customer_transactions t
GROUP BY txn_type

-- 2. What is the average total historical deposit counts and amounts for all customers?
SELECT ROUND(AVG(count), 0) AS avg_count,
       ROUND(AVG(amount), 2) AS avg_amount
FROM(
SELECT customer_id,
       COUNT(*) AS count,
	   AVG(txn_amount * 1.0) AS amount
FROM #customer_transactions t
WHERE txn_type = 'deposit'
GROUP BY customer_id) tmp


-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
SELECT month,
       COUNT(customer_id)
FROM(
SELECT DATEPART(MONTH, txn_date) AS month,
       customer_id,
	   SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
	   SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
	   SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
FROM #customer_transactions t
GROUP BY DATEPART(MONTH, txn_date), customer_id) a
WHERE deposit_count >= 2
  AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY month;

-- 4. What is the closing balance for each customer at the end of the month?
WITH month_record AS(
SELECT customer_id,
       DATEPART(MONTH, txn_date) AS txn_month,
	   SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
	            ELSE txn_amount * (-1) END) AS txn_amount
FROM #customer_transactions
GROUP BY customer_id,
         DATEPART(MONTH, txn_date)
)

SELECT customer_id,
       txn_month,
	   txn_amount,
	   SUM(txn_amount) OVER(
	   PARTITION BY customer_id
	   ORDER BY txn_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
FROM month_record

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

-- TBD
