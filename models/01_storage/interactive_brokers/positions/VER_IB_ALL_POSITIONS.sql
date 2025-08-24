{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('HIST_IB_ALL_POSITIONS'), 
    key_column              = 'POSITION_HKEY',
    diff_column             = 'POSITION_HDIFF',

    version_sort_column     = 'EFFECTIVITY_DATE'
) }}
