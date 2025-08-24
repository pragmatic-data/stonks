{%- set source_model = source('IB', 'CASH_TRANSACTIONS') %}
{%- set configuration -%}
source:
    columns: 
        include_all: false          #-- True enables using exclude / replace / rename lists // false does not include any source col
    where: STARTSWITH(CLIENTACCOUNTID, 'U')

calculated_columns:
    - Transaction_ID: TransactionID     #-- Not really unique :( !!!
    - Transaction_Type: Type            #-- needed in PK as Broker Interest Paid and Received for one currency have the same TX ID 
    - TX_DESCRIPTION: DESCRIPTION       #-- needed in PK as Broker Interest Received can have more than one row x ID & Type

    #-- Core FKs => Account, Security and Position (if related to a position) + Desc
    - BROKER_CODE: '!IB'
    - CLIENT_ACCOUNT_CODE: "'U***' || RIGHT(CLIENTACCOUNTID, 4)"
    - SECURITY_CODE: coalesce(SECURITYID, CONID)
    - LISTING_EXCHANGE: LISTINGEXCHANGE

    - CURRENCY_PRIMARY: CURRENCYPRIMARY
    - SECURITY_SYMBOL: SYMBOL


    #-- TX Details: Description and Classification
    - ACCOUNT_ALIAS: ACCOUNTALIAS
    - ASSET_CLASS: ASSETCLASS
    - Transaction_Category: |
        CASE
            WHEN ASSET_CLASS = 'STK' and TYPE IN ('Dividends', 'Payment In Lieu Of Dividends', 'Withholding Tax', 'Other Fees') 
                THEN 'DIVIDENDS'
            WHEN ASSET_CLASS is null and TYPE IN ('Broker Interest Received', 'Withholding Tax', 'Broker Interest Paid') 
                THEN 'INTERESTS'
            WHEN ASSET_CLASS is null and TYPE IN ('Deposits/Withdrawals') 
                THEN 'DEPOSITS'
            WHEN ASSET_CLASS is null and TYPE IN ('Other Fees') 
                THEN 'COSTS'
            ELSE 'UNKNOWN'
        END

    #-- Monetary amounts and currency
    - Multiplier: Multiplier::number(38,2)
    - AMOUNT_IN_FX: Amount::number(38,2)      #-- Gross Amount (before taxes) for Dividends
    - FX_RATE_TO_BASE: FXRATETOBASE::number(38,6)
    - AMOUNT_IN_BASE: AMOUNT_IN_FX * FX_RATE_TO_BASE

    #-- Time and TX identification
    - Date_Time: Date_Time::TIMESTAMP_NTZ
    - Settle_Date: SettleDate::date
    - REPORT_DATE: REPORTDATE::date
    - ClientReference

    #-- core metadata
    - EFFECTIVITY_DATE: SettleDate::date        #-- Effectivity is when accounted for, not when reported!!!
    - RECORD_SOURCE: FROM_FILE
    - FILE_ROW_NUMBER: FILE_ROW_NUMBER
    - FILE_LAST_MODIFIED_TS_UTC: FILE_LAST_MODIFIED_TS_UTC
    - INGESTION_TS_UTC: INGESTION_TS_UTC

    #-- IGNORED - Security ID columns, already in SECURITY Entity
    #- Conid
    #- SecurityID
    #- SecurityIDType
    #- CUSIP
    #- ISIN
    #-- IGNORED - 100% null values, leaving out
    #- MODEL: MODEL
    #- UnderlyingConid
    #- UnderlyingSymbol
    #- UnderlyingSecurityID
    #- UnderlyingListingExchange
    #- Issuer
    #- Strike
    #- Expiry
    #- Put_Call
    #- PrincipalAdjustFactor
    #- TradeID                 
    #- Code

hashed_columns: 
    TRANSACTION_HKEY:
        - Transaction_ID        #-- not unique :(
        - Transaction_Type      #-- needed as Broker Interest Paid and Received for one currency have the same TX ID 
        - TX_DESCRIPTION
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

    TRANSACTION_HDIFF:
        - Transaction_Type
        - Transaction_ID
        - TX_DESCRIPTION
        #-- FKs
        - BROKER_CODE
        - CLIENT_ACCOUNT_CODE
        - LISTING_EXCHANGE
        - SECURITY_SYMBOL
        - SECURITY_CODE
        #-- TX Details
        - ACCOUNT_ALIAS
        - ASSET_CLASS
        - Transaction_Category
        #-- TX Metrics
        - Multiplier
        - CURRENCY_PRIMARY
        - AMOUNT_IN_FX
        - FX_RATE_TO_BASE
        - AMOUNT_IN_BASE
        #-- Time & ref
        - Date_Time         #-- better to see the same data applied at different times than not
        - Settle_Date       #-- better to see the same data applied at different times than not
        - ClientReference

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
