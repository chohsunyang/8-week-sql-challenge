## What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
``` sql
SELECT DISTINCT DATEPART(WEEK, '2020-06-15') AS base_week_number

WITH #temp1 AS (
SELECT calendar_year,
       CAST(SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN sales END) AS FLOAT) AS group_before,
       CAST(SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN sales END) AS FLOAT) AS group_after
FROM #clean_weekly_sales
GROUP BY calendar_year
)

SELECT *,
       group_after - group_before AS sales_diff,
	   ROUND((group_after - group_before)/group_before * 100, 2) AS sales_diff_percent    
FROM #temp1
WHERE calendar_year = 2020
```
## What about the entire 12 weeks before and after?
``` sql
WITH #temp2 AS (
SELECT calendar_year,
       CAST(SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN sales END) AS FLOAT) AS group_before,
       CAST(SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN sales END) AS FLOAT) AS group_after
FROM #clean_weekly_sales
GROUP BY calendar_year
)

SELECT *,
       group_after - group_before AS sales_diff,
	   ROUND((group_after - group_before)/group_before * 100, 2) AS sales_diff_percent    
FROM #temp2
ORDER BY calendar_year
```
## 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
``` sql
SELECT *,
       group_after - group_before AS sales_diff,
	   ROUND((group_after - group_before)/group_before * 100, 2) AS sales_diff_percent    
FROM #temp2
ORDER BY calendar_year
```

