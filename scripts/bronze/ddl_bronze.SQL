/* 
__________________________________________________________________________________________
Bronze Tables 
___________________________________________________________________________________________
*/


--Creating table ----------
if object_id ('bronze.crm_cust_info', 'U') is not null
drop table bronze.crm_cust_info;
create table bronze.crm_cust_info (
cst_id int,	cst_key	varchar (50), cst_firstname varchar(50),	cst_lastname varchar(50), 
cst_marital_status varchar(20),
cst_gndr varchar(20), cst_create_date date
);

select * from bronze.crm_cust_info

--Creating table ----------
create table bronze.crm_prd_info (
prd_id int,	prd_key varchar(50),	
prd_nm varchar(50),	prd_cost int,
prd_line varchar (50),	prd_start_dt date,	prd_end_dt date );


--Creating table ----------
create table bronze.crm_sales_details (
sls_ord_num varchar(50),	
sls_prd_key varchar(50),
sls_cust_id int ,
sls_order_dt int,
sls_ship_dt	int, sls_due_dt	int, sls_sales int,
sls_quantity int,	sls_price int
);

--Creating table ----------
create table bronze.erp_cust_az12 (
CID varchar(50), 	BDATE date,	GEN varchar(50)
);


--Creating table ----------

create table bronze.erp_loc_a101 (
CID	varchar(50), CNTRY varchar (50)
);

--Creating table ----------

create table bronze.erp_px_cat_g1v2 (
ID varchar(50),	CAT varchar(50),	SUBCAT varchar(50)	, MAINTENANCE varchar (50)
);

-----------------------------------------------------------------------


create or alter procedure bronze.load_bronze as 
begin
declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;

begin try
print '**********************************************************';
print 'Loading Bronze Layer';
print '**********************************************************';
print 'Loading CRM Tables-----------------------------------------'

set @batch_start_time = getdate();

set @start_time = getdate();
truncate table bronze.crm_cust_info;
bulk insert bronze.crm_cust_info 
from 'C:\sql-data-warehouse-project\datasets\source_crm/cust_info.csv'
with (
firstrow = 2,
fieldterminator=',',
tablock
);
set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';


---------------------------------------------------------------------
set @start_time = getdate();
truncate table bronze.crm_prd_info;
bulk insert bronze.crm_prd_info 
from 'C:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
with (
firstrow = 2,
fieldterminator=',',
tablock
);
set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

-------------------------------------------------------------------------------------
set @start_time = getdate();
truncate table bronze.crm_sales_details;
bulk insert bronze.crm_sales_details
from 'C:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
with (
firstrow = 2,
fieldterminator=',',
tablock
);
set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

--------------------------------------------------------------------------
set @start_time = getdate();

print 'Loading ERP Tables----------------------------------------'
truncate table bronze.erp_cust_az12
bulk insert bronze.erp_cust_az12
from 'C:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
with (
firstrow = 2,
fieldterminator=',',
tablock
);
set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

--------------------------------------------------------------------------------
set @start_time = getdate();
truncate table bronze.erp_loc_a101
bulk insert bronze.erp_loc_a101
from 'C:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
with (
firstrow = 2,
fieldterminator=',',
tablock
);
set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

-----------------------------------------------------------------------------------------
set @start_time = getdate();
truncate table bronze.erp_px_cat_g1v2
bulk insert bronze.erp_px_cat_g1v2
from 'C:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
with (
firstrow = 2,
fieldterminator=',',
tablock
);
set @end_time = getdate();
print 'Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
print '.............';

set @batch_end_time = getdate();
print 'Loading bronze layer is completed';
print 'Total Load Duration : ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + 'seconds';
print '************************************************************************************************************';


end try
begin catch
     print '===================================================='
	 print  'Erorr occured in loading bronze layer'
	 print '===================================================='
end catch
end
