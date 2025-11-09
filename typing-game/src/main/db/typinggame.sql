-- Database: typinggame

CREATE TABLE if not exists users
(
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(64) NOT NULL,
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE if not exists quotes
(
    id SERIAL PRIMARY KEY,
    quote TEXT NOT NULL,
    movie VARCHAR(255),
    type VARCHAR(20),
    year INT
);

CREATE TABLE if not exists scores
(
    id SERIAL PRIMARY KEY,
    user_id INT DEFAULT 0,
    wpm NUMERIC(6,2) NOT NULL,
    accuracy NUMERIC(5,2) NOT NULL,
    time_taken NUMERIC(8,3) NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COPY quotes(quote, movie, type, year)
-- FROM 'C:\Program Files\PostgreSQL\18\data\movie_quotes.csv'
-- DELIMITER ','
-- CSV HEADER
-- QUOTE '"';

select * from quotes;
SELECT quote, movie, year FROM quotes WHERE movie IS NULL OR movie = '';

COMMIT;

