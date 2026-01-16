# SQL Basics - Complete Documentation

This document provides a comprehensive guide to all SQL concepts covered in the SQL Basics practice file, including explanations, examples, and use cases.

## Table of Contents

1. [Basic SQL Queries](#basic-sql-queries)
2. [Filtering and Sorting](#filtering-and-sorting)
3. [Aggregation Functions](#aggregation-functions)
4. [Data Definition Language (DDL)](#data-definition-language-ddl)
5. [Data Manipulation Language (DML)](#data-manipulation-language-dml)
6. [Joins and Set Operations](#joins-and-set-operations)
7. [String Functions](#string-functions)
8. [Numeric Functions](#numeric-functions)
9. [Date and Time Functions](#date-and-time-functions)
10. [NULL Handling Functions](#null-handling-functions)
11. [CASE Statements](#case-statements)
12. [Window Functions](#window-functions)
13. [Advanced SQL Concepts](#advanced-sql-concepts)
14. [Stored Procedures](#stored-procedures)
15. [Triggers](#triggers)
16. [Indexes](#indexes)

---

## Basic SQL Queries

### SELECT Statement

The `SELECT` statement is used to retrieve data from one or more tables.

**Basic Syntax:**
```sql
SELECT column1, column2, ...
FROM table_name;
```

**Examples:**
```sql
-- Select all columns from customers table
SELECT * FROM customers;

-- Select specific columns
SELECT first_name, country FROM customers;
```

**Explanation:**
- `SELECT *` retrieves all columns from the table
- Specifying column names retrieves only those columns
- This is the most fundamental SQL operation

---

## Filtering and Sorting

### WHERE Clause

The `WHERE` clause filters rows based on specified conditions.

**Syntax:**
```sql
SELECT * FROM table_name
WHERE condition;
```

**Examples:**
```sql
-- Filter customers with score >= 900
SELECT * FROM customers
WHERE score >= 900;

-- Filter by country
SELECT * FROM customers
WHERE country = 'Germany';
```

**Explanation:**
- Used to filter rows before they are returned
- Supports comparison operators: `=`, `!=`, `>`, `<`, `>=`, `<=`
- Can combine multiple conditions using `AND`, `OR`, `NOT`

### ORDER BY Clause

The `ORDER BY` clause sorts the result set by one or more columns.

**Syntax:**
```sql
SELECT * FROM table_name
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC];
```

**Examples:**
```sql
-- Sort by score in descending order
SELECT * FROM customers 
ORDER BY score DESC;

-- Nested sorting: first by country (ascending), then by score (descending)
SELECT * FROM customers 
ORDER BY country ASC, score DESC;
```

**Explanation:**
- `ASC` (ascending) is the default sort order
- `DESC` (descending) sorts from highest to lowest
- Multiple columns can be specified for nested sorting
- Useful for ranking and organizing data

---

## Aggregation Functions

### GROUP BY Clause

The `GROUP BY` clause groups rows that have the same values in specified columns and is used with aggregate functions.

**Syntax:**
```sql
SELECT column1, aggregate_function(column2)
FROM table_name
GROUP BY column1;
```

**Examples:**
```sql
-- Find total score for each country
SELECT country, SUM(score) AS Total_Scores 
FROM customers 
GROUP BY country;

-- Find total score and number of customers for each country
SELECT 
    country, 
    COUNT(id) AS number_of_cus, 
    SUM(score) AS total_scores 
FROM customers 
GROUP BY country;
```

**Explanation:**
- Groups rows with the same values in specified columns
- Must include all non-aggregated columns in GROUP BY
- Common aggregate functions: `SUM()`, `COUNT()`, `AVG()`, `MAX()`, `MIN()`

### HAVING Clause

The `HAVING` clause filters groups after aggregation (similar to WHERE but for groups).

**Syntax:**
```sql
SELECT column1, aggregate_function(column2)
FROM table_name
GROUP BY column1
HAVING condition;
```

**Example:**
```sql
-- Find countries with total score > 800
SELECT country, SUM(score) AS Total_score 
FROM customers 
GROUP BY country 
HAVING SUM(score) > 800;
```

**Explanation:**
- Used to filter groups after GROUP BY
- Can use aggregate functions in the condition
- WHERE filters rows before grouping; HAVING filters groups after grouping

### DISTINCT Keyword

The `DISTINCT` keyword returns unique values, eliminating duplicates.

**Example:**
```sql
-- Get unique countries
SELECT DISTINCT country FROM customers;
```

**Explanation:**
- Removes duplicate rows from the result set
- Can be used with multiple columns
- Useful for finding unique combinations

### TOP Clause

The `TOP` clause limits the number of rows returned (SQL Server specific).

**Examples:**
```sql
-- Get top 3 rows
SELECT TOP 3 * FROM customers;

-- Get top 3 customers with highest scores
SELECT TOP 3 * FROM customers 
ORDER BY score DESC;
```

**Explanation:**
- Limits result set to specified number of rows
- Often used with ORDER BY for ranking
- Alternative to LIMIT in other SQL dialects

---

## Data Definition Language (DDL)

DDL statements are used to define and modify database structure.

### CREATE TABLE

Creates a new table with specified columns and constraints.

**Example:**
```sql
CREATE TABLE persons (
    id INT NOT NULL,
    person_name VARCHAR(50) NOT NULL,
    birth_data DATE,
    phone VARCHAR(15) NOT NULL,
    CONSTRAINT pk_persons PRIMARY KEY (id)
);
```

**Explanation:**
- `NOT NULL` constraint ensures column cannot contain NULL values
- `PRIMARY KEY` constraint uniquely identifies each row
- Data types: `INT`, `VARCHAR(n)`, `DATE`, etc.
- Constraints enforce data integrity

### ALTER TABLE

Modifies an existing table structure.

**Examples:**
```sql
-- Add a new column
ALTER TABLE persons
ADD email VARCHAR(20) NOT NULL;

-- Drop a column
ALTER TABLE persons
DROP COLUMN phone;
```

**Explanation:**
- `ADD` adds new columns to existing table
- `DROP COLUMN` removes columns from table
- Use carefully in production as it can affect existing data

### DROP TABLE

Deletes a table and all its data.

**Example:**
```sql
DROP TABLE persons;
```

**Explanation:**
- Permanently removes table and all data
- Cannot be undone (unless you have backups)
- Use with extreme caution

---

## Data Manipulation Language (DML)

DML statements are used to manipulate data in tables.

### INSERT Statement

Adds new rows to a table.

**Examples:**
```sql
-- Insert a single row
INSERT INTO customers (id, first_name, country, score)
VALUES (6, 'Nitin', 'India', NULL);

-- Insert from another table
INSERT INTO persons (id, person_name, birth_data, phone)
SELECT id, first_name, NULL, 'UNKNOWN' 
FROM customers;
```

**Explanation:**
- First form inserts specific values
- Second form copies data from another table
- Column order must match between INSERT and VALUES/SELECT
- NULL values are allowed if column permits them

### UPDATE Statement

Modifies existing data in a table.

**Example:**
```sql
UPDATE customers
SET score = 0 
WHERE id = 6;
```

**Explanation:**
- Modifies values in existing rows
- WHERE clause specifies which rows to update
- Without WHERE, updates all rows (use with caution)

### DELETE Statement

Removes rows from a table.

**Example:**
```sql
DELETE FROM customers
WHERE id > 4;
```

**Explanation:**
- Removes rows matching the WHERE condition
- Without WHERE, deletes all rows (use with caution)
- Does not remove the table structure

---

## Joins and Set Operations

### JOIN Operations

Joins combine columns from multiple tables.

#### LEFT JOIN

Returns all rows from the left table and matching rows from the right table.

**Example:**
```sql
SELECT 
    o.OrderID,
    o.Sales,
    c.FirstName AS CustomerFirstName,
    c.LastName AS CustomerLastName,
    p.Product AS ProductName,
    p.price,
    e.FirstName AS EmployeeFirstName,
    e.LastName AS EmployeeLastName
FROM Sales.Orders AS o 
LEFT JOIN Sales.Customers AS c 
    ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Products AS p 
    ON o.ProductID = p.ProductID
LEFT JOIN Sales.Employees AS e  
    ON o.SalesPersonID = e.EmployeeID;
```

**Explanation:**
- Returns all rows from left table (Orders)
- Includes matching rows from right tables
- NULL values for non-matching right table columns
- Used when you need all records from the primary table

#### INNER JOIN

Returns only rows with matching values in both tables.

**Explanation:**
- Only returns rows where join condition is true
- Excludes rows without matches in either table
- Most common join type

#### FULL JOIN

Returns all rows from both tables.

**Explanation:**
- Combines LEFT and RIGHT JOIN results
- Includes all rows from both tables
- NULL values for non-matching columns

#### CROSS JOIN

Returns Cartesian product of both tables.

**Explanation:**
- Every row from first table combined with every row from second table
- No join condition required
- Results in large result sets (m × n rows)

### Set Operations

Set operations combine rows from multiple queries.

#### UNION

Combines results from multiple SELECT statements, removing duplicates.

**Example:**
```sql
SELECT CustomerID, LastName FROM Sales.Customers
UNION
SELECT EmployeeID, LastName FROM Sales.Employees;
```

**Explanation:**
- Combines rows from multiple queries
- Removes duplicate rows
- Column count and data types must match
- Sorts results by default

#### UNION ALL

Combines results including duplicates.

**Explanation:**
- Similar to UNION but keeps duplicates
- Faster than UNION (no duplicate checking)
- Use when duplicates are acceptable or desired

#### EXCEPT

Returns rows from first query that are not in second query.

**Example:**
```sql
SELECT c.FirstName, c.LastName 
FROM Sales.Customers AS c
EXCEPT
SELECT FirstName, LastName 
FROM Sales.Employees;
```

**Explanation:**
- Returns rows unique to first query
- Removes rows that exist in second query
- Useful for finding differences

#### INTERSECT

Returns only rows that exist in both queries.

**Explanation:**
- Returns common rows between queries
- Useful for finding overlaps
- Column structure must match

---

## String Functions

### CONCAT Function

Concatenates two or more strings together.

**Example:**
```sql
SELECT 
    first_name, 
    country,
    CONCAT(first_name, '-', country) AS firstname_country
FROM customers;
```

**Explanation:**
- Combines multiple strings into one
- Can concatenate columns and literals
- Alternative to using `+` operator

### UPPER and LOWER Functions

Convert strings to uppercase or lowercase.

**Explanation:**
- `UPPER()` converts to uppercase
- `LOWER()` converts to lowercase
- Useful for case-insensitive comparisons

### TRIM Function

Removes leading and trailing spaces from strings.

**Example:**
```sql
-- Find customers with leading/trailing spaces
SELECT first_name 
FROM customers 
WHERE first_name != TRIM(first_name);

-- Compare lengths before and after trimming
SELECT 
    first_name, 
    LEN(first_name) AS len_name, 
    LEN(TRIM(first_name)) AS len_trim_name,
    LEN(first_name) - LEN(TRIM(first_name)) AS flag
FROM customers;
```

**Explanation:**
- `TRIM()` removes spaces from both ends
- `LTRIM()` removes leading spaces
- `RTRIM()` removes trailing spaces
- `LEN()` returns string length

### REPLACE Function

Replaces occurrences of a substring within a string.

**Example:**
```sql
SELECT
    '123-345-567' AS phone_number,
    REPLACE('123-345-567', '-', '/') AS clean_phone_number;
```

**Explanation:**
- Replaces all occurrences of specified substring
- Useful for data cleaning
- Syntax: `REPLACE(string, old_substring, new_substring)`

### LEFT and RIGHT Functions

Extract characters from the left or right side of a string.

**Example:**
```sql
SELECT LEFT('nitin', 3) AS left_values;
```

**Explanation:**
- `LEFT(string, n)` returns first n characters
- `RIGHT(string, n)` returns last n characters
- Useful for extracting prefixes/suffixes

### SUBSTRING Function

Extracts a substring from a string.

**Example:**
```sql
SELECT 
    first_name, 
    SUBSTRING(TRIM(first_name), 2, LEN(first_name)) AS substring_from_2nd_char
FROM customers;
```

**Explanation:**
- Syntax: `SUBSTRING(string, start, length)`
- Extracts characters starting from `start` position
- Returns `length` characters
- Useful for parsing structured strings

---

## Numeric Functions

### ROUND Function

Rounds a number to a specified number of decimal places.

**Example:**
```sql
SELECT 
    3.1564, 
    ROUND(3.1564, 2),  -- Rounds to 2 decimal places
    ROUND(3.1564, 1);  -- Rounds to 1 decimal place
```

**Explanation:**
- Syntax: `ROUND(number, decimal_places)`
- Rounds to nearest value
- Negative decimal places round to left of decimal point

### ABS Function

Returns the absolute value of a number.

**Example:**
```sql
SELECT -20, ABS(-20);
```

**Explanation:**
- Returns positive value regardless of input sign
- Useful for distance calculations and comparisons

---

## Date and Time Functions

### Understanding Date Parts

Extract specific parts from date/time values.

**Example:**
```sql
SELECT 
    OrderID,
    CreationTime,
    DATETRUNC(day, CreationTime) AS day,
    DATENAME(MONTH, CreationTime) AS Month,
    DATEPART(year, CreationTime) AS year_dp,
    YEAR(CreationTime) AS Year,
    MONTH(CreationTime) AS Month  
FROM Sales.Orders;

-- Filter by month
SELECT * FROM Sales.Orders
WHERE MONTH(OrderDate) = 2;
```

**Explanation:**
- `DATEPART()` returns numeric part (year, month, day, etc.)
- `DATENAME()` returns string name (month name, day name)
- `YEAR()`, `MONTH()`, `DAY()` extract specific parts
- `DATETRUNC()` truncates to specified date part
- Useful for filtering and grouping by time periods

### FORMAT Function

Formats dates and numbers according to specified format.

**Examples:**
```sql
-- Format date as MM-dd-yyyy
SELECT 
    OrderID, 
    CreationTime,
    FORMAT(CreationTime, 'MM-dd-yyyy') AS USA_FORMAT
FROM Sales.Orders;

-- Custom format: Day Wed Jan Q1 2025 12:34:56 PM
SELECT 
    OrderId, 
    CreationTime,
    'Day ' + FORMAT(CreationTime, 'ddd mmm') +
    ' Q' + DATENAME(QUARTER, CreationTime) + ' ' +
    FORMAT(CreationTime, 'yyyy hh:mm:ss tt') AS CustomFormat
FROM Sales.Orders;

-- Group by formatted date
SELECT 
    FORMAT(OrderDate, 'MMM yy') AS OrderDate,
    COUNT(*)
FROM Sales.Orders
GROUP BY FORMAT(OrderDate, 'MMM yy');
```

**Explanation:**
- Formats dates according to pattern string
- Common patterns: 'MM-dd-yyyy', 'yyyy-MM-dd', 'MMM yy'
- Can combine with string concatenation for custom formats
- Useful for reporting and display

### CONVERT and CAST Functions

Convert data types.

**Examples:**
```sql
-- CONVERT (SQL Server specific)
SELECT 
    OrderID, 
    CreationTime,
    CONVERT(VARCHAR, CreationTime, 32) AS convertedtovarchar
FROM Sales.Orders;

-- CAST (SQL standard)
SELECT CAST('123' AS INT) AS [String to INT];
```

**Explanation:**
- `CAST()` is SQL standard, `CONVERT()` is SQL Server specific
- `CONVERT()` allows style parameter for dates
- Essential for type conversions and data type compatibility

---

## NULL Handling Functions

### ISNULL Function

Replaces NULL values with a specified value.

**Example:**
```sql
SELECT  
    CustomerID, 
    Score,
    AVG(Score) OVER () AS AverageScore,
    AVG(COALESCE(Score, 0)) OVER () AS AverageScore2
FROM Sales.Customers;
```

**Explanation:**
- `ISNULL(column, replacement)` replaces NULL with replacement value
- SQL Server specific function
- Useful for handling missing data

### COALESCE Function

Returns first non-NULL value from a list.

**Explanation:**
- `COALESCE(value1, value2, value3, ...)`
- Returns first non-NULL value
- Can handle multiple columns
- More flexible than ISNULL
- SQL standard function

---

## CASE Statements

The CASE statement provides conditional logic in SQL queries.

### Simple CASE

Maps specific values to other values.

**Example:**
```sql
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Gender,
    CASE Gender
        WHEN 'F' THEN '0'
        WHEN 'M' THEN '1'
        ELSE 'Not Available'
    END AS Gender1
FROM Sales.Employees;
```

**Explanation:**
- Compares a value against multiple conditions
- Returns corresponding result
- `ELSE` provides default value
- All result values must be same data type

### Searched CASE

Evaluates conditions rather than comparing values.

**Example:**
```sql
-- Categorize sales: High (>50), Medium (21-50), Low (≤20)
SELECT 
    Category,
    SUM(Sales) AS TotalSales
FROM (
    SELECT 
        OrderID,
        Sales,
        CASE
            WHEN Sales > 50 THEN 'HIGH'
            WHEN Sales > 20 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS Category
    FROM Sales.Orders
) t
GROUP BY Category
ORDER BY TotalSales DESC;
```

**Explanation:**
- Evaluates boolean conditions
- More flexible than simple CASE
- Can use complex conditions
- Useful for data categorization and business rules

---

## Window Functions

Window functions perform calculations across a set of rows related to the current row, without collapsing rows like GROUP BY.

### Overview

**Syntax:**
```sql
WINDOW_FUNCTION OVER (
    PARTITION_CLAUSE | 
    ORDER_CLAUSE | 
    FRAME_CLAUSE
)
```

**Types of Window Functions:**
1. **Aggregate Functions**: COUNT, SUM, AVG, MAX, MIN
2. **Rank Functions**: ROW_NUMBER, RANK, DENSE_RANK, CUME_DIST, PERCENT_RANK, NTILE
3. **Value Functions**: LEAD, LAG, FIRST_VALUE, LAST_VALUE

### Aggregate Window Functions

**Example:**
```sql
-- Total sales across all orders (window function keeps row details)
SELECT 
    OrderID, 
    ProductId, 
    SUM(sales) OVER(PARTITION BY ProductID) AS TotalSales
FROM Sales.Orders;

-- Multiple partitions
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER () AS TotalSales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS TotalSalesByProducts,
    SUM(Sales) OVER (PARTITION BY ProductID, OrderStatus) AS TotalByProductAndStatus
FROM Sales.Orders;
```

**Explanation:**
- `OVER()` applies function to all rows
- `PARTITION BY` creates groups (like GROUP BY but keeps all rows)
- Maintains row-level details while providing aggregates
- More flexible than GROUP BY for detailed analysis

### Rank Window Functions

**Example:**
```sql
-- Rank orders by sales
SELECT
    OrderID,
    OrderDate,
    Sales,
    RANK() OVER(ORDER BY Sales DESC) AS RankedSales
FROM Sales.Orders;
```

**Explanation:**
- `RANK()` assigns rank with gaps for ties
- `DENSE_RANK()` assigns rank without gaps
- `ROW_NUMBER()` assigns unique sequential numbers
- Requires `ORDER BY` clause
- Useful for ranking and top-N queries

### Frame Window Functions

Define a subset of rows within the window partition.

**Example:**
```sql
SELECT
    OrderID,
    OrderDate,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate
        ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
    ) AS total_sales
FROM Sales.Orders;
```

**Explanation:**
- `ROWS BETWEEN` defines frame boundaries
- `CURRENT ROW` - current row
- `UNBOUNDED PRECEDING` - start of partition
- `UNBOUNDED FOLLOWING` - end of partition
- `n PRECEDING/FOLLOWING` - n rows before/after
- Useful for running totals and moving averages

### Value Functions (LEAD, LAG)

Access values from other rows in the window.

**Functions:**
- `LAG()` - Gets previous row value
- `LEAD()` - Gets next row value
- `FIRST_VALUE()` - Gets first value in window
- `LAST_VALUE()` - Gets last value in window

**Rules:**
- Expression can be any data type
- `ORDER BY` is required
- Frame is optional

**Use Cases:**
- Time series analysis (MoM, YoY)
- Time gap analysis (customer retention)
- Comparison analysis (extremes)

**Example:**
```sql
-- Month-over-month sales change
SELECT *,
    CurrentMonthSales - PreviousMonthSales AS MOM_Change
FROM (
    SELECT
        MONTH(OrderDate) AS OrderMonth,
        SUM(Sales) AS CurrentMonthSales,
        LAG(SUM(Sales)) OVER (ORDER BY MONTH(OrderDate)) AS PreviousMonthSales
    FROM Sales.Orders
    GROUP BY MONTH(OrderDate)
) t;
```

### Window Functions Practice Exercises

**1. Count total number of orders for each product**
```sql
USE SalesDB;
SELECT 
    ProductID, 
    COUNT(ProductID) OVER (PARTITION BY ProductID) AS OrderCount
FROM Sales.Orders;
```

**2. Check for duplicate rows in orders table**
```sql
SELECT * 
FROM (
    SELECT 
        OrderID, 
        COUNT(*) OVER (PARTITION BY OrderID) AS checkPK
    FROM Sales.OrdersArchive
) t 
WHERE checkPK > 1;
```

**3. Find average sales for each product**
```sql
SELECT 
    ProductID, 
    Sales, 
    AVG(Sales) OVER () AS AvgSales, 
    AVG(COALESCE(Sales, 0)) OVER (PARTITION BY ProductID) AS AverageOfSalesByProducts
FROM Sales.Orders;
```

**4. Find all orders where sales are higher than average sales**
```sql
SELECT *
FROM (
    SELECT 
        OrderID,
        ProductID,
        Sales,
        AVG(Sales) OVER () AS AverageSales
    FROM Sales.Orders
) t 
WHERE Sales > AverageSales;
```

**5. Find highest and lowest sales with product details**
```sql
SELECT
    OrderID,
    ProductID,
    Sales,
    MIN(Sales) OVER() AS lowestSalesALL,
    MAX(Sales) OVER() AS HighestSalesALL,
    MIN(Sales) OVER(PARTITION BY ProductID) AS lowestSameProductSales,
    MAX(Sales) OVER(PARTITION BY ProductID) AS highestSameProductSales
FROM Sales.Orders;
```

**6. Show employees with highest salary**
```sql
SELECT * 
FROM (
    SELECT 
        EmployeeID, 
        FirstName, 
        LastName, 
        Salary,
        MAX(Salary) OVER() AS MaxSalary
    FROM Sales.Employees
) t 
WHERE Salary = MaxSalary;
```

**7. Find deviation of each sale from min and max**
```sql
SELECT
    OrderID,
    ProductID,
    Sales,
    MIN(Sales) OVER() AS lowestSalesALL,
    MAX(Sales) OVER() AS HighestSalesALL,
    Sales - MIN(Sales) OVER() AS deviationFromMin,
    MAX(Sales) OVER() - Sales AS deviationFromMAX
FROM Sales.Orders;
```

**8. Calculate moving average of sales for each product over time**
```sql
USE SalesDB;
SELECT
    OrderID, 
    ProductID, 
    OrderDate, 
    Sales,
    AVG(Sales) OVER (PARTITION BY ProductID) AS avgbyProduct,
    AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate) AS movingAVG
FROM Sales.Orders;
```

**Explanation:**
- Running total: Accumulates all values from start to current row
- Rolling total: Aggregates values within a fixed time window
- Moving average: Average of values within a specified window
- Useful for trend analysis and smoothing data

**9. Rank customers based on total sales**
```sql
SELECT
    CustomerID,
    SUM(Sales) AS TotalSales,
    RANK() OVER(ORDER BY SUM(Sales) DESC) AS RankCustomers
FROM Sales.Orders
GROUP BY CustomerID;
```

---

## Advanced SQL Concepts

### Database Architecture

#### Three-Level Architecture

1. **Physical Level**: Data files, logs, catalogs, partitions, caches, blocks
2. **Logical Level**: Tables, views, relationships, indexes, procedures, functions
3. **View Level**: Highest abstraction, multiple views for different departments

#### Metadata (INFORMATION_SCHEMA)

System-defined views providing database metadata.

**Example:**
```sql
-- Get column metadata
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;
```

**Explanation:**
- Provides information about database objects
- Useful for database introspection
- Standard SQL feature

### Subqueries

A query nested inside another query.

#### Non-Correlated Subqueries

Subquery that doesn't depend on the outer query.

**Examples:**
```sql
-- Subquery in FROM clause
SELECT * FROM
    (SELECT ProductID, Price, AVG(Price) OVER() AS AvgPrice
     FROM Sales.Products) t
WHERE Price > AvgPrice;

-- Subquery in JOIN
SELECT *
FROM Sales.Customers c
LEFT JOIN (
    SELECT COUNT(*) AS TotalOrders, CustomerID
    FROM Sales.Orders 
    GROUP BY CustomerID
) o ON c.CustomerID = o.CustomerID;

-- Subquery in WHERE clause
SELECT ProductID, Price
FROM Sales.Products
WHERE price > (
    SELECT AVG(Price) 
    FROM Sales.Products
);
```

**Explanation:**
- Executed once before main query
- Can be used in SELECT, FROM, WHERE, JOIN clauses
- Results can be used by outer query

#### Correlated Subqueries

Subquery that depends on outer query, executed for each row.

**Example:**
```sql
SELECT *, 
    (SELECT COUNT(*) 
     FROM Sales.Orders o 
     WHERE o.CustomerID = c.CustomerID) AS TotalSales
FROM Sales.Customers c;
```

**Explanation:**
- References columns from outer query
- Executed once per row of outer query
- Can be less efficient than joins
- Useful when join is not straightforward

### Common Table Expressions (CTE)

Temporary named result set that can be referenced multiple times in a query.

#### Non-Recursive CTE

**Syntax:**
```sql
WITH CTE_name AS (
    SELECT ...
)
SELECT ... FROM CTE_name;
```

**Example:**
```sql
-- Single CTE
WITH CTE_Total_Sales AS (
    SELECT customerID, SUM(Sales) AS TotalSales
    FROM sales.Orders
    GROUP BY customerID
)
SELECT
    c.CustomerID, 
    c.FirstName, 
    c.LastName, 
    cts.TotalSales
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales cts 
    ON cts.CustomerID = c.CustomerID;

-- Multiple CTEs
WITH CTE_Total_Sales AS (
    SELECT customerID, SUM(Sales) AS TotalSales
    FROM sales.Orders
    GROUP BY customerID
),
CTE_last_order AS (
    SELECT CustomerID, MAX(OrderDate) AS LastOrder
    FROM Sales.Orders
    GROUP BY CustomerID
)
SELECT
    c.CustomerID, 
    c.FirstName, 
    c.LastName, 
    cts.TotalSales, 
    clo.LastOrder
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales cts ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_last_order clo ON clo.CustomerID = c.CustomerID;

-- Nested CTEs (CTE using another CTE)
WITH CTE_Total_Sales AS (
    SELECT customerID, SUM(Sales) AS TotalSales
    FROM sales.Orders
    GROUP BY customerID
),
CTE_Customer_rank AS (
    SELECT 
        CustomerID, 
        TotalSales, 
        RANK() OVER (ORDER BY TotalSales DESC) AS CustomerRank
    FROM CTE_Total_Sales
),
CTE_Customer_based AS (
    SELECT
        CustomerID,
        CASE 
            WHEN TotalSales > 100 THEN 'HIGH'
            WHEN TotalSales > 80 THEN 'Medium'
            ELSE 'LOW'
        END AS CustomerSegments
    FROM CTE_Total_Sales
)
SELECT
    c.CustomerID, 
    c.FirstName, 
    c.LastName, 
    cts.TotalSales, 
    clo.LastOrder, 
    ccr.CustomerRank, 
    ccb.CustomerSegments
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales cts ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_last_order clo ON clo.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_rank ccr ON ccr.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_based ccb ON ccb.CustomerID = c.CustomerID;
```

**Explanation:**
- Improves query readability
- Can be referenced multiple times
- Cannot use ORDER BY in CTE definition
- Useful for complex queries and code reuse

#### Recursive CTE

CTE that references itself, useful for hierarchical data.

**Example:**
```sql
-- Generate sequence 1 to 20
WITH series AS (
    -- Anchor query
    SELECT 1 AS myNumber
    UNION ALL
    -- Recursive query
    SELECT myNumber + 1
    FROM Series
    WHERE myNumber < 20
)
SELECT * FROM series 
OPTION (MAXRECURSION 100);

-- Employee hierarchy
WITH CTE_Employee_hierarchy AS (
    -- Anchor query (top level employees)
    SELECT
        EmployeeID,
        FirstName,
        ManagerID,
        1 AS Level
    FROM Sales.Employees
    WHERE ManagerID IS NULL
    UNION ALL
    -- Recursive query (subordinates)
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.ManagerID,
        Level + 1
    FROM Sales.Employees AS e
    INNER JOIN CTE_Employee_hierarchy ceh
        ON e.ManagerID = ceh.EmployeeID
)
SELECT * FROM CTE_Employee_hierarchy;
```

**Explanation:**
- Requires anchor query and recursive query
- UNION ALL combines results
- Must have termination condition
- `MAXRECURSION` option limits recursion depth
- Useful for hierarchical queries (org charts, bill of materials)

### Views

Virtual tables based on the result of a SQL query.

**Example:**
```sql
-- Create view
CREATE VIEW V_monthlySummary AS (
    SELECT
        DATETRUNC(month, OrderDate) AS OrderMonth,
        SUM(Sales) AS TotalSales,
        COUNT(OrderID) AS TotatOrders,
        SUM(Quantity) AS TotalQuantities
    FROM Sales.Orders
    GROUP BY DATETRUNC(month, OrderDate)
);

-- Use view
SELECT * FROM V_monthlySummary;

-- Use view in query
SELECT 
    OrderMonth,
    SUM(TotalSales) OVER (ORDER BY OrderMonth) AS RunningTotal
FROM V_monthlySummary;

-- Drop view
DROP VIEW V_monthlySummary;
```

**Explanation:**
- Stores complex query logic
- Acts like a table but doesn't store data
- Simplifies complex queries
- Provides abstraction layer
- Can be used for security (restrict column access)
- Views are recalculated each time they're queried

### CTAS (Create Table As Select)

Creates a table from the result of a SELECT query.

**Example:**
```sql
-- Create table from query
SELECT
    DATENAME(month, OrderDate) AS OrderMonth,
    COUNT(OrderID) AS TotalOrders
INTO Sales.MonthlyOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate);

-- Refresh table (drop and recreate)
IF OBJECT_ID('Sales.MonthlyOrders', 'U') IS NOT NULL
    DROP TABLE Sales.MonthlyOrders
GO
SELECT
    DATENAME(month, OrderDate) AS OrderMonth,
    COUNT(OrderID) AS TotalOrders
INTO Sales.MonthlyOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate);
```

**Use Cases:**
- Create persistent snapshot of data
- Create data marts (physical layer)
- Temporary tables (use `#` prefix: `INTO #TempTable`)

**Explanation:**
- Creates physical table (unlike views)
- Data is stored, not recalculated
- Useful for performance optimization
- Can be refreshed by dropping and recreating

---

## Stored Procedures

Precompiled SQL code stored in the database for reuse.

### Basic Stored Procedure

**Example:**
```sql
-- Create procedure
CREATE PROCEDURE GetCustomerSummary AS
BEGIN
    SELECT
        COUNT(*) AS TotalCustomers,
        AVG(Score) AS AverageScore
    FROM Sales.Customers
    WHERE Country = 'USA'
END

-- Execute procedure
EXEC GetCustomerSummary;
```

**Explanation:**
- Encapsulates SQL logic
- Improves performance (precompiled)
- Reduces code duplication
- Enhances security
- Can be scheduled for automation

### Parameters

**Example:**
```sql
-- Procedure with parameter
ALTER PROCEDURE GetCustomerSummary 
    @Country NVARCHAR(50) = 'USA' 
AS
BEGIN
    SELECT
        COUNT(*) AS TotalCustomers,
        AVG(Score) AS AverageScore
    FROM Sales.Customers
    WHERE Country = @Country
END

-- Execute with parameter
EXEC GetCustomerSummary @Country = 'Germany';
EXEC GetCustomerSummary @Country = 'USA';
```

**Explanation:**
- Parameters prefixed with `@`
- Default values can be specified
- Pass values when executing
- Makes procedures flexible and reusable

### Variables

**Example:**
```sql
ALTER PROCEDURE GetCustomerSummary 
    @Country NVARCHAR(50) = 'USA' 
AS
BEGIN
    DECLARE @TotalCustomers INT, @AvgScore FLOAT;
    
    SELECT
        @TotalCustomers = COUNT(*),
        @AvgScore = AVG(Score)
    FROM Sales.Customers
    WHERE Country = @Country

    PRINT 'Total Customers From ' + @Country + ':' + CAST(@TotalCustomers AS NVARCHAR)
    PRINT 'Average Score from ' + @Country + ':' + CAST(@AvgScore AS NVARCHAR)
END
```

**Explanation:**
- Variables declared with `DECLARE`
- Assigned values using `SELECT` or `SET`
- Used for calculations and output
- Must be converted to string for concatenation

### Conditional Logic (IF-ELSE)

**Example:**
```sql
ALTER PROCEDURE GetCustomerSummary 
    @Country NVARCHAR(50) = 'USA' 
AS
BEGIN
    DECLARE @TotalCustomers INT, @AvgScore FLOAT;

    -- Data cleaning
    IF EXISTS (SELECT 1 FROM Sales.Customers WHERE Score IS NULL AND Country = @Country)
    BEGIN
        PRINT('Updating Null Scores to 0')
        UPDATE Sales.Customers
        SET Score = 0
        WHERE Score IS NULL AND Country = @Country;
    END
    ELSE
    BEGIN
        PRINT('NO Null Scores Found')
    END

    SELECT
        @TotalCustomers = COUNT(*),
        @AvgScore = AVG(Score)
    FROM Sales.Customers
    WHERE Country = @Country

    PRINT 'Total Customers From ' + @Country + ':' + CAST(@TotalCustomers AS NVARCHAR)
    PRINT 'Average Score from ' + @Country + ':' + CAST(@AvgScore AS NVARCHAR)
END
```

**Explanation:**
- `IF-ELSE` provides conditional execution
- `EXISTS` checks for row existence
- `BEGIN-END` blocks group statements
- Useful for data validation and cleaning

### Error Handling (TRY-CATCH)

**Example:**
```sql
ALTER PROCEDURE GetCustomerSummary 
    @Country NVARCHAR(50) = 'USA' 
AS
BEGIN
    BEGIN TRY
        DECLARE @TotalCustomers INT, @AvgScore FLOAT;

        -- Data cleaning
        IF EXISTS (SELECT 1 FROM Sales.Customers WHERE Score IS NULL AND Country = @Country)
        BEGIN
            PRINT('Updating Null Scores to 0')
            UPDATE Sales.Customers
            SET Score = 0
            WHERE Score IS NULL AND Country = @Country;
        END
        ELSE
        BEGIN
            PRINT('NO Null Scores Found')
        END

        SELECT
            @TotalCustomers = COUNT(*),
            @AvgScore = AVG(Score)
        FROM Sales.Customers
        WHERE Country = @Country

        PRINT 'Total Customers From ' + @Country + ':' + CAST(@TotalCustomers AS NVARCHAR)
        PRINT 'Average Score from ' + @Country + ':' + CAST(@AvgScore AS NVARCHAR)
    END TRY
    BEGIN CATCH
        PRINT('AN ERROR Occurred')
        PRINT('Error Message: ' + ERROR_MESSAGE())
        PRINT('ERROR Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR))
        PRINT('ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR))
    END CATCH
END
```

**Explanation:**
- `TRY-CATCH` blocks handle errors gracefully
- `ERROR_MESSAGE()` returns error description
- `ERROR_NUMBER()` returns error number
- `ERROR_LINE()` returns line number where error occurred
- Prevents procedure from crashing
- Essential for production code

---

## Triggers

Automated procedures that execute in response to specific database events.

### DML Triggers

Execute in response to INSERT, UPDATE, or DELETE operations.

**Example:**
```sql
-- Create log table
CREATE TABLE Sales.EmployeeLogs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    LogMessage VARCHAR(255),
    LogDate DATE
)

-- Create INSERT trigger
CREATE TRIGGER trg_AfterInsertEmployee ON Sales.Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO Sales.EmployeeLogs (EmployeeID, LogMessage, LogDate)
    SELECT
        EmployeeID,
        'New Employee Added = ' + CAST(EmployeeID AS VARCHAR),
        GETDATE() 
    FROM INSERTED
END

-- Trigger fires automatically on insert
INSERT INTO Sales.Employees
VALUES (6, 'Maria', 'Doe', 'HR', '1988-01-12', 'F', 80000, 3)
```

**Explanation:**
- `AFTER INSERT` - executes after insert operation
- `INSERTED` table contains newly inserted rows
- `DELETED` table contains deleted rows (for DELETE/UPDATE triggers)
- Useful for auditing, logging, and enforcing business rules
- Can impact performance if not designed carefully

**Types:**
- `AFTER` triggers - execute after the operation
- `INSTEAD OF` triggers - replace the operation

**Other Trigger Types:**
- **DDL Triggers**: Execute on CREATE, ALTER, DROP operations
- **LOGON Triggers**: Execute on user login events

---

## Indexes

Database objects that improve query performance by providing fast access to data.

### Index Structure

#### Clustered Index

Physically sorts and stores data rows in the table based on the index key. Only one clustered index per table.

**How it works:**
- Pages in database are stored in B-tree structure in sorted order
- Data pages are physically organized by the index key
- Access path: INDEX_PAGE → INDEX_PAGE (sorted) → DATA_PAGE
- Very fast for range queries and ordered data retrieval

**Example:**
```sql
USE SalesDB;
CREATE CLUSTERED INDEX idx_customer_ID ON Sales.Customers (CustomerID);
```

**Explanation:**
- Table data is physically sorted by CustomerID
- Only one clustered index allowed per table
- Primary key often creates clustered index automatically
- Best for columns frequently used in ORDER BY or range queries

#### Non-Clustered Index

Creates a separate structure that points to data rows. Multiple non-clustered indexes allowed per table.

**How it works:**
- Index pages contain row locators (page number, offset, etc.)
- Data pages remain in original order
- Access path: INDEX_PAGE → INDEX_PAGE → INDEX_PAGE (locations) → DATA_PAGE
- Requires additional lookup to retrieve actual data

**Example:**
```sql
CREATE NONCLUSTERED INDEX idx_customer_name ON Sales.Customers (FirstName);
```

**Explanation:**
- Faster for lookups on non-primary key columns
- Multiple non-clustered indexes can be created
- Slightly slower than clustered index (requires data page lookup)
- Best for foreign keys, frequently filtered columns, and join conditions

### Index Storage Types

#### RowStore Indexes

Traditional index storage where data is stored row by row.

**Characteristics:**
- Data stored as-is in row format
- Indexes follow same row structure
- Good for OLTP (Online Transaction Processing)
- Less efficient storage
- Normal speed for both read and write operations

**Use Cases:**
- Transactional databases
- Frequent INSERT/UPDATE/DELETE operations
- Point lookups and small range queries

#### ColumnStore Indexes

Indexes where data is stored column by column with compression.

**How it works:**
- Data compressed and stored column-wise
- Each column stored as large object format
- Creates separate column store index alongside original table
- Highly efficient storage with compression
- Fast reads but slower writes

**Example:**
```sql
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_customer_ID ON Sales.Customers (CustomerID);

-- Drop index
DROP INDEX idx_customer_ID ON Sales.Customers;
```

**Characteristics:**
- Excellent for analytical queries (OLAP)
- Very fast aggregation and scanning
- High compression ratio
- Slower for write operations
- Best for data warehouse scenarios

**Use Cases:**
- Data warehousing
- Analytical queries
- Aggregations and reporting
- Read-heavy workloads

### Index Functions

#### Unique Indexes

Ensures no duplicate values exist in the indexed column(s).

**Example:**
```sql
-- Create unique index for Products
CREATE UNIQUE NONCLUSTERED INDEX idx_Products_product
ON Sales.Products (Product);
```

**Explanation:**
- Enforces uniqueness constraint
- Faster reads but slower writes (must check for duplicates)
- Automatically created for PRIMARY KEY and UNIQUE constraints
- Useful for columns that should be unique but aren't primary keys

**Characteristics:**
- Prevents duplicate values
- Improves query performance
- Adds overhead to INSERT/UPDATE operations
- Can be created on single or multiple columns

#### Filtered Indexes

Indexes created on a subset of rows based on a filter condition.

**Example:**
```sql
-- Create filtered index for USA customers only
CREATE NONCLUSTERED INDEX idx_customers_country_filtered
ON Sales.Customers (Country)
WHERE Country = 'USA';
```

**Explanation:**
- Indexes only rows matching the filter condition
- Smaller index size (only relevant rows indexed)
- Faster queries when filter matches index filter
- Reduces index maintenance overhead
- Useful for frequently queried subsets of data

**Use Cases:**
- Indexing active records only
- Indexing specific status values
- Reducing index size for large tables
- Improving performance for filtered queries

### When to Use Which Index

**Decision Guide:**

1. **Fast INSERT operations**
   - Use: **HEAP** (no index, default)
   - When: Bulk inserts, staging tables, temporary data

2. **Primary Keys or Date columns**
   - Use: **CLUSTERED INDEX**
   - When: OLTP systems, frequently ordered by this column, range queries

3. **Analytical Queries**
   - Use: **COLUMNSTORE INDEX**
   - When: Data warehousing, aggregations, reporting, read-heavy workloads

4. **Non-primary key columns (foreign keys, joins, filters)**
   - Use: **NON-CLUSTERED INDEX**
   - When: Frequently filtered columns, join conditions, foreign keys

5. **Target subset of data or reduce index size**
   - Use: **FILTERED INDEX**
   - When: Querying specific subsets frequently, large tables with sparse data

6. **Enforce uniqueness or improve query speed**
   - Use: **UNIQUE INDEX**
   - When: Columns that should be unique, frequently queried unique columns

### Managing Indexes

#### List All Indexes on a Table

**Example:**
```sql
-- List all indexes on a specific table
sp_helpindex 'Sales.Customers';
```

**Explanation:**
- Returns index name, description, and indexed columns
- Useful for understanding existing indexes
- Helps identify duplicate or unused indexes

#### Monitor Index Usage

**Examples:**
```sql
-- View all index statistics
SELECT * FROM sys.indexes;

-- View detailed index usage statistics
SELECT * FROM sys.dm_db_index_usage_stats;

-- View missing index recommendations
SELECT * FROM sys.dm_db_missing_index_details;
```

**Explanation:**
- `sys.indexes`: Basic index information
- `sys.dm_db_index_usage_stats`: Tracks how often indexes are used
- `sys.dm_db_missing_index_details`: Suggests indexes that might improve performance
- Use these to identify unused indexes (candidates for removal) and missing indexes

#### Update Statistics

**Explanation:**
- Statistics help query optimizer choose best execution plan
- Should be updated regularly, especially after large data changes
- Can be done automatically or manually
- Outdated statistics can lead to poor query performance

#### Monitor Fragmentation

Fragmentation occurs when index pages are not stored contiguously, reducing performance.

**Example:**
```sql
-- Check index fragmentation
SELECT * FROM sys.dm_db_index_physical_stats(
    DB_ID(), 
    NULL, 
    NULL, 
    NULL, 
    'LIMITED'
);
```

**Fragmentation Guidelines:**
- **< 10%**: No action needed
- **10% to 30%**: Reorganize index
- **> 30%**: Rebuild index

**Reorganize Index (Light Operation)**

Defragments leaf nodes to keep them sorted.

**Example:**
```sql
ALTER INDEX idx_customers_country_filtered 
ON Sales.Customers 
REORGANIZE;
```

**Explanation:**
- Lightweight operation
- Can be done online (doesn't block queries)
- Reorganizes leaf-level pages
- Use for moderate fragmentation (10-30%)

**Rebuild Index (Heavy Operation)**

Recreates index from scratch.

**Example:**
```sql
ALTER INDEX idx_customers_country_filtered 
ON Sales.Customers 
REBUILD;
```

**Explanation:**
- Heavy operation (takes longer)
- May block queries depending on options
- Completely rebuilds index structure
- Use for high fragmentation (>30%)
- Can specify `ONLINE = ON` to allow concurrent access

**Best Practices:**
- Monitor fragmentation regularly
- Schedule maintenance during low-usage periods
- Use REORGANIZE for moderate fragmentation
- Use REBUILD for severe fragmentation
- Consider index maintenance in backup/recovery strategy

---

## Summary

This documentation covers SQL concepts from basic queries to advanced topics like stored procedures, triggers, and indexes. Key takeaways:

1. **Basic SQL**: SELECT, WHERE, ORDER BY, GROUP BY, HAVING
2. **Data Manipulation**: INSERT, UPDATE, DELETE
3. **Joins**: Combine data from multiple tables
4. **Functions**: String, numeric, date/time, NULL handling
5. **Window Functions**: Advanced analytics without collapsing rows
6. **Advanced Concepts**: Subqueries, CTEs, Views, CTAS
7. **Stored Procedures**: Reusable, parameterized SQL code
8. **Triggers**: Automated responses to database events
9. **Indexes**: Performance optimization through proper indexing strategies

Understanding these concepts is essential for effective database development, data analysis, and performance optimization.