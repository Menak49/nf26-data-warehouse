from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

# Mettre ces PATH dans le .env ? Tout le monde à les même ?
PROJECT_PATH = "NF26_Smart_Teems"
ENV_PATH = ".venv/bin/activate"

default_args = {
    "owner": "nf26",
    "retries": 2,
    "retry_delay": timedelta(seconds=5),
    "email_on_failure": False,
}

with DAG(
    dag_id="nf26_install_sid",
    description="Install SID",
    default_args=default_args,
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
) as dag:

    # ── Tâche : Installation du SID (création des tables Snowflake) ──────
    install_sid = BashOperator(
        task_id="install_sid",
        bash_command=f"""
        cd && 
        cd {PROJECT_PATH} && 
        source {ENV_PATH} && 
        python3 src/install_sid.py
        """,
    )

    # Déclenchement du deuxième DAG (ingestion)
    trigger_daily_dag = TriggerDagRunOperator(
        task_id="trigger_ingest_stg",
        trigger_dag_id="nf26_ingestion_dw",
    )

    # ── Ordre d'exécution ──────────────────────────────────────────────────
    install_sid >> trigger_daily_dag
