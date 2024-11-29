-- DDL for actors table with custom types films, quality_class


CREATE TYPE films AS (
    year INT,
    film TEXT,
    votes INT,
    rating REAL,
    filmid TEXT
);


CREATE TYPE quality_class AS ENUM ('star', 'good', 'average', 'bad');


CREATE TABLE actors (
    actorid TEXT,
    actor TEXT,
    current_year INT,
    films films[],
    quality_class quality_class,
    is_active BOOLEAN,
    PRIMARY KEY(actorid, current_year)
);
