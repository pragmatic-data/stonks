select 
    * rename (date_day as date)
from {{ ref('MDD_DATE_CALENDAR') }}
