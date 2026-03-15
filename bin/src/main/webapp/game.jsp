<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = session.getAttribute("username").toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Typing Game</title>
    <link rel="stylesheet" href="game.css">
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
        <a href="home.jsp">Leaderboard</a>
        <a href="logout" class="logout-btn">Logout</a>
    </div>
</div>

<div class="game-wrapper">

    <div class="controls-bar">
        <label for="quote_type">Text Length:</label>
        <select id="quote_type">
            <option value="short">Short</option>
            <option value="medium" selected>Medium</option>
            <option value="long">Long</option>
        </select>
        <button id="new-quote-btn" onclick="fetch_quote()">New Quote</button>
    </div>

    <div class="quote-box">
        <div id="quote_display"></div>
        <div id="movie"></div>
    </div>

    <textarea id="user_input"
              oninput="on_type()"
              placeholder="Start typing here to begin…"
              spellcheck="false"
              autocomplete="off"
              autocorrect="off"
              autocapitalize="off"></textarea>

    <div class="result-bar">
        <span class="stat-pill" id="stat-wpm">WPM: <strong>0</strong></span>
        <span class="stat-pill" id="stat-acc">Accuracy: <strong>100%</strong></span>
        <span class="stat-pill" id="stat-time">Time: <strong>0.0s</strong></span>
        <span id="stat-errors" class="stat-pill errors">Errors: <strong>0</strong></span>
    </div>

    <div id="finish-banner" style="display:none;">
        <span id="finish-msg"></span>
        <button onclick="fetch_quote()">Try Again</button>
    </div>

</div>

<script>
    let quote_text      = "";
    let quote_id        = null;
    let start_time      = null;
    let timer_id        = null;
    let ever_wrong      = new Set(); // positions that were ever typed incorrectly

    // ── Fetch quote ──────────────────────────────────────────────────────────
    async function fetch_quote() {
        const btn = document.getElementById("new-quote-btn");
        btn.disabled = true;

        hide_banner();
        const type = document.getElementById("quote_type").value;

        try {
            const res  = await fetch("QuoteServlet?type=" + encodeURIComponent(type));
            const data = await res.json();

            if (data.error) {
                show_error("Could not load quote: " + data.error);
                return;
            }

            quote_text = data.quote.trim();
            quote_id   = data.id;
            render_quote(quote_text);

            const movieEl = document.getElementById("movie");
            movieEl.textContent = "— " + (data.movie || "Unknown") + " (" + data.year + ")";

            reset_state();
        } catch (e) {
            console.error(e);
            show_error("Network error. Please try again.");
        } finally {
            btn.disabled = false;
        }
    }

    // ── Render quote as spans ─────────────────────────────────────────────────
    function render_quote(text) {
        const container = document.getElementById("quote_display");
        container.innerHTML = "";
        for (let i = 0; i < text.length; i++) {
            const span = document.createElement("span");
            span.textContent = text[i];
            if (i === 0) span.classList.add("cursor");
            container.appendChild(span);
        }
    }

    // ── Reset input + counters ────────────────────────────────────────────────
    function reset_state() {
        const input = document.getElementById("user_input");
        input.value    = "";
        input.disabled = false;
        input.focus();

        start_time = null;
        ever_wrong = new Set();

        if (timer_id) { clearInterval(timer_id); timer_id = null; }

        update_stats(0, 100, 0, 0);
    }

    // ── Live typing handler ───────────────────────────────────────────────────
    function on_type() {
        const input_val = document.getElementById("user_input").value;
        const spans     = document.querySelectorAll("#quote_display span");

        // Start timer on first keystroke
        if (start_time === null && input_val.length > 0) {
            start_time = Date.now();
            timer_id   = setInterval(tick, 100);
        }

        let correct_chars = 0;

        for (let i = 0; i < spans.length; i++) {
            spans[i].classList.remove("correct", "wrong", "cursor");

            if (i < input_val.length) {
                if (input_val[i] === quote_text[i]) {
                    spans[i].classList.add("correct");
                    correct_chars++;
                } else {
                    spans[i].classList.add("wrong");
                    ever_wrong.add(i);  // mark position as ever-wrong (persists even if corrected)
                }
            } else if (i === input_val.length) {
                spans[i].classList.add("cursor");
            }
        }

        const elapsed_ms  = start_time ? (Date.now() - start_time) : 0;
        const elapsed_sec = elapsed_ms / 1000;
        const minutes     = elapsed_sec / 60;
        const wpm         = minutes > 0 ? Math.round((correct_chars / 5) / minutes) : 0;
        const typed       = input_val.length;
        const mistakes    = [...input_val].filter((c, i) => c !== quote_text[i]).length; // current live errors
        const accuracy    = typed > 0 ? Math.max(0, ((typed - mistakes) / typed) * 100) : 100;

        update_stats(wpm, accuracy, elapsed_sec, ever_wrong.size);

        // ── Completion check ──────────────────────────────────────────────────
        if (input_val === quote_text) {
            clearInterval(timer_id); timer_id = null;
            document.getElementById("user_input").disabled = true;
            save_and_show(wpm, accuracy, elapsed_sec);
        }
    }

    function tick() {
        if (!start_time) return;
        const input_val   = document.getElementById("user_input").value;
        const elapsed_sec = (Date.now() - start_time) / 1000;
        const correct_chars = [...input_val].filter((c, i) => c === quote_text[i]).length;
        const minutes     = elapsed_sec / 60;
        const wpm         = minutes > 0 ? Math.round((correct_chars / 5) / minutes) : 0;
        const typed       = input_val.length;
        const mistakes    = [...input_val].filter((c, i) => c !== quote_text[i]).length;
        const accuracy    = typed > 0 ? Math.max(0, ((typed - mistakes) / typed) * 100) : 100;
        update_stats(wpm, accuracy, elapsed_sec, mistakes);
    }

    function update_stats(wpm, accuracy, elapsed_sec, mistakes) {
        document.querySelector("#stat-wpm strong").textContent   = wpm;
        document.querySelector("#stat-acc strong").textContent   = accuracy.toFixed(1) + "%";
        document.querySelector("#stat-time strong").textContent  = elapsed_sec.toFixed(1) + "s";
        document.querySelector("#stat-errors strong").textContent = mistakes;
    }

    // ── Save score ────────────────────────────────────────────────────────────
    async function save_and_show(wpm, accuracy, time_taken) {
        try {
            const params = new URLSearchParams({
                quote_id:   quote_id,
                wpm:        wpm.toFixed(2),
                accuracy:   accuracy.toFixed(2),
                time_taken: time_taken.toFixed(3)
            });
            const res  = await fetch("ScoreServlet", {
                method:  "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body:    params.toString()
            });
            const data = await res.json();
            show_banner(wpm, accuracy, time_taken, data.status === "success");
        } catch (e) {
            console.error("Score save failed:", e);
            show_banner(wpm, accuracy, time_taken, false);
        }
    }

    function show_banner(wpm, accuracy, time_taken, saved) {
        const banner = document.getElementById("finish-banner");
        const msg    = document.getElementById("finish-msg");
        msg.textContent = "✅ Done! " + wpm + " WPM · " +
                          accuracy.toFixed(1) + "% accuracy · " +
                          time_taken.toFixed(1) + "s" +
                          (saved ? " · Score saved!" : " · (Score not saved)");
        banner.style.display = "flex";
    }

    function hide_banner() {
        document.getElementById("finish-banner").style.display = "none";
    }

    function show_error(msg) {
        document.getElementById("quote_display").textContent = msg;
    }

    // ── User stats ────────────────────────────────────────────────────────────
    async function loadUserStats() {
        try {
            const res  = await fetch("UserStatsServlet");
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

    // ── Change quote type ─────────────────────────────────────────────────────
    document.addEventListener("DOMContentLoaded", function () {
        document.getElementById("quote_type").addEventListener("change", fetch_quote);
        loadUserStats();
        fetch_quote();
    });
</script>
</body>
</html>
