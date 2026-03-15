<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // If already logged in, skip the landing page
    if (session.getAttribute("username") != null) {
        response.sendRedirect("home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Typing Game – Test Your Speed</title>
    <link rel="stylesheet" href="lander.css">
</head>
<body>
    <div class="hero">
        <div class="hero-content">
            <div class="logo-icon">⌨️</div>
            <h1>Typing Game</h1>
            <p class="tagline">Test your speed. Track your progress. Climb the leaderboard.</p>
            <div class="cta-buttons">
                <a href="login.jsp" class="btn btn-primary">Login</a>
                <a href="register.jsp" class="btn btn-secondary">Create Account</a>
            </div>
            <div class="features">
                <div class="feature">
                    <span class="feature-icon">🎬</span>
                    <span>Movie quotes</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">📊</span>
                    <span>WPM & accuracy tracking</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">🏆</span>
                    <span>Global leaderboard</span>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
