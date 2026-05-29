SELECT
    ROW_NUMBER() OVER (
        ORDER BY MEDC_CD, MEDC_CATG, MANF_BRND
    )               AS MEDC_ID,
    MEDC_CD,
    MEDC_NAME,
    MEDC_COND,
    MEDC_CATG,
    MANF_BRND,
    0               AS EXEC_ID

FROM {{ ref('wrk_medicine') }}

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY MEDC_CD, MEDC_CATG, MANF_BRND
    ORDER BY MEDC_CD
) = 1
