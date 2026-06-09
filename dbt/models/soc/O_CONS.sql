SELECT
    wc.CONS_ID,
    rp_stff.PART_ID         AS STFF_ID,
    rp_patn.PART_ID         AS PATN_ID,
    wc.CONS_STRT_DTTM,
    wc.CONS_END_DTTM,
    wc.PATN_WEGH,
    wc.PATN_TEMP,
    wc.TEMP_UNIT,
    wc.BLD_PRSS,
    wc.PATH_DSC,
    wc.DIBT_IND,
    wc.TRET_ID,
    wc.HOSP_IND,
    {{ generate_exec_id() }} AS EXEC_ID

FROM {{ ref('wrk_consultation') }} wc
INNER JOIN {{ ref('R_PART') }} rp_stff
    ON rp_stff.SRC_ID  = wc.STFF_ID
   AND rp_stff.SRC_TYP != 'Patient'
INNER JOIN {{ ref('R_PART') }} rp_patn
    ON rp_patn.SRC_ID  = wc.PATN_ID
   AND rp_patn.SRC_TYP = 'Patient'

{% if is_incremental() %}
WHERE wc.CONS_STRT_DTTM > (SELECT COALESCE(MAX(CONS_STRT_DTTM), '1900-01-01'::TIMESTAMP) FROM {{ this }})
{% endif %}