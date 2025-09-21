SELECT
    ACCOUNT_ALIAS,
    YEAR,
    MONTH_NAME,
    CALENDAR_DATE,
    round(SUM(POSITION_VALUE_BASE), 2) AS total_portfolio_value,
    round(SUM(COST_BASIS_BASE_APPROX), 2) AS total_portfolio_cost_basis,
    round(SUM(GAIN_BASE), 2) AS total_portfolio_gain

FROM {{ ref('RPT_POSITIONS_DAILY_VALUES') }}

WHERE CALENDAR_DATE = LAST_DAY_OF_MONTH
  --and YEAR = 2024 AND ASSET_CLASS = 'STK'

GROUP BY 1, 2, 3,4
ORDER BY 1, 4