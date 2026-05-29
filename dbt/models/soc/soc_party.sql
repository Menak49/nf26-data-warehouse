{{
    config(
        materialized='table',
        schema='SOC'
    )
}}

SELECT
    ROW_NUMBER() OVER (
        ORDER BY SRC_TYP, SRC_ID
    )       AS PART_ID,
    SRC_ID,
    SRC_TYP

FROM {{ ref('wrk_party') }}

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY SRC_ID, SRC_TYP
    ORDER BY SRC_ID
) = 1
