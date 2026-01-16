-- Active: 1756166148797@@127.0.0.1@1433@DataWarehouse
use DataWarehouse;

Select * from bronze.crm_cust_info;

-- Step 1: Checking for duplicates and null values
Select cst_id, count(*)
from bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- COuld see many id's are there with more rows than 1
--Step 2: Ranking the data using create_date to only pick row which is recent out of duplicates

Select 
    *,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
from bronze.crm_cust_info

-- this will show all the unique recent rows which we want
Select * from (
    Select 
    *,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
    from bronze.crm_cust_info
)t where flag_last = 1;

-- Step 3: Triming the space in first name and lastname
Select cst_lastname
from bronze.crm_cust_info
where cst_lastname != TRIM(cst_lastname)

-- Step 4: Data consistency
Select DISTINCT(cst_gndr)
from bronze.crm_cust_info -- since there are M,F,NULL we can replace them with Male, Female, n/a


----- ACTUAL correct query based on above steps
Select 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname ,
TRIM(cst_lastname) as cst_lastname,
CASE WHEN UPPER(TRIM(cst_maritial_status)) = 'S' THEN 'Single'
     WHEN UPPER(TRIM(cst_maritial_status)) = 'M' THEN 'Married'
     ELSE 'n/a'
END cst_maritial_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
     ELSE 'n/a'
END cst_gndr,
cst_create_date 
from (
    Select 
    *,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
    from bronze.crm_cust_info
)t where flag_last = 1;



-- CHECKING crm_prd_info

Select
* 
from bronze.crm_prd_info

-- splitting prd_key into two column as     erp_px_cat_g1v2 has one column consist of first 5 char
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, len(prd_key)) as prd_key,
prd_nm,
ISNULL(prd_cost, 0) as prd_cost,
CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
    WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'other Sales'
    WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
    WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
    ELSE 'n/a'
END as prd_line,
CAST(prd_start_dt as Date) as prd_start_dt,
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
from bronze.crm_prd_info 


-- checking sales details data
select
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE when sls_order_dt = 0 OR len(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) as DATE)
    END AS sls_order_dt,
    CASE when sls_ship_dt = 0 OR len(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) as DATE)
    END AS sls_ship_dt,
    CASE when sls_due_dt = 0 OR len(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) as DATE)
    END AS sls_due_dt,
    CASE when sls_sales IS NULL or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE when sls_price is NULL or sls_price < 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price 
from bronze.crm_sales_details

--- Checking erp_cust_az12

Select 
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END as cid,
    CASE WHEN bdate > GETDATE() then NULL
        ELSE bdate
    END as bdate,
    CASE
        WHEN gen IS NULL OR TRIM(gen) = '' THEN 'n/a'
        WHEN UPPER(TRIM(gen)) LIKE 'M%' THEN 'Male'
        WHEN UPPER(TRIM(gen)) LIKE 'F%' THEN 'Female'
        ELSE 'n/a'
    END AS gen
From bronze.erp_cust_az12



SELECT DISTINCT
    gen AS raw_gen,
    CASE
        WHEN gen IS NULL OR TRIM(gen) = '' THEN 'n/a'
        WHEN UPPER(TRIM(gen)) LIKE 'M%' THEN 'Male'
        WHEN UPPER(TRIM(gen)) LIKE 'F%' THEN 'Female'
        ELSE 'n/a'
    END AS normalized_gen
FROM bronze.erp_cust_az12;


-- checking erp_loc_10... 
select  DISTINCT
    -- 
    cntry,
    CASE when TRIM(RTRIM(cntry)) = 'DE' THEN 'Germany'
         when TRIM(RTRIM(cntry)) in ('US', 'USA') Then 'United States'
         when TRIM(RTRIM(cntry)) = '' or cntry IS NULL then 'n/a'
         ELSE TRIM(RTRIM(cntry))
    end as cn
from bronze.erp_loc_a101




SELECT DISTINCT
    REPLACE(cid, '-','') cid,
    CASE
        WHEN cleaned_cntry = '' OR cleaned_cntry IS NULL THEN 'n/a'
        WHEN cleaned_cntry LIKE 'US%' THEN 'United States'
        WHEN cleaned_cntry LIKE 'DE%' THEN 'Germany'
        ELSE cleaned_cntry
    END AS normalized_cntry
FROM (
    SELECT cid,
        UPPER(
            LTRIM(RTRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(cntry, CHAR(160), ''),
                        CHAR(9), ''),
                    CHAR(10), ''),
                CHAR(13), '')
            ))
        ) AS cleaned_cntry,
        cntry
    FROM bronze.erp_loc_a101
) t;