{% macro get_IB_ingestion_cfg() %}
{% set ingestion_cfg %}
landing:
    database:   "{{ target.database }}"
    schema:     LAND_IB
    comment:    "'Landing table schema for CSV files from Interactive Brokers.'"

file_format:
    name: IB_CSV__FF
    definition:
        TYPE: "'CSV'"
        FIELD_DELIMITER: "','"
        FIELD_OPTIONALLY_ENCLOSED_BY: "'\\042'"      #-- '\042' double quote
        COMPRESSION: "'AUTO'"
        ERROR_ON_COLUMN_COUNT_MISMATCH: TRUE
        EMPTY_FIELD_AS_NULL: TRUE
        NULL_IF: ('', '\\N')
        #-- SKIP_HEADER: 1              #-- Set to 0 when we have more than one in each file
        #-- ENCODING: "'ISO-8859-1'"    #-- For nordic languages

stage:
    name: IB_CSV__STAGE
    definition:
        FILE_FORMAT:
        DIRECTORY: ( ENABLE = true )
        COMMENT: "'Stage for CSV files from Interactive Brokers.'"
{% endset %}

{{ return(fromyaml(ingestion_cfg)) }}
{% endmacro %}

/* GENERATE / RUN SQL COMMANDS to set up the ingestion: schema, file format and stage */
{%  macro get_IB_ingestion_setup_sql() %}
    {% do return(pragmatic_data.inout_setup_sql(cfg = get_IB_ingestion_cfg())) %}
{%- endmacro %}

{%  macro run_IB_ingestion_setup() %}
    {{ log('Setting up landing table schema, file format and stage for schema: '  ~ get_IB_ingestion_schema_name() ~ ' .', true) }}
    {% do run_query(get_IB_ingestion_setup_sql()) %}
    {{ log('Setup completed for schema: '  ~ get_IB_ingestion_schema_name() ~ ' .', true) }}
{%- endmacro %}


/* DEFINE Names  */
{%  macro get_IB_ingestion_db_name( cfg = get_IB_ingestion_cfg() ) %}
    {% do return( cfg.landing.database or target.database) %}
{%- endmacro %}

{%  macro get_IB_ingestion_schema_name( cfg = get_IB_ingestion_cfg() ) %}
    {% do return( cfg.landing.schema or target.schema) %}
{%- endmacro %}

{%  macro get_IB_ingestion_csv_ff_name( cfg = get_IB_ingestion_cfg() ) %}  -- return fully qualified name
    {% do return( get_IB_ingestion_db_name() ~ '.' ~ get_IB_ingestion_schema_name() ~  '.' ~ cfg.file_format.name ) %}
{%- endmacro %}

{%  macro get_IB_ingestion_stage_name( cfg = get_IB_ingestion_cfg() ) %}    -- return fully qualified name
    {% do return( get_IB_ingestion_db_name() ~ '.' ~ get_IB_ingestion_schema_name() ~  '.' ~ cfg.stage.name ) %}
{%- endmacro %}
