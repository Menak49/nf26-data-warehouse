# Lot 2 — Connexion à snowflake via api python

---

## 1. Créer un compte Snowflake

1. Aller sur [snowflake.com](https://snowflake.com) → **Start for free**
2. Choisir **Developer** (pas Entreprise)

---

## 2. Connexion à Snowflake

### Trouver ses informations de connexion

Les informations de connexions dont vous aurez besoin se trouvent sur le site de snowflake. Cliquer sur votre profil en bas à gauche de la page (sidebar). Aller sur Account -> View account details -> config file.

### Fichier `.env`

Insérer ces informations dans un fichier .env (il ne faut pas le mettre sur github). Ajouter votre password de snowflake qui n'était pas dans les informations de connexions récupérérées à l'étape précédente. Un fichier .env.example est dispo sur le Github pour vous aider.

### Problème MFA (authentification double facteur)

Snowflake demande une double identification MFA. Pour ça il faut créer une clé RSA qu'il faudra lui ajouter (les commandes bash fonctionnent sur linux).

```bash
# Générer la clé privée
openssl genrsa -out rsa_key.pem 2048

# Générer la clé publique
openssl rsa -in rsa_key.pem -pubout -out rsa_key.pub

# récupérer la clé
grep -v "PUBLIC KEY" rsa_key.pub | tr -d '\n'
```

Sur Snowflake worksheet, créer un fichier SQL et run:
Ou via SQL :

```sql
ALTER USER [TON_USER] SET RSA_PUBLIC_KEY='MIIBIjANBgkq...';
-- colle ici le contenu de rsa_key.
```

---

## 3. Le script install_sid.py

### Dépendances à installer

```bash
pip install snowflake-connector-python python-dotenv
```

Le fichier install_sid.py devra se connecter a snowflake et ajouter les base de données. Le fichier `logs/install_sid.log` contiendra le détail de chaque étape :

```
2026-05-29 10:00:00 - INFO - === DEBUT INSTALLATION SID ===
2026-05-29 10:00:01 - INFO - Exécution de src/sql/00_create_databases.sql
2026-05-29 10:00:01 - INFO -   → CREATE DATABASE IF NOT EXISTS STG...
...
2026-05-29 10:00:05 - INFO - === FIN INSTALLATION SID — Succès ===
```
