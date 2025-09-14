/**
 *  We are naming this model with a REF prefix because it only contains 
 *  the latest version of each corporate action transaction, not their full history.
 *  This is common with facts and events when you do aggregations and calculations, 
 *  as you want to account for event each only once.
 *
 *  That said, please not that the model is compliant with the expectations from an HIST model
 *  (HKeys, metadata - record source, file_update_ts, ingestion and hist load TS)
 */

WITH
corp_act_all as (
  SELECT * FROM {{ ref('INT_IB_CORPORATE_ACTIONS__MANUAL') }}  
  UNION ALL
  SELECT * FROM {{ ref('INT_IB_CORPORATE_ACTIONS__RULE_BASED') }}  
)
SELECT * FROM corp_act_all
ORDER BY account_alias, security_symbol, effectivity_date, SECURITY_CODE
