# Typing Game

A full-stack web app for testing and improving your typing speed using movie quotes. Built with Java Servlets, JSP, and PostgreSQL, deployed on Apache Tomcat.


## Project Structure

- `src/main/java/com/typinggame/dao/UserDAO.java` — User registration, login, and lookup.
- `src/main/java/com/typinggame/dao/ScoreDAO.java` — Score insertion and leaderboard queries.
- `src/main/java/com/typinggame/servlet/AuthServlet.java` — Handles login and register form submissions.
- `src/main/java/com/typinggame/servlet/LogoutServlet.java` — Invalidates user session.
- `src/main/java/com/typinggame/servlet/QuoteServlet.java` — Serves random movie quotes as JSON.
- `src/main/java/com/typinggame/servlet/ScoreServlet.java` — Saves game scores to the database.
- `src/main/java/com/typinggame/servlet/UserStatsServlet.java` — Returns per-user stats as JSON.
- `src/main/java/com/typinggame/util/DBConnection.java` — JDBC connection using `db.properties`.
- `src/main/resources/db.properties` — Your local DB credentials (gitignored).
- `src/main/resources/db.properties.example` — Safe placeholder to commit.
- `src/main/webapp/` — JSP pages and CSS (lander, login, register, game, home).
- `src/main/db/typinggame.sql` — Database schema.
- `src/main/db/movie_quotes.csv` — Quote data for seeding the database.


## Prerequisites

- [Eclipse IDE for Enterprise Java Developers](https://www.eclipse.org/downloads/)
- [Apache Tomcat 9.0](https://tomcat.apache.org/download-90.cgi)
- [PostgreSQL 14+](https://www.postgresql.org/download/)
- [Maven 3.6+](https://maven.apache.org/download.cgi) (or use Eclipse's built-in m2e)
- Java JDK 17+ (Eclipse's bundled JRE works fine)


## Setup

### 1. Database

**Create the database** in pgAdmin:
- Right-click **Databases → Create → Database**, name it `typinggame` → Save

Or run in pgAdmin Query Tool:
```sql
CREATE DATABASE typinggame;
```

**Create tables** — connect to `typinggame`, open Query Tool, paste and run the contents of:
```
src/main/db/typinggame.sql
```

**Import quotes** — in the same Query Tool (update the path to your project):
```sql
COPY quotes(quote, movie, type, year)
FROM 'C:/path/to/project/src/main/db/movie_quotes.csv'
DELIMITER ','
CSV HEADER
QUOTE '"';
```

### 2. Configure credentials

Copy the example file and fill in your details:
```
src/main/resources/db.properties.example  →  src/main/resources/db.properties
```

```properties
db.url=jdbc:postgresql://localhost:5432/typinggame
db.user=postgres
db.password=your_password_here
```

> `db.properties` is listed in `.gitignore` and will never be pushed to GitHub.

### 3. Import into Eclipse

1. **File → Import → Maven → Existing Maven Projects**
2. Browse to the project folder (where `pom.xml` is) → **Finish**
3. Wait for Maven to download dependencies (progress bar, bottom-right)
4. Right-click project → **Properties → Deployment Assembly**
5. Confirm `src/main/resources` maps to `WEB-INF/classes`. If missing, click **Add → Folder** and add it.

### 4. Configure Tomcat

1. **Window → Preferences → Server → Runtime Environments → Add**
2. Select **Apache Tomcat v9.0** → Next → Browse to your Tomcat folder → **Finish**
3. **Window → Show View → Servers**
4. Click *"No servers available. Click this link to create a new server..."*
5. Select **Apache Tomcat v9.0** → **Finish**
6. Double-click the server → **Server Locations** → select **Use Tomcat installation** → Save (`Ctrl+S`)


## Usage

**Start the app:**

Right-click the project → **Run As → Run on Server** → select Tomcat v9.0 → **Finish**

Open your browser and go to:
```
http://localhost:8080/typing-game/
```

Register an account and start typing!

> To open in your default browser instead of Eclipse's built-in one: **Window → Web Browser → Default system web browser**


## Features

- **Movie quote typing tests** — short, medium, and long quotes
- **Live stats** — WPM, accuracy, error count, and timer update as you type
- **Score saving** — every completed test is saved to the database
- **Global leaderboard** — top 20 scores filterable by quote length
- **Personal stats** — your runs, average WPM, top WPM, and average accuracy shown in the navbar
