{{ config( enabled=false) }}    -- !!! Remove this LINE to enable the model. Model disabled to avoid compilation error

{{ config( materialized='incremental') }}

{{ pragmatic_data.save_history_with_multiple_versions(
    input_rel               = ref('STG_XXXXXX'), 
    key_column              = 'XXXXXX_HKEY',
    diff_column             = 'XXXXXX_HDIFF',

    sort_expr               = 'EFFECTIVITY_DATE, INGESTION_TS_UTC, RECORD_SOURCE, FILE_ROW_NUMBER',
) }}

{# Optional parameters to improve performances, with their default settings
    load_ts_column          = 'INGESTION_TS_UTC',
    high_watermark_column   = 'INGESTION_TS_UTC',
    high_watermark_test     = '>',
    input_filter_expr       = 'true',
    history_filter_expr     = 'true',
#}
