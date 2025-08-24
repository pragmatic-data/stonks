{%- set source_model = source('IB', 'TRADES') %}
{%- set configuration -%}
source:
    columns: 
        include_all: false          #-- True enables using eclude / replace / rename lists // false does not include any source col
    where: STARTSWITH(CLIENTACCOUNTID, 'U')

calculated_columns: 
  <<: {{ config.get('calculated_columns') }}
  EFFECTIVITY_DATE: DateTime::TIMESTAMP_NTZ
  Transaction_ID: TransactionID

hashed_columns: 
    <<: {{ config.get('hashed_columns') }}
    TRADE_HKEY:
      - Transaction_ID        #-- ? unique?


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
