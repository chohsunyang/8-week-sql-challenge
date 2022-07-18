--------------------------
-- Case Study Questions --
--------------------------

-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id,
       SUM(m.price) AS amount
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
       COUNT(DISTINCT order_date) AS visits
FROM dannys_diner.sales 
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH sales_cte AS
(	SELECT customer_id, 
         order_date, 
         product_name,
		     DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
	FROM dannys_diner.sales s
	JOIN dannys_diner.menu m
	  ON s.product_id = m.product_id
)

SELECT customer_id,  -- customer A has two items in order
       product_name
FROM sales_cte
WHERE rank = 1
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name,
       COUNT(s.product_id) AS purchased
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH sales_cte AS
(	SELECT s.customer_id, 
         m.product_name,
         COUNT(s.product_id) AS order_count,
		     DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rank
	FROM dannys_diner.sales s
	JOIN dannys_diner.menu m
	  ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
)

SELECT customer_id,  -- customer B has three items with 2 count
       product_name,
       order_count
FROM sales_cte
WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH sales_cte AS
(	SELECT s.customer_id, 
         s.product_id,
         s.order_date,
         m.join_date,
		     DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
	FROM dannys_diner.sales s
	JOIN dannys_diner.members m
	  ON s.customer_id = m.customer_id
  WHERE s.order_date >= m.join_date
)

SELECT s.customer_id,  
       m.product_name
FROM sales_cte s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
WHERE rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH sales_cte AS
(	SELECT s.customer_id, 
         s.product_id,
         s.order_date,
         m.join_date,
		     DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank
	FROM dannys_diner.sales s
	JOIN dannys_diner.members m
	  ON s.customer_id = m.customer_id
  WHERE s.order_date < m.join_date
)

SELECT s.customer_id,  
       m.product_name
FROM sales_cte s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
WHERE rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
-- with member
SELECT s.customer_id, 
       COUNT(s.product_id) AS items,
       SUM(m2.price) AS amount
FROM dannys_diner.sales s
JOIN dannys_diner.members m1
  ON s.customer_id = m1.customer_id
JOIN dannys_diner.menu m2
  ON s.product_id = m2.product_id
WHERE s.order_date < m1.join_date
GROUP BY s.customer_id
UNION
-- without member
SELECT s.customer_id, 
       COUNT(s.product_id) AS items,
       SUM(m2.price) AS amount
FROM dannys_diner.sales s
JOIN dannys_diner.menu m2
  ON s.product_id = m2.product_id
WHERE s.customer_id NOT IN (select customer_id from dannys_diner.members)
GROUP BY s.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH menu_cte AS
(	SELECT *, 
         (CASE WHEN product_name = 'sushi' THEN price * 20
               ELSE price * 10 END) AS points     
	FROM dannys_diner.menu
)

SELECT s.customer_id,  
       SUM(m.points) AS total_points
FROM dannys_diner.sales s
JOIN menu_cte m
  ON s.product_id = m.product_id
GROUP BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
--     how many points do customer A and B have at the end of January?
SELECT s.customer_id,  
       SUM( CASE WHEN m1.product_name = 'sushi' THEN m1.price * 20
                 WHEN s.order_date BETWEEN m2.join_date AND (m2.join_date + 6) THEN m1.price * 20
                 ELSE m1.price * 10 END) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m1
  ON s.product_id = m1.product_id
JOIN dannys_diner.members m2
  ON s.customer_id = m2.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id
