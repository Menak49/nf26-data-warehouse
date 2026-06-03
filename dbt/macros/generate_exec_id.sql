{% macro generate_exec_id(model_name=None) %}
  {#
    Retourne une expression SQL qui récupère EXEC_ID UUID courant
    (créé par log_exec_start dans le pre-hook).
    Usage dans un model :
        SELECT ..., {{ generate_exec_id() }} AS EXEC_ID FROM ...
  #}
  {% set name = model_name if model_name else this.name %}
  {{ return(
      "(SELECT EXEC_ID FROM TCH.T_SUIV_TRMT "
      "WHERE SCRPT_NAME = '" ~ name ~ "' "
      "ORDER BY EXEC_STRT_DTTM DESC LIMIT 1)"
  ) }}
{% endmacro %}
