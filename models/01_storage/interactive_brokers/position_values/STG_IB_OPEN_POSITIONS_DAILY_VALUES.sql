{{ config( secure = true ) }}  {# Needed to force applying the filter to the view before the pushdown of filters from tests. #}

{%- set source_model = source('IB', 'OPEN_POSITIONS') %}
{%- set yaml_str -%}
source:
    columns: 
        include_all: false          #-- True enables using eclude / replace / rename lists // false does not include any source col
    where: STARTSWITH(CLIENTACCOUNTID, 'U')

calculated_columns:
    - BROKER_CODE: '!IB'        #-- Alternative would be "'IB'", that is double quoting the quoted static string
    - CLIENT_ACCOUNT_CODE: "'U***' || RIGHT(CLIENTACCOUNTID, 4)"
    - SECURITY_CODE: coalesce(SECURITYID, CONID)
    - LISTING_EXCHANGE: LISTINGEXCHANGE

    - CURRENCY_PRIMARY: CURRENCYPRIMARY
    - SECURITY_SYMBOL: SYMBOL
    - UNDERLYING_SECURITY_CODE: coalesce(UNDERLYINGSECURITYID, UNDERLYINGCONID)
    - REPORT_DATE: REPORTDATE::date
    - FX_RATE_TO_BASE: FXRATETOBASE::number(38,6)
    - MARK_PRICE: MARKPRICE::number(38,6)
    - POSITION_VALUE: POSITIONVALUE::number(38,2)
    - PERCENT_OF_NAV: PERCENTOFNAV::number(38,2)
    - FIFO_PNL_UNREALIZED: FIFOPNLUNREALIZED::number(38,6)
    - ACCRUED_INTEREST: ACCRUEDINTEREST::number(38,9)

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

    POSITION_VALUE_HDIFF:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - SECURITY_CODE
        - LISTING_EXCHANGE
        - CURRENCY_PRIMARY
        - SECURITY_SYMBOL
        - UNDERLYING_SECURITY_CODE
        - REPORT_DATE                   #-- This in the HDIFF turns the entity into a time-serie.
        - FX_RATE_TO_BASE
        - MARK_PRICE
        - POSITION_VALUE
        - PERCENT_OF_NAV
        - FIFO_PNL_UNREALIZED
        - ACCRUED_INTEREST


remove_duplicates: 
{%- endset -%}

{%- set metadata_dict = fromyaml(yaml_str) -%}

{{ pragmatic_data.stage(
    source_model            = source_model,
    source                  = metadata_dict['source'],
    calculated_columns      = metadata_dict['calculated_columns'],
    hashed_columns          = metadata_dict['hashed_columns'],
    remove_duplicates       = metadata_dict['remove_duplicates'],
) }}
