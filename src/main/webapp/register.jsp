<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Register</title>
    <link rel="stylesheet" href="auth.css">
</head>
<body>
    <div class="container">
        <h2>Register</h2>

        <form action="auth" method="post">
            <input type="hidden" name="action" value="register">

            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your username" required>

            <label>Email</label>
            <input type="email" name="email" placeholder="Enter your email" required>

            <label>Password</label>
            <input type="password" name="password" placeholder="Enter your password" required>

            <button type="submit">Register</button>
        </form>

        <p>Already have an account? <a href="login.jsp">Login</a></p>

        <p class="error-message"><%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %></p>
    </div>
</body>
</html>
