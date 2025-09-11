/** 
 *  This model uses a simple rule on SECURITY_SYMBOL to generate Corporate Action Transactions from Open Positions.
 *
 *  The rule looks for closed positins where the next row has the same SECURITY_SYMBOL, but different SECURITY_CODE.
 *  In such case we return two rows:
 *      - one row for the TX to close the old position (that was automatically closed in the Open Positions flow)
 *        This one is using the underlying automated closed position to source its data.
 *      - one row for the TX to open the new position with the new code
 *        This one is using the underlying new open position to source its data.
 *
 *  This works with these assumptions:
 *      - the Corporate Actions converts the securities 1 to 1, so the same amount that is closed is re-opened
 *      - the effectivity date is the same as the underlying open positions used to genrate the TXs
 *      - ?? the rule handles only long positions with close and reopen ?? TSLA ??
 */

WITH
corp_act_reported_positions as (
    SELECT *
        , LAG(SIDE) OVER(PARTITION BY ACCOUNT_ALIAS, SECURITY_SYMBOL ORDER BY REPORT_DATE, SECURITY_CODE)    as PREV_SIDE
        , LAG(SECURITY_CODE) OVER(PARTITION BY ACCOUNT_ALIAS, SECURITY_SYMBOL ORDER BY REPORT_DATE, SECURITY_CODE)    as PREV_SECURITY_CODE
        , LEAD(SECURITY_CODE) OVER(PARTITION BY ACCOUNT_ALIAS, SECURITY_SYMBOL ORDER BY REPORT_DATE, SECURITY_CODE)   as NEXT_SECURITY_CODE
        , LAG(SECURITY_SYMBOL) OVER(PARTITION BY ACCOUNT_ALIAS, SECURITY_SYMBOL ORDER BY REPORT_DATE, SECURITY_CODE)    as PREV_SECURITY_SYMBOL
        , LEAD(SECURITY_SYMBOL) OVER(PARTITION BY ACCOUNT_ALIAS, SECURITY_SYMBOL ORDER BY REPORT_DATE, SECURITY_CODE)   as NEXT_SECURITY_SYMBOL

        , LEAD(QUANTITY) OVER(PARTITION BY ACCOUNT_ALIAS, SECURITY_SYMBOL ORDER BY REPORT_DATE, SECURITY_CODE)   as NEXT_QUANTITY
        , LEAD(COST_BASIS_MONEY) OVER(PARTITION BY ACCOUNT_ALIAS, SECURITY_SYMBOL ORDER BY REPORT_DATE, SECURITY_CODE)   as NEXT_COST_BASIS_MONEY

    FROM {{ ref('REFH_IB_POSITIONS_REPORTED') }}
    WHERE SECURITY_SYMBOL NOT IN ('GCM', 'BAM', 'SPCE', 'TCFF', 'TRLEF', 'SBER')

    QUALIFY 
        (SIDE = 'Closed' and SECURITY_CODE != NEXT_SECURITY_CODE and SECURITY_SYMBOL = NEXT_SECURITY_SYMBOL)
        or (PREV_SIDE = 'Closed' and SECURITY_CODE != PREV_SECURITY_CODE and SECURITY_SYMBOL = PREV_SECURITY_SYMBOL)
    ORDER BY account_alias, security_symbol, REPORT_DATE, SECURITY_CODE
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
        CASE WHEN SIDE = 'Closed' THEN - NEXT_QUANTITY
             ELSE QUANTITY
        END as QUANTITY, 
        CURRENCY_PRIMARY,
        FX_RATE_TO_BASE,

        -- Hash Keys
        POSITION_HKEY,
        PORTFOLIO_HKEY,
        SECURITY_HKEY,

        -- Metadata
        RECORD_SOURCE, 
        coalesce(FILE_ROW_NUMBER, CASE WHEN SIDE = 'Closed' THEN 1 ELSE 2 END) as FILE_ROW_NUMBER, 
        FILE_LAST_MODIFIED_TS_UTC, 
        INGESTION_TS_UTC, 
        HIST_LOAD_TS_UTC,

        concat_ws('|', BROKER_CODE,CLIENT_ACCOUNT_CODE,SECURITY_CODE,LISTING_EXCHANGE,EFFECTIVITY_DATE)    as TRANSACTION_ID,
        {{ pragmatic_data.pdp_hash(['BROKER_CODE','CLIENT_ACCOUNT_CODE','SECURITY_CODE','LISTING_EXCHANGE','EFFECTIVITY_DATE']) }} as TRANSACTION_HKEY,
        'CORP_ACT'          as TRANSACTION_TYPE,
        EFFECTIVITY_DATE    as TRANSACTION_TS,


        CASE WHEN SIDE = 'Closed' THEN NEXT_COST_BASIS_MONEY
             ELSE - COST_BASIS_MONEY
        END as TX_MONEY_FX, 
        TX_MONEY_FX * FX_RATE_TO_BASE     as TX_MONEY_BASE,

        CASE WHEN SIDE = 'Closed' THEN NEXT_COST_BASIS_MONEY
             ELSE COST_BASIS_MONEY
        END as COST_BASIS_FX,

        CASE 
            WHEN SIDE = 'Closed' THEN 'C'
            ELSE 'O'
        END   as OPEN_CLOSE_INDICATOR,
        null  as NOTES_CODES,
        'CORP_ACT' as BUY_SELL


FROM corp_act_reported_positions
)
SELECT * 
FROM corp_act_transactions
ORDER BY account_alias, security_symbol, effectivity_date, SECURITY_CODE
