WITH cons AS (
    SELECT * FROM {{ ref('O_CONS') }}
),
staff AS (
    SELECT * FROM {{ ref('O_STFF') }}
),
party AS (
    SELECT * FROM {{ ref('R_PART') }}
),
medecins_par_patho AS (
    SELECT
        DATE_TRUNC('MONTH', c.CONS_STRT_DTTM) AS MOIS,
        c.PATH_DSC AS PATHOLOGIE,
        p.SRC_TYP AS SPECIALITE,
        COUNT(DISTINCT c.STFF_ID) AS NB_MEDECINS
    FROM cons c
    INNER JOIN party p ON c.STFF_ID = p.PART_ID
    WHERE c.PATH_DSC IS NOT NULL
    GROUP BY 1, 2, 3
),
total_par_patho AS (
    SELECT
        MOIS,
        PATHOLOGIE,
        SUM(NB_MEDECINS) AS TOTAL_MEDECINS
    FROM medecins_par_patho
    GROUP BY 1, 2
)
SELECT
    m.MOIS,
    m.PATHOLOGIE,
    m.SPECIALITE,
    m.NB_MEDECINS,
    t.TOTAL_MEDECINS,
    ROUND(m.NB_MEDECINS * 100.0 / NULLIF(t.TOTAL_MEDECINS, 0), 2) AS PROPORTION_PCT
FROM medecins_par_patho m
INNER JOIN total_par_patho t ON m.MOIS = t.MOIS AND m.PATHOLOGIE = t.PATHOLOGIE
ORDER BY 1, 2, PROPORTION_PCT DESC
