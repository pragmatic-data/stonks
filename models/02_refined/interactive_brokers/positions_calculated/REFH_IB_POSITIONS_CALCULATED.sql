WITH RECURSIVE
sorted_transactions as (
    SELECT 
        *,

        row_number() OVER(partition by POSITION_HKEY    
                          order by EFFECTIVITY_DATE, RECORD_SOURCE, FILE_ROW_NUMBER)
        as TX_ORDER_IN_POSITION,
        
        count(*) OVER(partition by POSITION_HKEY) 
        as TX_COUNT_IN_POSITION

    FROM {{ ref('REF_IB_POSITIONS_TRANSACTIONS') }}
)

, position_calculation as (
    SELECT
        t.* EXCLUDE(COST_BASIS_FX)
            RENAME(QUANTITY as POSITION_QUANTITY_CHANGE)

        , t.QUANTITY as POSITION_QUANTITY     -- Q>0 add/long // Q<0 remove/short
        , CASE 
            WHEN POSITION_QUANTITY > 0 THEN 'Long'
            WHEN POSITION_QUANTITY = 0 THEN 'Closed'
            WHEN POSITION_QUANTITY < 0 THEN 'Short'
          END as SIDE

        , t.COST_BASIS_FX   as COST_BASIS_FX
        , t.COST_BASIS_FX * t.FX_RATE_TO_BASE as COST_BASIS_BASE
        , t.COST_BASIS_FX   as COST_BASIS_CHANGE_FX

    FROM sorted_transactions t
    WHERE TX_ORDER_IN_POSITION = 1

    UNION ALL

    SELECT
        t.* EXCLUDE(COST_BASIS_FX)
            RENAME(QUANTITY as POSITION_QUANTITY_CHANGE)

        , c.POSITION_QUANTITY + t.QUANTITY as NEW_POSITION_QUANTITY

        , CASE 
            WHEN NEW_POSITION_QUANTITY = 0 THEN 'Closed'
            WHEN NEW_POSITION_QUANTITY > 0 THEN 'Long'             -- WHEN c.SIDE = 'Closed' and NEW_POSITION_QUANTITY > 0 THEN 'Long'
            WHEN NEW_POSITION_QUANTITY < 0 THEN 'Short'            -- WHEN c.SIDE = 'Closed' and NEW_POSITION_QUANTITY < 0 THEN 'Short'
            ELSE c.SIDE
          END as NEW_SIDE

        , CASE
            WHEN NEW_SIDE = 'Closed' THEN 0 
            WHEN (NEW_SIDE = 'Long' and t.QUANTITY > 0) OR (NEW_SIDE = 'Short' and t.QUANTITY < 0)  -- open or increase position
                THEN c.COST_BASIS_FX + t.COST_BASIS_FX
            ELSE c.COST_BASIS_FX / c.POSITION_QUANTITY * NEW_POSITION_QUANTITY      -- close or reduce position
          END as NEW_COST_BASIS_FX

        , CASE
            WHEN NEW_SIDE = 'Closed' THEN 0 
            WHEN (NEW_SIDE = 'Long' and t.QUANTITY > 0) OR (NEW_SIDE = 'Short' and t.QUANTITY < 0)
                THEN c.COST_BASIS_BASE + t.COST_BASIS_FX * t.FX_RATE_TO_BASE
            ELSE c.COST_BASIS_BASE / c.POSITION_QUANTITY * NEW_POSITION_QUANTITY
          END as NEW_COST_BASIS_BASE

        , NEW_COST_BASIS_FX - c.COST_BASIS_FX   as COST_BASIS_CHANGE_FX

    FROM position_calculation as c
    JOIN sorted_transactions as t
        ON (t.POSITION_HKEY = c.POSITION_HKEY 
        and t.TX_ORDER_IN_POSITION = c.TX_ORDER_IN_POSITION + 1 )
)

SELECT * 
    , TX_ORDER_IN_POSITION || '-' || POSITION_HKEY::text as POSITION_CALCULATED_HDIFF
    {#  
        ** NOTE on the POSITION_CALCULATED_HDIFF column
        *  To build the VER model on top of the REFH we need to pass an HDIFF column 
        *  that distinguishes between different versions of the entity.
        *  Given how we build the POSITIONS in this model the TX_ORDER_IN_POSITION column 
        *  perfectly fits the bill and it is as simple and efficient as we can ask.
        *  
        *  We could directly use the TX_ORDER_IN_POSITION column in the VER model,
        *  renaming it here to have a proper HDIFF name is for clarity, maybe an overkill 
        *  to satisfy the LSP => avoid questions from the readers of the VER model.
        *  
        *  Anyway this is a good opportunity to show two alternative ways to calculate HDIFFs in models
        *  1. by providing a list of culumn names 
        *  2. by putting the list of columns in a YAML file as a config for this model
        *     and referencing it here by using the config.get() function
    , {{ pragmatic_data.pdp_hash(['BROKER_CODE', 'CLIENT_ACCOUNT_CODE', 'LISTING_EXCHANGE', 'SECURITY_CODE', 'EFFECTIVITY_DATE', 'TRANSACTION_ID', 'TX_ORDER_IN_POSITION']) }} as POSITION_CALCULATED_HDIFF
    , {{ pragmatic_data.pdp_hash(config.get('position_hdiff_columns')) }} as POSITION_CALCULATED_HDIFF_CFG    -- using the column definition in the YAML file 
    #}
FROM position_calculation
order by CLIENT_ACCOUNT_CODE, SECURITY_SYMBOL, SECURITY_CODE, TX_ORDER_IN_POSITION
