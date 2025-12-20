/*
Stored Procedure : Load Bronze Layer 
*/



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
