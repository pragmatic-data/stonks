PUT 'file:///<path>/open_positions/*OpenPositions*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/open_positions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///<path>/cash_transactions/*CashTransactions*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/cash_transactions/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
PUT 'file:///<path>/Trades/*Trades*.csv'
    @STONKS_DEV.LAND_IB.IB_CSV__STAGE/trades/
    AUTO_COMPRESS = TRUE
    OVERWRITE = FALSE
;
