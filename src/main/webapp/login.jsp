<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Login</title>
</head>
<body>
    <h2>Login</h2>

    <form action="auth" method="post">
        <input type="hidden" name="action" value="login">
        <label>Email ID:</label>
        <input type="text" name="email" required><br><br>
        <label>Password:</label>
        <input type="password" name="password" required><br><br>
        <button type="submit">Login</button>
    </form>

    <p>Don't have an account? <a href="register.jsp">Register</a></p>

    <p style="color:red;"><%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %></p>
    <p style="color:green;"><%= request.getAttribute("message") != null ? request.getAttribute("message") : "" %></p>
</body>
</html>
