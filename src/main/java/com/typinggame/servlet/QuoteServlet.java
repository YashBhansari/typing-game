package com.typinggame.servlet;

import com.typinggame.util.DBConnection;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import org.json.JSONObject;

@WebServlet("/QuoteServlet")
public class QuoteServlet extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        response.setContentType("application/json");
        JSONObject json = new JSONObject();

        String type = request.getParameter("type");
        String whereClause = "";

        if ("short".equalsIgnoreCase(type))
        {
            whereClause = "WHERE char_length(coalesce(quote,'')) <= 50";
        }
        else if ("medium".equalsIgnoreCase(type))
        {
            whereClause = "WHERE char_length(coalesce(quote,'')) BETWEEN 51 AND 140";
        }
        else if ("long".equalsIgnoreCase(type))
        {
            whereClause = "WHERE char_length(coalesce(quote,'')) > 140";
        }

        String sql = "SELECT id, quote, movie, year FROM quotes "
                   + (whereClause.isEmpty() ? "" : whereClause)
                   + " ORDER BY RANDOM() LIMIT 1";

        try (Connection conn = DBConnection.get_connection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            if (rs.next())
            {
                json.put("id", rs.getInt("id"));
                json.put("quote", rs.getString("quote"));
                json.put("movie", rs.getString("movie"));
                json.put("year", rs.getInt("year"));
            }
            else
            {
                json.put("error", "No quotes found for the selected type");
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            json.put("error", "Database fetch failed");
        }

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
}
