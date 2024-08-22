WITH fact_sale__source AS(
    SELECT
        time_stamp
        ,ip
        ,cart_products.*
    FROM {{source('glamira','summary')}} AS glamira_raw,
    UNNEST(cart_products) AS cart_products
    WHERE collection = 'checkout_success'
)

,fact_sale__group_value AS (
    SELECT
        time_stamp
        ,ip
        ,product_id
        ,price
        ,amount
        ,currency
        ,MAX(CASE 
                WHEN option.option_label='alloy' THEN option.value_label ELSE NULL
            END) AS alloy_value
        ,MAX(CASE 
                WHEN option.option_label='diamond' THEN option.value_label ELSE NULL
            END) AS diamond_value
    FROM fact_sale__source,
    UNNEST(option) AS option
    GROUP BY 1,2,3,4,5,6
)

,fact_sale__format_value AS (
    SELECT
        CONCAT(
            EXTRACT(YEAR FROM TIMESTAMP_SECONDS(time_stamp))
            ,EXTRACT(MONTH FROM TIMESTAMP_SECONDS(time_stamp))
            ,EXTRACT(DAY FROM TIMESTAMP_SECONDS(time_stamp))
        ) AS full_date
        ,ip
        ,product_id
        ,diamond_value
        ,CASE 
             WHEN REGEXP_CONTAINS(price, r'^[0-9]{1,3}(,[0-9]{3})*\.[0-9]{2}$') THEN CAST(REPLACE(price,',', '') AS FLOAT64)
             ELSE CAST(REGEXP_REPLACE(REPLACE(REPLACE(price,"'",''),'.','') , r"[٫,]", '.') AS FLOAT64) --invalid value is 1,88.00 and 1'88,00 60,00
         END AS price
        ,amount 
        ,currency
        ,CASE
        -- Nếu chuỗi chứa số, trích xuất phần trước số và số, sau đó thay thế ký tự `_` và `-` bằng khoảng trắng
              WHEN REGEXP_CONTAINS(alloy_value, r'[0-9]') THEN CONCAT(
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
          END AS alloy_value
    FROM fact_sale__group_value
)

,fact_sale__handle_null AS(
    SELECT
        full_date
        ,COALESCE(ip, 'Undefined') AS ip
        ,COALESCE(product_id, 0) AS product_id
        ,COALESCE(diamond_value, 'Undefined') AS diamond_value
        ,COALESCE(alloy_value, 'Undefined') AS alloy_value
        ,price
        ,amount
        ,currency
    FROM fact_sale__format_value
)

,fact_sale__join AS (
    SELECT
        full_date
        ,fact_sale.ip
        ,CASE 
            WHEN ip_location.country_code = '-' OR ip_location.country_code IS NULL THEN 'Undefined'
            ELSE ip_location.country_code
        END AS country_code
        ,CASE 
            WHEN ip_location.country_name = '-' OR ip_location.country_name IS NULL THEN 'Undefined'
            ELSE  ip_location.country_name
         END AS country_name
        ,CASE 
            WHEN ip_location.region_name = '-' OR ip_location.region_name IS NULL THEN 'Undefined'
            ELSE ip_location.region_name  
         END AS region_name
        ,CASE 
            WHEN ip_location.city_name = '-' OR ip_location.city_name IS NULL THEN 'Undefined'
            ELSE ip_location.city_name    
         END AS city_name
        ,CASE 
            WHEN ip_location.postal_code = '-' OR ip_location.postal_code IS NULL THEN 'Undefined'
            ELSE ip_location.postal_code
         END AS postal_code
        ,product_id                                               
        ,alloy_value
        ,diamond_value
        ,price 
        ,amount 
        ,currency
        ,CASE 
            WHEN currency != '' THEN exchange_rate_to_usd
            ELSE 1
        END AS exchange_rate_to_usd
    FROM fact_sale__handle_null AS fact_sale
    LEFT JOIN {{source('glamira','currency_exchange_rates')}} AS currency_exchange_rates
     ON fact_sale.currency = currency_exchange_rates.currency_code
    LEFT JOIN {{source('glamira','ip_to_location')}} AS ip_location
     ON fact_sale.ip = ip_location.ip
)

SELECT
    fact_sale.full_date AS date_key
    ,{{ dbt_utils.generate_surrogate_key(['country_code','country_name','region_name','city_name','postal_code']) }} AS location_key
    ,product_id AS product_key
    ,{{ dbt_utils.generate_surrogate_key(['alloy_value']) }} AS alloy_key
    ,{{ dbt_utils.generate_surrogate_key(['diamond_value']) }} AS diamond_key
    ,price
    ,amount
    ,currency
    ,ROUND(price * amount * exchange_rate_to_usd ,2) AS total_price
FROM fact_sale__join AS fact_sale


