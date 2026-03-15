package com.typinggame.servlet;

import com.typinggame.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.json.JSONObject;

public class UserStatsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        JSONObject json = new JSONObject();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            json.put("error", "Not authenticated.");
            response.getWriter().print(json.toString());
            return;
        }

        int userId = (int) session.getAttribute("user_id");

        try (Connection conn = DBConnection.get_connection()) {
            String sql = "SELECT COUNT(*) AS total, " +
                         "COALESCE(AVG(wpm), 0)      AS avg_wpm, " +
                         "COALESCE(MAX(wpm), 0)      AS top_wpm, " +
                         "COALESCE(AVG(accuracy), 0) AS avg_accuracy " +
                         "FROM scores WHERE user_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    json.put("totalRuns", rs.getInt("total"));
                    json.put("avgWpm",    rs.getDouble("avg_wpm"));
                    json.put("topWpm",    rs.getDouble("top_wpm"));
                    json.put("avgAcc",    rs.getDouble("avg_accuracy"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            json.put("error", "Database error.");
        }

        response.getWriter().print(json.toString());
    }
}
