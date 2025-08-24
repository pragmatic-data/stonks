{# /*  ** Potential ways to declare the source table **
    model: "{{ ref('TABLE_NAME') }}"                  #-- model in this project
    model: "{{ ref('dbt project', 'TABLE_NAME') }}"   #-- model in another project (dbt Mesh)
    model: "{{ source('source', 'TABLE_NAME') }}"     #-- model from a source declared in this project
*/ #} 

{{ config( enabled=false) }}    -- !!! Remove this LINE to enable the model. Model disabled to avoid compilation errors

{# The model to read from, using a ref() or source() function. See above for how to produce it correctly. #}
{%- set source_model = source('SYSTEM_ABC', 'TABLE_ONE') %} 

{%- set configuration -%}
source:
    columns: 
        include_all: true       #-- True enables using eclude / replace / rename lists // false does not include the * operator
        exclude_columns:        #-- A simple list of columns to exclude
            - e1
            - e2
            - e3
        replace_columns:        #-- A list of columns to replace, in the form - input_column_name: sql_expression 
            - col1: exp1
            - col2: exp2
            - col3: exp3
        rename_columns:         #-- A list of columns to rename, in the form - new_column_name: input_column_name
            - new1: old1
            - new2: old2
            - new3: old3
    where: "SOME_COL != 'SomeValue'"       #-- Any SQL predicate for a WHERE clause (no WHERE keyword)

calculated_columns:
    - OLD_COL123                      #-- old column passed over without any change
    - NEW_COL1: OLD_COL1::date        #-- casting and renaming
    - NEW_COL2: LEFT(OLD_COL1, 4)     #-- general SQL expression on old columns
    - NEW_COL3: NEW_COL2::integer     #-- general SQL expression on preceding new columns

    #-- metadata from ingestion macro
    - RECORD_SOURCE: FROM_FILE
    - FILE_ROW_NUMBER: FILE_ROW_NUMBER
    - FILE_LAST_MODIFIED_TS_UTC: FILE_LAST_MODIFIED_TS_UTC
    - INGESTION_TS_UTC: INGESTION_TS_UTC

default_records: 
    - not_provided:    #-- default record 1, the text "not_provided" is not used
        - COLUMN_1: "'-1'"                              #-- String literals either as "'string'" or '!string'
        - COLUMN_2: '!NOT Provided (optional)'          #-- String literals either as "'string'" or '!string'
        - COLUMN_3: '!System.DefaultRecord'
        - COLUMN_4: "'{{ run_started_at }}'::TIMESTAMP_NTZ"
    - missing:          #-- default record 2
        - COLUMN_1: "'-2'"                              #-- String literals either as "'string'" or '!string'
        - COLUMN_2: '!Missing (required data)'          #-- String literals either as "'string'" or '!string'
        - COLUMN_3: '!System.DefaultRecord'
        - COLUMN_4: "'{{ run_started_at }}'::TIMESTAMP_NTZ"

hashed_columns: 
    ENTITY_1_HK:
        - ENTITY_1_CODE
    ENTITY_X_HK:
        - ENTITY_1_CODE
        - ENTITY_2_CODE
        - ENTITY_3_CODE
        - WEAK_KEY_COL

    ENTITY_1_HD:
        - ENTITY_1_CODE
        - OLD_COL1
        - OLD_COL2
        - OLD_COL3
        - NEW_COL1
        - NEW_COL2

remove_duplicates: 
    partition_by:
        - ENTITY_1_HK
        - INGESTION_TS_UTC
    order_by:
        - RECORD_SOURCE desc                #-- FROM_FILE useful if file path has extraction date
        - FILE_LAST_MODIFIED_TS_UTC desc    #-- When the file was written in the stage
        - FILE_ROW_NUMBER asc               #-- Position in the file, for dupes in the same file

{%- endset -%}


{%- set cfg = fromyaml(configuration) -%}

{{- pragmatic_data.stage(
    source_model            = source_model,
    source                  = cfg['source'],
    calculated_columns      = cfg['calculated_columns'],
    hashed_columns          = cfg['hashed_columns'],
    remove_duplicates       = cfg['remove_duplicates'],
) }}
