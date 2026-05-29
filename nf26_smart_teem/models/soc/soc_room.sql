{{
    config(
        materialized='table',
        schema='SOC'
    )
}}

SELECT
    ROOM_NUM,
    ROOM_NAME,
    FLOR_NUM,
    BULD_NAME,
    ROOM_TYP,
    ROOM_DAY_RATE,
    CRTN_DT,
    0   AS EXEC_ID

FROM {{ ref('wrk_room') }}
