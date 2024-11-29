-- Backfill query for actors_history_scd

INSERT INTO actors_history_scd
WITH with_previous AS (
    SELECT actorid,
           actor,
           current_year,
           quality_class,
           is_active,
           LAG(quality_class, 1) OVER (PARTITION BY actorid ORDER BY current_year) AS previous_quality_class,
           LAG(is_active, 1) OVER (PARTITION BY actorid ORDER BY current_year) AS previous_is_active
    FROM actors
    WHERE current_year <= 1971
),
     with_indicators AS (
        SELECT *,
               CASE
                   WHEN quality_class <> previous_quality_class THEN 1
                   WHEN is_active <> previous_is_active THEN 1
               ELSE 0
        END AS change_indicator
        FROM with_previous
     ),
    with_streak AS (
        SELECT *,
               SUM(change_indicator) OVER (PARTITION BY actorid ORDER BY current_year) as streak_identifier
        FROM with_indicators
    ),
    aggregated AS (
         SELECT
            actorid,
            actor,
            quality_class,
            streak_identifier,
            MIN(current_year) AS start_date,
            MAX(current_year) AS end_date,
            is_active,
            1971 as current_year

         FROM with_streak
         GROUP BY actorid, actor, quality_class, streak_identifier, is_active
     )

     SELECT actorid, actor, quality_class, start_date, end_date, is_active, current_year
     FROM aggregated;
