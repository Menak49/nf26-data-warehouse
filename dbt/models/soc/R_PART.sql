SELECT
    ROW_NUMBER() OVER (ORDER BY SRC_TYP, SRC_ID) -- Génère l'id de manière inscrémental en partant du max id pr éviter les doublons
    + COALESCE((SELECT MAX(PART_ID) FROM {{ this }}), 0)  AS PART_ID,
    SRC_ID,
    SRC_TYP

FROM {{ ref('wrk_party') }}

{% if is_incremental() %} -- Permet d'ajouter uniquement les nouvelles lignes à la table cible lors d'une exécution incrémentale
WHERE (SRC_ID, SRC_TYP) NOT IN (SELECT SRC_ID, SRC_TYP FROM {{ this }})
{% endif %}

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY SRC_ID, SRC_TYP
    ORDER BY SRC_ID
) = 1