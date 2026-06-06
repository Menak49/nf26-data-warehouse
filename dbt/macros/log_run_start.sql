{% macro log_run_start() %}
  {#
    on-run-start : crée 1 entrée T_SUIV_RUN (1 EXEC_ID UUID pour TOUT le run dbt).
    Les pre-hook récupèrent ce EXEC_ID via MAX(EXEC_ID) ENC.
  #}
  {% if execute %}
    {% set q = run_query("SELECT UUID_STRING() AS ID") %}
    {% set exec_id = q.columns[0].values()[0] %}
    {% do run_query(
        "INSERT INTO TCH.T_SUIV_RUN (EXEC_ID, RUN_STRT_DTTM, RUN_STTS_CD) "
        "VALUES ('" ~ exec_id ~ "', CURRENT_TIMESTAMP(0), 'ENC')"
    ) %}
    {{ log("✓ log_run_start : EXEC_ID=" ~ exec_id, info=True) }}
  {% endif %}
{% endmacro %}
