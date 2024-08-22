SELECT
    dt.year
    ,dt.quater
    ,SUM(total_price) AS total_revenue
FROM {{ref('Fact_Sale')}} AS s
LEFT JOIN {{ref('Dim_Date')}} AS dt 
    ON dt.date_key=s.date_key
GROUP BY 1,2