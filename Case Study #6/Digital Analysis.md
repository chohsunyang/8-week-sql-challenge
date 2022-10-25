## 1. How many users are there?
```sql
SELECT COUNT(DISTINCT user_id) AS user_count
FROM #users
```
## 2. How many cookies does each user have on average?
```sql
SELECT ROUND(COUNT(DISTINCT cookie_id)/CAST(COUNT(DISTINCT user_id) AS FLOAT), 2) AS cookie_per_user
FROM #users
```
## 3. What is the unique number of visits by all users per month?
```sql
SELECT DATEPART(YY, event_time) AS calander_year, 
       DATEPART(MM, event_time) AS calander_month,
	   COUNT(DISTINCT visit_id) AS unique_visit
FROM #events
GROUP BY DATEPART(YY, event_time), DATEPART(MM, event_time)
ORDER BY DATEPART(YY, event_time), DATEPART(MM, event_time)
```
## 4. What is the number of events for each event type?
```sql
SELECT e.event_type,
       ei.event_name,
       COUNT(*)
FROM #events e
LEFT JOIN #event_identifier ei
       ON e.event_type = ei.event_type
GROUP BY e.event_type, ei.event_name
ORDER BY e.event_type;
```
## 5. What is the percentage of visits which have a purchase event?
```sql
SELECT COUNT(*) AS visits, 
       COUNT(CASE WHEN purchase > 0 THEN 1 END) AS visit_with_purchase,
       ROUND((COUNT(CASE WHEN purchase > 0 THEN 1 END) / CAST(COUNT(*) AS FLOAT)) * 100,2) AS visit_with_purchase
FROM #activity
```
## 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
```sql
WITH #activity AS (
SELECT visit_id, 
       cookie_id,
	   COUNT(CASE WHEN event_type = 1 THEN 1 END) AS page_view,
	   COUNT(CASE WHEN event_type = 1 AND　page_id = 12 THEN 1 END) AS page_view_checkout,
	   COUNT(CASE WHEN event_type = 2 THEN 1 END) AS add_to_cart,
	   COUNT(CASE WHEN event_type = 3 THEN 1 END) AS purchase,
	   COUNT(CASE WHEN event_type = 4 THEN 1 END) AS ad_impression,
	   COUNT(CASE WHEN event_type = 5 THEN 1 END) AS ad_click,
	   COUNT(*) AS total_event
FROM #events
GROUP BY visit_id, cookie_id
)

SELECT COUNT(CASE WHEN page_view_checkout > 0 THEN 1 END) AS visits_with_checkout, 
       COUNT(CASE WHEN page_view_checkout > 0 AND purchase > 0 THEN 1 END) AS visit_with_purchase,
	   COUNT(CASE WHEN page_view_checkout > 0 AND purchase = 0 THEN 1 END) AS visit_without_purchase,
       ROUND(COUNT(CASE WHEN page_view_checkout > 0 AND purchase = 0 THEN 1 END) / CAST(COUNT(*) AS FLOAT) * 100,2) AS pecentage_all_visit
FROM #activity
```
## 7. What are the top 3 pages by number of views?
```sql
SELECT TOP(3)
       p.page_id,
       p.page_name,
       COUNT(*)
FROM #events e
LEFT JOIN #page_hierarchy p
       ON e.page_id = p.page_id
WHERE event_type = 1
GROUP BY p.page_id, p.page_name
ORDER BY  COUNT(*) DESC;
```
## 8. What is the number of views and cart adds for each product category?
```sql
SELECT p.product_category,
       COUNT(CASE WHEN event_type = 1 THEN 1 END) AS page_view,
	   COUNT(CASE WHEN event_type = 2 THEN 1 END) AS add_to_cart
FROM #events e
LEFT JOIN #page_hierarchy p
       ON e.page_id = p.page_id
--WHERE product_category <> 'null'
WHERE product_id > 0
GROUP BY p.product_category
```
## 9. What are the top 3 products by purchases?
```sql
SELECT p.page_name,
       COUNT(*) AS add_to_cart,
	   COUNT(v.visit_id) AS visit_with_purchase
FROM #events e
LEFT JOIN #page_hierarchy p
       ON e.page_id = p.page_id
LEFT JOIN (SELECT visit_id FROM #events WHERE event_type = 3 ) v
       ON e.visit_id = v.visit_id
WHERE e.event_type = 2
GROUP BY p.page_name
ORDER BY COUNT(v.visit_id) DESC
```
