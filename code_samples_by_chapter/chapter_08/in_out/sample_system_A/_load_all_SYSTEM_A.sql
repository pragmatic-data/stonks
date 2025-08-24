/**
 * This macro runs the setup and all individual ingestion macros
 * to load the landing tables for the XXX source system.
 */
 */
{%  macro load_all_SYSTEM_A() %}
{{ log('*** Load the landing tables for SYSTEM_A system ***', true) }}

{{ log('**   Setting up the LANDING schema, FF and STAGE for SYSTEM_A system **', true) }}
{% do run_SYSTEM_A_inout_setup() %}

{{ log('*   ingest__generic_two_column_table__YAML *', true) }}
{% do ingest__generic_two_column_table__YAML() %}

{# ** add here a call to all other ingestion macro that you want to run #}

{{ log('*** DONE Loading the landing tables for SYSTEM_A system ***', true) }}
{%- endmacro %}