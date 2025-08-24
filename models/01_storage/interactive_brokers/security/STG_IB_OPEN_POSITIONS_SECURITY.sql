{%- set source_model = source('IB', 'OPEN_POSITIONS') %}
{%- set configuration -%}
source:
    columns: 
        include_all: false          #-- True enables using eclude / replace / rename lists // false does not include any source col
    where: STARTSWITH(CLIENTACCOUNTID, 'U')

calculated_columns: 
    <<: {{ config.get('calculated_columns') }}
    EFFECTIVITY_DATE: REPORTDATE::date
    CLIENT_ACCOUNT_CODE: "'U***' || RIGHT(CLIENTACCOUNTID, 4)"
    Transaction_ID: concat_ws('|', BROKER_CODE,CLIENT_ACCOUNT_CODE,SECURITY_CODE,LISTING_EXCHANGE,REPORT_DATE)
    

hashed_columns: 
    <<: {{ config.get('hashed_columns') }}
    POSITION_HKEY:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - SECURITY_CODE
        - LISTING_EXCHANGE
    TRANSACTION_HKEY:
        - Transaction_ID

default_records: {{ config.get('default_records') }}

remove_duplicates: 
{%- endset -%}

{%- set cfg = fromyaml(configuration) -%}

{{- pragmatic_data.stage(
    source_model            = source_model,
    source                  = cfg['source'],
    calculated_columns      = cfg['calculated_columns'],
    hashed_columns          = cfg['hashed_columns'],
    remove_duplicates       = cfg['remove_duplicates'],
) }}
