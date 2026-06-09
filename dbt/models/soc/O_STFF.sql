SELECT
    rp.PART_ID,
    ws.WORK_STRT_DTTM,
    ws.WORK_END_DTTM,
    ws.WORK_END_RESN,
    {{ generate_exec_id() }}    AS EXEC_ID

FROM {{ ref('wrk_staff') }}   ws
INNER JOIN {{ ref('R_PART') }} rp
    ON rp.SRC_ID  = ws.SRC_ID
   AND rp.SRC_TYP = ws.SRC_TYP
