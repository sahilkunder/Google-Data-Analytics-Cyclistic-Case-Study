WITH H
combined_year_data AS (

SELECT *  
FROM `coursera-trial-364606.Divvy_Bike_Data.202101_divvy_tripdata` 
UNION ALL
SELECT *
FROM `coursera-trial-364606.Divvy_Bike_Data.202102_divvy_tripdata` 
UNION ALL
SELECT *
FROM `coursera-trial-364606.Divvy_Bike_Data.202103_divvy_tripdata` 
UNION ALL
SELECT *
FROM `coursera-trial-364606.Divvy_Bike_Data.202104_divvy_tripdata` 
UNION ALL
SELECT *
FROM `coursera-trial-364606.Divvy_Bike_Data.202105_divvy_tripdata` 
)

SELECT *
FROM combined_year_data
