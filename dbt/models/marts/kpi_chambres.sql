WITH room AS (
    SELECT * FROM {{ ref('R_ROOM') }}
),
hosp AS (
    SELECT * FROM {{ ref('O_HOSP') }}
),
jours_ref AS (
    SELECT DISTINCT DATE(HOSP_STRT_DTTM) AS JOUR
    FROM hosp
),
chambres_occupees AS (
    SELECT
        DATE(h.HOSP_STRT_DTTM) AS JOUR,
        h.ROOM_NUM
    FROM hosp h
    GROUP BY 1, 2
),
all_room_jour AS (
    SELECT j.JOUR, r.ROOM_NUM, r.ROOM_NAME, r.ROOM_TYP, r.BULD_NAME, r.FLOR_NUM, r.ROOM_DAY_RATE
    FROM jours_ref j
    CROSS JOIN room r
)
SELECT
    arj.JOUR,
    arj.ROOM_NUM,
    arj.ROOM_NAME,
    arj.ROOM_TYP,
    arj.BULD_NAME,
    arj.FLOR_NUM,
    arj.ROOM_DAY_RATE AS TARIF_JOURNALIER,
    CASE WHEN co.ROOM_NUM IS NOT NULL THEN 1 ELSE 0 END AS EST_OCCUPEE,
    CASE WHEN co.ROOM_NUM IS NULL THEN 1 ELSE 0 END AS EST_LIBRE
FROM all_room_jour arj
LEFT JOIN chambres_occupees co ON arj.JOUR = co.JOUR AND arj.ROOM_NUM = co.ROOM_NUM
ORDER BY arj.JOUR, arj.ROOM_NUM
