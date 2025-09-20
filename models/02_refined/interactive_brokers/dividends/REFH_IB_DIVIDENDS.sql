{%- set configuration -%}
calculated_columns:
    - DIM_SECURITY_SYMBOL: COALESCE(t1.SECURITY_SYMBOL, DIVIDEND_SECURITY_SYMBOL)
    - DIM_SECURITY_HKEY: COALESCE(t1.SECURITY_HKEY, bt.SECURITY_HKEY)

base_table:
    name: "{{ ref('VER_IB_CASH_TRANSACTIONS') }}"
    filter: TRANSACTION_CATEGORY = 'DIVIDENDS' and bt.IS_CURRENT    #-- is_current is needed to add restatements
    include_all_columns: false
    columns:
        - TRANSACTION_ID
        - TRANSACTION_TYPE
        - TRANSACTION_CATEGORY
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - ACCOUNT_ALIAS
        - ASSET_CLASS
        - DIVIDEND_SECURITY_SYMBOL: SECURITY_SYMBOL     #-- To keep around what is on the DIV row
        - SECURITY_CODE
        - DIVIDEND_DESCRIPTION: TX_DESCRIPTION
        - DIVIDEND_EXCHANGE: LISTING_EXCHANGE

        #-- Monetary amounts and currency
        - Multiplier
        - CURRENCY_PRIMARY
        - AMOUNT_IN_FX              #-- Gross Amount (before taxes) for Dividends
        - FX_RATE_TO_BASE
        - AMOUNT_IN_BASE

        #-- Time and TX identification
        - dividend_settlement_Date_Time: Date_Time
        - dividend_settlement_date: Settle_Date
        - REPORT_DATE
        - ClientReference

        #-- Keys
        - TRANSACTION_HKEY
        - TRANSACTION_HDIFF
        - POSITION_HKEY
        - PORTFOLIO_HKEY

        #-- core metadata
        - EFFECTIVITY_DATE
        - RECORD_SOURCE
        - FILE_ROW_NUMBER
        - FILE_LAST_MODIFIED_TS_UTC
        - INGESTION_TS_UTC


joined_tables:
    {{ ref('REFH_IB_SECURITIES') }}: 
        time_column:    #-- The default time operator is '>=' that gives bt.DT >= tn.DT, that is Tn is active before BT 
            EFFECTIVITY_DATE: SETTLE_DATE       #-- TN_col: BT_col
        join_columns: 
            SECURITY_CODE: SECURITY_CODE
        columns:
            - SECURITY_SCD_HKEY
            - SECURITY_NAME
            - LISTING_EXCHANGE
            - CONID
            - ISIN
            - SECURITY_CODE_TYPE: SECURITY_ID_TYPE

            # SECURITY metadata
            - SECURITY_EFFECTIVITY_DATE: EFFECTIVITY_DATE
            - SECURITY_INGESTION_TS_UTC: INGESTION_TS_UTC
            - SECURITY_HIST_LOAD_TS_UTC: HIST_LOAD_TS_UTC
            - SECURITY_VERSION_COUNT:    VERSION_COUNT
            - SECURITY_VERSION_NUMBER:   VERSION_NUMBER
            - SECURITY_VALID_FROM:       VALID_FROM
            - SECURITY_VALID_TO:         VALID_TO
            - SECURITY_IS_CURRENT:       IS_CURRENT

    {{ ref('REFH_IB_POSITIONS_REPORTED') }}:
        filter: SIDE != 'Closed'
        time_column:    #-- The default time operator is '>=' that gives bt.DT >= tn.DT, that is Tn is active before BT 
            EFFECTIVITY_DATE: EFFECTIVITY_DATE       #-- TN_col: BT_col
        join_columns: 
            POSITION_HKEY: POSITION_HKEY
        columns:
            - POSITION_SCD_HKEY
            - POSITION_QUANTITY: quantity
            - SIDE
            - POSITION_CURRENCY_PRIMARY: CURRENCY_PRIMARY
            - POSITION_FX_RATE_TO_BASE: FX_RATE_TO_BASE
            - POSITION_COST_BASIS_FX: cost_basis_money
            - POSITION_COST_BASIS_BASE: cost_basis_money * t2.FX_RATE_TO_BASE


{%- endset -%}

{%- set cfg = fromyaml(configuration) -%}

{{- pragmatic_data.time_join(
    base_table_dict     = cfg['base_table'],
    joined_tables_dict  = cfg['joined_tables'],
    calculated_columns  = cfg['calculated_columns']
) }}

order by bt.ACCOUNT_ALIAS, DIVIDEND_SECURITY_SYMBOL, EFFECTIVITY_DATE, TRANSACTION_TYPE
