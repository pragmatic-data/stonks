{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('HIST_IB_OPEN_POSITIONS_SECURITY'), 
    key_column              = 'SECURITY_HKEY',
    diff_column             = 'SECURITY_HDIFF',

    version_sort_column     = 'EFFECTIVITY_DATE'
) }}