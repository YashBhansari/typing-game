<%@ page import="java.util.*, com.typinggame.dao.ScoreDAO" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<%!
    // Page-level helper — must be declared OUTSIDE scriptlets (<%! not <%)
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private String rowsToJson(List<ScoreDAO.LeaderboardRow> rows) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < rows.size(); i++) {
            ScoreDAO.LeaderboardRow r = rows.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"username\":\"").append(escapeJson(r.username)).append("\",");
            sb.append("\"quote\":\"").append(escapeJson(r.quote != null ? r.quote : "")).append("\",");
            sb.append("\"movie\":\"").append(escapeJson(r.movie != null ? r.movie : "")).append("\",");
            sb.append("\"wpm\":").append(r.wpm).append(",");
            sb.append("\"accuracy\":").append(r.accuracy).append(",");
            sb.append("\"time_taken\":").append(r.timeTaken).append(",");
            sb.append("\"played_at\":\"").append(r.playedAt != null ? r.playedAt.toString() : "").append("\"");
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }
%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = session.getAttribute("username").toString();

    // Fetch all three leaderboards via DAO (no raw JDBC in JSP)
    List<ScoreDAO.LeaderboardRow> shortRows  = ScoreDAO.getTopScores("short",  20);
    List<ScoreDAO.LeaderboardRow> mediumRows = ScoreDAO.getTopScores("medium", 20);
    List<ScoreDAO.LeaderboardRow> longRows   = ScoreDAO.getTopScores("long",   20);

    // Build JSON strings once at the top — avoids multi-scriptlet variable scoping issues
    String shortJson  = rowsToJson(shortRows);
    String mediumJson = rowsToJson(mediumRows);
    String longJson   = rowsToJson(longRows);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leaderboard – Typing Game</title>
    <link rel="stylesheet" href="home.css">
</head>
<body>
    <div class="navbar">
        <div class="navbar-left">
            <h2>⌨️ Typing Game</h2>
        </div>
        <div class="navbar-stats">
            <span>Runs: <strong id="totalRuns">--</strong></span>
            <span>Avg WPM: <strong id="avgWpm">--</strong></span>
            <span>Top WPM: <strong id="topWpm">--</strong></span>
            <span>Avg Acc: <strong id="avgAcc">--</strong>%</span>
        </div>
        <div class="navbar-right">
            <span class="navbar-user">👤 <%= username %></span>
            <a href="game.jsp">Start Typing</a>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
    </div>

    <div class="page-content">
        <div class="leaderboard-header">
            <h3>🏆 Top 20 Scores</h3>
            <div class="filter-section">
                <label for="length-select">Text Length:</label>
                <select id="length-select">
                    <option value="short">Short (≤50 chars)</option>
                    <option value="medium" selected>Medium (51–140 chars)</option>
                    <option value="long">Long (&gt;140 chars)</option>
                </select>
            </div>
        </div>

        <table id="leaderboard-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Player</th>
                    <th>Quote</th>
                    <th>WPM</th>
                    <th>Accuracy</th>
                    <th>Time (s)</th>
                    <th>Played At</th>
                </tr>
            </thead>
            <tbody id="leaderboard-body"></tbody>
        </table>

        <p id="no-scores" style="display:none; color:#888; text-align:center; margin-top:30px;">
            No scores yet for this category. Be the first!
        </p>
    </div>

<script>
    // Leaderboard data injected from server — JSON built safely in Java at page top
    var leaderboards = {
        short:  <%= shortJson %>,
        medium: <%= mediumJson %>,
        long:   <%= longJson %>
    };

    async function loadUserStats() {
        try {
            const res = await fetch("UserStatsServlet");
            const data = await res.json();
            if (data.error) return;
            document.getElementById("totalRuns").textContent = data.totalRuns || 0;
            document.getElementById("avgWpm").textContent    = (data.avgWpm || 0).toFixed(1);
            document.getElementById("topWpm").textContent    = (data.topWpm || 0).toFixed(1);
            document.getElementById("avgAcc").textContent    = (data.avgAcc || 0).toFixed(1);
        } catch (e) {
            console.error("Failed to load user stats:", e);
        }
    }

    function truncate(str, n) {
        if (!str) return "";
        return str.length > n ? str.substring(0, n - 3) + "…" : str;
    }

    function renderLeaderboard(length) {
        var tbody = document.getElementById("leaderboard-body");
        var noScores = document.getElementById("no-scores");
        var data = leaderboards[length] || [];
        tbody.innerHTML = "";

        if (data.length === 0) {
            noScores.style.display = "block";
            document.getElementById("leaderboard-table").style.display = "none";
            return;
        }

        noScores.style.display = "none";
        document.getElementById("leaderboard-table").style.display = "table";

        for (var i = 0; i < data.length; i++) {
            var row = data[i];
            var tr  = document.createElement("tr");
            if (row.username === '<%= username %>') tr.classList.add("current-user");

            // Safe text content assignment (no innerHTML for user data)
            var rankTd    = document.createElement("td"); rankTd.textContent    = i + 1;
            var userTd    = document.createElement("td"); userTd.textContent    = row.username || "";
            var quoteTd   = document.createElement("td"); quoteTd.className     = "quote-cell";
                quoteTd.textContent = truncate(row.quote, 80);
                if (row.quote) quoteTd.title = row.quote;
            var wpmTd     = document.createElement("td"); wpmTd.textContent     = (row.wpm || 0).toFixed(1);
            var accTd     = document.createElement("td"); accTd.textContent     = (row.accuracy || 0).toFixed(1) + "%";
            var timeTd    = document.createElement("td"); timeTd.textContent    = (row.time_taken || 0).toFixed(2);
            var playedTd  = document.createElement("td");
                playedTd.textContent = row.played_at ? new Date(row.played_at).toLocaleString() : "";

            tr.appendChild(rankTd); tr.appendChild(userTd); tr.appendChild(quoteTd);
            tr.appendChild(wpmTd);  tr.appendChild(accTd);  tr.appendChild(timeTd);
            tr.appendChild(playedTd);
            tbody.appendChild(tr);
        }
    }

    document.addEventListener("DOMContentLoaded", function () {
        var select = document.getElementById("length-select");
        select.addEventListener("change", function () { renderLeaderboard(this.value); });
        renderLeaderboard("medium");
        loadUserStats();
    });
</script>
</body>
</html>
