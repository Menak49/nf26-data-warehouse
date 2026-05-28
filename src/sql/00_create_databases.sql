-- =============================================================
-- Script : create_databases.sql
-- Description : Creation des bases de données du SID
-- Date : 2026-05-28
-- Note : Idempotent — les bases ne sont pas recreees si elles existent deja (IF NOT EXISTS)
-- =============================================================


CREATE DATABASE IF NOT EXISTS STG;
CREATE DATABASE IF NOT EXISTS WRK;
CREATE DATABASE IF NOT EXISTS SOC;
CREATE DATABASE IF NOT EXISTS TCH;

CREATE SCHEMA IF NOT EXISTS STG.PUBLIC;
CREATE SCHEMA IF NOT EXISTS WRK.PUBLIC;
CREATE SCHEMA IF NOT EXISTS SOC.PUBLIC;
CREATE SCHEMA IF NOT EXISTS TCH.PUBLIC;