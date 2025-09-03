/**
 * Not really useful as Cash TX are immutable. 
 * Created for consistency.
 */
{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('HIST_IB_CASH_TRANSACTIONS'), 
    key_column              = 'TRANSACTION_HKEY',
    diff_column             = 'TRANSACTION_HDIFF',

    version_sort_column     = 'REPORT_DATE'
) }}
