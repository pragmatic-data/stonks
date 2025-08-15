{% macro load_IB_Trades(recreate_table = false) %}
{%- set ingestion_cfg -%}
ingestion:
    pattern: 'trades/.*Trades.*[.]csv.gz'
    stage_name: "{{ get_IB_ingestion_stage_name() }}"
    format_name:

landing_table:
    db_name:     "{{ get_IB_ingestion_db_name() }}"
    schema_name: "{{ get_IB_ingestion_schema_name() }}"
    table_name:  Trades
    columns: 
        - ClientAccountID       #-- No type means TEXT
        - AccountAlias
        - Model
        - CurrencyPrimary
        - FXRateToBase
        - AssetClass
        - Symbol
        - Description
        - Conid
        - SecurityID
        - SecurityIDType
        - CUSIP
        - ISIN
        - ListingExchange
        - UnderlyingConid
        - UnderlyingSymbol
        - UnderlyingSecurityID
        - UnderlyingListingExchange
        - Issuer
        - Multiplier
        - Strike
        - Expiry
        - TradeID
        - Put_Call              #-- was Put/Call, not valid, renamed
        - ReportDate
        - PrincipalAdjustFactor
        - DateTime
        - TradeDate
        - SettleDateTarget
        - TransactionType
        - Exchange
        - Quantity
        - TradePrice
        - TradeMoney
        - Proceeds
        - Taxes
        - IBCommission
        - IBCommissionCurrency
        - NetCash
        - ClosePrice
        - Open_CloseIndicator
        - Notes_Codes
        - CostBasis
        - FifoPnlRealized
        - FxPnl
        - MtmPnl
        - OrigTradePrice
        - OrigTradeDate
        - OrigTradeID
        - OrigOrderID
        - ClearingFirmID
        - TransactionID
        - Buy_Sell
        - IBOrderID
        - IBExecID
        - BrokerageOrderID
        - OrderReference
        - VolatilityOrderLink
        - ExchOrderID
        - ExtExecID
        - OrderTime
        - OpenDateTime
        - HoldingPeriodDateTime
        - WhenRealized
        - WhenReopened
        - LevelOfDetail
        - ChangeInPrice
        - ChangeInQuantity
        - OrderType
        - TraderID
        - IsAPIOrder
        - AccruedInterest

{%- endset -%}

{%- set cfg = fromyaml(ingestion_cfg) -%}

{% do pragmatic_data.run_CSV_ingestion(
        landing_table_dict = cfg['landing_table'],
        ingestion_dict  = cfg['ingestion'],
        recreate_table = recreate_table
) %}

{% endmacro %}
