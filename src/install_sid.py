"""Execute le sid"""

import sys
import time
import os
from snowflake_conn import init_snowflake_connexion
import logging

logging.basicConfig(
    filename="logs/install_sid.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
log = logging.getLogger(__name__)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SQL_DIR = os.path.join(SCRIPT_DIR, "sql")
SQL_SCRIPTS = [
    "src/sql/00_create_databases.sql",
    "src/sql/01_create_tables_stg.sql",
    "src/sql/02_create_tables_soc.sql",
    "src/sql/03_create_tables_tch.sql",
]

SNOWFLAKE_CONFIG = {"user", "password", "account", "role", "warehouse", "database"}


def execute_sql_file(cursor, filepath) -> bool:
    """Execute sql file and print logs"""
    log.info("Execution of %s", filepath)
    with open(filepath, "r", encoding="utf8") as f:
        sql = f.read()

    # Execute every statement (split with ;)
    ok, ko = 0, 0
    for statement in sql.split(";"):
        statement = statement.strip()
        if not statement:
            continue
        try:
            cursor.execute(statement)
            ok += 1
        except Exception as e:
            ko += 1
            log.error(" %s", e)

    log.info("%s executed: %d OK, %d KO", filepath, ok, ko)
    return ko == 0


def main() -> bool:
    """Apply sql files 0, 1, 2, 3, 4 to complete the sid"""
    t0 = time.time()
    log.info("SID INSTALLATION")
    if not os.path.isdir(SQL_DIR):
        log.error("SQL_DIR introuvable : %s", SQL_DIR)
        return False

    conn = init_snowflake_connexion()

    success = True
    for script in SQL_SCRIPTS:
        success &= execute_sql_file(conn.cursor(), script)

    conn.cursor().close()
    conn.close()
    if success:
        log.info("Installation ended successfully in %d s", time.time() - t0)
    else:
        log.error("Installation failed in %d s", time.time() - t0)
    return success


if __name__ == "__main__":
    sys.exit(0 if main() else 1)
