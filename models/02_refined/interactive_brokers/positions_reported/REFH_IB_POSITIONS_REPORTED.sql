WITH
ver_positions as (
    select * from {{ ref('VER_IB_ALL_POSITIONS') }}
)

/** 
 * When we get SECURITIES from the POSTION REPORTS we set EFFECTIVITY at the end of the EXTRACTION PERIOD,
 * because in the past we got only one export at the end of a quarter or a month and the start is always the start of the year.
 *
 * The end of the period is often later than when a position was extabilshed and other events (like dividends) start to be visible. 
 * We have therefore decided to set as EFFECTIVITY DATE, only for the **first version** of a Reported Position,
 * at the START of the export period, instead of the end of it.
 *
 * Each Reported Positions still has the REPORT DATE telling when we exported it (that is also the end of the period),
 * besides the two calculated fields EXTRACTION_PERIOD_START and EXTRACTION_PERIOD_END that are even more explicit.
 */
, fix_first_effectivity_date as (
    SELECT 
        p.* 
            EXCLUDE (EFFECTIVITY_DATE, VALID_FROM)
            RENAME (DIM_SCD_HKEY as POSITION_SCD_HKEY),
        
        TRY_TO_DATE(SUBSTR(RIGHT(RECORD_SOURCE, 24), 1, 8), 'YYYYMMDD') as EXTRACTION_PERIOD_START,
        TRY_TO_DATE(SUBSTR(RIGHT(RECORD_SOURCE, 24), 10, 8), 'YYYYMMDD') as EXTRACTION_PERIOD_END,

        CASE WHEN VERSION_NUMBER = 1 THEN coalesce(EXTRACTION_PERIOD_START, '2021-01-01'::date) 
            ELSE EFFECTIVITY_DATE END 
        as EFFECTIVITY_DATE,
        CASE WHEN VERSION_NUMBER = 1 THEN coalesce(EXTRACTION_PERIOD_START, '2021-01-01'::date) 
            ELSE VALID_FROM END
        as VALID_FROM

    from ver_positions as p
)

select * 
from fix_first_effectivity_date
order by ACCOUNT_ALIAS, SECURITY_SYMBOL, EFFECTIVITY_DATE
