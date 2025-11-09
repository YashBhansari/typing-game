<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html>

	<head>
		<title>Typing Game</title>
		<style>
			body {
				font-family: Arial, sans-serif;
				margin: 40px;
			}

			textarea {
				width: 100%;
				height: 120px;
				font-size: 16px;
			}

			#quote {
				font-size: 18px;
				margin-bottom: 10px;
			}

			#movie {
				color: gray;
				font-style: italic;
				margin-bottom: 15px;
			}

			#result {
				margin-top: 15px;
				font-weight: bold;
			}

			#timer {
				font-size: 16px;
				margin-top: 8px;
			}

			#leaderboard {
				margin-top: 20px;
				border-top: 1px solid #ddd;
				padding-top: 10px;
			}

			#leaderboard table {
				width: 100%;
				border-collapse: collapse;
			}

			#leaderboard th,
			#leaderboard td {
				text-align: left;
				padding: 6px;
				border-bottom: 1px solid #eee;
			}
		</style>
		<script>
			console.log("✅ JS is running");

			let quote_text = "";
			let start_time = null;
			let timer_running = false;
			let typed_chars = 0;
			let correct_chars = 0;
			let timer_interval;
			let visible_timer_interval;
			let score_submitted = false;

			async function fetch_quote() {
				try {
					const res = await fetch("QuoteServlet");
					const data = await res.json();

					if (data.error) {
						document.getElementById("quote").innerText = "Error fetching quote.";
						document.getElementById("movie").innerText = "";
						return;
					}

					document.getElementById("quote").innerText = data.quote;
					document.getElementById("movie").innerText = "- " + data.movie + "  (" + data.year + ")";
					// keep the quote exactly as returned from server (don't trim) so matching is consistent
					quote_text = data.quote;

					start_typing();
				}
				catch (e) {
					console.error(e);
					document.getElementById("quote").innerText = "Server error.";
				}
			}

			function start_typing() {
				const input = document.getElementById("user_input");
				const result = document.getElementById("result");
				input.value = "";
				result.innerText = "";
				start_time = null;
				timer_running = false;
				typed_chars = 0;
				correct_chars = 0;
				input.disabled = false;
				input.focus();
				document.getElementById("timer").innerText = "Time: 0.0s";
				score_submitted = false;
			}

			function on_type() {
				let input = document.getElementById("user_input").value;
				let result = document.getElementById("result");

				if (!timer_running && input.length > 0) {
					start_time = new Date();
					timer_running = true;
					timer_interval = setInterval(update_stats, 100);
				}

				update_stats();

				if (input === quote_text) {
					clearInterval(timer_interval);
					document.getElementById("user_input").disabled = true;
					// finalize and submit
					submit_score();
				}
			}

			function update_stats() {
				let input = document.getElementById("user_input").value;
				let result = document.getElementById("result");

				let typed_chars = input.length;
				let correct_chars = 0;

				for (let i = 0; i < input.length; i++) {
					if (input[i] === quote_text[i]) {
						correct_chars++;
					}
				}

				// if timer hasn't started yet, show zeroed stats
				if (!start_time) {
					result.innerHTML =
						"WPM: 0<br>" +
						"Accuracy: 0%<br>" +
						"Time: 0s";
					return;
				}

				let end_time = new Date();
				let time_taken = (end_time - start_time) / 1000;

				if (typed_chars === 0 || time_taken === 0 || isNaN(time_taken)) {
					result.innerHTML =
						"WPM: 0<br>" +
						"Accuracy: 0%<br>" +
						"Time: 0s";
					return;
				}

				let minutes = time_taken / 60;
				let wpm = ((correct_chars / 5) / minutes).toFixed(2);
				let accuracy = ((correct_chars / typed_chars) * 100).toFixed(2);
				document.getElementById("timer").innerText = "Time: " + time_taken.toFixed(1) + "s";
				result.innerHTML =
					"WPM: " + wpm + "<br>" +
					"Accuracy: " + accuracy + "%<br>" +
					"Time: " + time_taken.toFixed(1) + "s";
			}

			function start_visible_timer() {
				if (visible_timer_interval) clearInterval(visible_timer_interval);
				visible_timer_interval = setInterval(() => {
					if (!start_time) return;
					let t = (new Date() - start_time) / 1000;
					document.getElementById("timer").innerText = "Time: " + t.toFixed(1) + "s";
				}, 100);
			}

			async function submit_score() {
				if (score_submitted) return; // already submitted
				// compute final stats one last time
				let input = document.getElementById("user_input").value;
				let typed_chars = input.length;
				let correct_chars = 0;
				for (let i = 0; i < input.length; i++) {
					if (input[i] === quote_text[i]) correct_chars++;
				}

				if (!start_time) return; // nothing to submit
				let time_taken = (new Date() - start_time) / 1000;
				let minutes = time_taken / 60;
				let wpm = minutes > 0 ? ((correct_chars / 5) / minutes) : 0;
				let accuracy = typed_chars > 0 ? ((correct_chars / typed_chars) * 100) : 0;

				try {
					const res = await fetch('<%= request.getContextPath() %>/score', {
						method: 'POST',
						headers: { 'Content-Type': 'application/json' },
						body: JSON.stringify({ wpm: Number(wpm.toFixed(2)), accuracy: Number(accuracy.toFixed(2)), timeTaken: Number(time_taken.toFixed(2)) })
					});
					const data = await res.json();
					if (data.status === 'ok') {
						score_submitted = true;
						// refresh leaderboard
						fetch_leaderboard();
					} else if (data.status === 'ignored') {
						score_submitted = true; // treat ignored as submitted to avoid retry loops
					}
				} catch (e) {
					console.error('Failed to submit score', e);
				}
			}
async function fetch_leaderboard() {
    console.log("🔄 fetch_leaderboard() started");

    try {
        const res = await fetch('score');
        console.log("✅ fetch complete, status:", res.status);
        const text = await res.text();
        console.log("📜 raw response text:", text);

        const tbody = document.getElementById('leaderboard-body');
        tbody.innerHTML = '<tr><td colspan="5">Parsing response...</td></tr>';

        let arr;
        try {
            arr = JSON.parse(text);
            console.log("✅ parsed JSON:", arr);
        } catch (e) {
            console.error("❌ JSON parse failed:", e);
            tbody.innerHTML = '<tr><td colspan="5">Invalid leaderboard JSON</td></tr>';
            return;
        }

        tbody.innerHTML = ''; // clear the "Loading..." message

        if (!Array.isArray(arr) || arr.length === 0) {
            console.warn("⚠️ Empty leaderboard array");
            tbody.innerHTML = '<tr><td colspan="5">No scores yet</td></tr>';
            return;
        }

        console.log("✅ rendering leaderboard with", arr.length, "rows");

        arr.forEach((r, idx) => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>\${idx + 1}</td>
                <td>\${r.username || r.USERNAME || "(anonymous)"}</td>
                <td>\${r.wpm || r.WPM || 0}</td>
                <td>\${r.accuracy || r.ACCURACY || 0}%</td>
                <td>\${r.timeTaken || r.TIMETAKEN || 0}s</td>
            `;
            tbody.appendChild(tr);
        });

    } catch (e) {
        console.error("❌ fetch_leaderboard() failed:", e);
    }
}


			// async function fetch_leaderboard() {
				// try {
				// 	const res = await fetch('<%= request.getContextPath() %>/score');

				// 	const text = await res.text();
				// 	console.debug('score response text:', text);

				// 	const tbody = document.getElementById('leaderboard-body');

				// 	let arr;
				// 	try {
				// 		arr = JSON.parse(text);
				// 	} catch (e) {
				// 		console.error('Failed to parse leaderboard JSON', e);
				// 		tbody.innerHTML = '<tr><td colspan="5">Invalid leaderboard response</td></tr>';
				// 		return;
				// 	}

				// 	tbody.innerHTML = '';
				// 	if (!Array.isArray(arr) || arr.length === 0) {
				// 		tbody.innerHTML = '<tr><td colspan="5">No scores yet</td></tr>';
				// 		return;
				// 	}

				// 	arr.forEach((r, idx) => {
				// 		const user = r.username || r.USERNAME || "(anonymous)";
				// 		const wpm = r.wpm || r.WPM || 0;
				// 		const accuracy = r.accuracy || r.ACCURACY || 0;
				// 		const timeTaken = r.timeTaken || r.TIMETAKEN || 0;

				// 		const tr = document.createElement('tr');
				// 		tr.innerHTML = `
				// 		<td>\${idx + 1}</td>
				// 		<td>\${user}</td>
				// 		<td>\${wpm}</td>
				// 		<td>\${accuracy}%</td>
				// 		<td>\${timeTaken}s</td>
				// 	`;
				// 		tbody.appendChild(tr);
				// 	});


				// } catch (e) {
				// 	console.error('Failed to fetch leaderboard', e);
				// }
				
			// }


			function stop_test() {
				clearInterval(timer_interval);
				clearInterval(visible_timer_interval);
				timer_running = false;
				document.getElementById('user_input').disabled = true;
				submit_score();
			}

		</script>
	</head>

	<body onload="fetch_quote()">
		<h2>Typing Game</h2>
		<div id="quote"></div>
		<div id="movie"></div>

		<textarea id="user_input" oninput="on_type()"></textarea><br>
		<button onclick="fetch_quote()">Start New</button>
		<button onclick="stop_test()">Stop</button>
		<button type="button" onclick="location.href='<%= request.getContextPath() %>/logout'">Logout</button>
		<div id="timer">Time: 0.0s</div>

		<div id="result"></div>

		<div id="leaderboard">
			<h3>Leaderboard</h3>
			<table>
				<thead>
					<tr>
						<th>#</th>
						<th>User</th>
						<th>WPM</th>
						<th>Accuracy</th>
						<th>Time</th>
					</tr>
				</thead>
				<tbody id="leaderboard-body">
					<tr>
						<td colspan="5">Loading...</td>
					</tr>
				</tbody>
			</table>
		</div>

	<script>
		console.log("👀 Running fetch_leaderboard() on load");
		fetch_leaderboard();
	</script>

	</body>

	</html>