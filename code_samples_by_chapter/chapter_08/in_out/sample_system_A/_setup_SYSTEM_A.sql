{% macro get_SYSTEM_A_inout_cfg() %}
{% set inout_cfg %}
inout:
    database:   "{{ target.database }}"     #-- Leave empty or remove to use the DB for the env (same as target.database)
    schema:     LAND_SYSTEM_A
    comment:    "'Landing table schema for files from SYSTEM_A.'"       # -- Note the single quotes inside the double quotes!

file_format:
    name: SYSTEM_A_CSV__FF
    definition:
        TYPE: "'CSV'" 
        SKIP_HEADER: 1              #-- Set to 0 when we have more than one in each file
        FIELD_DELIMITER: "','"
        FIELD_OPTIONALLY_ENCLOSED_BY: "'\\042'"     #-- '\042' double quote
        COMPRESSION: "'AUTO'" 
        ERROR_ON_COLUMN_COUNT_MISMATCH: TRUE 
        # EMPTY_FIELD_AS_NULL: TRUE                 # -- Load null for empty fields
        # NULL_IF: ('', '\\N')                      # -- Load null if empty string or newline
        # ENCODING: "'ISO-8859-1'"                  # -- For nordic languages

stage:
    name: SYSTEM_A__STAGE
    definition:
        DIRECTORY: ( ENABLE = true )
        COMMENT: "'Stage for files from SYSTEM_A.'"
        FILE_FORMAT:                                #-- leave empty (or remove) to use the FF from the stage
        # -- Add Storage integration and URL for stages on external files --
        # STORAGE_INTEGRATION: <storage integration name>
        # URL: "'s3://some_bucket/some_folder/'"

{% endset %}

{{ return(fromyaml(inout_cfg)) }}
{% endmacro %}

/* DEFINE / RUN SQL COMMANDS to set up the inout: schema, file format and stage */
{%  macro run_SYSTEM_A_inout_setup() %}
    {{ log('Setting up inout table schema, file format and stage for schema: '  ~ get_SYSTEM_A_inout_schema_name() ~ ' .', true) }}
    {% do run_query(get_SYSTEM_A_inout_setup_sql()) %}
    {{ log('Setup completed for schema: '  ~ get_SYSTEM_A_inout_schema_name() ~ ' .', true) }} 
{%- endmacro %}

{%  macro get_SYSTEM_A_inout_setup_sql() %}
  {% do return(pragmatic_data.inout_setup_sql(cfg = get_SYSTEM_A_inout_cfg())) %}
{%- endmacro %}


/* DEFINE Names  */ 
{%  macro get_SYSTEM_A_inout_db_name( cfg = get_SYSTEM_A_inout_cfg() ) %}
  {% do return( cfg.inout.database  or target.database ) %}
{%- endmacro %}

{%  macro get_SYSTEM_A_inout_schema_name( cfg = get_SYSTEM_A_inout_cfg() ) %}
  {% do return( cfg.inout.schema or target.schema) %}
{%- endmacro %}

{%  macro get_SYSTEM_A_inout_csv_ff_name( cfg = get_SYSTEM_A_inout_cfg() ) %}  -- return fully qualified name
  {% do return( get_SYSTEM_A_inout_db_name() ~ '.' ~ get_SYSTEM_A_inout_schema_name() ~  '.' ~ cfg.file_format.name ) %}
{%- endmacro %}

{%  macro get_SYSTEM_A_inout_stage_name( cfg = get_SYSTEM_A_inout_cfg() ) %}    -- return fully qualified name
  {% do return( get_SYSTEM_A_inout_db_name() ~ '.' ~ get_SYSTEM_A_inout_schema_name() ~  '.' ~ cfg.stage.name ) %}
{%- endmacro %}

