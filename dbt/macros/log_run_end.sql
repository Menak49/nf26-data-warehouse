{% macro log_run_end(status='OK') %}
  {#
    Hook on-run-end : clôture le run courant dans TCH.T_SUIV_RUN.
    Le statut est OK si aucun model na échoué, KO sinon.
    On utilise la variable dbt 'results' pour détecter les erreurs.
  #}
  {% if execute %}
    {% set final_status = status %}
    {% if results is defined %}
      {% set has_error = namespace(value=false) %}
      {% for r in results %}
        {% if r.status == 'error' %}
          {% set has_error.value = true %}
        {% endif %}
      {% endfor %}
      {% if has_error.value %}
        {% set final_status = 'KO' %}
      {% else %}
        {% set final_status = 'OK' %}
      {% endif %}
    {% endif %}

    {% set q %}
      UPDATE TCH.T_SUIV_RUN
      SET RUN_END_DTTM = CURRENT_TIMESTAMP(0),
          RUN_STTS_CD = '{{ final_status }}'
      WHERE RUN_ID = (SELECT MAX(RUN_ID) FROM TCH.T_SUIV_RUN)
    {% endset %}
    {% do run_query(q) %}
    {{ log(" log_run_end : RUN clôturé avec statut " ~ final_status, info=True) }}
  {% endif %}
{% endmacro %}
