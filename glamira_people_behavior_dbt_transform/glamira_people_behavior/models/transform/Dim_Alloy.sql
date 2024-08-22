WITH dim_alloy__source AS (
  SELECT DISTINCT
    CASE 
      WHEN option.value_label IS NOT NULL  THEN  option.value_label
      ELSE option.alloy
    END AS alloy_value
  FROM {{source('glamira','summary')}},
  UNNEST(option) AS  option
  WHERE option.option_label = 'alloy' OR option.option_label IS NULL

  UNION DISTINCT

  SELECT
    option.value_label AS alloy_value
  FROM `people-behavior-glamira`.`glamira`.`summary`,
  UNNEST(cart_products) AS cart_products,
  UNNEST(cart_products.option) AS  option
  WHERE option.option_label = 'alloy'
)

,dim_alloy__format_name AS (
    SELECT
    DISTINCT
    CASE
        -- Nếu chuỗi chứa số, trích xuất phần trước số và số, sau đó thay thế ký tự `_` và `-` bằng khoảng trắng
              WHEN REGEXP_CONTAINS(alloy_value, r'[0-9]') THEN
                  CONCAT(
                      REGEXP_REPLACE(
                          SUBSTR(
                              alloy_value,
                              1,
                              GREATEST(1, REGEXP_INSTR(alloy_value, r'[0-9]') - 2)
                          ),
                          r'[_-]', ' '
                      ),
                      ' ',
                      REGEXP_EXTRACT(alloy_value, r'[0-9]+')
                  )
              WHEN alloy_value LIKE '' THEN NULL
              -- Nếu chuỗi không chứa số, thay thế ký tự `_` và `-` bằng khoảng trắng
              ELSE
                  REGEXP_REPLACE(alloy_value, r'[_-]', ' ')
          END AS alloy_name
    FROM dim_alloy__source
)

,dim_alloy_handle_null AS (
  SELECT
    COALESCE(alloy_name,'Undefined') AS alloy_name
  FROM dim_alloy__format_name
)
SELECT
    DISTINCT
    {{ dbt_utils.generate_surrogate_key(['alloy_name']) }} AS alloy_key
    ,alloy_name
FROM dim_alloy_handle_null