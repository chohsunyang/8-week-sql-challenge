## Campaign Analysis

Generate a table that has 1 single row for every unique visit_id record and has the following columns:

- `user_id`
- `visit_id`
- `visit_start_time`: the earliest event_time for each visit
- `page_views`: count of page views for each visit
- `cart_adds`: count of product cart add events for each visit
- `purchase`: 1/0 flag if a purchase event exists for each visit
- `campaign_name`: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
- `impression`: count of ad impressions for each visit
- `click`: count of ad clicks for each visit
- (Optional column) `cart_products`: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)



``` sql
SELECT 
  u.user_id,
  e.visit_id,
  s.event_time AS visit_start_time,
  CAST(COUNT(CASE WHEN event_type = 1 THEN 1 END) AS FLOAT) AS page_view,
  CAST(COUNT(CASE WHEN event_type = 2 THEN 1 END) AS FLOAT) add_to_cart,
  (CASE WHEN v.visit_id IS NOT NULL THEN 1 ELSE 0 END) AS purchase,
  s.campaign_name,
  CAST(COUNT(CASE WHEN event_type = 4 THEN 1 END) AS FLOAT) AS impression,
  CAST(COUNT(CASE WHEN event_type = 5 THEN 1 END) AS FLOAT) AS click
FROM #events e
LEFT JOIN #page_hierarchy p
       ON e.page_id = p.page_id
LEFT JOIN #users u
       ON u.cookie_id = e.cookie_id
LEFT JOIN (SELECT visit_id FROM #events WHERE event_type = 3 ) v
       ON e.visit_id = v.visit_id
LEFT JOIN (SELECT visit_id, event_time, campaign_name
           FROM #events e
           LEFT JOIN #campaign_identifier c
		              ON e.event_time BETWEEN c.start_date AND c.end_date
		       WHERE sequence_number = 1 ) s
       ON e.visit_id = s.visit_id
GROUP BY 
  u.user_id,
  e.visit_id,
  s.event_time,
  (CASE WHEN v.visit_id IS NOT NULL THEN 1 ELSE 0 END),
  s.campaign_name
```

| user_id | visit_id | visit_start_time        | page_view | add_to_cart | purchase | campaign_name                     | impression | click |
|---------|----------|-------------------------|-----------|-------------|----------|-----------------------------------|------------|-------|
| 149     | e922dd   | 2020-02-16 05:22:02.000 | 6         | 1           | 1        | Half Off - Treat Your Shellf(ish) | 1          | 0     |
| 456     | 680b95   | 2020-02-06 08:27:40.000 | 10        | 4           | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     |
| 475     | d73052   | 2020-02-03 14:27:25.000 | 1         | 0           | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     |
| 353     | 430061   | 2020-03-02 23:43:55.000 | 9         | 6           | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     |
| 446     | ce88bb   | 2020-01-23 21:53:15.000 | 9         | 2           | 1        | 25% Off - Living The Lux Life     | 0          | 0     |


Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:
- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to eachother?
