from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime
from datetime import timedelta

default_args = {
    "owner": "nf26",
    "retries": 2,
    "retry_delay": timedelta(seconds=5),
    "email_on_failure": False,
}

with DAG(
    dag_id="nf26_ingestion_dw",
    default_args=default_args,
    start_date=datetime(2026, 5, 1),
    schedule=None,
    catchup=False,
) as dag:

    ingest_stg = BashOperator(
        task_id="ingest_stg",
        bash_command="""
        cd /opt/airflow &&
        python src/load_stg.py {{ dag_run.conf['date'] if dag_run and 'date' in dag_run.conf else ds_nodash }}
        """,
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt run
        """,
    )

    ingest_stg >> dbt_run