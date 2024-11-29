-- Cumulative table generation query: Write a query that populates the actors table one year at a time.

INSERT INTO actors (actorid, actor, current_year, films, quality_class, is_active)
WITH lastyear AS (
        SELECT * FROM actors
        WHERE current_year = 1971
),
thisyear AS (
        SELECT
            actorid,
            actor,
            year AS current_year,
            ARRAY_AGG(
                    ROW(
                        year,
                        film,
                        votes,
                        rating,
                        filmid
                      )::films) AS films,
            CASE
                WHEN AVG(rating) > 8 THEN 'star'
                WHEN AVG(rating) > 7 AND AVG(rating) <= 8 THEN 'good'
                WHEN AVG(rating) > 6 AND AVG(rating) <= 7 THEN 'average'
                WHEN AVG(rating) <= 6 THEN 'bad'
                ELSE NULL
            END::quality_class AS quality_class
        FROM actor_films
        WHERE year = 1972
        GROUP BY actor, actorid, year
)

SELECT
    COALESCE(t.actorid, l.actorid) AS actorid,
    COALESCE(t.actor, l.actor) AS actor,
    CASE
        WHEN t.current_year IS NULL THEN l.current_year + 1
        ELSE t.current_year
    END AS current_year,
    -- Merge films from last year and this year
    CASE
        WHEN l.films IS NULL THEN t.films
        WHEN t.films IS NOT NULL THEN l.films || t.films
        ELSE l.films
    END AS films,
    -- Use quality class from this year or last year
    COALESCE(t.quality_class, l.quality_class) AS quality_class,
    -- Determine if the actor is active this year
    CASE
        WHEN t.films IS NOT NULL AND ARRAY_LENGTH(t.films, 1) > 0 THEN TRUE
        ELSE FALSE
    END AS is_active
FROM thisyear t
FULL OUTER JOIN lastyear l
ON t.actorid = l.actorid;
