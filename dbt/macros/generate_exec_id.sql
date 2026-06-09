{% macro generate_exec_id(model_name=None) %}
  {#
    Retourne expression SQL = EXEC_ID UUID du RUN courant (statut ENC).
    Usage : SELECT ..., {{ generate_exec_id() }} AS EXEC_ID FROM ...
  #}
  {{ return(
      "(SELECT EXEC_ID FROM TCH.T_SUIV_RUN "
      "WHERE RUN_STTS_CD = 'ENC' "
      "ORDER BY RUN_STRT_DTTM DESC LIMIT 1)"
  ) }}
{% endmacro %}
