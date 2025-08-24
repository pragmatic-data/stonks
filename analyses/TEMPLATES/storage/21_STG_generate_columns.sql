/**
  * Generate the list of the columns in the Landing table (or external table)
  * in a way that it is easy to use them for the calculated_columns dictionary
  * as shown in the following example

calculated_columns:
    - OLD_COL123                      -- unchanged column, preferred way, it makes clear the colum stays the same
    - OLD_COL123: OLD_COL123          -- unchanged column, OK, but not so readable (the ": OLD_COL123" part is useless complication)
    - NEW_COL1: OLD_COL1::date        -- casting and renaming
    - NEW_COL2: LEFT(OLD_COL1, 4)     -- general SQL expression on old columns
    - NEW_COL3: NEW_COL2::integer     -- general SQL expression on preceding new columns
  */

{#%- set model = ref('dbt_project', 'TABLE_NAME') %#}   -- ref to access another dbt model, eventually with dbt mesh in another project.
{#%- set model = source('IB', 'TRADES') %#}               -- source to access a table not being a dbt model (LTs are not dbt models!)

SELECT 
    '    - ' || COLUMN_NAME || ': '|| COLUMN_NAME || ' -- ' || DATA_TYPE as calculated_columns_text_with_types
--    '    - ' || COLUMN_NAME || ': '|| COLUMN_NAME as calculated_columns_text
--    '- ' || COLUMN_NAME  as hdiff_text (better if run on the first version of the STG model, instead of the LT)

FROM {{model.database}}.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = '{{model.schema | upper}}'
 and TABLE_NAME = '{{model.identifier | upper}}'
ORDER BY ORDINAL_POSITION