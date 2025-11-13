<%@ page import="java.sql.*, java.util.*, com.typinggame.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("username") == null)
    {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = session.getAttribute("username").toString();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Typing Game</title>
    <link rel="stylesheet" type="text/css" href="game.css">
</head>
<body onload="fetch_quote()">

    <div class="navbar">
        <div class="navbar-left">
            <h2>Welcome, <%= username %></h2>
        </div>
        <div>Total Runs: <strong id="totalRuns">--</strong></div>
        <div>Avg WPM: <strong id="avgWpm">--</strong></div>
        <div>Top WPM: <strong id="topWpm">--</strong></div>
        <div>Avg Accuracy: <strong id="avgAcc">--</strong>%</div>
        <div class="navbar-right">
        	<a href="home.jsp">Leaderboard</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>
	<br>
    <div id="quote_display"></div>
    <div id="movie"></div>
    <br>

    <textarea id="user_input" oninput="on_type()" placeholder="Start typing here..."></textarea>
    <div id="result" style="margin-top:10px;"></div>
    
    <div>
		<label for="quote_type" style="color:#fff;">Text Length:</label>
		<select id="quote_type">
			<option value="short">Short</option>
			<option value="medium" selected>Medium</option>
			<option value="long">Long</option>
		</select>
		<a href="#" onclick="fetch_quote(); return false;">New Quote</a>
    </div>
<script>
    let quote_text = "";
    let quote_id = null;
    let startTime = null;
    let timerInterval = null;

    let typed = 0;
    let correct = 0;
    let errors = 0;
    let finished = false;

    
    document.addEventListener("DOMContentLoaded", loadUserStats);

    
    
    
    async function loadUserStats() {
        try {
            const res = await fetch("<%= request.getContextPath() %>/UserStatsServlet");
            const data = await res.json();
            if (!data || data.error) return;

            document.getElementById("totalRuns").textContent = data.totalRuns ?? 0;
            document.getElementById("avgWpm").textContent = (data.avgWpm ?? 0).toFixed(2);
            document.getElementById("topWpm").textContent = (data.topWpm ?? 0).toFixed(2);
            document.getElementById("avgAcc").textContent = (data.avgAcc ?? 0).toFixed(2);
        } catch (err) {
            console.error(err);
        }
    }

    
    
    
    async function fetch_quote() {
        const type = document.getElementById("quote_type").value;

        try {
            const res = await fetch("QuoteServlet?type=" + encodeURIComponent(type));
            const data = await res.json();

            if (data.error) {
                document.getElementById("quote_display").innerText = "Error: " + data.error;
                return;
            }

            
            finished = false;
            clearInterval(timerInterval);

            quote_text = data.quote.trim();
            quote_id = data.id;

            render_quote(quote_text);

            document.getElementById("movie").innerText =
                "- " + data.movie + " (" + data.year + ")";

            reset_typing();
        } catch (e) {
            console.error(e);
        }
    }

    
    
    
    function render_quote(text) {
        const box = document.getElementById("quote_display");
        box.innerHTML = "";
        for (let c of text) {
            const span = document.createElement("span");
            span.textContent = c;
            box.appendChild(span);
        }
    }

    
    
    
    function reset_typing() {
        let input = document.getElementById("user_input");
        input.value = "";
        input.disabled = false;
        input.focus();

        typed = 0;
        correct = 0;
        errors = 0;
        startTime = null;

        document.getElementById("result").innerHTML = "WPM: 0 | Accuracy: 0% | Time: 0s";

        
        clearInterval(timerInterval);
        timerInterval = setInterval(updateLiveStats, 100);
    }

    
    
    
    function updateLiveStats() {
        if (!startTime) return;
        if (finished) return;

        const now = new Date();
        const seconds = (now - startTime) / 1000;
        const minutes = seconds / 60;

        const wpm = minutes > 0 ? ((correct / 5) / minutes) : 0;
        const accuracy = typed > 0 ? ((typed - errors) / typed) * 100 : 100;

        document.getElementById("result").innerHTML =
            "WPM: " + wpm.toFixed(2) +
            " | Accuracy: " + accuracy.toFixed(2) + "%" +
            " | Time: " + seconds.toFixed(1) + "s";
    }

    
    
    
    async function on_type() {
        if (finished) return;

        const input = document.getElementById("user_input").value;
        const spans = document.querySelectorAll("#quote_display span");

        if (!startTime && input.length > 0) {
            startTime = new Date();
        }

        typed = input.length;
        correct = 0;
        errors = 0;

        for (let i = 0; i < spans.length; i++) {
            const typedChar = input[i];

            if (typedChar == null) {
                spans[i].className = "";
                continue;
            }

            if (typedChar === quote_text[i]) {
                spans[i].className = "correct";
                correct++;
            } else {
                spans[i].className = "wrong";
                errors++;
            }
        }

        if (input === quote_text) {
            finishRun();
        }
    }

    
    
    
	async function finishRun() {
		if (finished) return;
		finished = true;

		clearInterval(timerInterval);

		const input = document.getElementById("user_input").value;
		document.getElementById("user_input").disabled = true;

		
		let correctChars = 0;
		for (let i = 0; i < input.length; i++) {
			if (input[i] === quote_text[i]) correctChars++;
		}

		const typedChars = input.length;
		const totalChars = quote_text.length;

		const percentTyped = (typedChars / totalChars) * 100;

		
		
		
		if (percentTyped < 60) {
			document.getElementById("result").innerHTML =
				"❌ You typed only " + percentTyped.toFixed(1) + "% of the quote.<br>" +
				"Score NOT saved (minimum 60% required).";
			return; 
		}

		
		const errorsFinal = typedChars - correctChars;

		const now = new Date();
		const seconds = (now - startTime) / 1000;
		const minutes = seconds / 60;

		const wpm = minutes > 0 ? (correctChars / 5) / minutes : 0;
		const accuracy = typedChars > 0 ? (correctChars / typedChars) * 100 : 100;

		document.getElementById("result").innerHTML =
			"WPM: " + wpm.toFixed(2) +
			" | Accuracy: " + accuracy.toFixed(2) + "%" +
			" | Time: " + seconds.toFixed(1) + "s" +
			"<br><span style='color:#66ff66'>✔ Score saved</span>";

		await save_score(
			wpm.toFixed(2),
			accuracy.toFixed(2),
			seconds.toFixed(1)
		);

		loadUserStats();
}


    
    
    
    document.addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
            e.preventDefault();
            finishRun();
        }
    });

    
    
    
    async function save_score(wpm, acc, time) {
        try {
            const params = new URLSearchParams();
            params.append("quote_id", quote_id);
            params.append("wpm", wpm);
            params.append("accuracy", acc);
            params.append("time_taken", time);

            await fetch("ScoreServlet", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: params.toString()
            });
        } catch (err) {
            console.error("Score save error:", err);
        }
    }
</script>

</body>
</html>
