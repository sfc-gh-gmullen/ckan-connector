--PACKAGE SHOW

    create or replace external function package_show(id varchar)
    returns variant
    api_integration = ckan_proxy_int
    MAX_BATCH_ROWS = 1
        request_translator = CKAN_show_request_translator
        response_translator = CKAN_show_response_translator
    as 'https://gmullen-api-mgmt.azure-api.net/package_show';

    create or replace function CKAN_show_request_translator(event object)
    returns object
    language javascript as
    '
    var package_id;
    for(i = 0; i < EVENT.body.data.length; i++) {
       let row = EVENT.body.data[i];
       // row[0] is the row number and row[1] is the input text.
       package_id=row[1]; //put text into the textlist
    }

    return { "body": { "id" : package_id } }
    ';
    create or replace function CKAN_show_response_translator(event object)
    returns object
    language javascript as
    '
    var responses = new Array(0);
    responses[0] = [0,EVENT.body.result.title]
    return { "body": { "data" : responses } };
    ';