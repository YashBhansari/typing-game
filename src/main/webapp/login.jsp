<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Redirect if already logged in
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
    <title>Login – Typing Game</title>
    <link rel="stylesheet" href="auth.css">
</head>
<body>
    <div class="container">
        <div class="logo">⌨️</div>
        <h2>Welcome Back</h2>

        <% if (request.getAttribute("error") != null) { %>
            <p class="error-msg"><%= request.getAttribute("error") %></p>
        <% } %>
        <% if (request.getAttribute("message") != null) { %>
            <p class="success-msg"><%= request.getAttribute("message") %></p>
        <% } %>

        <form action="auth" method="post">
            <input type="hidden" name="action" value="login">

            <label for="email">Email</label>
            <input type="email" id="email" name="email" placeholder="you@example.com" required autofocus>

            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="Enter your password" required>

            <button type="submit">Login</button>
        </form>

        <p>Don't have an account? <a href="register.jsp">Register</a></p>
    </div>
</body>
</html>
