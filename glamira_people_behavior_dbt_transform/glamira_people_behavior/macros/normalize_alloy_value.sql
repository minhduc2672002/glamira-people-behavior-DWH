{% macro normalize_alloy_value(alloy_column) %}
    CASE
        -- Nếu `alloy_value` chứa số, chuẩn hóa phần trước và sau số
        WHEN REGEXP_CONTAINS({{ alloy_column }}, r'[0-9]') THEN CONCAT(
            REGEXP_REPLACE(
                SUBSTR(
                    {{ alloy_column }},
                    1,
                    REGEXP_INSTR({{ alloy_column }}, r'[0-9]') - 1
                ),
                r'[_-]', ' '
            ),
            ' ',
            REGEXP_EXTRACT({{ alloy_column }}, r'[0-9]+')
        )
        -- Nếu `alloy_value` rỗng, trả về NULL
        WHEN {{ alloy_column }} LIKE '' THEN NULL
        
        -- Nếu `alloy_value` không chứa số, chỉ thay thế ký tự `_` và `-` bằng khoảng trắng
        ELSE REGEXP_REPLACE({{ alloy_column }}, r'[_-]', ' ')
    END
{% endmacro %}
