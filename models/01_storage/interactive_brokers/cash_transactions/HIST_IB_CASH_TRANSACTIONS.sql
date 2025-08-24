{{ config( materialized='incremental') }}

{{ pragmatic_data.save_history_with_multiple_versions(
    input_rel               = ref('STG_IB_CASH_TRANSACTIONS'), 
    key_column              = 'TRANSACTION_HKEY',
    diff_column             = 'TRANSACTION_HDIFF',

    sort_expr               = 'REPORT_DATE',
) }}
/**
    load_ts_column          = 'INGESTION_TS_UTC',
    high_watermark_column   = 'INGESTION_TS_UTC',
    high_watermark_test     = '>',
    input_filter_expr       = 'true',
    history_filter_expr     = 'true',
*/

/* ** About the SORTING of the INPUT ROWS **
 * Using a high watermark we limit the input evaluated for insertion to the rows most recently arrived 
 * compared to the last row for the same key and we evaluate all the rows for new keys.
 * Then we compare the first from the input with the last from the history to decide about storing the 
 * fist from the input, and then we also store the input rows that have a different HKEY from the previous 
 * row in the input (for the same key).
 *
 * We should therefore sort the input rows on metadata columns that would allow to store the first entry
 * of a series of entries with the same payload (that usually includes the column used for EFFECTIVITY DATE).
 */
