{%  macro export__generic_two_column_table__YAML() %}

{% set table_ref = ref('GENERIC_TWO_COLUMN_TABLE') %}    
{% set yaml_config %}
export_path_cfg: 
    export_path_base:           SYSTEM_A/generic/
    export_path_date_part:
    export_file_name_prefix:

stage_cfg:
    format_name: "{{ get_SYSTEM_A_inout_csv_ff_name() }}"
    stage_name:  "{{ get_SYSTEM_A_inout_stage_name() }}"

flags:
    only_one_export:                true
    remove_folder_before_export:    true
    create_dummy_file:              true
{% endset %}

{%- set cfg_dict = fromyaml(yaml_config) -%}

{% do pragmatic_data.run_table_export(
    table_ref           = table_ref,
    export_path_cfg     = cfg_dict.export_path_cfg,
    stage_cfg           = cfg_dict.stage_cfg,
    flags               = cfg_dict.flags
) %}
    
{% endmacro %}