{% macro log_exec_end(model_name, status='OK') %}
  {#
    post-hook : update T_SUIV_TRMT du model courant dans le RUN ENC actuel.
  #}
  {% if execute %}
    {% set q %}
      UPDATE TCH.T_SUIV_TRMT
      SET EXEC_END_DTTM = CURRENT_TIMESTAMP(0),
          EXEC_STTS_CD  = '{{ status }}'
      WHERE SCRPT_NAME = '{{ model_name }}'
        AND EXEC_ID = (
            SELECT EXEC_ID FROM TCH.T_SUIV_RUN
            WHERE RUN_STTS_CD = 'ENC'
            ORDER BY RUN_STRT_DTTM DESC LIMIT 1
        )
    {% endset %}
    {% do run_query(q) %}
  {% endif %}
{% endmacro %}
