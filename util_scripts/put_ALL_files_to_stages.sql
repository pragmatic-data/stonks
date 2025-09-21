/* Execute these commands on stonks project by running the command:
   SNOWSQL_PRIVATE_KEY_PASSPHRASE="..." snowsql -c stonks -f /Users/robertozagni/RobMcZag/stonks/util_scripts/put_ALL_files_to_stages.sql
*/

/* DEV */
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/open_positions/*OpenPositions*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/open_positions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/cash_transactions/*CashTransactions*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/cash_transactions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/trades/*Trades*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/trades/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/transfers/Transfers*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/transfers/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;

/* QA */
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/open_positions/*OpenPositions*.csv'
    @STONKS_QA.LAND_IB.IB_CSV__STAGE/open_positions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/cash_transactions/*CashTransactions*.csv'
    @STONKS_QA.LAND_IB.IB_CSV__STAGE/cash_transactions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/trades/*Trades*.csv'
    @STONKS_QA.LAND_IB.IB_CSV__STAGE/trades/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/transfers/Transfers*.csv'
    @STONKS_QA.LAND_IB.IB_CSV__STAGE/transfers/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;

/* PROD */
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/open_positions/*OpenPositions*.csv'
    @STONKS_PROD.LAND_IB.IB_CSV__STAGE/open_positions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/cash_transactions/*CashTransactions*.csv'
    @STONKS_PROD.LAND_IB.IB_CSV__STAGE/cash_transactions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/trades/*Trades*.csv'
    @STONKS_PROD.LAND_IB.IB_CSV__STAGE/trades/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///Users/robertozagni/Downloads/sample_IB_files/transfers/Transfers*.csv'
    @STONKS_PROD.LAND_IB.IB_CSV__STAGE/transfers/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;