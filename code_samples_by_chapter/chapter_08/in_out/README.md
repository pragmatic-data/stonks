# IMPORTANT NOTE
This section is copied and adapted from the integration test part of the Pragmatic Data Platform package.

# Ingestion and Export of data in Files

The suggestion is to organize ingestion and export by sample source system.

The integration tests follow this guideline and are organized in one base folder
for each sample system, containing the system set-up, and one sub-folder each for 
ingestion and export, containing macros to ingest/export the individual tables.

The suggested layout for each source system is:
```
    system_X/
      setup_system_X.sql
      export/
        export_TABLE_X1.sql
      ingest/
        ingest_TABLE_X1.sql
```


## Sample systems
To test and showcase different use cases the integration tests are based on two fictional systems:

- SYSTEM A  
  It is a more traditional system where data is exported and ingested in CSV.
  The number of files in the stages is not big, so that we can just set up a single stage 
  for all the sub-folders hosting the files for the source tables to be ingested.

- SYSTEM B
  This is a more complex system where data can be exported and ingested in multiple formats.
  The number of files in the stages is bigger, favoring the set-up of single folder stages.
