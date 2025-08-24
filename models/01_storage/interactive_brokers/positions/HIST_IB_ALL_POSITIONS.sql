{{ config( materialized='incremental') }}

{{ pragmatic_data.save_history_with_multiple_versions(
    input_rel               = ref('STG_IB_ALL_POSITIONS'), 
    key_column              = 'POSITION_HKEY',
    diff_column             = 'POSITION_HDIFF',

    sort_expr               = 'REPORT_DATE',
) }}
/**
    load_ts_column          = 'INGESTION_TS_UTC',
    high_watermark_column   = 'INGESTION_TS_UTC',
    high_watermark_test     = '>',
    input_filter_expr       = 'true',
    history_filter_expr     = 'true',
 */
 