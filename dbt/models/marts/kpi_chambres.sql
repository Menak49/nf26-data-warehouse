WITH room AS (
    SELECT * FROM {{ ref('R_ROOM') }}
),
hosp AS (
    SELECT * FROM {{ ref('O_HOSP') }}
),
mois_ref AS (
    SELECT DISTINCT DATE_TRUNC('MONTH', HOSP_STRT_DTTM) AS MOIS
    FROM hosp
),
chambres_occupees AS (
    SELECT
        DATE_TRUNC('MONTH', h.HOSP_STRT_DTTM) AS MOIS,
        h.ROOM_NUM
    FROM hosp h
    GROUP BY 1, 2
),
all_room_mois AS (
    SELECT m.MOIS, r.ROOM_NUM, r.ROOM_NAME, r.ROOM_TYP, r.BULD_NAME, r.FLOR_NUM, r.ROOM_DAY_RATE
    FROM mois_ref m
    CROSS JOIN room r
)
SELECT
    arm.MOIS,
    arm.ROOM_NUM,
    arm.ROOM_NAME,
    arm.ROOM_TYP,
    arm.BULD_NAME,
    arm.FLOR_NUM,
    arm.ROOM_DAY_RATE AS TARIF_JOURNALIER,
    CASE WHEN co.ROOM_NUM IS NOT NULL THEN 1 ELSE 0 END AS EST_OCCUPEE,
    CASE WHEN co.ROOM_NUM IS NULL THEN 1 ELSE 0 END AS EST_LIBRE
FROM all_room_mois arm
LEFT JOIN chambres_occupees co ON arm.MOIS = co.MOIS AND arm.ROOM_NUM = co.ROOM_NUM
ORDER BY arm.MOIS, arm.ROOM_NUM
