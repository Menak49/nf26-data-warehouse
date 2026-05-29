{{
    config(
        materialized='table',
        schema='WRK'
    )
}}

-- Personnel
SELECT
    ID_PERSONNEL        AS SRC_ID,
    FONCTION_PERSONNEL  AS SRC_TYP

FROM {{ source('STG', 'PERSONNEL') }}

WHERE ID_PERSONNEL IS NOT NULL
  AND FONCTION_PERSONNEL IS NOT NULL

UNION ALL

-- Patients
SELECT
    ID_PATIENT          AS SRC_ID,
    'Patient'           AS SRC_TYP

FROM {{ source('STG', 'PATIENT') }}

WHERE ID_PATIENT IS NOT NULL
