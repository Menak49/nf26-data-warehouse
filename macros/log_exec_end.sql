{% macro log_exec_end(model_name, status='OK') %}
  {#
    post_hook (à la fin de chaque model) :
    met à jour la dernière ligne de TCH.T_SUIV_TRMT correspondant
    au model_name + dernier RUN_ID, avec EXEC_END_DTTM et le statut final.
  #}
  {% if execute %}
    {% set q %}
      UPDATE TCH.T_SUIV_TRMT
      SET EXEC_END_DTTM = CURRENT_TIMESTAMP(0),
          EXEC_STTS_CD  = '{{ status }}'
      WHERE EXEC_ID = (
        SELECT MAX(EXEC_ID) FROM TCH.T_SUIV_TRMT
        WHERE SCRPT_NAME = '{{ model_name }}'
          AND RUN_ID = (SELECT MAX(RUN_ID) FROM TCH.T_SUIV_RUN)
      )
    {% endset %}
    {% do run_query(q) %}
  {% endif %}
{% endmacro %}
