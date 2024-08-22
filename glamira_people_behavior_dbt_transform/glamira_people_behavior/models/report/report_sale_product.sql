SELECT
    p.product_name
    ,SUM(total_price) AS total_revenue
FROM {{ref('Fact_Sale')}} AS s
LEFT JOIN {{ref('Dim_Product')}} AS p 
    ON p.product_key=s.product_key
GROUP BY 1