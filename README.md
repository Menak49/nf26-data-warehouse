# NF26 – Data Warehouse Hospitalier (Smart Team)

Projet réalisé dans le cadre de l'UV **NF26** (UTC) : conception et mise en place d'un entrepôt de données (data warehouse) pour un hôpital fictif, avec pipeline d'ingestion, modélisation en couches et restitution via KPIs / Power BI.

## Contexte

Le projet part d'un mapping de données hospitalières (patients, consultations, hospitalisations, traitements, personnel, chambres, coordonnées) fourni par l'entreprise partenaire (non inclus dans ce dépôt), et construit un pipeline complet jusqu'aux indicateurs métier.

## Architecture

- **Ingestion** : scripts Python (`src/install_sid.py`, `src/load_stg.py`) qui créent les bases/tables sur **Snowflake** et chargent les données brutes en zone *staging* (STG) pour un jour donné.
- **Modélisation** : couche *socle* (SOC) en SQL (`src/sql/`) puis transformations **dbt** (`dbt/models/`) organisées en :
  - `wrk/` : tables de travail (adresse, consultation, hospitalisation, individu, médicament, personnel, téléphone, traitement)
  - `soc/` : tables socle normalisées (`O_ADDR`, `O_CONS`, `O_HOSP`, `O_INDV`, `O_STFF`, `O_TELP`, `O_TRET`, `R_MEDC`, `R_PART`, `R_ROOM`)
  - `marts/` : indicateurs métier (KPI âge/pathologie, chambres, hospitalisation, médecins/pathologie, médicament/pathologie)
- **Orchestration** : DAGs **Airflow** (`src/dags/`) pour automatiser l'ingestion et le run dbt.
- **Restitution** : export des KPIs en CSV/XLSX (`exports/`) et tableau de bord **Power BI** (`NF26_PowerBI.pbix`).

Le schéma UML de la base est disponible dans `conception/uml_socle.plantuml` (et son export image dans `rendu1/UMLI.png`).

## Données

Les exports de `exports/` sont des indicateurs **agrégés et anonymisés** (comptages par jour/pathologie, âge moyen, etc.) — aucune donnée nominative de patient n'est présente dans le dépôt. Les pathologies sont désignées par des libellés génériques (`Pathology1`, `Pathology2`, ...).

## Installation

```bash
pip install -r requirements.txt
```

Créer un fichier `.env` à la racine (voir `.env_example`) avec vos identifiants Snowflake :

```
account = "VOTRE_COMPTE_SNOWFLAKE"
user = "VOTRE_USER"
password = "VOTRE_PASSWORD"
role = "TEAM_DEV"
warehouse = "COMPUTE_WH"
database = "NF26_HOSPITAL"
```

Pour dbt, créer un `dbt/profiles.yml` équivalent (voir `doc/help.md` pour le détail complet de la procédure : installation, connexion Snowflake, configuration Airflow).

## Utilisation

```bash
# Création des bases/tables
python3 src/install_sid.py

# Chargement du staging pour une date donnée
python3 src/load_stg.py 20260429

# Transformations dbt
cd dbt && dbt run
```

## Documentation complémentaire

- `doc/help.md` : guide d'installation et d'exécution détaillé
- `questions.txt` : décisions de modélisation et arbitrages pris pendant le projet
- `Diapos_NF26.pdf` : support de présentation du projet
