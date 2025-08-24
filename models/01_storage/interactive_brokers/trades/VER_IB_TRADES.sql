{{ pragmatic_data.versions_from_history_with_multiple_versions(
    history_rel             = ref('HIST_IB_TRADES'), 
    key_column              = 'TRADE_HKEY',
    diff_column             = 'TRADE_HDIFF',

    version_sort_column     = 'EFFECTIVITY_DATE'
) }}
/** Default values that you could modify.
 ** They define the technical timeline, what columns you read and a filter on the hist model
 *
     load_ts_column      = var('pdp.load_ts_column', 'INGESTION_TS_UTC'),
    hist_load_ts_column = var('pdp.hist_load_ts_column', 'HIST_LOAD_TS_UTC'),
    selection_expr      = '*',
    history_filter_expr = 'true'

 */