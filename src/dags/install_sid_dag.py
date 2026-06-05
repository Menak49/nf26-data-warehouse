from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

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
    dag_id="install_sid",
    description="Install SID",
    catchup=False,
    default_args=default_args,
    tags=["sid"],
) as dag:

    # ── Tâche : Installation du SID (création des tables Snowflake) ──────
    install_sid = BashOperator(
        task_id="script_install_sid",
        bash_command=(
            f"cd && cd {PROJECT_PATH} && source {ENV_PATH} && python3 src/install_sid.py"
        ),
    )

    # ── Ordre d'exécution ──────────────────────────────────────────────────
    install_sid
