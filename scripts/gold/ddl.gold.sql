/* 
===========================================================================================================================
DDL Script: Create Gold Views
===========================================================================================================================
Script Purpose:
             This script creates view for the gold layer in the data warehouse.
             The Gold Layer represents the final dimension and fact tables (Star Schema)

             Each View performs transformations and combines data from the silver layer to produce a clean, enriched 
             and business-ready dataset.
Usage: 
     - These Views can be queried directly for analytics and reporting.
============================================================================================================================
*/
--==========================================================================================================================
-- Create Dimension: gold.dim_customers
--==========================================================================================================================

if object_id ('gold.dim_customers', 'V') is not null
  DROP VIEW gold.dim_customers;

Go

CREATE VIEW gold.dim_customers AS

        SELECT 
		  ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
		  ci.cst_id AS customer_id,
		  ci.cst_key AS customer_number,
		  ci.cst_firstname AS first_name,
		  ci.cst_lastname AS last_name,
		  la.CNTRY AS country,
		  ci.cst_marital_status AS marital_status,
		  CASE 
			  WHEN ci.cst_gndr!= 'N/A' THEN ci.cst_gndr        -- CRM IS THE MASTER FOR GENDER INFO
			  ELSE COALESCE (cb.gen, 'N/A')
		  END AS gender,
		  cb.BDATE AS birthdate,
		  ci.cst_create_date AS create_date
	   FROM silver.crm_cust_info AS ci
		 LEFT JOIN silver.erp_cust_az12 AS cb
		 ON ci.cst_key=cb.CID
		 LEFT JOIN silver.erp_loc_a101 AS la
		 ON ci.cst_key=la.CID

  
--==========================================================================================================================
-- Create Dimension: gold.dim_products
--==========================================================================================================================
if object_id ('gold.dim_products', 'V') is not null
  DROP VIEW gold.dim_products;

Go

CREATE VIEW gold.dim_products AS   -------CREATING VIEWS
         SELECT 
		 ROW_NUMBER() OVER (ORDER BY pd.prd_start_dt, pd.prd_key) AS Product_Key,    ---CREATING P.KEY/SUUROGATE KEY FOR EACH DIMENSION
		 pd.prd_id AS Product_Id,
		 pd.prd_key AS Product_Number,
		 pd.prd_nm AS Product_Name,
		 pd.cat_id AS Category_Id,
		 pc.CAT AS Category,
		 pc.SUBCAT AS Subcategory,
		 pc.MAINTENANCE as Maintenance,
		 pd.prd_cost AS Product_Cost,
		 pd.prd_line AS Product_line,
		 pd.prd_start_dt AS Product_Start_Date
		 FROM  silver.crm_prd_info as pd
		 LEFT JOIN silver.erp_px_cat_g1v2 AS pc
		 ON pd.cat_id = pc.ID
		 WHERE prd_end_dt IS NULL ---FILTER OUT ALL HISTORICAL DATA


--==========================================================================================================================
-- Create Dimension: gold.fact_sales
--==========================================================================================================================
 if object_id ('gold.fact_sales', 'V') is not null
  DROP VIEW gold.fact_sales;

Go
CREATE VIEW gold.fact_sales AS  --LAST STEP TO CREATE A VIEW
		SELECT
		sd.sls_ord_num AS order_number,
		pr.Product_Key, --TAKING FROM THE DIMENSION AND REMOVING THE ORIGINAL PRODUCT KEY (sls_prd_key)
		cu.customer_key, --TAKING FROM THE DIMENSION AND REMOVING THE ORIGINAL CUSTOMER ID (sd.sls_cust_id)
		sd.sls_order_dt AS order_date,
		sd.sls_ship_dt AS shipping_date,
		sd.sls_due_dt AS due_date,
		sd.sls_sales AS sales_amount,
		sd.sls_quantity AS quantity,
		sd.sls_price AS price
		FROM silver.crm_sales_details AS sd
		LEFT JOIN gold.dim_products pr
		ON sd.sls_prd_key = pr.product_number
		LEFT JOIN gold.dim_customers cu
		ON sd.sls_cust_id = cu.customer_id
	--NOW THESE TWO DIMENSION KEYS PRODUCT_KEY & CUSTOMER_KEY WILL HELP TO CONNECT THE DATA MODEL WITH FACT & DIMENSIONS



