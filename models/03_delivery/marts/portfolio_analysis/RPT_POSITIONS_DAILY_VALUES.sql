WITH 

calendar as (
    select * RENAME (DATE_DAY as CALENDAR_DATE)
    from {{ ref('MDD_DATE_CALENDAR') }}
    where FIRST_DAY_OF_MONTH <= DATE_TRUNC('month', current_date())
)
, position_values as (
    select *
    from {{ ref('TS_IB_REPORTED_POSITIONS_DAILY_VALUES') }}
)
SELECT
    v.ACCOUNT_ALIAS
    , v.SECURITY_SYMBOL
    , v.SECURITY_NAME
    , v.ASSET_CLASS

    , c.CALENDAR_DATE

    -- position
    , v.POSITION_CHANGE_DATE
    , v.QUANTITY
    , v.SIDE
    , v.TRADING_CURRENCY

    -- position valuation
    , v.POSITION_VALUE_DATE
    -- , v.EFFECTIVITY_DATE     -- same as v.POSITION_VALUE_DATE
    , v.ADJUSTED_EFFECTIVITY_DATE
    , v.COST_BASIS_PRICE
    , v.MARK_PRICE
    , v.COST_BASIS_MONEY
    , v.POSITION_VALUE
    , v.GAIN_PCT_FX
    , v.PERCENT_OF_NAV
    , round(v.FIFO_PNL_UNREALIZED, 2) as FIFO_PNL_UNREALIZED

    -- CALCOLI sul NAV
    , round(v.position_value / v.percent_of_nav * 100, 2) as approx_side_NAV
    , coalesce(avg(case when side = 'Long' then approx_side_NAV end) over (partition by v.portfolio_hkey, c.CALENDAR_DATE), 0) as avg_long_NAV
    , coalesce(avg(case when side = 'Short' then approx_side_NAV end) over (partition by v.portfolio_hkey, c.CALENDAR_DATE), 0) as avg_short_NAV
    , avg_long_NAV + avg_short_NAV as avg_net_NAV
    , avg_long_NAV - avg_short_NAV as avg_gross_NAV


    -- option fields
    , v.UNDERLYING_LISTING_EXCHANGE
    , v.UNDERLYING_SYMBOL
    , v.PUT_CALL
    , v.MULTIPLIER
    , v.STRIKE
    , v.EXPIRY

    -- values in base (at time of position value)
    , v.FX_RATE_TO_BASE
    , v.POSITION_VALUE_BASE
    , v.COST_BASIS_BASE_APPROX
    , v.GAIN_BASE

    -- Keys & codes
    , v.POSITION_VALUE_SCD_HKEY
    , v.PORTFOLIO_HKEY
    , v.POSITION_HKEY
    , v.POSITION_SCD_HKEY
    , v.SECURITY_HKEY
    , v.SECURITY_SCD_HKEY

    , v.BROKER_CODE
    , v.CLIENT_ACCOUNT_CODE
    , v.LISTING_EXCHANGE
    , v.SECURITY_CODE
    , v.UNDERLYING_SECURITY_CODE

    -- filters on date parts
    , c.DAY
    , c.DAY_NAME
    , c.MONTH
    , c.MONTH_NAME
    , c.QUARTER_NUMBER
    , c.QUARTER
    , c.YEAR
    , c.YEAR_QUARTER


    -- metadata 
    , v.RECORD_SOURCE
    , v.INGESTION_TS_UTC
    , v.HIST_LOAD_TS_UTC
    , v.POSITION_VALUE_VERSION_NUMBER
    , v.ADJUSTED_POSITION_VALUE_VALID_FROM
    , v.POSITION_VALUE_VALID_FROM
    , v.POSITION_VALUE_VALID_TO
    , v.VALUE_IS_CURRENT

    , v.POSITION_EFFECTIVITY_DATE
    , v.POSITION_INGESTION_TS_UTC
    , v.POSITION_HIST_LOAD_TS_UTC
    , v.POSITION_VERSION_COUNT
    , v.POSITION_VERSION_NUMBER
    , v.POSITION_VALID_FROM
    , v.POSITION_VALID_TO
    , v.POSITION_IS_CURRENT

    , v.SECURITY_EFFECTIVITY_DATE
    , v.SECURITY_INGESTION_TS_UTC
    , v.SECURITY_HIST_LOAD_TS_UTC
    , v.SECURITY_VERSION_COUNT
    , v.SECURITY_VERSION_NUMBER
    , v.SECURITY_VALID_FROM
    , v.SECURITY_VALID_TO
    , v.SECURITY_IS_CURRENT

FROM calendar as c
JOIN position_values as v
    ON c.CALENDAR_DATE >= v.ADJUSTED_POSITION_VALUE_VALID_FROM
    and c.CALENDAR_DATE < v.POSITION_VALUE_VALID_TO
order by ACCOUNT_ALIAS, SECURITY_SYMBOL, CALENDAR_DATE, POSITION_VALUE_DATE
