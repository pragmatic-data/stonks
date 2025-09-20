{{ config(materialized='incremental') }}

{%- set configuration -%}
calculated_columns:
    - gain_fx: bt.position_value - t1.cost_basis_money
    - gain_pct_fx: DIV0(gain_fx, ABS(t1.cost_basis_money)) * 100
    - gain_base: gain_fx * bt.fx_rate_to_base
    - cost_basis_base_approx: t1.cost_basis_money * bt.fx_rate_to_base
    - position_value_base: bt.position_value * bt.fx_rate_to_base
    - UNDERLYING_SYMBOL: COALESCE(t2.UNDERLYING_SYMBOL, t2.SECURITY_SYMBOL)
    - UNDERLYING_LISTING_EXCHANGE: COALESCE(t2.UNDERLYING_LISTING_EXCHANGE, t2.LISTING_EXCHANGE)
    - ADJUSTED_EFFECTIVITY_DATE: |
        CASE 
            WHEN bt.VERSION_NUMBER = 1
                THEN LEAST_IGNORE_NULLS(bt.EFFECTIVITY_DATE, t1.EFFECTIVITY_DATE, t2.EFFECTIVITY_DATE, '2021-01-01'::date)
            ELSE bt.EFFECTIVITY_DATE 
        END
    - ADJUSTED_POSITION_VALUE_VALID_FROM: |
        CASE 
            WHEN bt.VERSION_NUMBER = 1 
                THEN LEAST_IGNORE_NULLS(bt.VALID_FROM, t1.VALID_FROM, t2.VALID_FROM, '2021-01-01'::date)::date
            ELSE POSITION_VALUE_VALID_FROM
        END 

base_table:
    name: "{{ ref('VER_IB_ALL_POSITIONS_DAILY_VALUES') }}"
    include_all_columns: false
    columns:
        - POSITION_VALUE_SCD_HKEY: DIM_SCD_HKEY
        - POSITION_HKEY
        - SECURITY_HKEY
        # - PORTFOLIO_HKEY

        - position_value_date: REPORT_DATE
        - FX_RATE_TO_BASE
        - MARK_PRICE
        - POSITION_VALUE
        - PERCENT_OF_NAV
        - FIFO_PNL_UNREALIZED

        # metadata
        - EFFECTIVITY_DATE
        - RECORD_SOURCE
        - INGESTION_TS_UTC
        - HIST_LOAD_TS_UTC
        - POSITION_VALUE_VERSION_NUMBER: VERSION_NUMBER
        - POSITION_VALUE_VALID_FROM: VALID_FROM
        - POSITION_VALUE_VALID_TO: VALID_TO
        - VALUE_IS_CURRENT: IS_CURRENT

#-- SYNTAX
#-- BaseTable_column: JoinedTable_column
#-- bt.BaseTable_column <operator> tX.JoinedTable_column
joined_tables:
    {{ ref('VER_IB_ALL_POSITIONS') }}:  
        time_column: 
            EFFECTIVITY_DATE: EFFECTIVITY_DATE
        time_operator: '>=' 
        join_columns: 
            POSITION_HKEY: POSITION_HKEY

        columns:
        # - POSITION_HKEY
        # - SECURITY_HKEY
        - PORTFOLIO_HKEY
        - POSITION_SCD_HKEY: DIM_SCD_HKEY

        - CLIENT_ACCOUNT_CODE
        - BROKER_CODE
        - LISTING_EXCHANGE
        - SECURITY_SYMBOL
        - SECURITY_CODE
        - UNDERLYING_SECURITY_CODE

        - ACCOUNT_ALIAS
        - position_change_date: REPORT_DATE
        - quantity
        - SIDE
        - trading_currency: CURRENCY_PRIMARY
        - cost_basis_price
        - cost_basis_money

        # POSITION metadata
        - POSITION_EFFECTIVITY_DATE: EFFECTIVITY_DATE
        - POSITION_INGESTION_TS_UTC: INGESTION_TS_UTC
        - POSITION_HIST_LOAD_TS_UTC: HIST_LOAD_TS_UTC
        - POSITION_VERSION_COUNT: VERSION_COUNT
        - POSITION_VERSION_NUMBER: VERSION_NUMBER
        - POSITION_VALID_FROM:       VALID_FROM
        - POSITION_VALID_TO:         VALID_TO
        - POSITION_IS_CURRENT:       IS_CURRENT


    {{ ref('REFH_IB_SECURITIES') }}: 
        time_column: 
            EFFECTIVITY_DATE: EFFECTIVITY_DATE
        join_columns: 
            SECURITY_HKEY: SECURITY_HKEY
        columns:
            - SECURITY_SCD_HKEY
            - SECURITY_NAME
            - ASSET_CLASS 
            - PUT_CALL 
            - MULTIPLIER 
            - STRIKE 
            - EXPIRY 

            # SECURITY metadata
            - SECURITY_EFFECTIVITY_DATE: EFFECTIVITY_DATE
            - SECURITY_INGESTION_TS_UTC: INGESTION_TS_UTC
            - SECURITY_HIST_LOAD_TS_UTC: HIST_LOAD_TS_UTC
            - SECURITY_VERSION_COUNT:    VERSION_COUNT
            - SECURITY_VERSION_NUMBER:   VERSION_NUMBER
            - SECURITY_VALID_FROM:       VALID_FROM
            - SECURITY_VALID_TO:         VALID_TO
            - SECURITY_IS_CURRENT:       IS_CURRENT

{%- endset -%}

{%- set cfg = fromyaml(configuration) -%}

{{- pragmatic_data.time_join(
    base_table_dict     = cfg['base_table'],
    joined_tables_dict  = cfg['joined_tables'],
    calculated_columns  = cfg['calculated_columns']
) }}

ORDER BY POSITION_HKEY, EFFECTIVITY_DATE