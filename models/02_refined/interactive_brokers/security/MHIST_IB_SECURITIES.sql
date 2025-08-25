WITH
trade_security as (
    SELECT * , 1 as PRIORITY
    FROM {{ ref('HIST_IB_TRADES_SECURITY') }}
)
, pos_security as (
    SELECT * , 1 as PRIORITY
FROM {{ ref('HIST_IB_OPEN_POSITIONS_SECURITY') }}
)
, transfer_security as (
    SELECT * EXCLUDE(ASSET_SUB_CATEGORY, FIGI)
        , 1 as PRIORITY
    FROM {{ ref('HIST_IB_TRANSFERS_SECURITY') }}
)
, corp_act_security as (
    SELECT * , 2 as PRIORITY
    FROM {{ ref('HIST_IB_CORP_ACT_SECURITY') }}
    -- We assign to Corp Act security definitions a LOWER priority than other types of inputs 
    -- as most columns in this source are empty, so they are beter than nothing, but not better than other sources.
)
, all_versions as (
    SELECT * FROM trade_security
    UNION
    SELECT * FROM pos_security
    UNION
    SELECT * FROM transfer_security
    UNION
    SELECT * FROM corp_act_security
)
, top_priority as (
    SELECT *
    FROM all_versions
    QUALIFY rank() OVER(PARTITION BY SECURITY_HKEY ORDER BY PRIORITY) = 1
    -- Keep only the records inthe top priority block for each Security.
)
, composite_hist as (
    SELECT *
        , LAG(SECURITY_HDIFF) OVER(PARTITION BY SECURITY_HKEY 
                                   ORDER BY EFFECTIVITY_DATE, EXTRACTION_PERIOD_START, EXTRACTION_PERIOD_END
                                   ) as PREV_HDIFF
        , CASE 
            WHEN PREV_HDIFF is null THEN true
            ELSE (SECURITY_HDIFF != PREV_HDIFF) 
          END as TO_BE_STORED
    FROM top_priority
    QUALIFY TO_BE_STORED
)
SELECT * EXCLUDE (PREV_HDIFF, TO_BE_STORED, PRIORITY)
FROM composite_hist
ORDER BY SECURITY_SYMBOL, EFFECTIVITY_DATE, EXTRACTION_PERIOD_START, EXTRACTION_PERIOD_END
 
/** Default Export Periods
 * In some cases, like for the Default Records, we do not have an export date, 
 * so we picked as default export period start and end the date '2021-01-01'.
 */
