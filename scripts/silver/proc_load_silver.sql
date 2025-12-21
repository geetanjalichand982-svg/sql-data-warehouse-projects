/*---------------------SILVER LOAD--------------------------------------*/

CREATE OR ALTER  PROCEDURE silver.load_silver AS
BEGIN

declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;

begin 
try
   print '**********************************************************';
   print 'LOADING SILVER LAYER';
   print '**********************************************************';
   print 'LOADING CRM TABLES-----------------------------------------'

set @batch_start_time = getdate();

set @start_time = getdate();

PRINT '>> Truncating Table: silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
PRINT '>> INSERTING DATA INTO silver.crm_cust_info';

 insert into silver.crm_cust_info (
	 cst_id,	
     cst_key, 
     cst_firstname,	
     cst_lastname, 
     cst_marital_status,
     cst_gndr, 
     cst_create_date 
)
select
	 cst_id,
	 cst_key,
	 trim(cst_firstname) as Cust_Firstname,
	 trim(cst_lastname) as Cust_Lastname,
	 CASE 
	      WHEN cst_marital_status = 'M' THEN 'Married'
	      WHEN cst_marital_status = 'S' THEN 'Single'
		  ELSE 'N/A'
	 END cst_marital_status,
	 CASE 
	      WHEN cst_gndr = 'F' THEN 'Female'
	      WHEN cst_gndr = 'M' THEN 'Male'
	      ELSE 'N/A'
	 END cst_gndr,
	 cst_create_date
	 from (
	 select *,
	 row_number() over (partition by cst_id order by cst_create_date desc) as Flag_last
	 from bronze.crm_cust_info 
	 where cst_id is not null
	 ) t where flag_last=1 
	 
	 set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

----------------------------------------------------------------------------------------------------

set @start_time = getdate();

PRINT '>> Truncating Table: silver.crm_prd_info';
TRUNCATE TABLE silver.crm_prd_info;
PRINT '>> INSERTING DATA INTO silver.crm_prd_info';

insert into silver.crm_prd_info (
   prd_id,
   cat_id,
   prd_key,
   prd_nm,
   prd_cost,
   prd_line,
   prd_start_dt,
   prd_end_dt
   )
select 
    prd_id,
    Replace (substring(prd_key, 1, 5), '-', '_') as cat_id,
    substring(prd_key, 7, len(prd_key)) as prd_key,
    prd_nm,
    isnull(prd_cost, 0) as prd_cost,
CASE 
     WHEN prd_line = 'M' THEN 'Mountain'
     WHEN prd_line = 'R' THEN 'Road'
	 WHEN prd_line = 'S' THEN 'Other Sales'
	 WHEN prd_line = 'T' THEN 'Touring'
	 ELSE 'N/A'
END as prd_line,
     cast(prd_start_dt as date) as prd_start_dt,
     cast(
     dateadd(day, -1, lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) ) as date ) as prd_end_dt
     from bronze.crm_prd_info

set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

-----------------------------------------------------------------------------------------------------------------------------
set @start_time = getdate();

PRINT '>> Truncating Table: silver.crm_sales_details';
TRUNCATE TABLE silver.crm_sales_details;
PRINT '>> INSERTING DATA INTO silver.crm_sales_details';

insert into silver.crm_sales_details (
        sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
select 
      sls_ord_num,
      sls_prd_key,
      sls_cust_id,
CASE 
     WHEN sls_order_dt = 0 or len(sls_order_dt) !=8 then NULL
     ELSE CAST(cast(sls_order_dt as varchar) as date)
END as sls_order_dt,
CASE 
     WHEN sls_ship_dt = 0 or len(sls_ship_dt) !=8 then NULL
     ELSE CAST(cast(sls_ship_dt as varchar) as date)
END as sls_ship_dt,
CASE 
     WHEN sls_due_dt = 0 or len(sls_due_dt) !=8 then NULL
     ELSE CAST(cast(sls_due_dt as varchar) as date)
END as sls_due_dt,
CASE 
     WHEN sls_sales is null or sls_sales <=0 or sls_quantity != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales
END as sls_sales,
sls_quantity,
CASE 
     WHEN sls_price is null or sls_price <=0
     THEN sls_sales/nullif(sls_quantity, 0)
     ELSE sls_price
END as sls_price 
from bronze.crm_sales_details


set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

---------------------------------------------------------------------------------------------------------------
   
   print 'LOADING ERP TABLES----------------------------------------------------------------------------------'


set @start_time = getdate();

PRINT '>> Truncating Table: silver.erp_cust_az12';
TRUNCATE TABLE silver.erp_cust_az12;
PRINT '>> INSERTING DATA INTO silver.erp_cust_az12';

INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT 
CASE 
     WHEN cid like 'NAS%' THEN SUBSTRING (cid, 4, LEN(cid))
	 ELSE cid
END cid,
CASE 
    WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END as bdate,
CASE 
    WHEN TRIM(gen) IN ('F', 'Female') THEN 'Female'
	WHEN TRIM(gen) IN ('M', 'male') THEN 'Male'
	Else 'N/A'
END as gen
From bronze.erp_cust_az12

set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

-----------------------------------------------------------------------------------------------------------------------------------

set @start_time = getdate();

PRINT '>> Truncating Table: silver.erp_loc_a101';
TRUNCATE TABLE silver.erp_cust_az12;
PRINT '>> INSERTING DATA INTO silver.erp_loc_a101';

INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
   REPLACE (cid, '-','') AS cid,
CASE 
   WHEN TRIM (cntry)= 'DE' THEN 'Germany'
   WHEN TRIM (cntry) IN ('US', 'USA') THEN 'United States'
   WHEN TRIM (cntry)= '' OR cntry IS NULL THEN 'N/A'
   ELSE TRIM (cntry)
END AS cntry
FROM bronze.erp_loc_a101

set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

-----------------------------------------------------------------------------------------------------------------------------
set @start_time = getdate();

PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
PRINT '>> INSERTING DATA INTO silver.erp_px_cat_g1v2';

INSERT INTO silver.erp_px_cat_g1v2 (ID, CAT, SUBCAT, MAINTENANCE)
   SELECT ID, 
      CAT, 
	  SUBCAT,
	  MAINTENANCE 
   FROM bronze.erp_px_cat_g1v2
set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

set @batch_end_time = getdate();
print 'LOADING SILVER LAYER IS COMPLETED';
print 'TOTAL LOAD DURATION : ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + 'seconds';
print '************************************************************************************************************';

end try
   begin catch
     print '======================================================================================================='
	 print                            'Erorr occured in loading bronze layer'
	 print '======================================================================================================='
   end catch
END
------------------------------------------------------------------------------------------------------------------------
