{# /*
    Calendar Weeks and Weekdays
    https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-calendar-weeks-weekdays

    The behavior of week-related functions in Snowflake is controlled by the WEEK_START and WEEK_OF_YEAR_POLICY session parameters.
-- ALTER SESSION SET WEEK_START = 1 ;      -- set week start on Monday. Default is 0 = Sunday.

    An important aspect of understanding how these parameters interact is the concept of ISO weeks.

    ISO Weeks
    As defined in the ISO 8601standard (for dates and time formats), ISO weeks always start on Monday and
    “belong” to the year that contains the Thursday of that week.

    Snowflake provides a special set of week-related date functions (and equivalent data parts)
    whose behavior is consistent with the ISO week semantics: DAYOFWEEKISO , WEEKISO , YEAROFWEEKISO.
    These functions (and date parts) disregard the session parameters (i.e. they always follow the ISO semantics).
 */ #}

{{ config(materialized='table') }}


WITH
date_spine AS (
    {{  dbt_utils.date_spine(
             datepart="day",
             start_date="'2021-01-01'::date",
             end_date="'2029-12-31'::date",
    ) }}
),

calculation as (
    SELECT
        DATE_DAY,   -- This is the name of the column that the spine provides us

        EXTRACT(day FROM date_day)::int AS day,
        EXTRACT(month FROM date_day)::int AS month,
        EXTRACT(quarter FROM date_day)::int AS quarter_number,
        EXTRACT(year FROM date_day)::int AS year,

        DAYNAME(date_day) AS day_name,
        TO_CHAR(date_day, 'MON') AS month_short_name,
        TO_CHAR(date_day, 'MMMM') AS month_name,

        TRUNC(date_day, 'week') as first_day_of_week,  -- Mon
        LAST_DAY(date_day, 'week') as last_day_of_week,  -- Mon

        TRUNC(date_day, 'month') AS first_day_of_month,
        LAST_DAY(date_day, 'month') AS last_day_of_month,

        TRUNC(date_day, 'quarter') AS first_day_of_quarter,
        LAST_DAY(date_day, 'quarter') AS last_day_of_quarter,

        TRUNC(date_day, 'year') AS first_day_of_year,
        LAST_DAY(date_day, 'year') AS last_day_of_year,

        -- The week and the year to which the week belongs to, according to ISO rules.
        DATE_PART(week, date_day) AS week_of_year,
        DATE_PART(yearofweek, date_day) AS year_of_week,

        /* Day of week =>  Mon 1 - Sun 7 // OK with WEEK_START = 0 or = 1 */
        CASE WHEN day_name = 'Sun' THEN 7 ELSE (DATE_PART(dayofweek, date_day)) END AS day_of_week,
        DATEDIFF(day, first_day_of_quarter, date_day) +1 AS day_of_quarter,
        DATEDIFF(day, first_day_of_quarter, last_day_of_quarter) +1 AS days_in_quarter,
        DATE_PART(dayofyear, date_day) AS day_of_year,
        DATEDIFF(day, first_day_of_year, last_day_of_year) +1 AS days_in_year,

        ('Q' || quarter_number) AS quarter,
        (year || '-Q' || quarter_number) AS year_quarter

        /* ** HOLIDAYS ** 
         * You could add a few common holidays with a CASE statement, but that is very limited.
         * Here we prefer to keep it simple and just have the base calendar.
         * 
         * A better approach is to create a separate CSV with the holidays you want to add. 
         * You can list there the date, the holiday name and other attributes like work time, flag or religious rules/info.
         * You can also have multiple holiday files, like one for each exchange/country you care.
         * You join on them based on the date to add the relevant columns to your "operational" calendar.
         * 
         * is_holiday - It is often useful to cook up a single bolean "is_holiday" column
         * that takes into consideration all your rules about when you want to call a day a holiday day or not.
         * This is simple in a single country, not so immediate across countries or exchanges and 
         * it is a great example of business rule that you have to agree upon or read from some policy.
         * Note that this column can be in a separate table/model along with the date (PK) to allow for 
         * multiple different implementations to be used along with the same main calendar table.
         */

    FROM date_spine
)
SELECT * FROM calculation
