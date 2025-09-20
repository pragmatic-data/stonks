with
portfolio_base_dim as (
    select *
    from {{ ref('REF_IB_PORTFOLIOS') }}
)

, portfolio_position_stats as (
    select
        portfolio_hkey
        , count(distinct position_hkey) as positions_in_portfolio
        , min(effectivity_date) as first_activity_date
        , max(effectivity_date) as last_position_change
        , datediff('day', last_position_change, CURRENT_DATE()) <= 30 AS is_active_last_30_days
        , datediff('day', last_position_change, CURRENT_DATE()) <= 360 AS is_active_last_360_days
    from {{ ref('VER_IB_POSITIONS_CALCULATED') }}
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
from portfolio_base_dim as p
inner join portfolio_daily_value_stats as vs
    on p.portfolio_hkey = vs.portfolio_hkey
inner join portfolio_position_stats as ps
    on p.portfolio_hkey = ps.portfolio_hkey
