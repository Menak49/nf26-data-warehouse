from datetime import datetime, timedelta
from airflow import DAG  # type: ignore
from airflow.operators.bash import BashOperator  # type: ignore

# Mettre ces PATH dans le .env ? Tout le monde à les même ?
PROJECT_PATH = "NF26_Smart_Teems"
ENV_PATH = ".venv/bin/activate"

default_args = {
    "owner": "nf26",
    "retries": 1,
    "retry_delay": timedelta(seconds=5),
    "email_on_failure": False,
    "max_active_runs": 1,
}


with DAG(
    dag_id="nf26_ingestion_dw",
    description="Ingestion des données txt dans les tables stg",
    default_args=default_args,
    start_date=datetime(2026, 4, 29),
    schedule="@daily",
    catchup=True,
) as dag:

    ingest_stg = BashOperator(
        task_id="ingest_stg",
        bash_command=f"""
        cd && 
        cd {PROJECT_PATH} && 
        source {ENV_PATH} && 
        python3 src/load_stg.py {{{{ dag_run.conf['date'] if dag_run and 'date' in dag_run.conf else ds_nodash }}}}
        """,
        wait_for_completion=True,
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"""
        cd && 
        cd {PROJECT_PATH} && 
        source {ENV_PATH} && 
        cd dbt && 
        dbt run
        """,
        wait_for_completion=True,
    )

    ingest_stg >> dbt_run
