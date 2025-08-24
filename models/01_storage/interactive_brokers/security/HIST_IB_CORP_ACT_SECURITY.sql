{{ config( materialized='incremental') }}

{{ pragmatic_data.save_history_with_multiple_versions(
    input_rel               = ref('STG_IB_CORP_ACT_SECURITY'), 
    key_column              = 'SECURITY_HKEY',
    diff_column             = 'SECURITY_HDIFF',

    sort_expr               = 'EFFECTIVITY_DATE, FILE_ROW_NUMBER',
    input_filter_expr       = 'SECURITY_CODE is NOT NULL',
) }}
/**
    load_ts_column          = 'INGESTION_TS_UTC',
    high_watermark_column   = 'INGESTION_TS_UTC',
    high_watermark_test     = '>',
    history_filter_expr     = 'true',
*/
