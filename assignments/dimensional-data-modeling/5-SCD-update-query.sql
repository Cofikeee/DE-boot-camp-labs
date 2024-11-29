-- TASK 5
CREATE TYPE scd_type AS (
                    quality_class quality_class,
                    start_date INTEGER,
                    end_date INTEGER,
                    is_active BOOLEAN
                        );


WITH last_year_scd AS (
        SELECT *
        FROM actors_history_scd
        WHERE current_year = 1971
        AND end_date = 1971
     ),
    historical_scd AS (
        SELECT  actorid,
                actor,
                quality_class,
                start_date,
                end_date,
                is_active
        FROM actors_history_scd
        WHERE current_year = 1971
        AND end_date < 1971
    ),
     this_year_data AS (
         SELECT * FROM actors
         WHERE current_year = 1972
     ),
     unchanged_records AS (
         SELECT
                ty.actorid,
                ty.actor,
                ty.quality_class,
                ly.start_date,
                ty.current_year as end_date,
                ty.is_active
        FROM this_year_data ty
        JOIN last_year_scd ly
        ON ly.actorid = ty.actorid
         WHERE ty.quality_class = ly.quality_class
         AND ty.is_active = ly.is_active
     ),
     changed_records AS (
        SELECT
                ty.actorid,
                ty.actor,
                UNNEST(ARRAY[
                    ROW(
                        ly.quality_class,
                        ly.start_date,
                        ly.end_date,
                        ly.is_active
                        )::scd_type,
                    ROW(
                        ty.quality_class,
                        ty.current_year,
                        ty.current_year,
                        ty.is_active
                        )::scd_type
                ]) as records
        FROM this_year_data ty
        JOIN last_year_scd ly
        ON ly.actorid = ty.actorid
         WHERE (ty.quality_class <> ly.quality_class
          OR ty.is_active <> ly.is_active)
     ),
     unnested_changed_records AS (

         SELECT actorid,
                actor,
                (records::scd_type).quality_class,
                (records::scd_type).start_date,
                (records::scd_type).end_date,
                (records::scd_type).is_active
                FROM changed_records
         ),
     new_records AS (
         SELECT
                ty.actorid,
                ty.actor,
                ty.quality_class,
                ty.current_year AS start_date,
                ty.current_year AS end_date,
                ty.is_active
        FROM this_year_data ty
        LEFT JOIN last_year_scd ly
        ON ty.actorid = ly.actorid
         WHERE ly.actorid IS NULL

     )


SELECT *, 1972 AS current_year FROM (
                  SELECT *
                  FROM historical_scd

                  UNION ALL

                  SELECT *
                  FROM unchanged_records

                  UNION ALL

                  SELECT *
                  FROM unnested_changed_records

                  UNION ALL

                  SELECT *
                  FROM new_records
              ) as t1
