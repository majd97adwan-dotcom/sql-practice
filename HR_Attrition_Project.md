# 📊 HR Employee Attrition & Data Cleaning Project
**Author:** Majd Adwan
**Tool / Tech Stack:** MySQL / SQL

---

## 📌 1. Project Overview
This project demonstrates data cleaning and analytical querying skills using SQL on a Human Resources (HR) dataset. 
The main objective is to answer a key business question: **"Which departments suffer from the highest turnover rates, and is there a correlation with average employee salaries?"**

---

## 🛠️ 2. Data Cleaning Steps

### A. Database and Raw Table Creation:
```sql
CREATE DATABASE IF NOT EXISTS hr_project;
USE hr_project;

CREATE TABLE raw_employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'Active'
);

B. Text & NULL Value Handling (Data Cleaning Script):
Text Standardization: Applied TRIM() and case formatting functions to fix inconsistent department names and remove whitespace.
Salary Formatting: Removed text symbols like ($) and formatted values into numeric DECIMAL(10,2).
Handling Missing Values: Managed missing salaries (NULL) using conditional CASE WHEN logic.


SELECT 
    TRIM(department) AS department_name,
    CASE 
        WHEN salary IS NULL THEN 0
        ELSE CAST(REPLACE(salary, '$', '') AS DECIMAL(10,2))
    END AS clean_salary
FROM raw_employees;

📈 3. Main Analytical Query
This query aggregates employee records per department to present total staff count, number of resignations, and average salary:


SELECT 
    department,
    COUNT(emp_id) AS total_employees,
    SUM(CASE WHEN status = 'Left' THEN 1 ELSE 0 END) AS left_employees,
    ROUND(AVG(salary), 2) AS average_salary
FROM raw_employees
GROUP BY department;

💡 4. Business Insights & Recommendations
High Turnover in Sales: The analysis reveals that the Sales department experienced the highest attrition rate.
Salary Gap Impact: Employees in the Sales department have the lowest average salary compared to other departments (such as IT and HR), which likely drives higher turnover.
Actionable Recommendation: It is recommended to review the compensation structure and incentive plans for the Sales team to reduce employee attrition.
