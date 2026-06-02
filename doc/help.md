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
