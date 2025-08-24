/**
 *  ** Calculation of closed positions **
 *  1. in `report_dates` we get the list of all dates for which we have a position report
 *  2. in `positions_to_close` 
 *      - for each position we calculate the next report where the position appears (NEXT_REPORT_DATE)
 *      - we use a TIME JOIN with the list of reports to find the next report after the position date (CLOSING_DATE)
 *  3. in `src_data` 
 *      - we keep only the positions to be closed (no next report for the position, but a next report exists)
 *      - we use the date for the next report as CLOSE DATE For this position
 *      - we set some columns and metadata to the correct value for a closed position
 */

{% set position_hdiff_columns %}
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
{% endset %}

{%- set stg_open_positions = ref('STG_IB_OPEN_POSITIONS') %}

WITH
report_dates as (
    SELECT distinct REPORT_DATE
    FROM {{ stg_open_positions }}
)
,positions_to_close as (
    SELECT p.*
        , LEAD(p.REPORT_DATE) OVER(PARTITION BY POSITION_HKEY ORDER BY p.REPORT_DATE) as NEXT_REPORT_DATE
        , r.REPORT_DATE as CLOSING_DATE
    FROM {{ stg_open_positions }} p
    ASOF JOIN report_dates r
    MATCH_CONDITION( p.REPORT_DATE < r.REPORT_DATE)
    QUALIFY NEXT_REPORT_DATE is null and CLOSING_DATE is not null
)
, src_data as (
    SELECT * 
        EXCLUDE(NEXT_REPORT_DATE, CLOSING_DATE)
        REPLACE(
            CLOSING_DATE as REPORT_DATE,
            CLOSING_DATE as EFFECTIVITY_DATE,
            0 as QUANTITY,
            0 as OPEN_PRICE,
            0 as COST_BASIS_PRICE,
            0 as COST_BASIS_MONEY,
            'Closed' as SIDE,
            'System.Calculation' as RECORD_SOURCE, 
            null as FILE_ROW_NUMBER, 
            null as FILE_LAST_MODIFIED_TS_UTC, 
            '{{ run_started_at }}'::timestamp as INGESTION_TS_UTC
        )
    FROM positions_to_close
)
, hashed as (
    SELECT * 
        REPLACE(            
            {{ pragmatic_data.pdp_hash(fromyaml( position_hdiff_columns )) }} as POSITION_HDIFF
        )
    FROM src_data
)

SELECT * FROM hashed
