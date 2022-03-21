create or replace database ckan_db;
--PUBLISHED_DATASETS is where
create schema published_datasets;
create or replace stage published_extracts encryption = (type = 'SNOWFLAKE_SSE');

use database ckan_db;
USE ROLE SECURITYADMIN;
GRANT OWNERSHIP ON DATABASE CKAN_DB TO ROLE CKAN_ROLE;
GRANT OWNERSHIP ON SCHEMA ckan_db.PUBLIC TO ROLE CKAN_ROLE;
GRANT OWNERSHIP ON SCHEMA ckan_db.published_datasets TO ROLE CKAN_ROLE;
GRANT OWNERSHIP ON VIEW CKAN_DB.published_datasets.trips TO ROLE SYSADMIN;
GRANT SELECT ON VIEW CKAN_DB.published_datasets.trips TO ROLE CKAN_ROLE;
GRANT OWNERSHIP ON TABLE CONTROL_TABLE TO ROLE CKAN_ROLE;
GRANT OWNERSHIP ON stream CONTROL_STREAM TO ROLE CKAN_ROLE;

create or replace table control_table (
package_id string NULL
,notes string NOT NULL
,accesslevel string NOT NULL
,contact_name string NOT NULL
,contact_email string NOT NULL
,rights string NOT NULL
,accrualperiodicity string NOT NULL
,tag_string string NOT NULL
,owner_org string NOT NULL
,table_name string NOT NULL
);

create or replace stream control_stream on table control_Table;

--Create new package
insert into control_table values (
    NULL
,'test run notes'
,'public'
,'Gabriel Mullen'
,'gabriel.mullen@snowflake.com'
,'Public Use'
,'irregular'
,'Snowflake'
,'sf-testing'
,'TRIPS');

-- Logs to flush the stream
create or replace table public.ckan_log (dt date, packageid string, table_name string);

--EXAMPLE: let's ETL a test table to this schema.
use role sysadmin;
create or replace VIEW ckan_db.published_datasets.trips AS SELECT * FROM citibike.demo.trips limit 100;
use role ckan_role;
use database ckan_db;
use schema published_datasets;

