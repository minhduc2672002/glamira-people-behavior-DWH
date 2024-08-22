WITH dim_location__source AS (
    SELECT DISTINCT
        CASE WHEN country_code = '-' THEN 'Undefined' ELSE country_code END AS country_code
        ,CASE WHEN country_name = '-' THEN 'Undefined' ELSE country_name END AS country_name
        ,CASE WHEN region_name = '-' THEN 'Undefined' ELSE region_name END AS region_name
        ,CASE WHEN city_name = '-' THEN 'Undefined' ELSE city_name END AS city_name
        ,CASE WHEN postal_code = '-' THEN 'Undefined' ELSE postal_code END AS postal_code
    FROM {{source('glamira','ip_to_location')}} 
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['country_code','country_name','region_name','city_name','postal_code']) }} AS location_key
    ,country_code
    ,country_name
    ,region_name
    ,city_name
    ,postal_code
FROM dim_location__source
