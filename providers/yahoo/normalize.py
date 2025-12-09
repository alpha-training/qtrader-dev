import pandas as pd

def normalize_history(df: pd.DataFrame, symbol: str) -> pd.DataFrame:
    if df.empty: return df

    # Flatten index and map columns to kdb+ standard (lowercase) in one pass
    df = df.reset_index().rename(columns={
        "Date": "time", "Datetime": "time", 
        "Open": "open", "High": "high", "Low": "low", "Close": "close", "Volume": "volume"
    })
    
    df["sym"] = symbol
    
    # Return intersection of expected schema and actual columns
    cols = [c for c in ["time", "sym", "open", "high", "low", "close", "volume"] if c in df.columns]
    return df[cols]