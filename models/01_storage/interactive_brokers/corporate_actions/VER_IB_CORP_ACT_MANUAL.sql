{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('HIST_IB_CORP_ACT_MANUAL'), 
    key_column              = 'CORP_ACT_HKEY',
    diff_column             = 'CORP_ACT_HDIFF',

    version_sort_column     = 'EFFECTIVITY_DATE'
) }}
