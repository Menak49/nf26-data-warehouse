{% macro log_exec_end(model_name, status='OK') %}
  {#
    post-hook : update T_SUIV_TRMT + T_SUIV_RUN du dernier EXEC_ID
    correspondant au model_name.
  #}
  {% if execute %}
    {% set lookup %}
      (SELECT EXEC_ID FROM TCH.T_SUIV_TRMT
       WHERE SCRPT_NAME = '{{ model_name }}'
       ORDER BY EXEC_STRT_DTTM DESC LIMIT 1)
    {% endset %}
    {% do run_query(
        "UPDATE TCH.T_SUIV_TRMT SET EXEC_END_DTTM=CURRENT_TIMESTAMP(0), "
        "EXEC_STTS_CD='" ~ status ~ "' WHERE EXEC_ID = " ~ lookup
    ) %}
    {% do run_query(
        "UPDATE TCH.T_SUIV_RUN SET RUN_END_DTTM=CURRENT_TIMESTAMP(0), "
        "RUN_STTS_CD='" ~ status ~ "' WHERE EXEC_ID = " ~ lookup
    ) %}
  {% endif %}
{% endmacro %}
