{{ config( materialized='incremental') }}

{{ pragmatic_data.save_history_with_multiple_versions(
    input_rel               = ref('STG_IB_CORP_ACT_MANUAL'), 
    key_column              = 'CORP_ACT_HKEY',
    diff_column             = 'CORP_ACT_HDIFF',

    sort_expr               = 'INGESTION_TS_UTC',
) }}
/**
    load_ts_column          = 'INGESTION_TS_UTC',
    high_watermark_column   = 'INGESTION_TS_UTC',
    high_watermark_test     = '>',
    input_filter_expr       = 'true',
    history_filter_expr     = 'true',
*/
