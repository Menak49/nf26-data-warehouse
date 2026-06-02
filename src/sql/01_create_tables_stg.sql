-- =============================================================
-- Script      : 01_create_tables_stg.sql
-- Description : Creation des tables de la zone Staging (STG)
-- Date        : 2026-05-28
-- Note        : Idempotent — CREATE OR REPLACE recree les tables
--               a chaque execution (comportement attendu pour STG)
-- =============================================================

USE DATABASE NF26_HOSPITAL;
USE SCHEMA STG;

-- -------------------------------------------------------------
-- CHAMBRE
-- Source : CHAMBRE_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.CHAMBRE (
    NO_CHAMBRE      INTEGER         NOT NULL,
    NOM_CHAMBRE     VARCHAR(20)     NOT NULL,
    NO_ETAGE        BYTEINT,
    NOM_BATIMENT    VARCHAR(20),
    TYPE_CHAMBRE    VARCHAR(10),
    PRIX_JOUR       SMALLINT        NOT NULL,
    DT_CREATION     DATE            NOT NULL
);

-- -------------------------------------------------------------
-- MEDICAMENT
-- Source : MEDICAMENT_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.MEDICAMENT (
    CD_MEDICAMENT       VARCHAR(10)     NOT NULL,
    NOM_MEDICAMENT      VARCHAR(250),
    CONDIT_MEDICAMENT   VARCHAR(100),
    CATG_MEDICAMENT     VARCHAR(100)    NOT NULL,
    MARQUE_FABRI        VARCHAR(100)    NOT NULL
);

-- -------------------------------------------------------------
-- PERSONNEL
-- Source : PERSONNEL_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PERSONNEL (
    ID_PERSONNEL            INTEGER         NOT NULL,
    NOM_PERSONNEL           VARCHAR(100)    NOT NULL,
    PRENOM_PERSONNEL        VARCHAR(100)    NOT NULL,
    FONCTION_PERSONNEL      VARCHAR(50)     NOT NULL,
    TS_DEBUT_ACTIVITE       TIMESTAMP(0)    NOT NULL,
    TS_FIN_ACTIVITE         TIMESTAMP(0),
    RAISON_FIN_ACTIVITE     VARCHAR(100),
    TS_CREATION_PERSONNEL   TIMESTAMP(0)    NOT NULL,
    TS_MAJ_PERSONNEL        TIMESTAMP(0)    NOT NULL,
    CD_STATUT_PERSONNEL     VARCHAR(10)     NOT NULL
);

-- -------------------------------------------------------------
-- PATIENT
-- Source : PATIENT_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.PATIENT (
    ID_PATIENT          INTEGER         NOT NULL,
    NOM_PATIENT         VARCHAR(100)    NOT NULL,
    PRENOM_PATIENT      VARCHAR(100)    NOT NULL,
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
    TS_CREATION_PATIENT TIMESTAMP(0)    NOT NULL,
    TS_MAJ_PATIENT      TIMESTAMP(0)    NOT NULL
);

-- -------------------------------------------------------------
-- CONSULTATION
-- Source : CONSULTATION_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.CONSULTATION (
    ID_CONSULT          INTEGER         NOT NULL,
    ID_PERSONNEL        INTEGER         NOT NULL,
    ID_PATIENT          INTEGER         NOT NULL,
    TS_DEBUT_CONSULT    TIMESTAMP(0)    NOT NULL,
    TS_FIN_CONSULT      TIMESTAMP(0)    NOT NULL,
    POIDS_PATIENT       INTEGER         NOT NULL,
    TEMP_PATIENT        INTEGER,
    UNIT_TEMP           VARCHAR(15),
    TENSION_PATIENT     INTEGER,
    DSC_PATHO           VARCHAR(250),
    INDIC_DIABETE       VARCHAR(10),
    ID_TRAITEMENT       INTEGER,
    INDIC_HOSPI         VARCHAR(10)
);

-- -------------------------------------------------------------
-- TRAITEMENT
-- Source : TRAITEMENT_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.TRAITEMENT (
    ID_TRAITEMENT           INTEGER         NOT NULL,
    CD_MEDICAMENT           INTEGER         NOT NULL,
    CATG_MEDICAMENT         VARCHAR(100)    NOT NULL,
    MARQUE_FABRI            VARCHAR(100)    NOT NULL,
    QTE_MEDICAMENT          SMALLINT,
    DSC_POSOLOGIE           VARCHAR(100)    NOT NULL,
    ID_CONSULT              INTEGER         NOT NULL,
    TS_CREATION_TRAITEMENT  TIMESTAMP(0)    NOT NULL
);

-- -------------------------------------------------------------
-- HOSPITALISATION
-- Source : HOSPITALISATION_YYYYMMDD.txt
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE STG.HOSPITALISATION (
    ID_HOSPI            INTEGER         NOT NULL,
    ID_CONSULT_HOSPI    INTEGER         NOT NULL,
    NO_CHAMBRE_HOSPI    SMALLINT        NOT NULL,
    TS_DEBUT_HOSPI      TIMESTAMP(0)    NOT NULL,
    TS_FIN_HOSPI        TIMESTAMP(0),
    COUT_HOSPI          FLOAT,
    ID_PERSONNEL_RESP   INTEGER         NOT NULL
);