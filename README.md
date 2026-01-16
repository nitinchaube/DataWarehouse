# Data Warehouse and Analytics

A SQL Server-based data warehouse implementation following the Medallion Architecture (Bronze, Silver, Gold layers) for ETL processing and analytics.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Sources](#data-sources)
- [Data Structure](#data-structure)
- [Implementation Details](#implementation-details)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [License](#license)

## Overview

This project implements a three-layer data warehouse architecture to process and transform data from multiple source systems (CRM and ERP) into a clean, analytics-ready format. The pipeline follows the Medallion Architecture pattern:

- **Bronze Layer**: Raw data ingestion from source systems
- **Silver Layer**: Cleaned and transformed data with business rules applied
- **Gold Layer**: Final dimensional model (Star Schema) optimized for analytics

## Architecture

### Medallion Architecture Layers

```
Source Systems (CSV Files)
    ↓
Bronze Layer (Raw Data)
    ↓
Silver Layer (Cleansed & Transformed)
    ↓
Gold Layer (Dimensional Model)
```

#### Bronze Layer
- **Purpose**: Raw data ingestion with minimal transformation
- **Schema**: `bronze`
- **Tables**: Direct mappings from source CSV files
- **Characteristics**: 
  - Preserves original data structure
  - No data quality checks
  - Fast bulk loading

#### Silver Layer
- **Purpose**: Data cleansing, standardization, and business rule application
- **Schema**: `silver`
- **Tables**: Cleaned versions of bronze tables
- **Characteristics**:
  - Data quality improvements
  - Standardized formats
  - Deduplication
  - Data type conversions
  - Business rule enforcement

#### Gold Layer
- **Purpose**: Analytics-ready dimensional model
- **Schema**: `gold`
- **Views**: Star schema with fact and dimension tables
- **Characteristics**:
  - Denormalized for query performance
  - Surrogate keys
  - Business-friendly column names
  - Optimized for reporting and analytics

## Project Structure

```
DataWarehouse/
├── Datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv          # Customer information from CRM
│   │   ├── prd_info.csv           # Product information from CRM
│   │   └── sales_details.csv      # Sales transaction details
│   └── source_erp/
│       ├── CUST_AZ12.csv          # Customer data from ERP
│       ├── LOC_A101.csv           # Location data from ERP
│       └── PX_CAT_G1V2.csv        # Product category data from ERP
├── scripts/
│   ├── initialize_database.sql   # Database and schema creation
│   ├── bronze/
│   │   ├── ddl.sql               # Bronze layer table definitions
│   │   └── proc_load_bronze.sql   # Stored procedure for bronze loading
│   ├── silver/
│   │   ├── ddl.sql               # Silver layer table definitions
│   │   ├── proc_load_silver.sql   # Stored procedure for silver loading
│   │   └── cleansing_bronze.sql   # Data quality analysis queries
│   └── gold/
│       └── ddl.sql               # Gold layer view definitions
├── docs/                          # Documentation directory
├── tests/                         # Test scripts directory
├── README.md                      # This file
└── LICENSE                        # MIT License
```

## Data Sources

### CRM System (`source_crm/`)
- **cust_info.csv**: Customer master data
- **prd_info.csv**: Product master data
- **sales_details.csv**: Sales transaction records

### ERP System (`source_erp/`)
- **CUST_AZ12.csv**: Customer demographic data
- **LOC_A101.csv**: Customer location/country data
- **PX_CAT_G1V2.csv**: Product category and classification data

## Data Structure

### Bronze Layer Tables

#### `bronze.crm_cust_info`
Raw customer information from CRM system.

| Column | Data Type | Description |
|--------|-----------|-------------|
| cst_id | INT | Customer ID |
| cst_key | NVARCHAR(50) | Customer key/number |
| cst_firstname | NVARCHAR(50) | First name |
| cst_lastname | NVARCHAR(50) | Last name |
| cst_maritial_status | NVARCHAR(50) | Marital status (M/S) |
| cst_gndr | NVARCHAR(50) | Gender (M/F) |
| cst_create_date | DATE | Record creation date |

#### `bronze.crm_prd_info`
Raw product information from CRM system.

| Column | Data Type | Description |
|--------|-----------|-------------|
| prd_id | INT | Product ID |
| prd_key | NVARCHAR(50) | Product key (format: CO-RF-FR-R92B-58) |
| prd_nm | NVARCHAR(50) | Product name |
| prd_cost | INT | Product cost |
| prd_line | NVARCHAR(50) | Product line code (M/R/S/T) |
| prd_start_dt | DATETIME | Product start date |
| prd_end_dt | DATETIME | Product end date |

#### `bronze.crm_sales_details`
Raw sales transaction data from CRM system.

| Column | Data Type | Description |
|--------|-----------|-------------|
| sls_ord_num | NVARCHAR(50) | Order number |
| sls_prd_key | NVARCHAR(50) | Product key |
| sls_cust_id | INT | Customer ID |
| sls_order_dt | INT | Order date (YYYYMMDD format) |
| sls_ship_dt | INT | Ship date (YYYYMMDD format) |
| sls_due_dt | INT | Due date (YYYYMMDD format) |
| sls_sales | INT | Sales amount |
| sls_quantity | INT | Quantity sold |
| sls_price | INT | Unit price |

#### `bronze.erp_cust_az12`
Raw customer demographic data from ERP system.

| Column | Data Type | Description |
|--------|-----------|-------------|
| cid | NVARCHAR(50) | Customer ID (may have NAS prefix) |
| bdate | DATE | Birth date |
| gen | NVARCHAR(50) | Gender |

#### `bronze.erp_loc_a101`
Raw location data from ERP system.

| Column | Data Type | Description |
|--------|-----------|-------------|
| cid | NVARCHAR(50) | Customer ID |
| cntry | NVARCHAR(50) | Country code |

#### `bronze.erp_px_cat_g1v2`
Raw product category data from ERP system.

| Column | Data Type | Description |
|--------|-----------|-------------|
| id | NVARCHAR(50) | Category ID |
| cat | NVARCHAR(50) | Category name |
| subcat | NVARCHAR(50) | Subcategory name |
| maintenance | NVARCHAR(50) | Maintenance information |

### Silver Layer Tables

Silver layer tables mirror bronze structure but include:
- **Data cleansing**: Trimmed strings, standardized values
- **Data type conversions**: Proper date formats, corrected data types
- **Deduplication**: Most recent records for duplicate keys
- **Business rules**: Code mappings (M→Male, S→Single, etc.)
- **Additional column**: `dwh_create_date` (DATETIME2) - timestamp of record creation in warehouse

#### Key Transformations in Silver Layer:

**crm_cust_info**:
- Trim whitespace from names
- Normalize marital status: S→Single, M→Married
- Normalize gender: F→Female, M→Male
- Deduplicate by selecting most recent record per customer

**crm_prd_info**:
- Extract category ID from product key (first 5 characters)
- Extract product key (remaining characters after position 7)
- Normalize product line codes: M→Mountain, R→Road, S→Other Sales, T→Touring
- Calculate end dates using LEAD window function
- Handle NULL costs

**crm_sales_details**:
- Convert integer dates (YYYYMMDD) to DATE type
- Validate and recalculate sales amounts
- Derive missing prices from sales and quantity
- Handle invalid date values (0 or incorrect length)

**erp_cust_az12**:
- Remove 'NAS' prefix from customer IDs
- Validate birth dates (reject future dates)
- Normalize gender values

**erp_loc_a101**:
- Remove special characters and whitespace from country codes
- Normalize country names: US→United States, DE→Germany
- Remove hyphens from customer IDs
- Deduplicate records

### Gold Layer Views

#### `gold.dim_customers`
Customer dimension table combining CRM and ERP data.

| Column | Data Type | Description |
|--------|-----------|-------------|
| customer_key | INT | Surrogate key (ROW_NUMBER) |
| customer_id | INT | Customer ID from CRM |
| customer_number | NVARCHAR(50) | Customer key/number |
| first_name | NVARCHAR(50) | First name |
| last_name | NVARCHAR(50) | Last name |
| country | NVARCHAR(50) | Country from ERP location |
| marital_status | NVARCHAR(50) | Marital status |
| gender | NVARCHAR(50) | Gender (CRM primary, ERP fallback) |
| birthdate | DATE | Birth date from ERP |
| create_date | DATE | Customer creation date |

**Joins**:
- `silver.crm_cust_info` (primary)
- LEFT JOIN `silver.erp_cust_az12` ON cst_key = cid
- LEFT JOIN `silver.erp_loc_a101` ON cst_key = cid

#### `gold.dim_products`
Product dimension table with category information.

| Column | Data Type | Description |
|--------|-----------|-------------|
| product_key | INT | Surrogate key |
| product_id | INT | Product ID |
| product_number | NVARCHAR(50) | Product key |
| product_name | NVARCHAR(50) | Product name |
| category_id | NVARCHAR(50) | Category ID |
| category | NVARCHAR(50) | Category name from ERP |
| subcategory | NVARCHAR(50) | Subcategory name |
| maintenance | NVARCHAR(50) | Maintenance info |
| cost | INT | Product cost |
| product_line | NVARCHAR(50) | Product line (Mountain/Road/etc.) |
| start_date | DATE | Product start date |

**Joins**:
- `silver.crm_prd_info` (primary)
- LEFT JOIN `silver.erp_px_cat_g1v2` ON cat_id = id
- Filter: Only current products (prd_end_dt IS NULL)

#### `gold.fact_sales`
Sales fact table with foreign keys to dimensions.

| Column | Data Type | Description |
|--------|-----------|-------------|
| order_number | NVARCHAR(50) | Order number |
| product_key | INT | Foreign key to dim_products |
| customer_key | INT | Foreign key to dim_customers |
| order_date | DATE | Order date |
| shipping_date | DATE | Shipping date |
| due_date | DATE | Due date |
| sales_amount | INT | Total sales amount |
| quantity | INT | Quantity sold |
| price | INT | Unit price |

**Joins**:
- `silver.crm_sales_details` (primary)
- LEFT JOIN `gold.dim_products` ON sls_prd_key = product_number
- LEFT JOIN `gold.dim_customers` ON sls_cust_id = customer_id

## Implementation Details

### Database Initialization

**File**: `scripts/initialize_database.sql`

- Creates `DataWarehouse` database
- Drops and recreates database if it exists
- Creates three schemas: `bronze`, `silver`, `gold`

### Bronze Layer Implementation

**DDL**: `scripts/bronze/ddl.sql`
- Creates all bronze tables matching source CSV structure
- Uses IF EXISTS checks for idempotent execution
- Tables are dropped and recreated on each run

**Load Procedure**: `scripts/bronze/proc_load_bronze.sql`
- Stored procedure: `bronze.load_bronze`
- Uses BULK INSERT for fast CSV loading
- Truncates tables before loading
- Includes error handling with TRY/CATCH
- Logs timing information for each table load
- Skips header rows (FIRSTROW = 2)

### Silver Layer Implementation

**DDL**: `scripts/silver/ddl.sql`
- Creates silver tables with same structure as bronze
- Adds `dwh_create_date` column with default GETDATE()
- Uses proper data types (DATE instead of DATETIME where appropriate)

**Load Procedure**: `scripts/silver/proc_load_silver.sql`
- Stored procedure: `silver.load_silver`
- Performs data transformations:
  - String trimming and normalization
  - Code value mappings
  - Date conversions
  - Deduplication using ROW_NUMBER()
  - Data validation and correction
- Truncates tables before loading
- Includes comprehensive error handling
- Logs timing for each transformation

**Cleansing Analysis**: `scripts/silver/cleansing_bronze.sql`
- Contains exploratory queries used to analyze bronze data
- Documents data quality issues found
- Shows transformation logic development process

### Gold Layer Implementation

**DDL**: `scripts/gold/ddl.sql`
- Creates views (not tables) for dimensional model
- Implements Star Schema design:
  - Dimension tables: `dim_customers`, `dim_products`
  - Fact table: `fact_sales`
- Uses ROW_NUMBER() to generate surrogate keys
- Joins multiple silver tables to create enriched dimensions
- Filters to current/active records where applicable

### Data Flow

1. **Source → Bronze**: CSV files loaded via BULK INSERT
2. **Bronze → Silver**: Stored procedure applies transformations
3. **Silver → Gold**: Views create dimensional model on-the-fly

### Key Design Decisions

1. **Medallion Architecture**: Separates concerns and allows for data quality improvements at each layer
2. **Stored Procedures**: Encapsulate ETL logic for reusability and scheduling
3. **Views for Gold Layer**: Provides flexibility and always reflects current silver data
4. **Surrogate Keys**: Enable dimension table updates without affecting fact tables
5. **Deduplication**: Handles duplicate records by selecting most recent
6. **Data Type Corrections**: Converts integer dates to proper DATE types
7. **Business Rule Application**: Standardizes codes to readable values

## Setup Instructions

### Prerequisites

- SQL Server (2016 or later)
- SQL Server Management Studio (SSMS) or Azure Data Studio
- Access to file system where CSV files are located

### Installation Steps

1. **Clone or download the repository**

2. **Place CSV files in the correct directories**:
   - Ensure CSV files are in `Datasets/source_crm/` and `Datasets/source_erp/`

3. **Update file paths in stored procedures**:
   - Edit `scripts/bronze/proc_load_bronze.sql`
   - Update BULK INSERT paths to match your file system
   - Default paths: `/datasets/source_crm/` and `/datasets/source_erp/`

4. **Run initialization script**:
   ```sql
   -- Execute in SQL Server Management Studio
   -- File: scripts/initialize_database.sql
   ```

5. **Create Bronze layer tables**:
   ```sql
   -- Execute: scripts/bronze/ddl.sql
   ```

6. **Create Silver layer tables**:
   ```sql
   -- Execute: scripts/silver/ddl.sql
   ```

7. **Create Bronze load procedure**:
   ```sql
   -- Execute: scripts/bronze/proc_load_bronze.sql
   ```

8. **Create Silver load procedure**:
   ```sql
   -- Execute: scripts/silver/proc_load_silver.sql
   ```

9. **Create Gold layer views**:
   ```sql
   -- Execute: scripts/gold/ddl.sql
   ```

## Usage

### Loading Data

#### Load Bronze Layer
```sql
USE DataWarehouse;
EXEC bronze.load_bronze;
```

This will:
- Truncate all bronze tables
- Load data from CSV files
- Display row counts and timing for each table

#### Load Silver Layer
```sql
USE DataWarehouse;
EXEC silver.load_silver;
```

This will:
- Truncate all silver tables
- Transform and cleanse data from bronze
- Apply business rules and data quality improvements
- Display timing information

#### Query Gold Layer
```sql
USE DataWarehouse;

-- Query customer dimension
SELECT * FROM gold.dim_customers;

-- Query product dimension
SELECT * FROM gold.dim_products;

-- Query sales fact table
SELECT * FROM gold.fact_sales;

-- Example analytics query
SELECT 
    c.country,
    p.product_line,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY c.country, p.product_line
ORDER BY total_sales DESC;
```

### Typical Workflow

1. **Initial Setup**: Run all DDL scripts once
2. **Daily/Periodic Load**:
   - Execute `bronze.load_bronze` to load new source data
   - Execute `silver.load_silver` to transform data
   - Gold layer views automatically reflect updated silver data
3. **Analytics**: Query gold layer views for reporting and analysis

### Monitoring

Both load procedures include:
- Timing information for each table/transformation
- Row counts after loading
- Error handling with detailed error messages
- Batch-level timing summaries

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 nitinchaube
