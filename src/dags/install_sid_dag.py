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
from airflow.utils.trigger_rule import TriggerRule  # type: ignore

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

    check_sid = BranchPythonOperator(task_id="check_sid", python_callable=table_exists)

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
    trigger_ingest_stg = TriggerDagRunOperator(
        task_id="trigger_ingest_stg",
        trigger_dag_id="nf26_ingestion_dw",
        conf={"date": "{{ ds_nodash }}"},
        trigger_rule="none_failed",
    )

    check_sid >> [install_sid, trigger_ingest_stg]
    install_sid >> trigger_ingest_stg
