# Data Cleaning and Exploration Using SQL

## Overview

Data cleaning and exploration are crucial steps in the data analysis process. SQL (Structured Query Language) is a powerful tool for these tasks, enabling users to efficiently manage, clean, and explore large datasets. This README provides a comprehensive guide to using SQL for data cleaning and exploration.

## What is Data Cleaning and Exploration?

- **Data Cleaning:** The process of identifying and correcting (or removing) errors and inconsistencies in data to improve its quality.
- **Data Exploration:** The process of analyzing and summarizing data to understand its structure, patterns, and relationships.

## Why Use SQL for Data Cleaning and Exploration?

- **Efficiency:** SQL handles large datasets efficiently, making it suitable for cleaning and exploring substantial amounts of data.
- **Versatility:** SQL provides a range of functions and operators for manipulating and querying data.
- **Standardization:** SQL is a widely-used language, making skills transferable across different database systems.

## Basic SQL Commands for Data Cleaning

1. **Removing Duplicates:**

   ```sql
   SELECT DISTINCT *
   FROM table_name;
   ```

2. **Handling Missing Values:**

   - **Find missing values:**

     ```sql
     SELECT *
     FROM table_name
     WHERE column_name IS NULL;
     ```

   - **Replace missing values:**

     ```sql
     UPDATE table_name
     SET column_name = 'default_value'
     WHERE column_name IS NULL;
     ```

3. **Correcting Data Types:**

   - **Convert data types (e.g., to integer):**

     ```sql
     ALTER TABLE table_name
     MODIFY column_name INT;
     ```

4. **Standardizing Data Formats:**

   - **Update date format:**

     ```sql
     UPDATE table_name
     SET date_column = STR_TO_DATE(date_column, '%m/%d/%Y');
     ```

5. **Trimming Whitespaces:**

   ```sql
   UPDATE table_name
   SET column_name = TRIM(column_name);
   ```

## Exploring Data with SQL

1. **Basic Queries:**

   - **View table schema:**

     ```sql
     DESCRIBE table_name;
     ```

   - **View first few rows:**

     ```sql
     SELECT *
     FROM table_name
     LIMIT 10;
     ```

2. **Aggregating Data:**

   - **Count rows:**

     ```sql
     SELECT COUNT(*)
     FROM table_name;
     ```

   - **Calculate averages:**

     ```sql
     SELECT AVG(column_name)
     FROM table_name;
     ```

   - **Group data:**

     ```sql
     SELECT column_name, COUNT(*)
     FROM table_name
     GROUP BY column_name;
     ```

3. **Filtering Data:**

   - **Apply conditions:**

     ```sql
     SELECT *
     FROM table_name
     WHERE column_name = 'value';
     ```

   - **Use multiple conditions:**

     ```sql
     SELECT *
     FROM table_name
     WHERE column_name1 = 'value1'
       AND column_name2 > 100;
     ```

4. **Joining Tables:**

   - **Inner join:**

     ```sql
     SELECT a.*, b.column_name
     FROM table_a a
     INNER JOIN table_b b
     ON a.id = b.a_id;
     ```

   - **Left join:**

     ```sql
     SELECT a.*, b.column_name
     FROM table_a a
     LEFT JOIN table_b b
     ON a.id = b.a_id;
     ```

## Advanced Data Cleaning Techniques

1. **Handling Outliers:**

   - **Identify outliers:**

     ```sql
     SELECT *
     FROM table_name
     WHERE column_name > (SELECT AVG(column_name) + 2 * STDDEV(column_name)
                           FROM table_name);
     ```

   - **Remove outliers:**

     ```sql
     DELETE FROM table_name
     WHERE column_name > (SELECT AVG(column_name) + 2 * STDDEV(column_name)
                           FROM table_name);
     ```

2. **Data Transformation:**

   - **Apply functions to data:**

     ```sql
     SELECT column_name, UPPER(column_name) AS upper_case_column
     FROM table_name;
     ```

3. **Data Validation:**

   - **Ensure data integrity:**

     ```sql
     SELECT column_name
     FROM table_name
     WHERE column_name NOT REGEXP '^[0-9]+$';
     ```

## Examples

1. **Example 1: Cleaning a Customer Table**

   - Remove duplicates:

     ```sql
     DELETE FROM customers
     WHERE id NOT IN (
         SELECT MIN(id)
         FROM customers
         GROUP BY email
     );
     ```

   - Fill missing phone numbers with a default value:

     ```sql
     UPDATE customers
     SET phone = '000-000-0000'
     WHERE phone IS NULL;
     ```

2. **Example 2: Exploring Sales Data**

   - Find total sales by product:

     ```sql
     SELECT product_name, SUM(sales_amount) AS total_sales
     FROM sales
     GROUP BY product_name;
     ```

   - Join sales data with product information:

     ```sql
     SELECT s.product_name, p.category, SUM(s.sales_amount) AS total_sales
     FROM sales s
     INNER JOIN products p
     ON s.product_id = p.product_id
     GROUP BY s.product_name, p.category;
     ```

Feel free to reach out for any questions or further assistance with SQL data cleaning and exploration!

---

This provides a thorough overview of using SQL for data cleaning and exploration, including practical commands and examples to help users get started.
