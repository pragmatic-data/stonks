WITH
ver_security as (
    {{-  pragmatic_data.versions_from_history_with_multiple_versions(
        history_rel             = ref('MHIST_IB_SECURITIES'), 
        key_column              = 'SECURITY_HKEY',
        diff_column             = 'SECURITY_HDIFF',

        version_sort_column     = 'EFFECTIVITY_DATE'
    ) }}
)
/** 
 * WHY
 * When we get SECURITIES from the POSTION REPORTS we the EFFECTIVITY is set at the end of the EXTRACTION PERIOD,
 * because that is how the report date used to set the EFFECTIVITY is set. 
 * In some periods we have only one export at the end of a quarter or a month.
 * When Positions become effective at the end of a period, the end of the period is later 
 * than when a position was extabilshed and other events (like dividends) start to happen. 
 *
 * WHAT
 * Only if the first version of a Security is derived from an Open Positions record,
 * we set as EFFECTIVITY DATE the START of the export period, instead of the end of it,
 * so that events coming from that Position happen after the position is estabilished.
 *
 * Note that we do not change it before calculating the VERSIONS to safeguard the order that depends on the exact EFFECTIVITY DATE.
 * Each security from Opn Positions still has the REPORT DATE telling when we exported it (that is also the end of the period).
 */
, fixed_start_dates as (
    SELECT * 
        REPLACE (
            CASE WHEN VERSION_NUMBER = 1 AND STARTSWITH(UPPER(RECORD_SOURCE), 'OPEN_POSITIONS/')
                 THEN coalesce(EXTRACTION_PERIOD_START, '2021-01-01'::date) ELSE EFFECTIVITY_DATE END
            as EFFECTIVITY_DATE,
            CASE WHEN VERSION_NUMBER = 1 AND STARTSWITH(UPPER(RECORD_SOURCE), 'OPEN_POSITIONS/')
                 THEN coalesce(EXTRACTION_PERIOD_START, '2021-01-01'::date) ELSE VALID_FROM END
            as VALID_FROM
        )
        RENAME (
            DIM_SCD_HKEY as SECURITY_SCD_HKEY
        )
    FROM ver_security
)

SELECT * FROM fixed_start_dates
