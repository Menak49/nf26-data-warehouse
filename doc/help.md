# Lot 2: Important

## Bibliothèques nécessaires

Il faut installer dotenv, snowflake-connector, dbt...
Vous pouz run cette ligne, elle installera tout ce que vous n'avez pas encore (et ne touchera pas au reste):

```bash
pip install requirement.txt
```

## Connexion à Snowflake pour script python:

Il faut créer d'un fichier .env à la racine du projet (un exemple est donné dans le git). Ce fichier permet de stocker localement toutes les informations de connexion que vous ne voulez pas mettre sur Github. Le fichier exemple possède presque toutes les informations, il suffit de rajouter votre nom d'utilisateur (prénom en majuscule) et le mot de passe de votre compte. Le programme prendra directement ces informations quand il se connectera à Sowflake.

Vous pourrez ensuite run _install_sid.py_ et _load_stg.py_ (dans le dossier _src_) avec les lignes:

```bash
python3 src/install_sid.py

python3 src/load_stg.py 20260429
```

Avant de pouvoir run le script, il faut créer un dossier _logs_ à la racine du projet. Les fichiers de log pour le sid et le load stg seront insérés ici.

Pour pouvoir load le STG sans erreur, il faut que vous ayez les données dans ce chemin: _Inputs_Projets_NF26_AI07/Inputs_Projets_NF26_AI07/Data Hospital_.

_install_sid.py_ créer les bases de données sur Snowflake.
_load_stg.py_ insère les données d'un certain jour (dans l'exemple on insère les données du 29/04/2026).

## Connexion à Snowflake pour dbt:

dbt utilise une autre façon de se connecter (qui est presque identique). Pour cela, il faut créer un fichier _profiles.yml_ dans le dossier dbt.
il doit avoir ces informations:

```yml
nf26_hospital:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: VOTRE_COMPTE_SNOWFLAKE
      user: USER
      password: PASSWORD
      role: TEAM_DEV
      database: NF26_HOSPITAL
      warehouse: COMPUTE_WH
      schema: SOC
      threads: 4
```

Modifier le user et le password.
Une fois cette étape terminée, vous pouvez naviguer dans le dossier dbt à partir du terminal et run dbt:

```bash
cd dbt

cd run dbt
```

L'ensemble des tâches s'effectueront.

## Création de nouvelles tâches

Pour créer les autres tables de soc, il faut reproduire ce qui a été fait précédemment:

- Ajouter dans _models/schemas.yml_ le nom de la table et une description (mettre la table de soc et la table work si besoin).
- Créer un fichier avec le **même nom** que le nom mis dans l'étape précédente.
- Utiliser les macros si besoin.
- Faire un _dbt run_ pour tester. Si vous avez fait une mauvaise manip et que vous voulez supprimer les tables socles, il faut ajouter un _DROP TABLE XXX;_ au début du fichier _src/sql/02_create_tables_soc.sql_ puis run le _install_sid.py_ puis le _load_stg.py_ **Ne pas oublier de l'enlever après.** (vous pouvez aussi run un script sql qui ne fait que supprimer et recréer la table que vous souhaitez remettre à 0).

## Installation de Airflow sur linux:

Il faut mettre airflow dans un autre venv que celui utilisé pour le projet car il y a très souvent des conflits de versions. Nous pourrons tout de même utiliser le venv du projet lorsque nous executerons les scripts.

```bash
# Création du venv airflow (à la racine de l'ordinateur pour pouvoir être utilisé par d'autres projets si besoin)
python3 -m venv ~/airflow-venv
source ~/airflow-venv/bin/activate

# Définition du home Airflow (peut être mis dans le /.bashrc si vous ne voulez pas mettre ce dossier à la racine)
export AIRFLOW_HOME=~/airflow

# Installation de Airflow avec une contrainte sur les versions de python et d'airfloww
AIRFLOW_VERSION=2.9.3
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
```

Airflow est maintenant installé. Dans le dossier airflow de la racine de votre ordinateur (ou le dossier que vous avez choisi à la ligne AIRFLOW*HOME), il y a un fichier \_airflow.cfg*. Ce fichier contient l'ensemble des paramètres de airflow que vous pouvez modifier. Je vous conseille de mettre à False la variable _load_examples_ car sinon tous les dags d'exemple seront ajoutés (et il y en a beaucoup).

Modifier aussi la variable _dags_folder_ qui est le path du dossier avec tous vos dags. Pour une meilleure robustesse, je vous conseille d'utiliser le path qui part de la racine de votre ordinateur.

Ensuite, il faut initialiser la db utilisée par Airflow:

```bash
# Initialisation de la db de airflow
airflow db init

# Création d'un utilisateur
airflow users create \
  --username name \
  --firstname Firstname \
  --lastname Lastname \
  --role Admin \
  --email admin@example.com \
  --password name_lastname
```

La base de données est maintenant créée. Il suffit d'activer Airflow (section suivante).

## Activation de airflow pour système linux:

Pour faire focntionner airflow, il faut lancer son scheduler et son webserver.

Dans un premier terminal il faut activer le venv de airflow et son scheduler.

```bash
source ~/airflow-venv/bin/activate # Activation du venv avec airflow
airflow scheduler # Lancement du scheduler (gère les DAG)
```

Dans un autre terminal, il faut lancer le webserver.

```bash
source ~/airflow-venv/bin/activate # Activation du venv avec airflow
airflow webserver --port 8080 # Lancement du serveur (pour l'interface graphique)
```

Les 2 taches tourneront en arrière plan.
Vous pouvez maintenant aller sur le lien localhost:8080 ou vous pourrez utiliser l'interface graphique d'airflow.
