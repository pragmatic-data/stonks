{{ config( materialized='incremental') }}

{{ pragmatic_data.save_history_with_multiple_versions(
    input_rel               = ref('STG_IB_TRADES'), 
    key_column              = 'TRADE_HKEY',
    diff_column             = 'TRADE_HDIFF',

    sort_expr               = 'EFFECTIVITY_DATE, Transaction_ID, RECORD_SOURCE, FILE_ROW_NUMBER',
) }}
/** Default values, mostly to manage load performace, that you could modify:
    load_ts_column          = 'INGESTION_TS_UTC',
    high_watermark_column   = 'INGESTION_TS_UTC',
    high_watermark_test     = '>',
    input_filter_expr       = 'true',
    history_filter_expr     = 'true',
*/
