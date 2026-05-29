import csv
from pathlib import Path
from datetime import datetime


DATE = datetime.today().strftime("%Y%m%d") 
DATA_DIR = Path(f"./Data Hospital/BDD_HOSPITAL_{DATE}/")

TABLE_CONFIG = {
    "CHAMBRE":         {"fichier": f"CHAMBRE_{DATE}.txt",         "mode": "full"},
    "MEDICAMENT":      {"fichier": f"MEDICAMENT_{DATE}.txt",      "mode": "full"},
    "PERSONNEL":       {"fichier": f"PERSONNEL_{DATE}.txt",       "mode": "full"},
    "PATIENT":         {"fichier": f"PATIENT_{DATE}.txt",         "mode": "delta"},
    "CONSULTATION":    {"fichier": f"CONSULTATION_{DATE}.txt",    "mode": "delta"},
    "TRAITEMENT":      {"fichier": f"TRAITEMENT_{DATE}.txt",      "mode": "delta"},
    "HOSPITALISATION": {"fichier": f"HOSPITALISATION_{DATE}.txt", "mode": "delta"},
}

def lire_fichier(chemin):
    with open(chemin, encoding="utf-8", newline="") as f:
        reader = csv.reader(f, delimiter=";")
        lignes = list(reader)

    colonnes = [c.strip().upper() for c in lignes[0]]
    donnees  = [
        [None if v.strip() == "" else v.strip() for v in ligne]
        for ligne in lignes[1:]
    ]
    return colonnes, donnees

def inserer(conn, table, colonnes, donnees, mode):
    cursor = conn.cursor()

    if mode == "full":
        cursor.execute(f"TRUNCATE TABLE STG.PUBLIC.{table}")

    placeholders = ", ".join(["%s"] * len(colonnes))
    cols         = ", ".join(colonnes)
    sql          = f"INSERT INTO STG.PUBLIC.{table} ({cols}) VALUES ({placeholders})"
    cursor.executemany(sql, donnees)

    print(f"{table} : {len(donnees)} ligne(s) insérée(s) ({mode})")

conn = None  #  connexion Snowflake

for table, config in TABLE_CONFIG.items():
    chemin = DATA_DIR / config["fichier"]
    colonnes, donnees = lire_fichier(chemin)
    inserer(conn, table, colonnes, donnees, config["mode"])