# Import python packages
# streamlit_app.py
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Set page title
st.set_page_config(layout="wide")
st.title("My Current Portfolio Holdings")

# Get the current Snowflake session
session = get_active_session()

# Query our dbt model and convert to a Pandas DataFrame
target_table = "STONKS_DEV.RZ_APP_CURRENT_POSITIONS.RPT_POSITIONS_CURRENT_VALUES"
portfolio_df = session.table(target_table).to_pandas()

if not portfolio_df.empty:
    st.dataframe(
        portfolio_df,
        column_config={
            # Rename, format, and style columns for better readability
            "ACCOUNT_ALIAS": "Account",
            "SECURITY_SYMBOL": st.column_config.TextColumn("Symbol"),
            "SECURITY_NAME": "Security Name",
            "ASSET_CLASS": "Asset Class",
            "QUANTITY": st.column_config.NumberColumn("Quantity", format="%.2f"),
            "MARKET_VALUE_BASE": st.column_config.NumberColumn(
                "Market Value (Base)", format="%.2f"
            ),
            "COST_BASIS_BASE": st.column_config.NumberColumn(
                "Cost Basis (Base)", format="%.2f"
            ),
            "GAIN_BASE": st.column_config.NumberColumn(
                "Unrealized P&L (Base)",
                format="%.2f",
                help="The unrealized profit or loss in the portfolio's base currency."
            ),
            "POSITION_VALUE_DATE": st.column_config.DateColumn(
                "As Of Date", format="YYYY-MM-DD"
            ),

            # Hide columns that are not relevant for this high-level view
            "SIDE": None,
            "TRADING_CURRENCY": None,
            "MARKET_VALUE_FX": None,
            "COST_BASIS_FX": None,
            "GAIN_FX": None,
            "GAIN_PCT_FX": None,
            "FX_RATE_TO_BASE": None,
            "MARKET_PRICE_FX": None
        },
        hide_index=True,
    )
else:
    st.write("No current positions found.")