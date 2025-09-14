{% set common_columns %}
        -- Business Keys
        BROKER_CODE, 
        CLIENT_ACCOUNT_CODE, 
        LISTING_EXCHANGE,
        SECURITY_CODE,

        -- Position Naming, Classification and Times
        SECURITY_SYMBOL,
        SECURITY_NAME,
        ACCOUNT_ALIAS, 
        ASSET_CLASS, 
        EFFECTIVITY_DATE, 

        -- Position core DATA
        QUANTITY, 
        CURRENCY_PRIMARY,
        FX_RATE_TO_BASE,

        -- Hash Keys
        POSITION_HKEY,
        PORTFOLIO_HKEY,
        SECURITY_HKEY,

        -- Metadata
        RECORD_SOURCE, 
        FILE_ROW_NUMBER, 
        FILE_LAST_MODIFIED_TS_UTC, 
        INGESTION_TS_UTC, 
        HIST_LOAD_TS_UTC
{% endset %}

WITH 
trades as (
    SELECT 
        {{common_columns}},
        TRANSACTION_ID,
        TRADE_HKEY as TRANSACTION_HKEY,
        TRANSACTION_TYPE, 
        TRADE_DATE_TIME as TRANSACTION_TS,

        NET_CASH_FX  as TX_MONEY_FX,
        TX_MONEY_FX * FX_RATE_TO_BASE as TX_MONEY_BASE, 

        COST_BASIS::NUMBER(38,9) as COST_BASIS_FX,
        OPEN_CLOSE_INDICATOR,
        NOTES_CODES,
        BUY_SELL

    FROM {{ ref('VER_IB_TRADES') }}
    WHERE IS_CURRENT 
      and ASSET_CLASS != 'CASH'
)
, transfers as (
    SELECT 
        {{common_columns}},
        TRANSFER_ID             as TRANSACTION_ID,
        TRANSFER_HKEY           as TRANSACTION_HKEY,
        TRANSFER_TYPE           as TRANSACTION_TYPE,
        TRANSFER_DATE_TIME      as TRANSACTION_TS,

        - TRANSFER_MONEY_FX       as TX_MONEY_FX,
        - TRANSFER_MONEY_BASE     as TX_MONEY_BASE,

        TRANSFER_MONEY_FX as COST_BASIS_FX,
        CASE 
            WHEN TRANSFER_DIRECTION = 'IN' THEN 'O'
            WHEN TRANSFER_DIRECTION = 'OUT' THEN 'C'
            ELSE null
        END   as OPEN_CLOSE_INDICATOR,
        null  as NOTES_CODES,
        'TRANSFER' as BUY_SELL

    FROM {{ ref('VER_IB_TRANSFERS') }}
    WHERE IS_CURRENT 
      and ASSET_CLASS != 'CASH'
)
, corp_acts as (
    SELECT *
    FROM {{ ref('REF_IB_CORPORATE_ACTIONS_TXS') }}
)
, all_tx as (
    SELECT * FROM trades
    UNION ALL
    SELECT * FROM transfers
    UNION ALL
    SELECT * FROM corp_acts
)
SELECT * FROM all_tx
ORDER BY account_alias, security_symbol, effectivity_date, SECURITY_CODE
