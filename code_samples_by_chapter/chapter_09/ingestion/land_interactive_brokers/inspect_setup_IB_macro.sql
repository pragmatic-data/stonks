/**
 * To inspect the the setup macro you can just compile this model.
 *
 * In general to see the code geenrated by macro producing code output (not logs) you do:
 * 1. create a new empty dbt model with the plus on the top right (no need to save or name it)
 * 2. call the macro to inspect in a print block {{...}} , like the code below. Remember the parenthesis at the end "()"
 * 3. compile the model, do not run it. 
 *
 * Note that if you compile a macro with side effects (that executes SQL code), like the run_... macro for the setup, 
 * dbt will run the code inside the macro to print out the result, in practice executing the SQL and producing the side effects.
 * This is not the ideal way to run such macro, as you will lose and output that is logged to the console, 
 * use the dbt run-operation command to execute macros properly.
 */

{{ get_IB_ingestion_setup_sql() }}