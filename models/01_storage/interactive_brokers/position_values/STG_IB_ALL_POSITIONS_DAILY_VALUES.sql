/**
 *  =1= Creation of the records with the value of closed positions
 *  =2= Union of =1= with the values of open positions
 *  =3= Claculation of the updated HDIFF after the union
 */
{% set hashed_columns %}
POSITION_VALUE_HDIFF:
    - BROKER_CODE
    - CLIENT_ACCOUNT_CODE
    - SECURITY_CODE
    - LISTING_EXCHANGE
    - CURRENCY_PRIMARY
    - SECURITY_SYMBOL
    - UNDERLYING_SECURITY_CODE
    - REPORT_DATE
    - FX_RATE_TO_BASE
    - MARK_PRICE
    - POSITION_VALUE
    - PERCENT_OF_NAV
    - FIFO_PNL_UNREALIZED
    - ACCRUED_INTEREST
{% endset %}
{%- set hashed_columns_dict = fromyaml(hashed_columns) -%}


WITH
closed_positions_values as (
    SELECT
        BROKER_CODE, 
        CLIENT_ACCOUNT_CODE, 
        SECURITY_CODE,
        LISTING_EXCHANGE, 
        CURRENCY_PRIMARY,
        SECURITY_SYMBOL, 
        UNDERLYING_SECURITY_CODE,

        REPORT_DATE, 
        0 as FX_RATE_TO_BASE, 
        0 as MARK_PRICE, 
        0 as POSITION_VALUE, 
        0 as PERCENT_OF_NAV, 
        0 as FIFO_PNL_UNREALIZED, 
        0 as ACCRUED_INTEREST, 

        --# metadata
        EFFECTIVITY_DATE, 
        RECORD_SOURCE, 
        FILE_ROW_NUMBER, 
        FILE_LAST_MODIFIED_TS_UTC, 
        INGESTION_TS_UTC,

        --# HKEYS
        POSITION_HKEY,
        SECURITY_HKEY
    FROM {{ ref('STG_IB_CLOSED_POSITIONS') }}
)
, open_positions_daily_values as (
    SELECT *
    FROM {{ ref('STG_IB_OPEN_POSITIONS_DAILY_VALUES') }}
)

SELECT * 
    ,  {{ pragmatic_data.pdp_hash( hashed_columns_dict['POSITION_VALUE_HDIFF'] ) }} as POSITION_VALUE_HDIFF
    -- Moved calculation here to use the RE-Defined values instead of the input values for the closed positions
FROM closed_positions_values

UNION ALL 

SELECT * FROM open_positions_daily_values
