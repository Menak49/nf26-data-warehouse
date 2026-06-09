"""Test si les tables existent"""

from snowflake_conn import init_snowflake_connexion
import logging

logging.basicConfig(
    filename="logs/test_exist_table.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
log = logging.getLogger(__name__)


def table_exists():
    conn = init_snowflake_connexion(log)
    cursor = conn.cursor()

    query = "SELECT * FROM SOC.R_PART;"
    cursor.execute(query)

    # Si fetchone() renvoie un résultat, la table existe
    exists = cursor.fetchone() is not None

    cursor.close()
    conn.close()
    return exists


if __name__ == "__main__":
    print(table_exists())
