-- DDL for actors_history_scd table
CREATE TABLE actors_history_scd (
    actorid TEXT,
    actor TEXT,
    quality_class quality_class,
    start_date INTEGER,
    end_date INTEGER,
    is_active BOOLEAN,
    current_year INTEGER,
    PRIMARY KEY (actorid, start_date)
);
