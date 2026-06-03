{% macro log_exec_start(model_name) %}
  {#
    pre-hook : génère 1 UUID, insère dans T_SUIV_TRMT puis T_SUIV_RUN.
  #}
  {% if execute %}
    {% set q = run_query("SELECT UUID_STRING() AS ID") %}
    {% set exec_id = q.columns[0].values()[0] %}
    {% do run_query(
        "INSERT INTO TCH.T_SUIV_TRMT (EXEC_ID, SCRPT_NAME, EXEC_STRT_DTTM, EXEC_STTS_CD) "
        "VALUES ('" ~ exec_id ~ "', '" ~ model_name ~ "', CURRENT_TIMESTAMP(0), 'ENC')"
    ) %}
    {% do run_query(
        "INSERT INTO TCH.T_SUIV_RUN (EXEC_ID, RUN_STRT_DTTM, RUN_STTS_CD) "
        "VALUES ('" ~ exec_id ~ "', CURRENT_TIMESTAMP(0), 'ENC')"
    ) %}
  {% endif %}
{% endmacro %}
