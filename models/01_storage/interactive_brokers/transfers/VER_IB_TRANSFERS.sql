{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('HIST_IB_TRANSFERS'), 
    key_column              = 'TRANSFER_HKEY',
    diff_column             = 'TRANSFER_HDIFF',

    version_sort_column     = 'EFFECTIVITY_DATE'
) }}