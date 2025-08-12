ls @database.schema.stage_name;

--azure://<container_name>.blob.core.windows.net/<path>/<file_name>.parquet


/* INSPECT METADATA (columns & types) from Parquet File */
select *                                                          -- show all inferred info
--SELECT '- ' || column_name                                        -- list columns for STG model "- col1"
--SELECT '- ' || column_name || ': ' || column_name  AS sql_text    -- list columns for STG model ready for rename "- col1: col1"
--SELECT '- ' || column_name || ': ' || expression  AS sql_text     -- list columns for LT ingestion " - col1: expression"
  from table( INFER_SCHEMA(
  LOCATION => '@database.schema.stage_name/'
  , FILE_FORMAT => 'database.schema.file_format_name'
  , FILES => 'file_name.parquet'
  , IGNORE_CASE => FALSE
) );

/* Select DATA from Parquet file*/
SELECT
    $1 as source_data,                              -- all the payload as a variant
    $1:NODE1 as NODE1,                              -- sub-structure, still as vaiant
    $1:COL1::TIMESTAMP_NTZ as COL1,                 -- individual column (must be cast to the desired type)

    -- Snowflake specific metadata
    METADATA$FILENAME as FROM_FILE,
    METADATA$FILE_ROW_NUMBER as FILE_ROW_NUMBER

FROM @database.schema.stage_name/
(FILE_FORMAT => 'database.schema.file_format_name', 
 PATTERN => 'file_name.parquet' )

 WHERE $1:column_XYZ ilike '%Some Value%'
 LIMIT 1000;
