"""Execute le sid"""

import snowflake.connector
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

load_dotenv()

# Chargement de la clé privée
if os.getenv("PRIVATE_KEY_PATH") is None:
    raise ValueError("No PRIVATE_KEY_PATH")

path = os.getenv("PRIVATE_KEY_PATH")
path_str: str = path if not path is None else ""
with open(path_str, "rb") as file:
    private_key = serialization.load_pem_private_key(
        file.read(), password=None, backend=default_backend()
    )

private_key_bytes = private_key.private_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption(),
)

# Connexion à Snowflake
conn = snowflake.connector.connect(
    user=os.getenv("user"),
    password=os.getenv("password"),
    account=os.getenv("account"),
    warehouse=os.getenv("warehouse"),
    role=os.getenv("role"),
    private_key=private_key_bytes,
)

cursor = conn.cursor()


def execute_sql_file(filepath):
    """Execute un fichier sql"""
    logging.info("Exécution de %s", filepath)
    with open(filepath, "r", encoding="utf8") as f:
        sql = f.read()
    # Exécute chaque statement séparé par un ;
    for statement in sql.split(";"):
        statement = statement.strip()
        if statement:
            cursor.execute(statement)
    logging.info("%s exécuté avec succès", filepath)


# Ordre d'exécution
scripts = [
    "src/sql/00_create_databases.sql",
    "src/sql/01_create_tables_stg.sql",
    "src/sql/02_create_tables_soc.sql",
    "src/sql/03_create_tables_tch.sql",
]

for script in scripts:
    execute_sql_file(script)

cursor.close()
conn.close()
logging.info("Installation SID terminée.")
