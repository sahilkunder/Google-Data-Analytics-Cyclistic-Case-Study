WITH 

/* Getting data of departing member types from each station */

casual_riders_per_station AS (
  SELECT COUNT(member_casual) AS number_of_casual_riders, start_station_name_clean
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  WHERE member_casual = 'casual'
  GROUP BY start_station_name_clean
),

member_riders_per_station AS (
  SELECT COUNT(member_casual) AS number_of_member_riders, start_station_name_clean
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  WHERE member_casual = 'member'
  GROUP BY start_station_name_clean 
),

membertype_per_station AS (
  SELECT crps.start_station_name_clean, mrps.start_station_name_clean AS start_station_name_clean_2, crps.number_of_casual_riders, mrps.number_of_member_riders
  FROM casual_riders_per_station AS crps
  FULL OUTER JOIN member_riders_per_station AS mrps
    ON crps.start_station_name_clean=mrps.start_station_name_clean
),

membertype_per_station_cleaned AS (
  SELECT * EXCEPT (number_of_casual_riders,number_of_member_riders),
  IFNULL(membertype_per_station.number_of_member_riders, 0) AS Member,
  IFNULL(membertype_per_station.number_of_casual_riders, 0) AS Casual
  FROM membertype_per_station

),

member_type_per_station AS (
SELECT *,
CASE
  WHEN start_station_name_clean IS NULL THEN start_station_name_clean_2
  ELSE start_station_name_clean
END AS start_station_name,

FROM membertype_per_station_cleaned
),

average_geo_info_start_stations AS (
SELECT start_station_name_clean, ROUND(AVG(start_lat),4) AS depart_lat, ROUND(AVG(start_lng),4) AS depart_lng
FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
GROUP BY start_station_name_clean
),

geoviz_depart_stations AS(
SELECT ag.start_station_name_clean, mtps.Member, mtps.Casual, ag.depart_lat, ag.depart_lng 
FROM average_geo_info_start_stations AS ag
JOIN member_type_per_station AS mtps
ON ag.start_station_name_clean=mtps.start_station_name
),

/* Now the same for arriving stations */

casual_riders_per_station_arrive AS (
  SELECT COUNT(member_casual) AS number_of_casual_riders_arrive, end_station_name_clean
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  WHERE member_casual = 'casual'
  GROUP BY end_station_name_clean
),

member_riders_per_station_arrive AS (
  SELECT COUNT(member_casual) AS number_of_member_riders_arrive, end_station_name_clean
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  WHERE member_casual = 'member'
  GROUP BY end_station_name_clean 
), 

membertype_per_station_arrive AS (
  SELECT crpa.end_station_name_clean, mrpa.end_station_name_clean AS end_station_name_clean_2, crpa.number_of_casual_riders_arrive, mrpa.number_of_member_riders_arrive
  FROM casual_riders_per_station_arrive AS crpa
  FULL OUTER JOIN member_riders_per_station_arrive AS mrpa
    ON crpa.end_station_name_clean=mrpa.end_station_name_clean
),

membertype_per_station_cleaned_arrive AS (
  SELECT * EXCEPT (number_of_casual_riders_arrive,number_of_member_riders_arrive),
  IFNULL(membertype_per_station_arrive.number_of_member_riders_arrive, 0) AS Member,
  IFNULL(membertype_per_station_arrive.number_of_casual_riders_arrive, 0) AS Casual
  FROM membertype_per_station_arrive

),

member_type_per_station_arrive AS (
SELECT *,
CASE
  WHEN end_station_name_clean IS NULL THEN end_station_name_clean_2
  ELSE end_station_name_clean
END AS end_station_name,

FROM membertype_per_station_cleaned_arrive
),

average_geo_info_end_stations AS (
SELECT end_station_name_clean, ROUND(AVG(end_lat),4) AS arrive_lat, ROUND(AVG(end_lng),4) AS arrive_lng
FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
GROUP BY end_station_name_clean
),

geoviz_arrive_stations AS(
SELECT age.end_station_name_clean, mtpa.Member, mtpa.Casual, age.arrive_lat, age.arrive_lng 
FROM average_geo_info_end_stations AS age
JOIN member_type_per_station_arrive AS mtpa
ON age.end_station_name_clean=mtpa.end_station_name
),

/* Calculating the rider types on specific dates within the 5 months*/

casual_riders_on_date AS (
  SELECT dat_in_year, COUNT(member_casual) AS Casual
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  WHERE member_casual = 'casual'
  GROUP BY dat_in_year
),

member_riders_on_date AS (
  SELECT dat_in_year, COUNT(member_casual) AS Member
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  WHERE member_casual = 'member'
  GROUP BY dat_in_year
),

count_rider_type_date AS (
  SELECT mrd.dat_in_year, crd.Casual, mrd.Member
  FROM member_riders_on_date AS mrd
  JOIN casual_riders_on_date AS crd
  ON mrd.dat_in_year=crd.dat_in_year
),

/* Calculating total rider types within the 5 months */

count_rider_type_total AS (
  SELECT member_casual, COUNT(member_casual) AS total_riders
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  GROUP BY member_casual
),

/* Calculating total rider types based on day of the week */

count_casual_per_day AS (
  SELECT day_week,  
  COUNT (member_casual) AS Casual,
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  WHERE member_casual = 'casual'
  GROUP BY day_week
),

count_member_per_day AS (
  SELECT day_week,  
  COUNT (member_casual) AS Member,
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  WHERE member_casual = 'member'
  GROUP BY day_week
),

count_rider_type_day_of_week AS (
  SELECT cc.day_week, cc.Casual, cm.Member
  FROM count_casual_per_day AS cc
  JOIN count_member_per_day AS cm
  ON cc.day_week=cm.day_week
),

/* calculate the average ride time for different member types */

avg_ride_time_rider_type AS (
  SELECT member_casual, ROUND(AVG(total_minutes),2) AS average_ride_time
  FROM `coursera-trial-364606.Combined_cleaned_divvy_tripdata.final_cleaned_table`
  GROUP BY member_casual
)

SELECT *
FROM avg_ride_time_rider_type




