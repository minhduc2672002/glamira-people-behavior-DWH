{% macro normalize_price(price_column) %}
    CASE
        -- Nếu giá trị `price` có định dạng hợp lệ (1,000.00)
        WHEN REGEXP_CONTAINS({{ price_column }}, r'^[0-9]{1,3}(,[0-9]{3})*\.[0-9]{2}$') THEN 
            CAST(REPLACE({{ price_column }}, ',', '') AS FLOAT64)
        
        -- Nếu giá trị `price` có định dạng không hợp lệ (1.88,00 hoặc 1'88,00 hoặc 60,00)
        ELSE 
            CAST(
                REGEXP_REPLACE(
                    REPLACE(REPLACE({{ price_column }}, "'", ''), '.', ''), 
                    r"[٫,]", '.'
                ) 
                AS FLOAT64
            )
    END
{% endmacro %}
