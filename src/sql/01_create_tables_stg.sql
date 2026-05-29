-- =============================================================
-- Script      : create_tables_stg.sql
-- Description : Creation des tables de la zone Staging (STG)
-- Date        : 2026-05-28
-- Note        : Idempotent — CREATE OR REPLACE recree les tables à chaque execution (comportement attendu pour STG)
-- =============================================================





USE DATABASE STG;
USE SCHEMA PUBLIC;

-- -------------------------------------------------------------
-- CHAMBRE
-- Source : CHAMBRE_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PUBLIC.CHAMBRE (
    NO_CHAMBRE      INTEGER,
    NOM_CHAMBRE     VARCHAR(20),
    NO_ETAGE        INTEGER,
    NOM_BATIMENT    VARCHAR(20),
    TYPE_CHAMBRE    VARCHAR(10),
    PRIX_JOUR       INTEGER,
    DT_CREATION     DATE
);

-- -------------------------------------------------------------
-- MEDICAMENT
-- Source : MEDICAMENT_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PUBLIC.MEDICAMENT (
    CD_MEDICAMENT       INTEGER,
    NOM_MEDICAMENT      VARCHAR(250),
    CONDIT_MEDICAMENT   VARCHAR(100),
    CATG_MEDICAMENT     VARCHAR(100),
    MARQUE_FABRI        VARCHAR(100)
);

-- -------------------------------------------------------------
-- PERSONNEL
-- Source : PERSONNEL_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PUBLIC.PERSONNEL (
    ID_PERSONNEL            INTEGER,
    NOM_PERSONNEL           VARCHAR(100),
    PRENOM_PERSONNEL        VARCHAR(100),
    FONCTION_PERSONNEL      VARCHAR(50),
    TS_DEBUT_ACTIVITE       TIMESTAMP,
    TS_FIN_ACTIVITE         TIMESTAMP,
    RAISON_FIN_ACTIVITE     VARCHAR(100),
    TS_CREATION_PERSONNEL   TIMESTAMP,
    TS_MAJ_PERSONNEL        TIMESTAMP,
    CD_STATUT_PERSONNEL     VARCHAR(10)
);

-- -------------------------------------------------------------
-- PATIENT
-- Source : PATIENT_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PUBLIC.PATIENT (
    ID_PATIENT          INTEGER,
    NOM_PATIENT         VARCHAR(100),
    PRENOM_PATIENT      VARCHAR(100),
    DT_NAISS            DATE,
    VILLE_NAISS         VARCHAR(100),
    PAYS_NAISS          VARCHAR(100),
    NUM_SECU            VARCHAR(15),
    IND_PAYS_NUM_TELP   VARCHAR(5),
    NUM_TELEPHONE       VARCHAR(20),
    NUM_VOIE            VARCHAR(10),
    DSC_VOIE            VARCHAR(250),
    CMPL_VOIE           VARCHAR(250),
    CD_POSTAL           VARCHAR(10),
    VILLE               VARCHAR(100),
    PAYS                VARCHAR(100),
    TS_CREATION_PATIENT TIMESTAMP,
    TS_MAJ_PATIENT      TIMESTAMP
);

-- -------------------------------------------------------------
-- CONSULTATION
-- Source : CONSULTATION_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PUBLIC.CONSULTATION (
    ID_CONSULT          INTEGER,
    ID_PERSONNEL        INTEGER,
    ID_PATIENT          INTEGER,
    TS_DEBUT_CONSULT    TIMESTAMP,
    TS_FIN_CONSULT      TIMESTAMP,
    POIDS_PATIENT       FLOAT,
    TEMP_PATIENT        FLOAT,
    UNIT_TEMP           VARCHAR(15),
    TENSION_PATIENT     FLOAT,
    DSC_PATHO           VARCHAR(250),
    INDIC_DIABETE       VARCHAR(10), 
    ID_TRAITEMENT       INTEGER,
    INDIC_HOSPI         VARCHAR(10)
);

-- -------------------------------------------------------------
-- TRAITEMENT
-- Source : TRAITEMENT_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PUBLIC.TRAITEMENT (
    ID_TRAITEMENT           INTEGER,
    CD_MEDICAMENT           INTEGER,
    CATG_MEDICAMENT         VARCHAR(100),
    MARQUE_FABRI            VARCHAR(100),
    QTE_MEDICAMENT          INTEGER,
    DSC_POSOLOGIE           VARCHAR(100),
    ID_CONSULT              INTEGER,
    TS_CREATION_TRAITEMENT  TIMESTAMP
);

-- -------------------------------------------------------------
-- HOSPITALISATION
-- Source : HOSPITALISATION_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PUBLIC.HOSPITALISATION (
    ID_HOSPI            INTEGER,
    ID_CONSULT_HOSPI    INTEGER,
    NO_CHAMBRE_HOSPI    INTEGER,
    TS_DEBUT_HOSPI      TIMESTAMP,
    TS_FIN_HOSPI        TIMESTAMP,
    COUT_HOSPI          FLOAT,
    ID_PERSONNEL_RESP   INTEGER
);