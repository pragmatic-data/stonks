{% macro load_IB_OpenPositions(recreate_table = false) %}
{%- set ingestion_cfg -%}
ingestion:
    pattern: 'open_positions/.*OpenPositions.*[.]csv.gz'
    stage_name: "{{ get_IB_ingestion_stage_name() }}"
    format_name:

landing_table:
    db_name:     "{{ get_IB_ingestion_db_name() }}"
    schema_name: "{{ get_IB_ingestion_schema_name() }}"
    table_name:  Open_Positions
    columns: 
        - ClientAccountID       #-- No type specification means TEXT
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
        - Put_Call  
        - PrincipalAdjustFactor  
        - ReportDate  
        - Quantity  
        - MarkPrice  
        - PositionValue  
        - OpenPrice  
        - CostBasisPrice  
        - CostBasisMoney  
        - PercentOfNAV  
        - FifoPnlUnrealized  
        - Side  
        - LevelOfDetail  
        - OpenDateTime  
        - HoldingPeriodDateTime  
        - VestingDate  
        - Code  
        - OriginatingOrderID  
        - OriginatingTransactionID  
        - AccruedInterest 

{%- endset -%}

{%- set cfg = fromyaml(ingestion_cfg) -%}

{% do pragmatic_data.run_CSV_ingestion(
        landing_table_dict = cfg['landing_table'],
        ingestion_dict  = cfg['ingestion'],
        recreate_table = recreate_table
) %}

{% endmacro %}
