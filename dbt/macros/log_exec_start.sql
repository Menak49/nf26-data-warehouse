{% macro log_exec_start(model_name) %}
  {#
    pre-hook : insère 1 ligne T_SUIV_TRMT dans le RUN courant.
    EXEC_ID = MAX(RUN_ID 'ENC')  ;  SCRPT_NAME = nom du model.
  #}
  {% if execute %}
    {% set q %}
      INSERT INTO TCH.T_SUIV_TRMT (EXEC_ID, SCRPT_NAME, EXEC_STRT_DTTM, EXEC_STTS_CD)
      SELECT EXEC_ID, '{{ model_name }}', CURRENT_TIMESTAMP(0), 'ENC'
      FROM TCH.T_SUIV_RUN
      WHERE RUN_STTS_CD = 'ENC'
      ORDER BY RUN_STRT_DTTM DESC LIMIT 1
    {% endset %}
    {% do run_query(q) %}
  {% endif %}
{% endmacro %}
