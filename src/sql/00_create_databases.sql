-- =============================================================
-- Script      : 00_create_databases.sql
-- Description : Creation de la base de donnees et des schemas du SID
-- Date        : 2026-05-28
-- Note        : Idempotent — IF NOT EXISTS
-- =============================================================

CREATE DATABASE IF NOT EXISTS NF26_HOSPITAL;

USE DATABASE NF26_HOSPITAL;

CREATE SCHEMA IF NOT EXISTS STG;
CREATE SCHEMA IF NOT EXISTS WRK;
CREATE SCHEMA IF NOT EXISTS SOC;
CREATE SCHEMA IF NOT EXISTS TCH;

CREATE SEQUENCE IF NOT EXISTS TCH.SEQ_EXEC_ID START = 1 INCREMENT = 1;