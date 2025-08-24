{% macro ingest__generic_two_column_table__with_defaults_YAML(recreate_table = false) %}

{% set default_config = SYSTEM_A__ingestion_config()  %}
{%- set yaml_str -%}
landing_table:
    <<: {{default_config.landing_table}}
    table_name:  GENERIC_TWO_COLUMN_TABLE__WITH_DEFAULT

ingestion:
    <<: {{default_config.ingestion}}
    pattern: 'SYSTEM_A/generic/.*/GENERIC_TWO_COLUMN_TABLE.*.csv.gz'


{%- endset -%}

{%- set metadata_dict = fromyaml(yaml_str) -%}

{% do pragmatic_data.run_CSV_ingestion(
        landing_table_dict = metadata_dict['landing_table'],
        ingestion_dict  = metadata_dict['ingestion'],
        recreate_table = recreate_table
) %}

{% endmacro %}
