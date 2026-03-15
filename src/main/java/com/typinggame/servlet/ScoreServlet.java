package com.typinggame.servlet;

import com.typinggame.dao.ScoreDAO;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import org.json.JSONObject;

public class ScoreServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        JSONObject json = new JSONObject();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.put("status", "error");
            json.put("message", "Not authenticated.");
        } else {
            try {
                int userId      = (int) session.getAttribute("user_id");
                int quoteId     = Integer.parseInt(request.getParameter("quote_id"));
                double wpm      = Double.parseDouble(request.getParameter("wpm"));
                double accuracy = Double.parseDouble(request.getParameter("accuracy"));
                double timeTaken = Double.parseDouble(request.getParameter("time_taken"));

                // Sanity bounds
                if (wpm < 0 || wpm > 300 || accuracy < 0 || accuracy > 100 || timeTaken < 0) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    json.put("status", "error");
                    json.put("message", "Invalid score values.");
                } else {
                    boolean saved = ScoreDAO.insertScore(userId, quoteId, wpm, accuracy, timeTaken);
                    json.put("status", saved ? "success" : "error");
                    if (!saved) json.put("message", "Failed to save score.");
                }

            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                json.put("status", "error");
                json.put("message", "Invalid parameter format.");
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                json.put("status", "error");
                json.put("message", "Server error.");
            }
        }

        // Single write point — avoids getWriter() called multiple times
        response.getWriter().print(json.toString());
    }
}
