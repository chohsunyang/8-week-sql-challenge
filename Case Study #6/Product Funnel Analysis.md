
## Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:
- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

First we can create a CTE table to make the calculation easier.
``` sql
WITH #funnel AS (
SELECT 
  p.product_category,
  p.page_name,
  CAST(COUNT(CASE WHEN event_type = 1 THEN 1 END) AS FLOAT) AS page_view,
  CAST(COUNT(CASE WHEN event_type = 2 THEN 1 END) AS FLOAT) add_to_cart,
  CAST(COUNT(CASE WHEN event_type = 2 AND v.visit_id IS NULL THEN 1 END) AS FLOAT) AS abandon,
  CAST(COUNT(CASE WHEN event_type = 2 AND v.visit_id IS NOT NULL THEN 1 END) AS FLOAT) AS purchase
FROM #events e
LEFT JOIN #page_hierarchy p
       ON e.page_id = p.page_id
LEFT JOIN (SELECT visit_id FROM #events WHERE event_type = 3 ) v
       ON e.visit_id = v.visit_id
WHERE p.product_id > 0
GROUP BY p.product_category, p.page_name
)
```
### 1. Which product had the most views, cart adds and purchases?
### 2. Which product was most likely to be abandoned?
### 3. Which product had the highest view to purchase percentage?
``` sql
SELECT *,
       page_view + add_to_cart + purchase AS view_cart_purchase,
	   ROUND(abandon / add_to_cart * 100, 2) AS abandon_rate,
	   ROUND(purchase / page_view * 100, 2) AS view_to_purchase,
	   ROUND(add_to_cart / page_view * 100, 2) AS view_to_addCart,
	   ROUND(purchase / add_to_cart * 100, 2) AS addCart_to_purchase
FROM #funnel
```

### 4. What is the average conversion rate from view to cart add?
``` sql
SELECT ROUND(SUM(add_to_cart) / SUM(page_view) * 100, 2) AS avg_view_to_addCart
FROM #funnel
```

### 5. What is the average conversion rate from cart add to purchase?
``` sql
SELECT ROUND(SUM(purchase) / SUM(add_to_cart) * 100, 2) AS avg_addCart_to_purchase
FROM #funnel
```

Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
``` sql
SELECT p.product_category,
       CAST(COUNT(CASE WHEN event_type = 1 THEN 1 END) AS FLOAT) AS page_view,
	   CAST(COUNT(CASE WHEN event_type = 2 THEN 1 END) AS FLOAT) add_to_cart,
	   CAST(COUNT(CASE WHEN event_type = 2 AND v.visit_id IS NULL THEN 1 END) AS FLOAT) AS abandon,
	   CAST(COUNT(CASE WHEN event_type = 2 AND v.visit_id IS NOT NULL THEN 1 END) AS FLOAT) AS purchase
FROM #events e
LEFT JOIN #page_hierarchy p
       ON e.page_id = p.page_id
LEFT JOIN (SELECT visit_id FROM #events WHERE event_type = 3 ) v
       ON e.visit_id = v.visit_id
WHERE p.product_id > 0
GROUP BY p.product_category
```

