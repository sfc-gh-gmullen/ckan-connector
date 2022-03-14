--create task
USE ROLE accountadmin;
grant EXECUTE MANAGED TASK on account to role ckan_role;
USE ROLE CKAN_ROLE;
use database ckan_db;

CREATE OR REPLACE TASK PUBLISH_CKAN_TASK
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE ='XSMALL'
SCHEDULE = '1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('CONTROL_STREAM')
AS
CALL SP_PUBLISH_DATASET();

--package create
CREATE OR REPLACE PROCEDURE SP_PUBLISH_DATASET()
RETURNS VARIANT
LANGUAGE JAVASCRIPT
AS
$$
//Get Tables to validate from control table
var rs_tables = snowflake.createStatement({
	sqlText: "select table_name from control_stream;"
}).execute();


while (rs_tables.next()) {
	//FOR EACH TABLE GET TABLE INFO
	var table_name = rs_tables.getColumnValue('TABLE_NAME');

    //drop all published files to internal stage
    snowflake.createStatement({
        sqlText: "copy into @published_datasets.published_extracts/" +
        table_name + ".csv from CKAN_DB.PUBLISHED_DATASETS." +
        table_name + " SINGLE = TRUE file_format = (type = csv compression = none);"
    });
}
    //make the api call. Updates packageid
    snowflake.createStatement({
        sqlText: "UPDATE CONTROL_TABLE set package_id = EXT_PACKAGE_ID FROM (select package_create(lower(table_name),notes,accesslevel,contact_name,contact_email,rights  ,accrualperiodicity,tag_string  ,owner_org) EXT_PACKAGE_ID, TABLE_NAME, METADATA$ISUPDATE ISUPDATE from ckan_db.public.control_Stream) STRM WHERE CONTROL_TABLE.TABLE_NAME = STRM.TABLE_NAME AND ISUPDATE = FALSE;"
});

     snowflake.createStatement({
        sqlText: "select resource_create(package_id,lower(table_name),notes,'CSV',(select get_presigned_url(@published_datasets.published_extracts, table_name || '.csv'))) from ckan_db.public.control_table;"
    });

    $$;

