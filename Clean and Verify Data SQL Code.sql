WITH total_minute AS (
SELECT * EXCEPT (day_of_week),
DATE_DIFF(ended_at,started_at, MINUTE) AS total_minutes,
CASE
WHEN day_of_week=1 THEN 'Sunday'
WHEN day_of_week=2 THEN 'Monday'
WHEN day_of_week=3 THEN 'Tuesday'
WHEN day_of_week=4 THEN 'Wednesday'
WHEN day_of_week=5 THEN 'Thursday'
WHEN day_of_week=6 THEN 'Friday'
ELSE 'Saturday'
END
AS day_week
FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.combined_year_data` 
),

null_cleaned_data AS (
  SELECT *
  FROM total_minute
  WHERE start_station_name NOT LIKE '%NULL%'
          AND start_station_id NOT LIKE '%NULL%'
            AND end_station_name NOT LIKE '%NULL%'
              AND end_station_id NOT LIKE '%NULL%'
),

clean_ride_id_data AS
(
	SELECT *
	FROM null_cleaned_data
	WHERE LENGTH(ride_id) = 16 AND total_minutes >= 1
),

clean_startend_station_name AS (
  SELECT ride_id,
  TRIM(REPLACE(REPLACE(start_station_name,'(*)',''),'(Temp)','')) AS start_station_name_clean,
  TRIM(REPLACE(REPLACE(end_station_name,'(*)',''),'(Temp)','')) AS end_station_name_clean
  FROM clean_ride_id_data
  WHERE start_station_name NOT LIKE '%(LBS-WH-TEST)%' AND end_station_name NOT LIKE '%(LBS-WH-TEST)%'
),

final_cleaned_table AS (
  SELECT cssn.ride_id, crid.rideable_type, crid.member_casual, crid.day_week, CAST(crid.started_at AS DATE) AS dat_in_year, crid.ended_at,
  crid.total_minutes, cssn.start_station_name_clean, cssn.end_station_name_clean, crid.start_lat, crid.start_lng, crid.end_lat, crid.end_lng
  FROM clean_ride_id_data AS crid
    JOIN clean_startend_station_name AS cssn
    ON crid.ride_id=cssn.ride_id
)

SELECT *
FROM final_cleaned_table
