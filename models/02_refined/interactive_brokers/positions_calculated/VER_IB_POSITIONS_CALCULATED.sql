{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('REFH_IB_POSITIONS_CALCULATED'), 
    key_column              = 'POSITION_HKEY',
    diff_column             = 'POSITION_CALCULATED_HDIFF',

    version_sort_column     = 'EFFECTIVITY_DATE',
    extra_sort_columns      = 'TX_ORDER_IN_POSITION'
) }}