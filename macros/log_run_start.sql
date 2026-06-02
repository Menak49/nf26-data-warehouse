{% macro log_run_start() %}
  {#
    Hook onrunstart : crée un nouvel enregistrement dans TCH.T_SUIV_RUN
    avec un RUN_ID = MAXIMUM(RUN_ID)+1 et statut 'ENC'.
    Doit être appelé une seule fois par exécution dbt.
  #}
  {% if execute %}
    {% set q %}
      INSERT INTO TCH.T_SUIV_RUN (RUN_ID, RUN_STRT_DTTM, RUN_STTS_CD)
      SELECT COALESCE(MAX(RUN_ID), 0) + 1,
             CURRENT_TIMESTAMP(0),
             'ENC'
      FROM TCH.T_SUIV_RUN
    {% endset %}
    {% do run_query(q) %}
    {{ log("✓ log_run_start : nouveau RUN créé dans TCH.T_SUIV_RUN", info=True) }}
  {% endif %}
{% endmacro %}
