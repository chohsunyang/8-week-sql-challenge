## 1. What are the top 3 products by total revenue before discount?
``` sql
WITH #revenue AS (
SELECT p.product_id,
       p.product_name,
	   p.segment_id,
	   p.segment_name,
	   p.category_id,
	   p.category_name,
	   SUM(qty) As total_qty,
       SUM(s.qty * s.price) AS revenue,
	   SUM(s.qty * s.price * (CAST(discount AS FLOAT)/100)) AS discount,
	   ROW_NUMBER() OVER(PARTITION BY segment_name 
	                     ORDER BY 
							SUM(s.qty * s.price) DESC) AS segment_rank
FROM #sales s
LEFT JOIN #product_details p
ON s.prod_id = p.product_id
GROUP BY p.product_id,
         p.product_name,
		 p.segment_id,
		 p.segment_name,
		 p.category_id,
	     p.category_name
)

SELECT TOP (3)
       product_name,
	   revenue
FROM #revenue
ORDER BY revenue DESC
```
## 2. What is the total quantity, revenue and discount for each segment?
``` sql
SELECT segment_name,
       SUM(total_qty) AS total_qty,
	   SUM(revenue) AS revenue,
	   SUM(discount) AS discount
FROM #revenue
GROUP BY segment_name
ORDER BY revenue DESC
```
## 3. What is the top selling product for each segment?
``` sql
SELECT segment_name,
       product_name,
	   revenue
FROM #revenue
WHERE segment_rank = 1
```
## 4. What is the total quantity, revenue and discount for each category?
``` sql
SELECT category_name,
       SUM(total_qty) AS total_qty,
	   SUM(revenue) AS revenue,
	   SUM(discount) AS discount
FROM #revenue
GROUP BY category_name
```
## 5. What is the top selling product for each category?
``` sql
WITH #revenue AS (
SELECT p.product_id,
       p.product_name,
	   p.segment_id,
	   p.segment_name,
	   p.category_id,
	   p.category_name,
	   SUM(qty) As total_qty,
       SUM(s.qty * s.price) AS revenue,
	   SUM(s.qty * s.price * (CAST(discount AS FLOAT)/100)) AS discount,
	   ROW_NUMBER() OVER(PARTITION BY category_name 
	                     ORDER BY 
							SUM(s.qty * s.price) DESC) AS category_rank
FROM #sales s
LEFT JOIN #product_details p
ON s.prod_id = p.product_id
GROUP BY p.product_id,
         p.product_name,
		 p.segment_id,
		 p.segment_name,
		 p.category_id,
	     p.category_name
)

SELECT category_name,
       product_name,
	   revenue
FROM #revenue
WHERE category_rank = 1
```
## 6. What is the percentage split of revenue by product for each segment?
``` sql
SELECT p.segment_name,
       p.product_name,
	   ROUND(100 * (SUM(s.qty * CAST(s.price AS FLOAT)) / SUM(SUM(s.qty * s.price)) OVER(PARTITION BY segment_name)
				   ), 2
			) AS percent_of_segment
FROM #sales s
LEFT JOIN #product_details p
ON s.prod_id = p.product_id
GROUP BY p.segment_name,
         p.product_name
```
## 7. What is the percentage split of revenue by segment for each category?
``` sql
SELECT p.category_name,
       p.segment_name,
	   ROUND(100 * (SUM(s.qty * CAST(s.price AS FLOAT)) / SUM(SUM(s.qty * s.price)) OVER(PARTITION BY category_name)
				   ), 2
			) AS percent_of_catrgory
FROM #sales s
LEFT JOIN #product_details p
ON s.prod_id = p.product_id
GROUP BY p.segment_name,
         p.category_name
```
## 8. What is the percentage split of total revenue by category?
``` sql
SELECT p.category_name,
	   ROUND(100 * (SUM(s.qty * CAST(s.price AS FLOAT)) / SUM(SUM(s.qty * s.price)) OVER()
				   ), 2
			) AS percent_of_catrgory
FROM #sales s
LEFT JOIN #product_details p
ON s.prod_id = p.product_id
GROUP BY p.category_name
```
## 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
``` sql
SELECT p.product_name,
       COUNT(DISTINCT txn_id) AS ttl_txn,
	   total_txn,
	   100 * (COUNT(DISTINCT txn_id) / CAST(total_txn AS FLOAT)) AS penetration
FROM #sales s
LEFT JOIN #product_details p
ON s.prod_id = p.product_id
CROSS APPLY (SELECT COUNT(DISTINCT txn_id) AS total_txn FROM #sales) pp
GROUP BY p.product_name,
         total_txn
ORDER BY COUNT(DISTINCT txn_id) DESC
```
## 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
``` sql
WITH #product AS (
SELECT s.prod_id,
       p.product_name,
       s.txn_id
FROM #sales s
LEFT JOIN #product_details p
ON s.prod_id = p.product_id
)

SELECT  TOP(1) *
FROM (
SELECT 
	p1.prod_id AS prod_id1,
	p1.product_name AS product_name1,
	p2.prod_id AS prod_id2,
	p2.product_name AS product_name2,
	p3.prod_id AS prod_id3,
	p3.product_name AS product_name3,
	COUNT(*) AS ttl
FROM #product p1
LEFT JOIN #product p2 
  ON p1.txn_id = p2.txn_id
 AND p1.prod_id < p2.prod_id
LEFT JOIN #product p3 
  ON p1.txn_id = p3.txn_id
 AND p1.prod_id < p3.prod_id
 AND p2.prod_id < p3.prod_id
GROUP BY 
	p1.prod_id,
	p1.product_name,
	p2.prod_id,
	p2.product_name,
	p3.prod_id,
	p3.product_name
) a
WHERE prod_id1 IS NOT NULL
  AND prod_id2 IS NOT NULL
  AND prod_id3 IS NOT NULL
ORDER BY ttl DESC
```
