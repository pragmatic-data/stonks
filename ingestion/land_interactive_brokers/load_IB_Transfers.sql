{% macro load_IB_Transfers(recreate_table = false) %}
{%- set ingestion_cfg -%}
ingestion:
    pattern: 'transfers/Transfers.*[.]csv.gz'
    stage_name: "{{ get_IB_ingestion_stage_name() }}"
    format_name:

landing_table:
    db_name:     "{{ get_IB_ingestion_db_name() }}"
    schema_name: "{{ get_IB_ingestion_schema_name() }}"
    table_name:  Transfers
    columns: 
        - ClientAccountID       #-- No type specification means TEXT
        - AccountAlias
        - Model
        - CurrencyPrimary
        - FXRateToBase
        - AssetClass
        - SubCategory
        - Symbol
        - Description
        - Conid
        - SecurityID
        - SecurityIDType
        - CUSIP
        - ISIN
        - FIGI
        - ListingExchange
        - UnderlyingConid
        - UnderlyingSymbol
        - UnderlyingSecurityID
        - UnderlyingListingExchange
        - Issuer
        - IssuerCountryCode
        - Multiplier
        - Strike
        - Expiry
        - Put_Call
        - PrincipalAdjustFactor
        - ReportDate
        - Date
        - DateTime
        - SettleDate
        - Type
        - Direction
        - TransferCompany
        - TransferAccount
        - TransferAccountName
        - DeliveringBroker
        - Quantity
        - TransferPrice
        - PositionAmount
        - PositionAmountInBase
        - PnlAmount
        - PnlAmountInBase
        - CashTransfer
        - Code
        - ClientReference
        - TransactionID
        - LevelOfDetail
        - PositionInstructionID
        - PositionInstructionSetID
        - SerialNumber
        - DeliveryType
        - CommodityType
        - Fineness
        - Weight

{%- endset -%}

{%- set cfg = fromyaml(ingestion_cfg) -%}

{% do pragmatic_data.run_CSV_ingestion(
        landing_table_dict = cfg['landing_table'],
        ingestion_dict  = cfg['ingestion'],
        recreate_table = recreate_table
) %}

{% endmacro %}
