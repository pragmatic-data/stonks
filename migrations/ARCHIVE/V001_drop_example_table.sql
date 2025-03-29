{% macro V001_drop_example_table(
        database = target.database,
        schema_prefix = target.schema
) -%}

DROP TABLE IF EXISTS  {{database}}.{{schema_prefix}}_EXAMPLE.my_first_dbt_model ;

{%- endmacro %}
