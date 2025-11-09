package com.typinggame.servlet;

import com.typinggame.dao.ScoreDAO;
import com.typinggame.dao.UserDAO;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

public class ScoreServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        List<ScoreDAO.LeaderboardRow> rows = ScoreDAO.getTopScores(10);
        JSONArray arr = new JSONArray();
        for (ScoreDAO.LeaderboardRow r : rows) {
            JSONObject o = new JSONObject();
            o.put("username", r.username);
            o.put("wpm", r.wpm);
            o.put("accuracy", r.accuracy);
            o.put("timeTaken", r.timeTaken);
            o.put("playedAt", r.playedAt == null ? "" : r.playedAt.toString());
            arr.put(o);
        }
        // debug log
        System.out.println("[ScoreServlet] returning leaderboard rows=" + rows.size());
        for (int i = 0; i < arr.length(); i++) {
            System.out.println("[ScoreServlet] row=" + arr.getJSONObject(i).toString());
        }
        PrintWriter out = response.getWriter();
        out.print(arr.toString());
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        JSONObject resp = new JSONObject();

        // Attempt to parse JSON body first
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }

    double wpm;
    double accuracy;
    double timeTaken;

    // debug: log raw request body
    System.out.println("[ScoreServlet] raw POST body='" + sb.toString() + "'");

        try {
            if (sb.length() > 0) {
                JSONObject body = new JSONObject(sb.toString());
                wpm = body.optDouble("wpm", 0.0);
                accuracy = body.optDouble("accuracy", 0.0);
                timeTaken = body.optDouble("timeTaken", 0.0);
            } else {
                // fallback to form params
                wpm = Double.parseDouble(request.getParameter("wpm"));
                accuracy = Double.parseDouble(request.getParameter("accuracy"));
                timeTaken = Double.parseDouble(request.getParameter("timeTaken"));
            }
   		} catch (NumberFormatException nfe) {
            resp.put("error", "invalid_payload");
            PrintWriter out = response.getWriter();
            out.print(resp.toString());
            out.flush();
            return;
        }

    System.out.println("[ScoreServlet] parsed wpm=" + wpm + " accuracy=" + accuracy + " timeTaken=" + timeTaken);

        HttpSession session = request.getSession(false);
        Integer userId = null;
        if (session != null && session.getAttribute("email") != null) {
            String email = (String) session.getAttribute("email");
            userId = UserDAO.get_user_id_by_email(email);
        }

        // Ignore likely-broken submissions (no time taken)
        if (timeTaken <= 0) {
            System.out.println("[ScoreServlet] ignoring insert: non-positive timeTaken=" + timeTaken);
            resp.put("status", "ignored");
            PrintWriter out = response.getWriter();
            out.print(resp.toString());
            out.flush();
            return;
        }

        boolean ok = ScoreDAO.insertScore(userId == null ? 0 : userId, wpm, accuracy, timeTaken);
        System.out.println("[ScoreServlet] insert result=" + ok + " for userId=" + (userId == null ? 0 : userId));
        if (ok) resp.put("status", "ok");
        else resp.put("status", "error");

        PrintWriter out = response.getWriter();
        out.print(resp.toString());
        out.flush();
    }
}
