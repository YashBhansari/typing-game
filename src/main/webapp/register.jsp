<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Register</title>
</head>
<body>
    <h2>Register</h2>

    <form action="auth" method="post">
        <input type="hidden" name="action" value="register">
        <label>Username:</label>
        <input type="text" name="username" required><br><br>
        <label>Email:</label>
        <input type="email" name="email" required><br><br>
        <label>Password:</label>
        <input type="password" name="password" required><br><br>
        <button type="submit">Register</button>
    </form>

    <p>Already have an account? <a href="login.jsp">Login</a></p>

    <p style="color:red;"><%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %></p>
</body>
</html>



<p style="color:red;">
<%
    String error = request.getParameter("error");
    if (error != null) {
        if ("1".equals(error)) out.print("Registration failed.");
        else if ("duplicate".equals(error)) out.print("Username already exists.");
        else out.print("Unknown error occurred.");
    }
%>
</p>
