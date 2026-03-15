package com.typinggame.servlet;

import com.typinggame.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import org.json.JSONObject;

public class QuoteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        JSONObject json = new JSONObject();

        String type = request.getParameter("type");

        // Only accept known values — never interpolate user input into SQL
        String whereClause;
        if ("short".equalsIgnoreCase(type)) {
            whereClause = "WHERE char_length(coalesce(quote,'')) <= 50 ";
        } else if ("long".equalsIgnoreCase(type)) {
            whereClause = "WHERE char_length(coalesce(quote,'')) > 140 ";
        } else {
            // default: medium
            whereClause = "WHERE char_length(coalesce(quote,'')) BETWEEN 51 AND 140 ";
        }

        String sql = "SELECT id, quote, movie, year FROM quotes "
                   + whereClause
                   + "ORDER BY RANDOM() LIMIT 1";

        try (Connection conn = DBConnection.get_connection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                json.put("id",    rs.getInt("id"));
                json.put("quote", rs.getString("quote"));
                json.put("movie", rs.getString("movie") != null ? rs.getString("movie") : "Unknown");
                json.put("year",  rs.getInt("year"));
            } else {
                json.put("error", "No quotes found for the selected length.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            json.put("error", "Database error. Please try again.");
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(json.toString());
        }
    }
}
