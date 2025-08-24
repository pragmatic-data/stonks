{%- set source_model = ref('ib_corp_act_manual') %}

{%- set configuration -%}
source:
    columns: 
        include_all: true
        replace_columns:
            - TRANSACTION_ID: concat_ws('|', BROKER_CODE,CLIENT_ACCOUNT_CODE,SECURITY_CODE,LISTING_EXCHANGE,CORP_ACT_DATE)


calculated_columns:
    - EFFECTIVITY_DATE: CORP_ACT_DATE
    - FILE_ROW_NUMBER: CORP_ACT_ORDER
    - FILE_LAST_MODIFIED_TS_UTC: INGESTION_TS_UTC
    #-- - INGESTION_TS_UTC: "'{{ run_started_at }}'::TIMESTAMP_NTZ"

hashed_columns: 
    CORP_ACT_HKEY:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - SECURITY_CODE
        - LISTING_EXCHANGE
        - CORP_ACT_DATE
    POSITION_HKEY:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - SECURITY_CODE
        - LISTING_EXCHANGE
    PORTFOLIO_HKEY:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
    SECURITY_HKEY:
        - SECURITY_CODE
        - LISTING_EXCHANGE

    CORP_ACT_HDIFF:
        #-- PK
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - LISTING_EXCHANGE
        - SECURITY_CODE
        - CORP_ACT_DATE
        #-- Name and Classification
        - SECURITY_SYMBOL
        - SECURITY_NAME
        - ACCOUNT_ALIAS
        - ASSET_CLASS
        #-- CORP ACT Content
        - Quantity
        - CURRENCY_PRIMARY
        - FX_RATE_TO_BASE
        - TX_MONEY_FX
        - TX_MONEY_BASE
        - COST_BASIS_FX
        #-- Order, Security and Position Info
        - OPEN_CLOSE_INDICATOR
        - Notes_Codes
        - Buy_Sell
        #-- CORP ACT Details
        - TRANSACTION_ID
        - TRANSACTION_TYPE

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
