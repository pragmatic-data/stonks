{# ** This macro provides a dictionary with the default ingestion parameters for SYSTEM A (PROD data)
   *
   *  USAGE:
   *  Print out the object that you want and add or redefine entries as shown below
        ingestion:
          <<: {{config_dict.ingestion}}
          pattern: 'base_path/table_folder/.*.gz'
#}

{% macro SYSTEM_A__ingestion_config() %}
{%- set yaml_str -%}
landing_table:
    db_name:     "{{ get_SYSTEM_A_inout_db_name() }}"
    schema_name: "{{ get_SYSTEM_A_inout_schema_name() }}"
    table_name:  LANDING_TABLE_NAME
    columns:        #-- Define the landing table columns and eventually its type (& constraints - same syntax as in Create Table).
        - COLUMN1   # -- NO data type => TEXT
        - COLUMN2: TEXT

        # -- Sample columns with data type definitions
        # - src_data: variant     # -- a Variant column can hold all the parsed payload
        # - col1: TEXT
        # - col2
        # - some_payload_timestamp: TIMESTAMP_NTZ
        # - partition_date: DATE

ingestion:
    stage_name: "{{ get_SYSTEM_A_inout_stage_name() }}"
    # pattern: 'base_path/table_folder/.*.gz'
    # format_name:

    # -- Nothing needed for CSV, as the number of fields is taken from the list of columns.
    # -- Field definition NEEDED FOR SEMI STRUCTURED inputs - Map the variant internal columns to desired explicit columns
    # -- field_expressions:  
    # --     - src_data: $1
    # --     - col1: $1:col1::TEXT
    # --     - col2: $1:col2::TEXT
    # --     #-- calculated column for partitioning
    # --     - partition_date: $1:some_payload_timestamp::DATE

{%- endset -%}

{%- set config_dict = fromyaml(yaml_str) -%}
{% do return(config_dict) %}

{% endmacro %}

