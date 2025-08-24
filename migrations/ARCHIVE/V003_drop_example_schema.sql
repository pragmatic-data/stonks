{% macro V003_drop_example_schema(
        database = target.database,
        schema_prefix = target.schema
) -%}

DROP SCHEMA IF EXISTS  {{database}}.{{schema_prefix}}_EXAMPLE;

{%- endmacro %}
