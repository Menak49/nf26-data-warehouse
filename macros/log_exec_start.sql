{% macro log_exec_start(model_name) %}
  {#
    pre_hook (au début de chaque model) :
    insère 1 ligne dans TCH.T_SUIV_TRMT avec :
      - EXEC_ID = TCH.SEQ_EXEC_ID.NEXTVAL
      - RUN_ID  = MAX(RUN_ID) du dernier run en cours (créé par on-run-start)
      - SCRPT_NAME = nom du model
      - EXEC_STRT_DTTM = CURRENT_TIMESTAMP
      - EXEC_STTS_CD = 'ENC'
  #}
  {% if execute %}
    {% set q %}
      INSERT INTO TCH.T_SUIV_TRMT (EXEC_ID, RUN_ID, SCRPT_NAME,
                                   EXEC_STRT_DTTM, EXEC_STTS_CD)
      SELECT TCH.SEQ_EXEC_ID.NEXTVAL,
             (SELECT MAX(RUN_ID) FROM TCH.T_SUIV_RUN),
             '{{ model_name }}',
             CURRENT_TIMESTAMP(0),
             'ENC'
    {% endset %}
    {% do run_query(q) %}
  {% endif %}
{% endmacro %}
