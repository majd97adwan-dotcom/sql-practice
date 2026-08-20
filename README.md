# Sales Data Cleaning & Transformation Pipeline (MySQL)

## 📌 Business Scenario
In real-world data environments, incoming raw sales data often contains formatting errors, extra spaces, missing values (NULL), and improper date formats. 
This project demonstrates an **ETL (Extract, Transform, Load)** process in MySQL that cleans and transfers valid data from a staging table (`raw_sales_staging`) to a production-ready target table (`clean_orders`).

---

## 🛠️ Data Cleaning & Logic Rules
1. **Customer Name:** Standardized using `LOWER(TRIM())` to strip whitespace and lowercase all characters.
2. **Phone Number:** Stripped extra characters (`+`, `-`) using nested `REPLACE()` functions.
3. **Amount:** Stripped `$` symbols, converted text to `DECIMAL(10,2)`, and filtered out non-positive/NULL amounts.
4. **Order Status:** Converted to uppercase via `UPPER()` and handled `NULL` values by assigning `'UNKNOWN'`.
5. **Order Date:** Cast valid date strings to proper `DATE` types while filtering out invalid formats.
6. **Filtering:** Excluded invalid rows containing `NULL` product codes, invalid amounts, missing dates, or broken dates (`INVALID_DATE`).

---

## 💻 SQL Implementation

### 1. Database & Tables Setup
```sql
CREATE DATABASE IF NOT EXISTS sales_db;
USE sales_db;

-- Staging Table
CREATE TABLE IF NOT EXISTS raw_sales_staging (
    raw_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    raw_phone VARCHAR(50),
    product_code VARCHAR(50),
    amount_str VARCHAR(50),
    status_code VARCHAR(50),
    created_at_text VARCHAR(50)
);

-- Target Clean Table
CREATE TABLE IF NOT EXISTS clean_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    clean_phone VARCHAR(20),
    product_code VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(20) DEFAULT 'UNKNOWN',
    order_date DATE NOT NULL
);

2. Transformation & Loading Query

INSERT INTO clean_orders (
    customer_name, clean_phone, product_code, amount, order_status, order_date
)
SELECT 
    LOWER(TRIM(customer_name)) AS customer_name,
    REPLACE(REPLACE(raw_phone, '+', ''), '-', '') AS clean_phone,
    product_code,
    CAST(REPLACE(amount_str, '$', '') AS DECIMAL(10,2)) AS amount,
    CASE 
        WHEN status_code IS NULL THEN 'UNKNOWN'
        ELSE UPPER(status_code)
    END AS order_status,
    CAST(created_at_text AS DATE) AS order_date
FROM raw_sales_staging
WHERE product_code IS NOT NULL
  AND amount_str IS NOT NULL
  AND CAST(REPLACE(amount_str, '$', '') AS DECIMAL(10,2)) > 0
  AND created_at_text IS NOT NULL
  AND created_at_text != 'INVALID_DATE';

📊 Results Verification
Executing SELECT * FROM clean_orders; verifies that all bad records were filtered out and remaining data strictly adheres to relational schema integrity.
