{{ config( enabled=false) }}    -- !!! Remove this LINE to enable the model. Model disabled to avoid compilation error

{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('HIST_IB_TRADES'), 
    key_column              = 'TRADE_HKEY',
    diff_column             = 'TRADE_HDIFF',

    version_sort_column     = 'EFFECTIVITY_DATE'
) }}