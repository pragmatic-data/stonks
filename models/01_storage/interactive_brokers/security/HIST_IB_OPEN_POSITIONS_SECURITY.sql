{{ config( materialized='incremental') }}

{{ pragmatic_data.save_history_with_multiple_versions(
    input_rel               = ref('DELTA_IB_OPEN_POSITIONS_SECURITY'), 
    key_column              = 'SECURITY_HKEY',
    diff_column             = 'SECURITY_HDIFF',

    sort_expr               = 'RECORD_SOURCE, FILE_ROW_NUMBER',
) }}
/**
    load_ts_column          = 'INGESTION_TS_UTC',
    high_watermark_column   = 'INGESTION_TS_UTC',
    high_watermark_test     = '>',
    input_filter_expr       = 'true',
    history_filter_expr     = 'true',
*/
