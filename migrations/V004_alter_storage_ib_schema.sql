{% macro V004_alter_storage_ib_schema(
        database = target.database,
        schema_prefix = target.schema
) -%}

ALTER SCHEMA IF EXISTS  {{database}}.{{schema_prefix}}_storage_ib
    RENAME TO {{database}}.{{schema_prefix}}_ib_storage;

{%- endmacro %}
