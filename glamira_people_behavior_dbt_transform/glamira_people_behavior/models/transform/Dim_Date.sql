WITH dim_date__source AS (
    SELECT DISTINCT 
        time_stamp
    FROM {{ source('glamira', 'summary') }}
),

dim_date__extract AS (
    SELECT
        EXTRACT(DATE FROM TIMESTAMP_SECONDS(time_stamp)) AS full_date,
        EXTRACT(YEAR FROM TIMESTAMP_SECONDS(time_stamp)) AS year,
        EXTRACT(MONTH FROM TIMESTAMP_SECONDS(time_stamp)) AS month,
        EXTRACT(QUARTER FROM TIMESTAMP_SECONDS(time_stamp)) AS quarter,
        EXTRACT(DAY FROM TIMESTAMP_SECONDS(time_stamp)) AS day_of_month,
        EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) AS day_of_week,
        FORMAT_TIMESTAMP('%A', TIMESTAMP_SECONDS(time_stamp)) AS day_of_week_string, -- Lấy tên đầy đủ của ngày
        FORMAT_TIMESTAMP('%a', TIMESTAMP_SECONDS(time_stamp)) AS day_of_week_short,  -- Lấy tên viết tắt của ngày
        CASE
            WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) IN (2, 3, 4, 5, 6) THEN 'Weekday'
            ELSE 'Weekend'
        END AS is_weekday_or_weekend
    FROM dim_date__source
)

SELECT DISTINCT
    CONCAT(year, month, day_of_month) AS date_key,
    *
FROM dim_date__extract;
