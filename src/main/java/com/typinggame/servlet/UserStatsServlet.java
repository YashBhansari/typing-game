package com.typinggame.servlet;

import com.typinggame.util.DBConnection;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.json.JSONObject;

@WebServlet("/UserStatsServlet")

public class UserStatsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession(false);
        JSONObject json = new JSONObject();

        if (session == null || session.getAttribute("username") == null) {
            json.put("error", "User not logged in");
            response.getWriter().print(json);
            return;
        }

        String username = session.getAttribute("username").toString();

        try (Connection conn = DBConnection.get_connection()) {
            String sql = "SELECT COUNT(*) AS total, " +
                         "AVG(wpm) AS avg_wpm, " +
                         "MAX(wpm) AS top_wpm, " +
                         "AVG(accuracy) AS avg_accuracy " +
                         "FROM scores s JOIN users u ON s.user_id = u.id " +
                         "WHERE u.username = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    json.put("totalRuns", rs.getInt("total"));
                    json.put("avgWpm", rs.getDouble("avg_wpm"));
                    json.put("topWpm", rs.getDouble("top_wpm"));
                    json.put("avgAcc", rs.getDouble("avg_accuracy"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            json.put("error", "Database error");
        }

        response.getWriter().print(json);
    }
}
