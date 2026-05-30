"""Execute le sid"""

import snowflake.connector as snf
import logging
from dotenv import load_dotenv
import os
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

logging.basicConfig(
    filename="logs/install_sid.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)


def init_snowflake_connexion() -> snf.SnowflakeConnection:
    """Create Snowflake link"""
    load_dotenv()

    # ====== Get the private key for the MSA authentification ======
    path = os.getenv("PRIVATE_KEY_PATH")
    if path is None:
        raise ValueError("No PRIVATE_KEY_PATH in .env")

    with open(path, "rb") as file:
        private_key = serialization.load_pem_private_key(
            file.read(), password=None, backend=default_backend()
        )

    private_key_bytes = private_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )

    # ====== Connect to Snowflake with .env info ======
    try:
        conn = snf.connect(
            user=os.getenv("user"),
            password=os.getenv("password"),
            account=os.getenv("account"),
            warehouse=os.getenv("warehouse"),
            role=os.getenv("role"),
            private_key=private_key_bytes,
        )
        return conn
    except Exception as e:
        print(e)
        logging.error("Connection failed, one of the .env information may be wrong")
        raise ValueError(
            "Connection failed, one of the .env information may be wrong"
        ) from e


def execute_sql_file(cursor, filepath):
    """Execute sql file and print logs"""
    logging.info("Execution of %s", filepath)
    with open(filepath, "r", encoding="utf8") as f:
        sql = f.read()

    # Execute every statement (split with ;)
    for statement in sql.split(";"):
        statement = statement.strip()
        if statement:
            cursor.execute(statement)

    logging.info("%s executed successfully", filepath)


def main():
    """Apply sql files 0, 1, 2, 3, 4 to complete the seed"""
    conn = init_snowflake_connexion()
    scripts = [
        "src/sql/00_create_databases.sql",
        "src/sql/01_create_tables_stg.sql",
        "src/sql/02_create_tables_soc.sql",
        "src/sql/03_create_tables_tch.sql",
    ]

    for script in scripts:
        execute_sql_file(conn.cursor(), script)

    conn.cursor().close()
    conn.close()
    logging.info("SID install ended succefully.")


if __name__ == "__main__":
    main()
