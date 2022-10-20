## Data Cleaning

Here is the data cleaning required from step 1

``` sql
DROP TABLE IF EXISTS #clean_weekly_sales;
SELECT CONVERT(DATE, week_date, 3) AS week_date,
       DATEPART(WEEK, CONVERT(DATE, week_date, 3)) AS week_number,
	   DATEPART(MONTH, CONVERT(DATE, week_date, 3)) AS month_number,
	   DATEPART(YEAR, CONVERT(DATE, week_date, 3)) AS calendar_year,
	   region,
	   platform,
	   CASE WHEN segment IS NULL OR segment = 'null' THEN 'unknown'
	        ELSE segment END AS segment,
	   CASE WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
	        WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
			WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
			WHEN segment IS NULL OR segment = 'null' THEN 'unknown'
			ELSE 'TBC' END AS age_band,
       CASE WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
	        WHEN LEFT(segment, 1) = 'F' THEN 'Families'
			WHEN segment IS NULL OR segment = 'null' THEN 'unknown'
			ELSE 'TBC' END AS demographic,
       customer_type,
       transactions,
	   sales,
	   ROUND((CAST(sales AS FLOAT) / CAST(transactions AS FLOAT)), 2) AS avg_transaction
INTO #clean_weekly_sales
FROM #weekly_sales

```
