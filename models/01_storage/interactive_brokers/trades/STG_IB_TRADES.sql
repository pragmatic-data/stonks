{{ config( secure = true ) }}  {# Needed to force applying the filter to the view before the pushdown of filters from tests. #}

{%- set source_model = source('IB', 'TRADES') %}
{%- set configuration -%}
source:
    columns: 
        include_all: false          #-- True enables using exclude / replace / rename lists // false does not include any source col
    where: STARTSWITH(CLIENTACCOUNTID, 'U')

calculated_columns:
    - Transaction_ID: TransactionID     #-- unique ???
    - Transaction_Type: TransactionType #-- Needed for uniqueness???

    #-- Core FKs => Account, Security and Position (if related to a position) + Desc
    - BROKER_CODE: '!IB'
    - CLIENT_ACCOUNT_CODE: "'U***' || RIGHT(CLIENTACCOUNTID, 4)"
    - SECURITY_CODE: coalesce(SECURITYID, CONID)
    - LISTING_EXCHANGE: LISTINGEXCHANGE

    - CURRENCY_PRIMARY: CURRENCYPRIMARY
    - SECURITY_SYMBOL: SYMBOL
    - UNDERLYING_SYMBOL: UNDERLYINGSYMBOL
    - UNDERLYING_SECURITY_CODE: coalesce(UNDERLYINGSECURITYID, UNDERLYINGCONID)

    #-- Name and Classification
    - ACCOUNT_ALIAS: ACCOUNTALIAS
    - ASSET_CLASS: ASSETCLASS
    - SECURITY_NAME: DESCRIPTION

    #-- TRADE Details
    - FX_RATE_TO_BASE: FXRATETOBASE::number(38,9)
    - Trade_ID: TradeID
    - Trade_Exchange: Exchange                      #-- The exchange the Trade executed on
    - Trade_Date_Time: DateTime::TIMESTAMP_NTZ      #-- When the Trade did execute
    - Trade_Record_Date: TradeDate::DATE            #-- When the Trade was recorded at IB (even after settlement) 
    - Settle_Date_Target: SettleDateTarget::DATE    #-- When the Trade should settle

    #-- TRADE Content
    - Quantity: Quantity::number(38,9)              #-- Fractional trades
    - Trade_Price_FX: TradePrice::number(38,9)
    - Trade_Money_FX: TradeMoney::number(38,9)
    - Proceeds_FX: Proceeds::number(38,9)
    - Taxes_FX: Taxes::number(38,5)
    - IB_Commission_FX: IBCommission::number(38,9)
    - IB_CommissionCurrency: IBCommissionCurrency   #-- It is 'EUR' or same as CURRENCYPRIMARY
    - Net_Cash_FX: NetCash::number(38,9)

    #-- Order, Security and Position Info
    - Close_Price: ClosePrice
    - Open_Close_Indicator: Open_CloseIndicator
    - Notes_Codes
    - Cost_Basis: CostBasis
    - Fifo_Pnl_Realized: FifoPnlRealized
    - Fx_Pnl: FxPnl
    - Mtm_Pnl: MtmPnl
    - Orig_Trade_Price: OrigTradePrice
    - Orig_Trade_Date: OrigTradeDate
    - Orig_Trade_ID: OrigTradeID
    - Clearing_Firm_ID: ClearingFirmID
    - Buy_Sell: Buy_Sell
    - Orig_Order_ID: OrigOrderID

    - REPORT_DATE: REPORTDATE::date                 #-- When the Report we received was done

    #-- core metadata
    - EFFECTIVITY_DATE: DateTime::TIMESTAMP_NTZ     #-- Effectivity is when executed, not when recorded or reported
    - RECORD_SOURCE: FROM_FILE
    - FILE_ROW_NUMBER
    - FILE_LAST_MODIFIED_TS_UTC
    - INGESTION_TS_UTC

hashed_columns: 
    TRADE_HKEY:
        - Transaction_ID
    POSITION_HKEY:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - SECURITY_CODE
        - LISTING_EXCHANGE
    PORTFOLIO_HKEY:
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
    SECURITY_HKEY:
        - SECURITY_CODE
        - LISTING_EXCHANGE

    TRADE_HDIFF:
        - Transaction_Type
        - Transaction_ID
        #-- FKs
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - LISTING_EXCHANGE
        - CURRENCY_PRIMARY
        - SECURITY_SYMBOL
        - SECURITY_CODE
        - UNDERLYING_SYMBOL
        - UNDERLYING_SECURITY_CODE

        #-- Name and Classification
        - ACCOUNT_ALIAS
        - ASSET_CLASS
        - SECURITY_NAME
        #- Transaction_Category

        #-- TRADE Details
        - FX_RATE_TO_BASE
        - Trade_ID
        - Trade_Exchange
        - Trade_Date_Time
        - Trade_Record_Date
        - Settle_Date_Target

        #-- TRADE Content
        - Quantity
        - Trade_Price_FX
        - Trade_Money_FX
        - Proceeds_FX
        - Taxes_FX
        - IB_Commission_FX
        - IB_CommissionCurrency
        - Net_Cash_FX

        #-- Order, Security and Position Info
        - Close_Price
        - Open_Close_Indicator
        - Notes_Codes
        - Cost_Basis
        - Fifo_Pnl_Realized
        - Fx_Pnl
        - Mtm_Pnl
        - Orig_Trade_Price
        - Orig_Trade_Date
        - Orig_Trade_ID
        - Clearing_Firm_ID
        - Buy_Sell
        - Orig_Order_ID

        #- REPORT_DATE      #-- Not constitutes a change

remove_duplicates: 
{%- endset -%}

{%- set cfg = fromyaml(configuration) -%}

{{- pragmatic_data.stage(
    source_model            = source_model,
    source                  = cfg['source'],
    calculated_columns      = cfg['calculated_columns'],
    hashed_columns          = cfg['hashed_columns'],
    remove_duplicates       = cfg['remove_duplicates'],
) }}
