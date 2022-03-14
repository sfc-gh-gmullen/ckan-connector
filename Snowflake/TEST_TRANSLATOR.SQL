 select --CKAN_package_create_request_translator(
        $${"body": {"data": [$$ c1,
        array_construct('0',
        table_name
        ,notes
        ,accesslevel
        ,contact_name
        ,contact_email
        ,rights
        ,accrualperiodicity
        ,tag_string
        ,owner_org
        ,(select get_presigned_url(@published_datasets.published_extracts, 'trips.csv'))
    ) c2,
     ']}}' c3, parse_json(c1||c2::string||c3) c4

     ,CKAN_package_create_request_translator(c4)
     --, CKAN_package_create_request_translator(object_construct("body",c2::string,c3))
                                                 --)
from ckan_db.public.control_table;