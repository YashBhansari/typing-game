<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("username") == null)
    {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<html>
<head>
    <title>Home</title>
</head>
<body>
    <h2>Welcome, <%= session.getAttribute("username") %></h2>
    <a href="game.jsp">Start Typing Test</a> | 
    <a href="logout.jsp">Logout</a>
</body>
</html>
