<%@ page import="java.sql.*, java.util.*, com.typinggame.util.DBConnection" %>
<%@ page import="org.json.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<% 
if (session.getAttribute("username")==null) { 
	response.sendRedirect("login.jsp"); 
	return; 
} 
String username=session.getAttribute("username").toString(); 
Map<String, List<Map<String, Object>>> all_leaderboards = new HashMap<>();
String[] lengths = {"short", "medium", "long"};
for (String lengthParam : lengths) {
	String whereClause = "";
	if ("short".equals(lengthParam)) {
		whereClause = "WHERE char_length(coalesce(q.quote,'')) <= 50"; 
	} else if ("medium".equals(lengthParam)) {
		whereClause="WHERE char_length(coalesce(q.quote,'')) BETWEEN 51 AND 140" ; 
	} else if ("long".equals(lengthParam)) { 
		whereClause="WHERE char_length(coalesce(q.quote,'')) > 140" ;
	} 
	String sql="SELECT s.*, u.username, q.quote " + "FROM scores s " + "JOIN users u ON s.user_id = u.id " + "LEFT JOIN quotes q ON s.quote_id = q.id " + (whereClause.isEmpty() ? "" : (" " + whereClause)) + " ORDER BY s.wpm DESC, s.accuracy DESC LIMIT 20"; 
	List<Map<String, Object>> records = new ArrayList<>();

	try (Connection conn = DBConnection.get_connection();
	PreparedStatement ps = conn.prepareStatement(sql);
	ResultSet rs = ps.executeQuery()) {
		while (rs.next()) {
			Map<String, Object> record = new HashMap<>();
			record.put("username", rs.getString("username"));
			record.put("quote", rs.getString("quote"));
			record.put("wpm", rs.getDouble("wpm"));
			record.put("accuracy", rs.getDouble("accuracy"));
			record.put("time_taken", rs.getDouble("time_taken"));
			record.put("played_at", rs.getTimestamp("played_at"));
			records.add(record);
		}
	}
	catch (Exception e) {
		getServletContext().log("Error fetching leaderboard for " + lengthParam, e);
	}
	all_leaderboards.put(lengthParam, records);
}
%>

<!DOCTYPE html>
<html>

<head>
	<title>Home</title>
	<link rel="stylesheet" type="text/css" href="home.css">
</head>

<body>
	<div class="navbar">
		<div class="navbar-left">
			<h2>Welcome, <%= username %>
			</h2>
		</div>
		<div>Total Runs: <strong id="totalRuns">--</strong></div>
		<div>Avg WPM: <strong id="avgWpm">--</strong></div>
		<div>Top WPM: <strong id="topWpm">--</strong></div>
		<div>Avg Accuracy: <strong id="avgAcc">--</strong>%</div>
		<div class="navbar-right">
			<a href="game.jsp">Start Typing Test</a>
			<a href="logout.jsp">Logout</a>
		</div>
	</div>

	<h3 style="color:#fff; margin-top:20px;">Top 20 Typing Scores</h3>

	<table>
		<thead>
			<tr>
				<th>Rank</th>
				<th>Username</th>
				<th>Quote</th>
				<th>WPM</th>
				<th>Accuracy (%)</th>
				<th>Time (s)</th>
				<th>Played At</th>
			</tr>
		</thead>
		<tbody id="leaderboard-body"></tbody>
	</table>
	<br>
	<label for="length-select" style="color:#fff;">Text Length:</label>
	<select id="length-select">
		<option value="short">Short</option>
		<option value="medium" selected>Medium</option>
		<option value="long">Long</option>
	</select>


	<script>
		var all_leaderboards = {
			short: JSON.parse(<%= JSONObject.quote(new JSONArray(all_leaderboards.get("short")).toString()) %>),
			medium: JSON.parse(<%= JSONObject.quote(new JSONArray(all_leaderboards.get("medium")).toString()) %>),
			long: JSON.parse(<%= JSONObject.quote(new JSONArray(all_leaderboards.get("long")).toString()) %>)
		};

		async function loadUserStats() {
			try {
				const res = await fetch("<%= request.getContextPath() %>/UserStatsServlet");
				const data = await res.json();
				if (data.error) return;

				document.getElementById("totalRuns").textContent = data.totalRuns || 0;
				document.getElementById("avgWpm").textContent = (data.avgWpm || 0).toFixed(2);
				document.getElementById("topWpm").textContent = (data.topWpm || 0).toFixed(2);
				document.getElementById("avgAcc").textContent = (data.avgAcc || 0).toFixed(2);
			} catch (e) {
				console.error("Failed to load user stats:", e);
			}
		}

		function truncate(str, n) {
			if (!str) return "";
			return str.length > n ? str.substring(0, n - 3) + "..." : str;
		}

		function render_leaderboard(length) {
			var tbody = document.getElementById("leaderboard-body");
			var data = all_leaderboards[length] || [];
			tbody.innerHTML = "";

			for (var i = 0; i < data.length; i++) {
				var row = data[i];
				var wpm = row.wpm ? row.wpm.toFixed(2) : "0.00";
				var acc = row.accuracy ? row.accuracy.toFixed(2) : "0.00";
				var time = row.time_taken ? row.time_taken.toFixed(2) : "0.00";
				var played = row.played_at ? new Date(row.played_at).toLocaleString() : "";
				var quote = row.quote ? row.quote : "";

				var tr = document.createElement("tr");
				tr.innerHTML =
					"<td>" + (i + 1) + "</td>" +
					"<td>" + (row.username || "") + "</td>" +
					"<td class='quote-cell' title=\"" + quote.replace(/"/g, '&quot;') + "\">" +
						truncate(quote, 80) +
					"</td>" +
					"<td>" + wpm + "</td>" +
					"<td>" + acc + "</td>" +
					"<td>" + time + "</td>" +
					"<td>" + played + "</td>";

				tbody.appendChild(tr);
			}
		}

		document.addEventListener("DOMContentLoaded", function () {
			var select = document.getElementById("length-select");
			select.addEventListener("change", function () {
				render_leaderboard(this.value);
			});

			render_leaderboard("medium");
			loadUserStats();
		});
	</script>
</body>

</html>