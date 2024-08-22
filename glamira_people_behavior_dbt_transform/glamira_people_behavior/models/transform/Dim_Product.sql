
WITH dim_product__source AS(

    SELECT 
        product_id
    FROM {{source('glamira','summary')}}
    WHERE product_id IS NOT NULL

    UNION ALL

    SELECT 
        cart_prodcuts.product_id AS product_id
    FROM {{source('glamira','summary')}}, 
        UNNEST(cart_products) AS cart_prodcuts
    WHERE cart_prodcuts.product_id IS NOT NULL
)

,dim_product__drop_duplicate AS (
    SELECT DISTINCT
        product_id 
    FROM dim_product__source 
)

SELECT 
    dim_product.product_id AS product_key
    ,COALESCE(stg_product.product_name, 'Undefined') AS product_name
FROM dim_product__drop_duplicate AS dim_product
LEFT JOIN {{source('glamira','products')}} AS stg_product
 ON dim_product.product_id = stg_product.product_id