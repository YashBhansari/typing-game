-- Typing Game Database Schema
-- Run this once against your PostgreSQL database: psql -d typinggame -f typinggame.sql

CREATE TABLE IF NOT EXISTS users (
    id            SERIAL PRIMARY KEY,
    username      VARCHAR(100) NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(64)  NOT NULL,
    join_date     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quotes (
    id    SERIAL PRIMARY KEY,
    quote TEXT         NOT NULL,
    movie VARCHAR(255),
    type  VARCHAR(20),
    year  INT
);

CREATE TABLE IF NOT EXISTS scores (
    id         SERIAL PRIMARY KEY,
    user_id    INT            NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    quote_id   INT            NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
    wpm        NUMERIC(6, 2)  NOT NULL,
    accuracy   NUMERIC(5, 2)  NOT NULL,
    time_taken NUMERIC(8, 3)  NOT NULL,
    played_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for leaderboard and stats queries
CREATE INDEX IF NOT EXISTS idx_scores_user_id  ON scores(user_id);
CREATE INDEX IF NOT EXISTS idx_scores_wpm_desc ON scores(wpm DESC);

-- Fix curly quotes in existing quote data (run once after CSV import)
-- UPDATE quotes
--   SET quote = REPLACE(REPLACE(REPLACE(REPLACE(quote,
--     '\u2018', ''''),
--     '\u2019', ''''),
--     '\u201C', '"'),
--     '\u201D', '"');

-- To import quotes from CSV (adjust path for your system):
-- COPY quotes(quote, movie, type, year)
-- FROM '/path/to/movie_quotes.csv'
-- DELIMITER ','
-- CSV HEADER
-- QUOTE '"';
