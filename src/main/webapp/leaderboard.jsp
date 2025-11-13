<%@ page import="java.sql.*, com.typinggame.util.DBConnection" %>
<%
    
    String lengthParam = request.getParameter("length");
    String whereClause = "";
    
    if ("short".equals(lengthParam)) {
        whereClause = "WHERE char_length(coalesce(q.quote,'')) <= 50";
    } else if ("medium".equals(lengthParam)) {
        whereClause = "WHERE char_length(coalesce(q.quote,'')) BETWEEN 51 AND 140";
    } else if ("long".equals(lengthParam)) {
        whereClause = "WHERE char_length(coalesce(q.quote,'')) > 140";
    }

    String sql = "SELECT s.*, u.username, q.quote " +
                 "FROM scores s " +
                 "JOIN users u ON s.user_id = u.id " +
                 "LEFT JOIN quotes q ON s.quote_id = q.id " +
                 (whereClause.isEmpty() ? "" : (" " + whereClause)) +
                 " ORDER BY s.wpm DESC, s.accuracy DESC LIMIT 20";

    try (Connection conn = DBConnection.get_connection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery())
    {
        int rank = 1;
        while (rs.next())
        {
%>
<tr>
    <td><%= rank++ %></td>
    <td><%= rs.getString("username") %></td>
    <td><%= rs.getString("quote") %></td>
    <td><%= rs.getDouble("wpm") %></td>
    <td><%= rs.getDouble("accuracy") %></td>
    <td><%= rs.getDouble("time_taken") %></td>
    <td><%= rs.getTimestamp("played_at").toString() %></td>
</tr>
<%
        }
    }
    catch (Exception e)
    {
        getServletContext().log("Error rendering leaderboard fragment", e);
    }
%>
