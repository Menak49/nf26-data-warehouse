SELECT
    wh.HOSP_ID,
    wh.CONS_ID,
    wh.ROOM_NUM,
    wh.HOSP_STRT_DTTM,
    wh.HOSP_END_DTTM,
    wh.HOSP_FINL_RATE,
    rp.PART_ID              AS STFF_ID,
    {{ generate_exec_id() }} AS EXEC_ID

FROM {{ ref('wrk_hospitalisation') }} wh
INNER JOIN {{ ref('R_PART') }} rp
    ON rp.SRC_ID  = wh.STFF_ID
   AND rp.SRC_TYP != 'Patient'

{% if is_incremental() %}
WHERE wh.HOSP_STRT_DTTM > (SELECT COALESCE(MAX(HOSP_STRT_DTTM), '1900-01-01'::TIMESTAMP) FROM {{ this }})
{% endif %}