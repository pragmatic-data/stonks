/** 
 *  This model loads the Manual Transactions entered to represent complex Corporate Actions.
 *
 *  For each Corporate Action there can be multiple TXs.
 *  A Corporate Action is identified by the position (account, security and exchange) plus the action date.
 *  In general we have:
 *      - one row for the TX to close the old position.
 *      - one row for the TX to open the new position with the new security code
 *  but when there is no code change, like in most of stock splits, one TX to update the count can be enough.
 *  
 *  In the end, manual TXs do not need to make any assumption on the number of TX and we can enter as many TXs as needed.
 */

WITH
corp_act_manual_tx as (
    SELECT *
    FROM {{ ref('VER_IB_CORP_ACT_MANUAL') }}
    WHERE IS_CURRENT
)
, corp_act_transactions as (
    SELECT 
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
        HIST_LOAD_TS_UTC,

        TRANSACTION_ID,
        CORP_ACT_HKEY       as TRANSACTION_HKEY,
        TRANSACTION_TYPE,
        CORP_ACT_DATE::TIMESTAMP_NTZ    as TRANSACTION_TS,

        TX_MONEY_FX, 
        TX_MONEY_BASE,
        COST_BASIS_FX,

        OPEN_CLOSE_INDICATOR,
        NOTES_CODES,
        BUY_SELL


FROM corp_act_manual_tx
)
SELECT * 
FROM corp_act_transactions
ORDER BY account_alias, security_symbol, effectivity_date, SECURITY_CODE
