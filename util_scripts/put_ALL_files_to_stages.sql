/* Execute these commands on stonks project by running the command:
   SNOWSQL_PRIVATE_KEY_PASSPHRASE="..." snowsql -c stonks -f /Users/robertozagni/RobMcZag/stonks/util_scripts/put_ALL_files_to_stages.sql
*/
PUT 'file:///Users/robertozagni/Downloads/ingestion_base/open_positions/*OpenPositions*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/open_positions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/ingestion_base/CashTransactions/*CashTransactions*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/cash_transactions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/ingestion_base/Trades/*Trades*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/trades/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/ingestion_base/Transfers/Transfers*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/transfers/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
