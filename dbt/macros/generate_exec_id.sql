{% macro generate_exec_id(model_name=None) %}
  {#
    Retourne une expression SQL qui récupère lEXEC_ID courant (créé par log_exec_start dans le pre_hook).
    Utilisation dans un model :
        SELECT ..., {{ generate_exec_id() }} AS EXEC_ID FROM ...
    Si model_name non précisé, on prend le nom du model courant via {{ this.name }}.
  #}

  {% set name = model_name if model_name else this.name %}
  {{ return("(SELECT MAX(EXEC_ID) FROM TCH.T_SUIV_TRMT WHERE SCRPT_NAME = '" ~ name ~ "' AND RUN_ID = (SELECT MAX(RUN_ID) FROM TCH.T_SUIV_RUN))") }}
{% endmacro %}
