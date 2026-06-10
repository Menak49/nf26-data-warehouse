"""
Export des KPI views (MART) vers fichiers CSV et XLSX.

Pour chaque vue dans MART_VIEWS, exporte :
  - exports/csv/<nom_vue>.csv
  - exports/xlsx/<nom_vue>.xlsx
Puis génère un seul fichier xlsx multi-feuilles : exports/all_kpis.xlsx
"""

import os
import sys
import logging
import pandas as pd
import snowflake.connector
from sf_config import SNOWFLAKE_CONFIG

SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
EXPORT_DIR  = os.path.join(PROJECT_DIR, "exports")
CSV_DIR     = os.path.join(EXPORT_DIR, "csv")
XLSX_DIR    = os.path.join(EXPORT_DIR, "xlsx")

MART_VIEWS = [
    "KPI_AGE_PATHOLOGIE",
    "KPI_MEDICAMENT_PATHOLOGIE",
    "KPI_CHAMBRES_PATHOLOGIE",
    "KPI_MEDECINS_PATHOLOGIE",
    "KPI_HOSPITALISATION",
    "KPI_CHAMBRES",
]

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s [%(levelname)s] %(message)s",
                    datefmt="%H:%M:%S")
log = logging.getLogger(__name__)


def export_view(conn, view_name):
    """Lit la vue MART.<view_name> et écrit CSV + XLSX."""
    sql = f"SELECT * FROM NF26_HOSPITAL.MART.{view_name}"
    df = pd.read_sql(sql, conn)
    csv_path  = os.path.join(CSV_DIR, f"{view_name}.csv")
    xlsx_path = os.path.join(XLSX_DIR, f"{view_name}.xlsx")
    df.to_csv(csv_path, index=False, sep=";", encoding="utf-8-sig")
    df.to_excel(xlsx_path, index=False, sheet_name=view_name[:31])
    log.info(f"  ✓ {view_name}: {len(df):>6} lignes  →  {csv_path}, {xlsx_path}")
    return view_name, df


def export_all_kpis_to_one_xlsx(views_data):
    """Crée un seul fichier xlsx avec une feuille par KPI (pour Power BI / Excel)."""
    if not views_data:
        log.warning("  ⚠ Aucune donnée à consolider")
        return
    out_path = os.path.join(EXPORT_DIR, "all_kpis.xlsx")
    with pd.ExcelWriter(out_path, engine="openpyxl") as writer:
        for name, df in views_data:
            df.to_excel(writer, index=False, sheet_name=name[:31])
    log.info(f"  ✓ Fichier consolidé : {out_path}")


def main():
    log.info("=" * 50)
    log.info("LOT 4 - EXPORT KPI VIEWS → CSV / XLSX")
    os.makedirs(CSV_DIR,  exist_ok=True)
    os.makedirs(XLSX_DIR, exist_ok=True)

    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    success = True
    try:
        results = []
        for v in MART_VIEWS:
            try:
                results.append(export_view(conn, v))
            except Exception as e:
                log.error(f"  ✗ {v}: {e}")
                success = False
        export_all_kpis_to_one_xlsx(results)
    finally:
        conn.close()

    log.info("=" * 50)
    log.info(f"Exports disponibles dans {EXPORT_DIR}")
    return success


if __name__ == "__main__":
    sys.exit(0 if main() else 1)
