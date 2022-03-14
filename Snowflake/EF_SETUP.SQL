--SETUP THE SECURITY INTEGRATION

create or replace api integration ckan_proxy_int
   api_provider=azure_api_management
   AZURE_TENANT_ID='REDACTED-GUID'
   AZURE_AD_APPLICATION_ID='REDACTED-GUID'
   api_allowed_prefixes=('https://gmullen-api-mgmt.azure-api.net/')
   api_key='REDACTED-API-KEY'
   enabled=true;

describe api integration ckan_proxy_int;
--GET THE MSFT AD URL AND ENTERPISE APP ID

























