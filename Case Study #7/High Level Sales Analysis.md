## 1. What was the total quantity sold for all products?
``` sql
SELECT SUM(qty) AS total_quantity
FROM #sales
```

## 2. What is the total generated revenue for all products before discounts?
``` sql
SELECT SUM(qty * price) AS total_sales
FROM #sales
```

## 3. What was the total discount amount for all products?
``` sql
SELECT SUM(qty * price * (CAST(discount AS FLOAT)/100))  AS total_discount
FROM #sales
```
