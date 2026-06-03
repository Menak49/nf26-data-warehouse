import sys
import time
import os
import logging
from dotenv import load_dotenv
import snowflake.connector as snf


def init_snowflake_connexion(log) -> snf.SnowflakeConnection:
    """Create Snowflake link"""
    load_dotenv()

    # ====== Connect to Snowflake with .env info ======
    try:
        conn = snf.connect(
            user=os.getenv("user"),
            password=os.getenv("password"),
            account=os.getenv("account"),
            warehouse=os.getenv("warehouse"),
            role=os.getenv("role"),
            database=os.getenv("database"),
        )
        return conn
    except Exception as e:
        print(e)
        log.error("Connection failed, one of the .env information may be wrong")
        raise ValueError(
            "Connection failed, one of the .env information may be wrong"
        ) from e
