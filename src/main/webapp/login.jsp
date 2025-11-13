<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="auth.css">
</head>
<body>
    <div class="container">
    <h2>Login</h2>

    <form action="auth" method="post">
        <input type="hidden" name="action" value="login">

        <label>Email ID:</label>
        <input type="text" name="email" placeholder="Enter your email" required>

        <label>Password:</label>
        <input type="password" name="password" placeholder="Enter your password"  required>

        <button type="submit">Login</button>
    </form>
    <p>Don't have an account? <a href="register.jsp">Register</a></p>
    <p class="error-msg"><%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %></p>
    <p class="success-msg"><%= request.getAttribute("message") != null ? request.getAttribute("message") : "" %></p>
</div>

</body>	
</html>
