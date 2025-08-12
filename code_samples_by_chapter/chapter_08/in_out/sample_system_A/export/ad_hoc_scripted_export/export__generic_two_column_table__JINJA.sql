/** Sample export of a table to files in the provided stage
 * 
 * table_ref                the reference to the table to export                - NO DEFAULT
 * export_path_base         the base path where to put the exported files       - NO DEFAULT, should end with '/''
 * export_path_date_part    the date partitioning of the export path            - default is current date with '_' in place of '-'
 * export_file_name_prefix  the first part of the name of the exported files    - default is source table name plus '__'
 */
{%  macro export__generic_two_column_table__JINJA(
        table_ref                   = ref('GENERIC_TWO_COLUMN_TABLE'),
        export_path_base            = 'SYSTEM_A/generic/',

        export_path_date_part       = none,                       
        export_file_name_prefix     = none,                    
        format_name                 = get_SYSTEM_A_inout_csv_ff_name(),
        stage_name                  = get_SYSTEM_A_inout_stage_name(),
        only_one_export             = true,
        remove_folder_before_export = true,
        create_dummy_file           = true
) %}
    {% if not export_path_date_part %}
        {% set current_date = modules.datetime.datetime.now() %}
        {% set export_path_date_part = current_date.strftime('%Y-%m-%d') | replace("-", "_") -%}
    {% endif %}

    {% set export_path = export_path_base ~ export_path_date_part ~ '/' %}
    {% set stage_with_export_path = stage_name ~ '/' ~ export_path %}

    {% if not export_file_name_prefix %}
        {% set export_file_name_prefix = table_ref.identifier ~ '__' %}
    {% endif %}

    {% if only_one_export and pragmatic_data.check_dummy_exists(stage_name, export_path) %}
        {{ print('***** dummy file found in '~ stage_with_export_path) }}
        {{ print('***** not doing the export again.') }}
        {% do return(false) %}
    {% endif %}

    {% if remove_folder_before_export and execute %}
        {{ print('* Removing folder ' ~ stage_with_export_path) }}
        {% set results = run_query('REMOVE @' ~ stage_with_export_path) %}
        {{ log('*** Status - Removed: ' ~ results.columns[0].values() | length ~ ' files.', info=True) }}
    {% endif %}

    {% if execute %}        
        {{ log('* Exporting data to stage from table ' ~ table_ref ~ '.', true) }}
        {% set results = run_query(pragmatic_data.export_to_stage_sql(
            table_name          = table_ref, 
            stage_with_path     = stage_with_export_path ~ export_file_name_prefix, 
            format_name         = format_name
        ) ) %}
        {{ log('*** Exported data to stage from table ' ~ table_ref ~ '.', true) }}
        {{ log_export_results(results) }}
    {% endif %}

    {% if create_dummy_file and execute %}
        {% set results = run_query(pragmatic_data.export_dummy_file_sql(stage_with_export_path)) %}
        {{ print('*** Dummy file exported as : ' ~ pragmatic_data.get_dummy_base_name(stage_with_export_path) ~ '...') }}
    {% endif %}

    {{ print('***** DONE Extraction of Table ' ~ table_ref) }}
    {% do return(true) %}
{%- endmacro %}

{% macro log_export_results(results) %}
    {% set export_result_str %}
        {%- if results.column_names|length > 1 -%}
        Exported: {{ results.columns[0].values()[0] }} rows || {{ results.columns[1].values()[0] }}/{{ results.columns[2].values()[0] }} : input/output bytes
        {%- else -%}
        Status: {{ results.columns[0].values()[0]  }}
        {%- endif %}
    {% endset %}
    {{ print('*** ' ~ export_result_str) }}
{% endmacro %}
