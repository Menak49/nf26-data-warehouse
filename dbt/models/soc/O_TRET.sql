SELECT
    wt.TRET_ID,
    rm.MEDC_ID,
    wt.MEDC_QTY,
    wt.DOSG_DSC,
    wt.CONS_ID,
    wt.TRET_CRTN_DTTM,
    {{ generate_exec_id() }} AS EXEC_ID

FROM {{ ref('wrk_treatment') }} wt
INNER JOIN {{ ref('R_MEDC') }} rm
    ON rm.MEDC_CD   = wt.MEDC_CD
   AND rm.MEDC_CATG = wt.MEDC_CATG
   AND rm.MANF_BRND = wt.MANF_BRND

{% if is_incremental() %}
WHERE wt.TRET_CRTN_DTTM > (SELECT COALESCE(MAX(TRET_CRTN_DTTM), '1900-01-01'::TIMESTAMP) FROM {{ this }})
{% endif %}