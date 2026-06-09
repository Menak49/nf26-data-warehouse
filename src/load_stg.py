import os
import sys
import time
import tempfile
import pandas as pd
import logging
from snowflake.connector.pandas_tools import write_pandas
from snowflake_conn import init_snowflake_connexion
import uuid

logging.basicConfig(
    filename="logs/load_stg.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
log = logging.getLogger(__name__)


# --- Date : passée en argument
DATE = sys.argv[1] if len(sys.argv) > 1 else None  # ex: python load_stg.py 20260430

# --- Chemins ---
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.abspath(
    os.path.join(
        SCRIPT_DIR,
        "..",
        "Inputs_Projets_NF26_AI07",
        "Inputs_Projets_NF26_AI07",
        "Data Hospital",
        f"BDD_HOSPITAL_{DATE}",
    )
)

TABLE_CONFIG = {
    "CHAMBRE": {
        "mode": "full",
        "pk": "NO_CHAMBRE",
        "notnull": ["NOM_CHAMBRE", "NO_ETAGE","NOM_BATIMENT", "PRIX_JOUR", "DT_CREATION"],
    },
    "MEDICAMENT": {
        "mode": "full",
        "pk": "CD_MEDICAMENT",
        "notnull": ["NOM_MEDICAMENT", "CONDIT_MEDICAMENT","CATG_MEDICAMENT", "MARQUE_FABRI"],
    },
    "PERSONNEL": {
        "mode": "full",
        "pk": "ID_PERSONNEL",
        "notnull": [
            "NOM_PERSONNEL",
            "PRENOM_PERSONNEL",
            "FONCTION_PERSONNEL",
            "TD_DEBUT_ACTIVITE",
            "TS_CREATION_PERSONNEL",
            "TS_MAJ_PERSONNEL",
            "CD_STATUT_PERSONNEL",
        ],
    },
    "PATIENT": {
        "mode": "delta",
        "pk": "ID_PATIENT",
        "notnull": [
            "NOM_PATIENT",
            "PRENOM_PATIENT",
            "TS_CREATION_PATIENT",
            "TS_MAJ_PATIENT",
        ],
    },
    "CONSULTATION": {
        "mode": "delta",
        "pk": "ID_CONSULT",
        "notnull": ["ID_PERSONNEL", "ID_PATIENT", "TS_DEBUT_CONSULT", "TS_FIN_CONSULT", "POIDS_PATIENT",],
    },
    "TRAITEMENT": {
        "mode": "delta",
        "pk": "ID_TRAITEMENT",
        "notnull": [
            "CD_MEDICAMENT",
            "CATG_MEDICAMENT",
            "MARQUE_FABRI",
            "DSC_POSOLOGIE",
            "ID_CONSULT",
            "TS_CREATION_TRAITEMENT",
        ],
    },
    "HOSPITALISATION": {
        "mode": "delta",
        "pk": "ID_HOSPI",
        "notnull": [
            "ID_CONSULT",
            "NO_CHAMBRE",
            "TS_DEBUT_HOSPI",
            "TS_FIN_HOSPI",
            "COUT_HOSPI",
            "ID_PERSONNEL_RESP",
        ],
    },
}


# --- Tracking TCH ---




def run_start(conn):
    exec_id = str(uuid.uuid4())

    with conn.cursor() as c:
        c.execute(
            """
            INSERT INTO TCH.T_SUIV_RUN
            (EXEC_ID, RUN_STRT_DTTM, RUN_STTS_CD)
            VALUES (%s, CURRENT_TIMESTAMP(0), 'ENC')
            """,
            (exec_id,),
        )

    log.info(f"RUN démarré → EXEC_ID = {exec_id}")
    return exec_id


def run_end(conn, exec_id, status):
    with conn.cursor() as c:
        c.execute(
            """
            UPDATE TCH.T_SUIV_RUN
            SET RUN_END_DTTM = CURRENT_TIMESTAMP(0),
                RUN_STTS_CD = %s
            WHERE EXEC_ID = %s
            """,
            (status, exec_id),
        )

    log.info(f"RUN {exec_id} terminé → {status}")


def exec_start(conn, exec_id, name):
    with conn.cursor() as c:
        c.execute(
            """
            INSERT INTO TCH.T_SUIV_TRMT
            (EXEC_ID, SCRPT_NAME, EXEC_STRT_DTTM, EXEC_STTS_CD)
            VALUES (%s, %s, CURRENT_TIMESTAMP(0), 'ENC')
            """,
            (exec_id, name),
        )

def exec_end(conn, exec_id, name, status):
    with conn.cursor() as c:
        c.execute(
            """
            UPDATE TCH.T_SUIV_TRMT
            SET EXEC_END_DTTM = CURRENT_TIMESTAMP(0),
                EXEC_STTS_CD = %s
            WHERE EXEC_ID = %s
              AND SCRPT_NAME = %s
            """,
            (status, exec_id, name),
        )


# --- Découverte des fichiers ---


def discover():
    """
    Parcourt DATA_PATH et retourne pour chaque table
    la liste des fichiers trouvés triés par date.
    Si DATE est défini, on filtre sur ce jour uniquement.
    """
    by_table = {}
    for root, _, files in os.walk(DATA_PATH):
        for f in files:
            if not f.endswith(".txt") or f.startswith("._"):
                continue
            parts = f[:-4].split("_")
            # Nom fichier : NOMTABLE_YYYYMMDD.txt → 2 parties
            # Mais HOSPITALISATION_YYYYMMDD → split donne plus de 2 parties
            # donc on prend tout sauf le dernier élément comme nom de table
            date = parts[-1]
            table = "_".join(parts[:-1]).upper()
            if table not in TABLE_CONFIG:
                continue
            if DATE and date != DATE:
                continue
            by_table.setdefault(table, []).append((date, os.path.join(root, f)))
    for t in by_table:
        by_table[t].sort()
    return by_table


# --- Construction du DataFrame ---


def build_df(table, files):
    cfg = TABLE_CONFIG[table]
    _, p = files[-1]  # on prend le fichier du jour
    df = pd.read_csv(p, sep=";", dtype=str)
    log.info(f"  [{cfg['mode']}] {len(df)} lignes lues")

    # Suppression des lignes avec PK ou colonnes obligatoires vides
    cols_required = [cfg["pk"]] + cfg.get("notnull", [])
    cols_required = [c for c in cols_required if c in df.columns]
    if cols_required:
        n0 = len(df)
        df = df.dropna(subset=cols_required)
        df = df[
            (df[cols_required].astype(str).apply(lambda s: s.str.strip()) != "").all(
                axis=1
            )
        ]
        if len(df) != n0:
            log.info(f"  [filter] {n0 - len(df)} ligne(s) écartée(s)")

    return df.reset_index(drop=True)


# --- Chargement dans Snowflake ---


def load(conn, table, df):
    # Tentative avec write_pandas (le plus rapide)
    try:
        ok, _, n, _ = write_pandas(
            conn,
            df,
            table,
            schema="STG",
            quote_identifiers=False,
            auto_create_table=False,
        )
        if ok:
            log.info(f"  STG.{table} : {n} lignes chargées (write_pandas)")
            return True
    except Exception as e:
        log.warning(f"  write_pandas KO ({e}), fallback CSV+PUT")

    # Fallback : PUT + COPY INTO si write_pandas échoue
    tmp = tempfile.mkdtemp()
    path = os.path.join(tmp, f"{table}.csv")
    df.to_csv(path, sep="\x01", index=False, header=False, na_rep="")
    stage = f"@~/ingest_{table}_stage"
    try:
        with conn.cursor() as c:
            c.execute(f"PUT 'file://{path}' {stage} OVERWRITE=TRUE AUTO_COMPRESS=TRUE")
            c.execute(f"""COPY INTO NF26_HOSPITAL.STG.{table}
                        FROM {stage}/{table}.csv.gz
                        FILE_FORMAT = (TYPE=CSV FIELD_DELIMITER='\\x01'
                                        NULL_IF=('') EMPTY_FIELD_AS_NULL=TRUE)
                        ON_ERROR = 'ABORT_STATEMENT'""")
            c.execute(f"REMOVE {stage}")
            c.execute(f"SELECT COUNT(*) FROM NF26_HOSPITAL.STG.{table}")
            n = c.fetchone()[0]
        log.info(f"  STG.{table} : {n} lignes chargées (CSV+PUT)")
        return True
    except Exception as e:
        log.error(f"  STG.{table} : {e}")
        return False
    finally:
        os.remove(path)
        os.rmdir(tmp)


# --- Point d'entrée ---


def main():
    print("DATA_PATH =", DATA_PATH)
    print("exists =", os.path.exists(DATA_PATH))

    t0 = time.time()
    log.info("=" * 50)
    log.info(f"LOT 2.2 - INGESTION TXT → STG  (date={DATE or 'tous les jours'})")
    log.info("=" * 50)

    files_by_table = discover()
    if not files_by_table:
        log.error(f"Aucun fichier trouvé dans {DATA_PATH}")
        return False

    conn = init_snowflake_connexion(log)
    exec_id = run_start(conn)
    success = True

    try:
        for table in sorted(files_by_table):
            mode = TABLE_CONFIG[table]["mode"]
            log.info(f"--- STG.{table} [{mode}] ---")
            exec_start(conn, exec_id, f"INGEST_{table}")
            ok = True
            try:
                df = build_df(table, files_by_table[table])
                with conn.cursor() as c:
                    c.execute(f"TRUNCATE TABLE IF EXISTS NF26_HOSPITAL.STG.{table}")
                ok = load(conn, table, df)
            except Exception as e:
                log.error(f"  STG.{table} : {e}")
                ok = False
            exec_end(conn, exec_id, f"INGEST_{table}", "OK" if ok else "KO")
            success &= ok
    finally:
        run_end(conn, exec_id, "OK" if success else "KO")
        conn.close()

    log.info(f"{'OK' if success else 'KO'} en {time.time() - t0:.1f}s")
    return success


if __name__ == "__main__":
    sys.exit(0 if main() else 1)
