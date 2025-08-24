{%- set source_model = source('IB', 'OPEN_POSITIONS') %}
{%- set configuration -%}
source:
    columns: 
        include_all: false          #-- True enables using exclude / replace / rename lists // false does not include any source col
    where: STARTSWITH(CLIENTACCOUNTID, 'U')

calculated_columns:
    - BROKER_CODE: '!IB'
    - CLIENT_ACCOUNT_CODE: "'U***' || RIGHT(CLIENTACCOUNTID, 4)"
    - SECURITY_CODE: coalesce(SECURITYID, CONID)
    - LISTING_EXCHANGE: LISTINGEXCHANGE

    - CURRENCY_PRIMARY: CURRENCYPRIMARY
    - SECURITY_SYMBOL: SYMBOL
    - SECURITY_NAME: DESCRIPTION
    - ISSUER: ISSUER
    - UNDERLYING_SECURITY_CODE: coalesce(UNDERLYINGSECURITYID, UNDERLYINGCONID)
    - ASSET_CLASS: ASSETCLASS
    - ACCOUNT_ALIAS: ACCOUNTALIAS
    - MODEL: MODEL
    - QUANTITY: QUANTITY::number(38,0)
    - OPEN_PRICE: OPENPRICE::number(38,9)
    - COST_BASIS_PRICE: COSTBASISPRICE::number(38,9)
    - COST_BASIS_MONEY: COSTBASISMONEY::number(38,6)
    - SIDE: SIDE
    - LEVEL_OF_DETAIL: LEVELOFDETAIL
    - OPEN_TS: OPENDATETIME::TIMESTAMP_NTZ
    - HOLDING_PERIOD_TS: HOLDINGPERIODDATETIME::TIMESTAMP_NTZ
    - VESTING_DATE: VESTINGDATE::date
    - CODE: CODE
    - ORIGINATING_ORDER_ID: ORIGINATINGORDERID
    - ORIGINATING_TRANSACTION_ID: ORIGINATINGTRANSACTIONID
    - PRINCIPAL_ADJUST_FACTOR: PRINCIPALADJUSTFACTOR
    - REPORT_DATE: REPORTDATE::date
    - FULL_CLIENT_ACCOUNT_CODE: CLIENTACCOUNTID

    - FX_RATE_TO_BASE: FXRATETOBASE::number(38,6)
    
#    - MARK_PRICE: MARKPRICE::number(38,6)
#    - POSITION_VALUE: POSITIONVALUE::number(38,2)
#    - PERCENT_OF_NAV: PERCENTOFNAV::number(38,2)
#    - FIFO_PNL_UNREALIZED: FIFOPNLUNREALIZED::number(38,6)
#    - ACCRUEDINTEREST: ACCRUEDINTEREST::number(38,9)

    # metadata
    - EFFECTIVITY_DATE: REPORTDATE::date
    - RECORD_SOURCE: FROM_FILE
    - FILE_ROW_NUMBER: FILE_ROW_NUMBER
    - FILE_LAST_MODIFIED_TS_UTC: FILE_LAST_MODIFIED_TS_UTC
    - INGESTION_TS_UTC: INGESTION_TS_UTC

hashed_columns: 
    POSITION_HKEY:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - SECURITY_CODE
        - LISTING_EXCHANGE

    SECURITY_HKEY:
        - SECURITY_CODE
        - LISTING_EXCHANGE

    PORTFOLIO_HKEY:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE

    POSITION_HDIFF:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - LISTING_EXCHANGE
        - SECURITY_SYMBOL
        - SECURITY_CODE
        - UNDERLYING_SECURITY_CODE
        - ACCOUNT_ALIAS
        - SECURITY_NAME
        - ISSUER
        - ASSET_CLASS
        - MODEL
        - CURRENCY_PRIMARY
        - QUANTITY
        - OPEN_PRICE
        - COST_BASIS_PRICE
        - COST_BASIS_MONEY
        - SIDE
        - LEVEL_OF_DETAIL
        - OPEN_TS
        - HOLDING_PERIOD_TS
        - VESTING_DATE
        - CODE
        - ORIGINATING_ORDER_ID
        - ORIGINATING_TRANSACTION_ID
        - PRINCIPAL_ADJUST_FACTOR
#        - FX_RATE_TO_BASE
#        - MARK_PRICE
#        - POSITION_VALUE
#        - PERCENT_OF_NAV
#        - FIFO_PNL_UNREALIZED
#        - ACCRUEDINTEREST
#        - REPORT_DATE


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
