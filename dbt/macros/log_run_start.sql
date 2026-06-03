{% macro log_run_start() %}
  {#
    on-run-start : insère 1 ligne dans T_SUIV_TRMT et T_SUIV_RUN
    avec un UUID partagé (SCRPT_NAME='DBT_RUN').
  #}
  {% if execute %}
    {% set q = run_query("SELECT UUID_STRING() AS ID") %}
    {% set exec_id = q.columns[0].values()[0] %}
    {% do run_query(
        "INSERT INTO TCH.T_SUIV_TRMT (EXEC_ID, SCRPT_NAME, EXEC_STRT_DTTM, EXEC_STTS_CD) "
        "VALUES ('" ~ exec_id ~ "', 'DBT_RUN', CURRENT_TIMESTAMP(0), 'ENC')"
    ) %}
    {% do run_query(
        "INSERT INTO TCH.T_SUIV_RUN (EXEC_ID, RUN_STRT_DTTM, RUN_STTS_CD) "
        "VALUES ('" ~ exec_id ~ "', CURRENT_TIMESTAMP(0), 'ENC')"
    ) %}
    {{ log("✓ log_run_start : EXEC_ID=" ~ exec_id, info=True) }}
  {% endif %}
{% endmacro %}
