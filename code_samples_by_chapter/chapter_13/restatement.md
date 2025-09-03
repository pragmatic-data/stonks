# Data restatement

In this folder we provide an example of restating (changing) two dividend rows, 
that would be immutable transactions, to fix an error in the data that we received (wrong Settle Date).

We have two alternatives to fix the data: reverse or restate the bad data.
The major difference between the two methods is what you will see in the end:
- with the reversal you will see the old, bad data, the TXs that reverse it and the new, good ones. Total 6 rows.
- with the reststement the old data will be only in the history and in your dividend report you will only find the right data. Total 2 rows.

What do they entail:
- Method 1 (**Reversal**): 
  We would add two TX in a new date to reverse the two wrong TXs and add two more on th esame new date with the right value.
  This will add 4 immutable TXs (all with new IDs). Nothing else to do. 
  This is how the broker also fixes their mistakes, and the suggested way if you care about the highest level of auditing. 
  It takes a bit more of effort to correctly produce the 4 TXs with a new ID and all, 
  even if you can start from a copy of the bad TX to reverse.
  
- Method 2 (**Restatement**): 
  We would add two TX that will RESTATE the two wrong TX, creating a second version of the same two TXs.
  We will overwrite a material error with a new version, making the transactions mutable, but our macros handle it very well.
  In practice we put a copy of the two TXs in a new CSV and edit what we want to fix.
  
  This is relies on the correct setup of the timelines in our macros and an update of some tests.
  Things we need in place for restatement to work:
  - Update the tests on the HIST model to accept restatements by adding a where clause to allow multiple rows with "restate" in the RECORD_SOURCE.  
    We are effectively giving up the immutability of the transactions, introducing versions, even if only the ones we introduce as restatement
    in controlled data files.
  - Need to sort versions (VER model) on REPORT_DATE and not on EFFECTIVIE_DATE (that is the Settle date).
    Our business timeline is expressed by the REPORT_DATE. Before anything would work as each key only had one version.
  - Need to add the expression `AND bt.IS_CURRENT` to the filter row in the REFH model for dividends. 
    This is needed to keep only the current version of each TX. Before we already had only one (and tested for it).

