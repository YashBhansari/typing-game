package com.typinggame.dao;

import com.typinggame.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ScoreDAO {

    public static boolean insertScore(int userId, int quoteId, double wpm, double accuracy, double timeTaken) {
        String sql = "INSERT INTO scores (user_id, quote_id, wpm, accuracy, time_taken, played_at) " +
                     "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (Connection con = DBConnection.get_connection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, quoteId);
            ps.setDouble(3, wpm);
            ps.setDouble(4, accuracy);
            ps.setDouble(5, timeTaken);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<LeaderboardRow> getTopScores(String lengthFilter, int limit) {
        String whereClause = "";
        if ("short".equals(lengthFilter)) {
            whereClause = "WHERE char_length(coalesce(q.quote,'')) <= 50 ";
        } else if ("medium".equals(lengthFilter)) {
            whereClause = "WHERE char_length(coalesce(q.quote,'')) BETWEEN 51 AND 140 ";
        } else if ("long".equals(lengthFilter)) {
            whereClause = "WHERE char_length(coalesce(q.quote,'')) > 140 ";
        }

        // limit is an integer constant, safe to inline
        String sql = "SELECT s.wpm, s.accuracy, s.time_taken, s.played_at, " +
                     "u.username, q.quote, q.movie " +
                     "FROM scores s " +
                     "JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN quotes q ON s.quote_id = q.id " +
                     whereClause +
                     "ORDER BY s.wpm DESC, s.accuracy DESC LIMIT " + limit;

        List<LeaderboardRow> rows = new ArrayList<>();
        try (Connection con = DBConnection.get_connection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                LeaderboardRow r = new LeaderboardRow();
                String uname = rs.getString("username");
                r.username = (uname == null || uname.isEmpty()) ? "(anonymous)" : uname;
                r.wpm = rs.getDouble("wpm");
                r.accuracy = rs.getDouble("accuracy");
                r.timeTaken = rs.getDouble("time_taken");
                r.playedAt = rs.getTimestamp("played_at");
                r.quote = rs.getString("quote");
                r.movie = rs.getString("movie");
                rows.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rows;
    }

    public static class LeaderboardRow {
        public String username;
        public String quote;
        public String movie;
        public double wpm;
        public double accuracy;
        public double timeTaken;
        public Timestamp playedAt;
    }
}
