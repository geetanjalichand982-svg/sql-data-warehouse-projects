/* create database and schemas 
**************************************************
Script Purpose:
This script creates databse name 'DataWarehous' after checking if it already exists.
*/


use master;
go

  --drp and recreate the 'datawarehouse' database
  if exists (select 1 from sys.databses where name = 'DataWarehouse')
  begin
  alter database DataWarehouse set single_user with rollback Immediate;
end;
go

----Create Database 'Datawarehouse'-------

create database DataWarehouse;

use DataWarehouse;

create schema bronze;
go
create schema silver;
go 
create schema gold;
go
