/**
 *  We are naming this model with a REFH prefix for two reasons:
 *  1. to signal that it is compliant with the expectations from an HIST model
 *     (HKeys, metadata - record source, file_update_ts, ingestion and hist load TS)
 *  2. to signal that here there is all the history we can have,
 *     even if there is not much as TX are immutable.
 */

WITH
corp_act_all as (
  SELECT * FROM {{ ref('INT_IB_CORPORATE_ACTIONS__MANUAL') }}  
  UNION ALL
  SELECT * FROM {{ ref('INT_IB_CORPORATE_ACTIONS__RULE_BASED') }}  
)
SELECT * FROM corp_act_all
ORDER BY account_alias, security_symbol, effectivity_date, SECURITY_CODE
