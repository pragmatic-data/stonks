{%- set source_model = source('IB', 'TRANSFERS') %}
{%- set configuration -%}
source:
    model: "{{ source('IB', 'TRANSFERS') }}"
    columns: 
        include_all: false          #-- True enables using exclude / replace / rename lists // false does not include any source col
    where: STARTSWITH(CLIENTACCOUNTID, 'U')

calculated_columns:
    - Transfer_ID: TransactionID     #-- unique

    #-- Core FKs => Account, Security and Position (if related to a position) + Desc
    - BROKER_CODE: '!IB'
    - CLIENT_ACCOUNT_CODE: "'U***' || RIGHT(CLIENTACCOUNTID, 4)"
    - LISTING_EXCHANGE: LISTINGEXCHANGE
    - CURRENCY_PRIMARY: CURRENCYPRIMARY
    - SECURITY_SYMBOL: SYMBOL
    - SECURITY_CODE: coalesce(SECURITYID, CONID)
    - UNDERLYING_SYMBOL: UNDERLYINGSYMBOL
    - UNDERLYING_SECURITY_CODE: coalesce(UNDERLYINGSECURITYID, UNDERLYINGCONID)

    #-- Name and Classification
    - ACCOUNT_ALIAS: ACCOUNTALIAS
    - ASSET_CLASS: ASSETCLASS
    - ASSET_SUB_CATEGORY: SubCategory
    - SECURITY_NAME: DESCRIPTION

    #-- TRANSFER Details
    - Transfer_Type: Type               #-- 'FOP' for transfers, 'INTERNAL' or 'INTERCOMPANY' for others
    - FX_RATE_TO_BASE: FXRATETOBASE::number(38,9)
    - Transfer_Record_Date: Date::DATE        #-- When the Transfer was recorded at IB (usually first date) 
    - Transfer_Date_Time: DateTime::TIMESTAMP_NTZ      #-- When the Transfer did execute (usually same as record, except for time)
    - Settle_Date: SettleDate::DATE    #-- When the Transfer has settled (after record)
    - REPORT_DATE: REPORTDATE::date           #-- When the Report we are processing was done (usually after settle for FOP)

    - TRANSFER_Direction: Direction             #-- 'IN' or 'OUT'
    - Transfer_Company: TransferCompany         #-- unused, '--'
    - Transfer_Account_CODE: TransferAccount    #-- not reliable, sometimes U code, sometimes full code, sometimes 'FOP'
    - Transfer_Account_Name: TransferAccountName    #-- always null
    - Delivering_Broker_CODE: DeliveringBroker      #-- not reliable

    #-- TRANSFER Content
    - Quantity: Quantity::number(38,9)              #-- The amount transferred, 0 for chash deposits/withdrawal
    - Transfer_Cash_FX: CashTransfer::number(38,9)              #-- The value in FX of the cash transfer
    - Transfer_Money_FX: PositionAmount::number(38,9)           #-- The value in FX of the security transfer
    - Transfer_Money_BASE: PositionAmountInBase::number(38,9)   #-- The value in BASE of the security transfer

    - Transfer_Price_FX: TransferPrice::number(38,9)            #-- almost always 0
    - Pnl_Amount_FX: PnlAmount::number(38,9)                    #-- almost always 0
    - Pnl_Amount_Base: PnlAmountInBase::number(38,9)            #-- almost always 0

    #-- Other Transfer Info
    - Client_Reference: ClientReference
    - IB_Operation_Code: Code
    - Level_Of_Detail: LevelOfDetail
    - Position_Instruction_ID: PositionInstructionID
    - Position_Instruction_Set_ID: PositionInstructionSetID
    - Serial_Number: SerialNumber
    - Delivery_Type: DeliveryType
    - Commodity_Type: CommodityType
    - Fineness
    - Weight


    #-- core metadata
    - EFFECTIVITY_DATE: DateTime::TIMESTAMP_NTZ     #-- Effectivity is when the transfer executed, not when recorded or reported
    - RECORD_SOURCE: FROM_FILE
    - FILE_ROW_NUMBER: FILE_ROW_NUMBER
    - FILE_LAST_MODIFIED_TS_UTC: FILE_LAST_MODIFIED_TS_UTC
    - INGESTION_TS_UTC: INGESTION_TS_UTC

hashed_columns: 
    TRANSFER_HKEY:
        - Transfer_ID        #-- unique
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

    TRANSFER_HDIFF:
        - Transfer_ID
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
        - ASSET_SUB_CATEGORY
        - SECURITY_NAME

        #-- TRANSFER Details
        - Transfer_Type
        - FX_RATE_TO_BASE
        - Transfer_Record_Date
        - Transfer_Date_Time
        - Settle_Date
        - REPORT_DATE

        - TRANSFER_Direction
        - Transfer_Company
        - Transfer_Account_CODE
        - Transfer_Account_Name
        - Delivering_Broker_CODE

        #-- TRANSFER Content
        - Quantity
        - Transfer_Cash_FX
        - Transfer_Money_FX
        - Transfer_Money_BASE

        - Transfer_Price_FX
        - Pnl_Amount_FX
        - Pnl_Amount_Base

        #-- Other Transfer Info
        - Client_Reference
        - IB_Operation_Code
        - Level_Of_Detail
        - Position_Instruction_ID
        - Position_Instruction_Set_ID
        - Serial_Number
        - Delivery_Type
        - Commodity_Type
        - Fineness
        - Weight

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
