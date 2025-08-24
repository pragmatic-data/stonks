{%- set source_model = ref('ib_corp_act_manual') %}
{%- set configuration -%}
source:
    columns: 
        include_all: false          
    where: "ASSET_CLASS = 'STK'"    #-- There is enough infor in Corp Acts about Stocks, makes litle sense to try to build Security for Options

calculated_columns: 
    - INGESTION_TS_UTC
    - FILE_LAST_MODIFIED_TS_UTC: INGESTION_TS_UTC
    - FILE_ROW_NUMBER: CORP_ACT_ORDER
    - RECORD_SOURCE: "'{{ run_started_at }}'::DATE || '_Corp_Act.Manual' "
    - EXTRACTION_PERIOD_END: "'{{ run_started_at }}'::DATE"
    - EXTRACTION_PERIOD_START: "'2021-01-01'::DATE"
    - REPORT_DATE: CORP_ACT_DATE
    - PRINCIPAL_ADJUST_FACTOR: 'null'
    - UNDERLYING_LISTING_EXCHANGE: 'null'
    - UNDERLYING_SECURITY_ID: 'null'
    - UNDERLYING_SYMBOL: 'null'
    - UNDERLYING_CONID: 'null'
    - EXPIRY: 'null'
    - STRIKE: 'null'
    - MULTIPLIER: '1'
    - PUT_CALL: 'null'
    - ASSET_CLASS
    - ISIN: 'null'
    - CUSIP: 'null'
    - CONID: 'null'
    - SECURITY_ID_TYPE: '!CODE'
    - SECURITY_ID: SECURITY_CODE
    - UNDERLYING_SECURITY_CODE: 'null'
    - ISSUER: 'null'
    - SECURITY_NAME
    - SECURITY_SYMBOL
    - CURRENCY_PRIMARY
    - LISTING_EXCHANGE
    - SECURITY_CODE
    - BROKER_CODE: '!IB'
    - EFFECTIVITY_DATE: CORP_ACT_DATE
    - Transaction_ID: concat_ws('|', BROKER_CODE,CLIENT_ACCOUNT_CODE,SECURITY_CODE,LISTING_EXCHANGE,CORP_ACT_DATE)

hashed_columns: 
    <<: {{ config.get('hashed_columns') }}
    TRANSACTION_HKEY:
        - Transaction_ID

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
