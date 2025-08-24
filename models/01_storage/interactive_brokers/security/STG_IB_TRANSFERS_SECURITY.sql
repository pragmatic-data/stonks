{%- set source_model = source('IB', 'TRANSFERS') %}
{%- set configuration -%}
source:
    columns: 
        include_all: false          #-- True enables using eclude / replace / rename lists // false does not include any source col
    where: STARTSWITH(CLIENTACCOUNTID, 'U')

calculated_columns: 
    <<: {{ config.get('calculated_columns') }}
    EXTRACTION_PERIOD_START: TRY_TO_DATE(SUBSTR(RIGHT(RECORD_SOURCE, 24), 1, 8), 'YYYYMMDD')
    EXTRACTION_PERIOD_END: TRY_TO_DATE(SUBSTR(RIGHT(RECORD_SOURCE, 24), 10, 8), 'YYYYMMDD')
    EFFECTIVITY_DATE: DateTime::TIMESTAMP_NTZ
    Transfer_ID: TransactionID
    ASSET_SUB_CATEGORY: SubCategory
    FIGI: FIGI          #-- Financial Instrument Global Identifier (formerly Bloomberg Global Identifier (BBGID))
                        #-- https://en.wikipedia.org/wiki/Financial_Instrument_Global_Identifier
                        #-- https://www.openfigi.com/

hashed_columns: 
    <<: {{ config.get('hashed_columns') }}
    TRANSFER_HKEY:
    - Transfer_ID


default_records: {{ config.get('default_records') }}

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
