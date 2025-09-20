{% set configuration %}
source_models:
    - VER_IB_ALL_POSITIONS
    - REF_IB_POSITIONS_TRANSACTIONS
    - VER_IB_CASH_TRANSACTIONS
{% endset %}
{%- set cfg = fromyaml(configuration) -%}

with
{% for model in cfg.source_models -%}
portfolios__{{model}} as (
    select
        portfolio_hkey

        , broker_code
        , client_account_code

        , account_alias
        , case when broker_code = 'IB' then 'Interactive Brokers'
        end as broker_name
        , RECORD_SOURCE
        , EFFECTIVITY_DATE
        , INGESTION_TS_UTC
        , HIST_LOAD_TS_UTC
    from {{ ref(model) }}
    qualify row_number() over (
        partition by portfolio_hkey 
        order by EFFECTIVITY_DATE, INGESTION_TS_UTC, HIST_LOAD_TS_UTC
    ) = 1
)
{% if not loop.last %}, {% endif -%}
{%- endfor %}

, all_portfolios as (
{%- for model in cfg.source_models %}
    select * from portfolios__{{model}}
{% if not loop.last %}    UNION{% endif %}
{%- endfor -%}
)

select * 
from all_portfolios
qualify row_number() over (
    partition by portfolio_hkey 
    order by EFFECTIVITY_DATE, INGESTION_TS_UTC, HIST_LOAD_TS_UTC
) = 1
