WITH dim_diamond__source AS (
  SELECT DISTINCT
    CASE 
      WHEN option.value_label IS NOT NULL  THEN  option.value_label
      ELSE option.diamond
    END AS diamond_value
  FROM {{source('glamira','summary')}},
  UNNEST(option) AS  option
  WHERE option.option_label = 'diamond' OR option.option_label IS NULL

  UNION DISTINCT

  SELECT
    coalesce(option.value_label,'unknown') AS diamond_value
  FROM {{source('glamira','summary')}},
  UNNEST(cart_products) AS cart_products,
  UNNEST(cart_products.option) AS  option
  WHERE option.option_label = 'diamond'
)

,dim_diamond__handle_null AS (
  SELECT
    COALESCE(diamond_value,'Undefined') AS diamond_value
  FROM dim_diamond__source
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['diamond_value']) }} AS diamond_key
    ,diamond_value as diamond_value_label
FROM dim_diamond__handle_null