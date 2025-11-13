package com.typinggame.servlet;

import com.typinggame.util.DBConnection;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/ScoreServlet")
public class ScoreServlet extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        response.setContentType("application/json");

        try (Connection conn = DBConnection.get_connection())
        {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user_id") == null)
            {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            int user_id = (int) session.getAttribute("user_id");
            int quote_id = Integer.parseInt(request.getParameter("quote_id"));
            double wpm = Double.parseDouble(request.getParameter("wpm"));
            double accuracy = Double.parseDouble(request.getParameter("accuracy"));
            double time_taken = Double.parseDouble(request.getParameter("time_taken"));

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO scores (user_id, quote_id, wpm, accuracy, time_taken) VALUES (?, ?, ?, ?, ?)"
            );
            ps.setInt(1, user_id);
            ps.setInt(2, quote_id);
            ps.setDouble(3, wpm);
            ps.setDouble(4, accuracy);
            ps.setDouble(5, time_taken);

            ps.executeUpdate();

            response.getWriter().print("{\"status\":\"success\"}");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            response.getWriter().print("{\"status\":\"error\"}");
        }
    }
}
