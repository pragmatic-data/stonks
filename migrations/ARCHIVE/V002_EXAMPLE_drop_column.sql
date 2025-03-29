{% macro V002_drop_example_column() -%}

{#%- set model = ref('REF_GROUP_CUSTOMER') %#}
{%- set col = 'XXXXXX' %}

{%- if coulmn_exists(model, col) %}

ALTER TABLE {{ model }}
DROP COLUMN {{ col }};

{%- else %}

SELECT 1;

{%- endif %}

{%- endmacro %}
