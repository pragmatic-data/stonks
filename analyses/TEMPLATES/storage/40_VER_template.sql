{{ config( enabled=false) }}    -- !!! Remove this LINE to enable the model. Model disabled to avoid compilation error

{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('HIST_XXXXXX'), 
    key_column              = 'XXXXXX_HKEY',
    diff_column             = 'XXXXXX_HDIFF',

    version_sort_column     = 'EFFECTIVITY_DATE'
) }}