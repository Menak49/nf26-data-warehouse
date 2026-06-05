SELECT
    rp.PART_ID,
    wt.CNTR_IND,
    wt.TELP_NUM,
    wt.STRT_VALD_DTTM,
    wt.END_VALD_DTTM,
    {{ generate_exec_id() }} AS EXEC_ID

FROM {{ ref('wrk_telephone') }} wt
INNER JOIN {{ ref('R_PART') }} rp
    ON rp.SRC_ID  = wt.SRC_ID
   AND rp.SRC_TYP = 'Patient'