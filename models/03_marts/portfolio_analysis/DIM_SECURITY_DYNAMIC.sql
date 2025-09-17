{% set configuration %}
fact_defs:
  - 'model': 'TS_IB_REPORTED_POSITIONS_DAILY_VALUES' 
    'key': 'SECURITY_HKEY'
  - 'model': 'AGG_IB_DIVIDENDS' 
    'key': 'SECURITY_HKEY'
{% endset %}
{%- set cfg = fromyaml(configuration) -%}

{{ pragmatic_data.self_completing_dimension(
    dim_rel = ref('REFH_IB_SECURITIES'),
    dim_key_column  = 'SECURITY_HKEY',
    dim_default_key_value = '-1',
    ref_columns_to_exclude = [],

    fact_defs = cfg.fact_defs
) }}
