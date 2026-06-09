import sys
import os

dag_path = os.path.dirname(os.path.abspath(__file__))
parent_path = os.path.abspath(os.path.join(dag_path, ".."))
if parent_path not in sys.path:
    sys.path.append(parent_path)

from datetime import datetime, timedelta
from airflow import DAG  # type: ignore
from airflow.operators.bash import BashOperator  # type: ignore
from airflow.operators.python import BranchPythonOperator  # type: ignore
from airflow.operators.trigger_dagrun import TriggerDagRunOperator  # type: ignore
from airflow.operators.empty import EmptyOperator  # type: ignore
from test_exist_table import table_exists  # type: ignore
import logging

# Mettre ces PATH dans le .env ? Tout le monde à les même ?
PROJECT_PATH = "NF26_Smart_Teems"
ENV_PATH = ".venv/bin/activate"


default_args = {
    "owner": "nf26",
    "retries": 2,
    "retry_delay": timedelta(seconds=5),
    "email_on_failure": False,
    "max_active_runs": 1,
}

with DAG(
    dag_id="nf26_install_sid",
    description="Install SID",
    default_args=default_args,
    start_date=datetime(2026, 4, 29),
    schedule="@daily",
    catchup=True,
) as dag:
    # 1. Test existance table
    test_exist = BranchPythonOperator(
        task_id="test_table_exist", python_callable=table_exists
    )

    # 2. Une tâche vide si table existe
    skip_action = EmptyOperator(task_id="skip_action")

    # 3. Installation du SID si table existe pas (création des tables Snowflake)
    install_sid = BashOperator(
        task_id="install_sid",
        bash_command=f"""
        cd && 
        cd {PROJECT_PATH} && 
        source {ENV_PATH} && 
        python3 src/install_sid.py
        """,
    )

    # 4. Déclenchement du deuxième DAG (ingestion)
    trigger_daily_dag = TriggerDagRunOperator(
        task_id="trigger_ingest_stg",
        trigger_dag_id="nf26_ingestion_dw",
        wait_for_completion=True,
    )

    # ── Ordre d'exécution ──────────────────────────────────────────────────
    test_exist >> [install_sid, skip_action]
    install_sid >> trigger_daily_dag
    skip_action >> trigger_daily_dag
