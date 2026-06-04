SELECT
    rp.PART_ID,
    wi.INDV_NAME,
    wi.INDV_FIRS_NAME,
    wi.INDV_STTS_CD,
    wi.CRTN_DTTM,
    wi.UPDT_DTTM,
    wi.BIRT_DT,
    wi.BIRT_CITY,
    wi.BIRT_CNTR,
    wi.SOCL_NUM,
    {{ generate_exec_id() }}    AS EXEC_ID

FROM {{ ref('wrk_individual') }}  wi
INNER JOIN {{ ref('R_PART') }}    rp
    ON rp.SRC_ID  = wi.SRC_ID
   AND rp.SRC_TYP = wi.SRC_TYP
