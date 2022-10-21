### 1. What day of the week is used for each week_date value?
``` sql
SELECT DISTINCT
       DATENAME(WEEKDAY, week_date) AS date_name
FROM #clean_weekly_sales
```

### 2. What range of week numbers are missing from the dataset?
``` sql
SELECT week_number,
       COUNT(*) AS records
FROM #clean_weekly_sales
GROUP BY week_number
ORDER BY week_number
```

### 3. How many total transactions were there for each year in the dataset?
``` sql
SELECT calendar_year,
       SUM(transactions) AS transactions
FROM #clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year
```

### 4. What is the total sales for each region for each month?
``` sql
SELECT region,
       calendar_year,
       month_number,
       DATENAME(MONTH, week_date) AS month_name,
       SUM(CAST(sales AS BIGINT)) AS sales
FROM #clean_weekly_sales
GROUP BY region, calendar_year, month_number, DATENAME(MONTH, week_date)
ORDER BY region, calendar_year, month_number
```

### 5. What is the total count of transactions for each platform
``` sql
SELECT platform,
       SUM(CAST(transactions AS BIGINT)) AS transactions
FROM #clean_weekly_sales
GROUP BY platform
```

### 6. What is the percentage of sales for Retail vs Shopify for each month?
``` sql
WITH #temp AS (
SELECT calendar_year,
       month_number,
       DATENAME(MONTH, week_date) AS month_name,
	   platform,
	   SUM(CAST(sales AS FLOAT)) AS total_sales
FROM #clean_weekly_sales
GROUP BY calendar_year, month_number, DATENAME(MONTH, week_date), platform
)

SELECT calendar_year,
       month_number,
       month_name,
	   ROUND(100 * SUM(CASE WHEN platform = 'Retail' THEN total_sales END) / SUM(total_sales), 2) AS Retail,
	   ROUND(100 * SUM(CASE WHEN platform = 'Shopify' THEN total_sales END) / SUM(total_sales), 2) AS Shopify
FROM #temp
GROUP BY calendar_year, month_number, month_name
ORDER BY calendar_year, month_number
```

### 7. What is the percentage of sales by demographic for each year in the dataset?
``` sql
WITH #temp1 AS (
SELECT calendar_year,
	   demographic,
	   SUM(CAST(sales AS FLOAT)) AS total_sales
FROM #clean_weekly_sales
GROUP BY calendar_year, demographic
)

SELECT calendar_year,
	   ROUND(100 * SUM(CASE WHEN demographic = 'Families' THEN total_sales END) / SUM(total_sales), 2) AS Families,
	   ROUND(100 * SUM(CASE WHEN demographic = 'Couples' THEN total_sales END) / SUM(total_sales), 2) AS Couples,
	   ROUND(100 * SUM(CASE WHEN demographic = 'unknown' THEN total_sales END) / SUM(total_sales), 2) AS unknown
FROM #temp1
GROUP BY calendar_year
ORDER BY calendar_year
```

### 8. Which age_band and demographic values contribute the most to Retail sales?
``` sql
SELECT age_band,
	   demographic,
	   SUM(CAST(sales AS FLOAT)) AS total_sales
FROM #clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY SUM(CAST(sales AS FLOAT)) DESC
```

### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
``` sql
SELECT calendar_year,
       platform,
	   ROUND(AVG(avg_transaction), 2) AS avg_transaction,
       ROUND(SUM(CAST(sales AS FLOAT)) / SUM(CAST(transactions AS FLOAT)), 2) AS avg_transaction_new
FROM #clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year
