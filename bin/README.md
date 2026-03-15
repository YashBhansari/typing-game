# Typing Game

A movie-quote typing speed game built with Java Servlets, JSP, and PostgreSQL.

## Features
- User registration and login (SHA-256 hashed passwords)
- Movie quotes fetched randomly by length (short / medium / long)
- Live WPM, accuracy, error count and timer while typing
- Scores saved per user per quote
- Global leaderboard filterable by text length
- Personal stats in the navbar (runs, avg WPM, top WPM, avg accuracy)
- Landing page for logged-out visitors

## Tech Stack
- **Backend:** Java 8, Servlets (javax.servlet 4), JSP
- **Database:** PostgreSQL 14+
- **Build:** Maven 3, packaged as `.war`
- **Server:** Apache Tomcat 9+

## Setup

### 1. Database
```sql
-- Create the database
CREATE DATABASE typinggame;

-- Run the schema
psql -d typinggame -f src/main/db/typinggame.sql

-- Import quotes (adjust path)
COPY quotes(quote, movie, type, year)
FROM '/absolute/path/to/movie_quotes.csv'
DELIMITER ',' CSV HEADER QUOTE '"';
```

### 2. Configuration
Set these environment variables (or edit `DBConnection.java` for local dev):

| Variable      | Default                                  |
|---------------|------------------------------------------|
| `DB_URL`      | `jdbc:postgresql://localhost:5432/typinggame` |
| `DB_USER`     | `postgres`                               |
| `DB_PASSWORD` | `changeme`                               |

### 3. Build & Deploy
```bash
mvn clean package
# Deploy target/typing-game.war to Tomcat's webapps/ directory
```

Then open: `http://localhost:8080/typing-game/`

## Project Structure
```
src/main/
├── java/com/typinggame/
│   ├── dao/
│   │   ├── UserDAO.java        # User CRUD + password hashing
│   │   └── ScoreDAO.java       # Score insert + leaderboard queries
│   ├── servlet/
│   │   ├── AuthServlet.java    # Login / register
│   │   ├── LogoutServlet.java  # Session invalidation
│   │   ├── QuoteServlet.java   # Serves random quotes as JSON
│   │   ├── ScoreServlet.java   # Saves game scores
│   │   └── UserStatsServlet.java # Returns per-user stats as JSON
│   └── util/
│       └── DBConnection.java   # JDBC connection (env-var configurable)
├── webapp/
│   ├── lander.jsp     # Public landing page
│   ├── login.jsp      # Login form
│   ├── register.jsp   # Registration form
│   ├── home.jsp       # Leaderboard (auth required)
│   ├── game.jsp       # Typing game (auth required)
│   ├── logout.jsp     # Redirect to /logout servlet
│   ├── auth.css
│   ├── game.css
│   ├── home.css
│   ├── lander.css
│   └── WEB-INF/
│       └── web.xml
└── db/
    └── typinggame.sql
```

## Known Fixes Applied (vs original)
- `auth.css`: Removed `width: 200%` on `.container` (caused overflow on all screens)
- `DBConnection.java`: Credentials moved to environment variables (no hardcoded password)
- `AuthServlet.java`: Errors forwarded via request attributes instead of query-string params; proper server-side input validation added
- `home.jsp`: Raw JDBC removed — leaderboard now uses `ScoreDAO`; user data rendered via safe DOM API (no XSS via `innerHTML`)
- `game.jsp`: Error counter fixed; live timer via `setInterval`; completion banner with save confirmation
- `UserStatsServlet.java`: Now queries by `user_id` (integer) instead of joining on username string
- `ScoreServlet.java`: Input bounds validation (WPM 0–300, accuracy 0–100)
- `QuoteServlet.java`: Only whitelisted length values accepted — no user input ever interpolated into SQL
- `lander.jsp`: Was empty; now a proper public landing page
- `pom.xml`: Removed duplicate `javax.servlet-api` dependency
- `typinggame.sql`: Removed stray `SELECT *` and bare `COMMIT`; added foreign key constraints and indexes
- `web.xml`: All servlets registered; `lander.jsp` set as welcome file; session timeout configured
