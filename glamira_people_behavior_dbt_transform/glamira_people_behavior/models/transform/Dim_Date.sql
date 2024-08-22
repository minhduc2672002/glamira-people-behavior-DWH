WITH dim_date__source AS(
    SELECT DISTINCT 
        time_stamp
    FROM {{source('glamira','summary')}}
)

,dim_date__extract AS (
  SELECT
    EXTRACT(DATE FROM TIMESTAMP_SECONDS(time_stamp)) AS full_date
    ,EXTRACT(YEAR FROM TIMESTAMP_SECONDS(time_stamp)) AS year
    ,EXTRACT(MONTH FROM TIMESTAMP_SECONDS(time_stamp)) AS month 
    ,EXTRACT(QUARTER FROM TIMESTAMP_SECONDS(time_stamp)) AS quarter
    ,EXTRACT(DAY FROM TIMESTAMP_SECONDS(time_stamp)) AS day_of_month
    ,EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) AS day_of_week
    ,CASE
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 1 THEN 'Sunday'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 2 THEN 'Monday'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 3 THEN 'Tuesday'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 4 THEN 'Wednesday'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 5 THEN 'Thursday'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 6 THEN 'Friday'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 7 THEN 'Saturday'
     END AS day_of_week_string
    ,CASE
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 1 THEN 'Sun'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 2 THEN 'Mon'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 3 THEN 'Tues'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 4 THEN 'Wed'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 5 THEN 'Thu'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 6 THEN 'Fri'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) = 7 THEN 'Sat'
     END AS day_of_week_short
    ,CASE
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) in (2,3,4,5,6) THEN 'Weekday'
      WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP_SECONDS(time_stamp)) in (1,7) THEN 'Weekend'
     END AS is_weekday_or_weekend
  FROM dim_date__source)


SELECT DISTINCT
      CONCAT(dim_date.year,dim_date.month,dim_date.day_of_month)   AS date_key
      ,*
FROM dim_date__extract AS dim_date
