SELECT
    rp.PART_ID,
    wa.STRT_NUM,
    wa.STRT_DSC,
    wa.COMP_STRT,
    wa.POST_CD,
    wa.CITY_NAME,
    wa.CNTR_NAME,
    wa.STRT_VALD_DTTM,
    wa.END_VALD_DTTM,
    {{ generate_exec_id() }} AS EXEC_ID

FROM {{ ref('wrk_address') }} wa
INNER JOIN {{ ref('R_PART') }} rp
    ON rp.SRC_ID  = wa.SRC_ID
   AND rp.SRC_TYP = 'Patient'

{% if is_incremental() %}
WHERE wa.STRT_VALD_DTTM > (SELECT MAX(STRT_VALD_DTTM) FROM {{ this }})
{% endif %}