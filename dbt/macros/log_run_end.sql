{% macro log_run_end(status='OK') %}
  {#
    on-run-end : clôture le RUN courant (le dernier 'ENC' dans T_SUIV_RUN).
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

    {% do run_query(
        "UPDATE TCH.T_SUIV_RUN SET RUN_END_DTTM=CURRENT_TIMESTAMP(0), "
        "RUN_STTS_CD='" ~ final ~ "' "
        "WHERE EXEC_ID = (SELECT EXEC_ID FROM TCH.T_SUIV_RUN "
                         "WHERE RUN_STTS_CD='ENC' ORDER BY RUN_STRT_DTTM DESC LIMIT 1)"
    ) %}
    {{ log("✓ log_run_end : statut " ~ final, info=True) }}
  {% endif %}
{% endmacro %}
