<%@ page contentType="text/html;charset=UTF-8" %>
<%
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
    <title>Register – Typing Game</title>
    <link rel="stylesheet" href="auth.css">
</head>
<body>
    <div class="container">
        <div class="logo">⌨️</div>
        <h2>Create Account</h2>

        <% if (request.getAttribute("error") != null) { %>
            <p class="error-msg"><%= request.getAttribute("error") %></p>
        <% } %>

        <form action="auth" method="post">
            <input type="hidden" name="action" value="register">

            <label for="username">Username</label>
            <input type="text" id="username" name="username" placeholder="Choose a username"
                   minlength="2" maxlength="50" required autofocus>

            <label for="email">Email</label>
            <input type="email" id="email" name="email" placeholder="you@example.com" required>

            <label for="password">Password <span class="hint">(min. 6 characters)</span></label>
            <input type="password" id="password" name="password" placeholder="Choose a password"
                   minlength="6" required>

            <button type="submit">Create Account</button>
        </form>

        <p>Already have an account? <a href="login.jsp">Login</a></p>
    </div>
</body>
</html>
