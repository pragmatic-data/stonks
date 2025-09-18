with
portfolio_daily_value_dim as (
    select distinct
        portfolio_hkey
        , broker_code
        , client_account_code
        , account_alias
        , case when broker_code = 'IB' then 'Interactive Brokers'
        end as broker_name
    from {{ ref('TS_IB_REPORTED_POSITIONS_DAILY_VALUES') }}
)

, portfolio_position_stats as (
    select
        portfolio_hkey
        , count(distinct position_hkey) as positions_in_portfolio
        , max(effectivity_date) as last_position_change
    from {{ ref('VER_IB_POSITIONS_CALCULATED') }}
    where is_current and side != 'Closed'
    group by portfolio_hkey
)

, portfolio_daily_value_stats as (
    select
        portfolio_hkey
        , round(sum(position_value), 2) as portfolio_value
        , round(sum(cost_basis_money), 2) as portfolio_cost_basis
    from {{ ref('TS_IB_REPORTED_POSITIONS_DAILY_VALUES') }} as v
    where VALUE_IS_CURRENT and side != 'Closed'
    group by portfolio_hkey
)

select 
    p.*
    , ps.* exclude(portfolio_hkey)
    , vs.* exclude(portfolio_hkey)
from portfolio_daily_value_dim as p
inner join portfolio_daily_value_stats as vs
    on p.portfolio_hkey = vs.portfolio_hkey
inner join portfolio_position_stats as ps
    on p.portfolio_hkey = ps.portfolio_hkey
