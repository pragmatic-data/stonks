/**
 * This macro runs all the inividual macros to load the landing tables for the IB source system.
 */
{%  macro load_all_IB() %}
{{ log('*** Load the landing tables for Interactive Brokers system ***', true) }}

{{ log('**   Setting up the LANDING schema, FF and STAGE for Interactive Brokers system **', true) }}
{% do run_IB_ingestion_setup() %}

{{ log('*   load_IB_OpenPositions *', true) }}
{% do load_IB_OpenPositions() %}

{{ log('*   load_IB_CashTransactions *', true) }}
{% do load_IB_CashTransactions() %}

{{ log('*   load_IB_Trades *', true) }}
{% do load_IB_Trades() %}

{{ log('*   load_IB_Transfers *', true) }}
{% do load_IB_Transfers() %}


{{ log('*** DONE Loading the landing tables for Interactive Brokers system ***', true) }}
{%- endmacro %}