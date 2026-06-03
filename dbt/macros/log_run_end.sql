{% macro log_run_end(status='OK') %}
  {#
    on-run-end : clôture la dernière entrée 'DBT_RUN' (T_SUIV_TRMT + T_SUIV_RUN).
    Statut OK / KO selon dbt 'results'.
  #}
  {% if execute %}
    {% set final = status %}
    {% if results is defined %}
      {% set has_err = namespace(v=false) %}
      {% for r in results %}
        {% if r.status == 'error' %}{% set has_err.v = true %}{% endif %}
      {% endfor %}
      {% set final = 'KO' if has_err.v else 'OK' %}
    {% endif %}

    {% set lookup %}
      (SELECT EXEC_ID FROM TCH.T_SUIV_TRMT
       WHERE SCRPT_NAME = 'DBT_RUN'
       ORDER BY EXEC_STRT_DTTM DESC LIMIT 1)
    {% endset %}
    {% do run_query(
        "UPDATE TCH.T_SUIV_TRMT SET EXEC_END_DTTM=CURRENT_TIMESTAMP(0), "
        "EXEC_STTS_CD='" ~ final ~ "' WHERE EXEC_ID = " ~ lookup
    ) %}
    {% do run_query(
        "UPDATE TCH.T_SUIV_RUN SET RUN_END_DTTM=CURRENT_TIMESTAMP(0), "
        "RUN_STTS_CD='" ~ final ~ "' WHERE EXEC_ID = " ~ lookup
    ) %}
    {{ log("✓ log_run_end : statut " ~ final, info=True) }}
  {% endif %}
{% endmacro %}
