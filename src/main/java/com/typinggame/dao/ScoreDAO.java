package com.typinggame.dao;

import com.typinggame.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ScoreDAO {

    public static boolean insertScore(int userId, double wpm, double accuracy, double timeTaken) {
        String sql = "INSERT INTO scores (user_id, wpm, accuracy, time_taken, played_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (Connection con = DBConnection.get_connection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDouble(2, wpm);
            ps.setDouble(3, accuracy);
            ps.setDouble(4, timeTaken);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<LeaderboardRow> getTopScores(int limit) {
        // Some JDBC drivers/databases don't accept a parameter for LIMIT; build query with the integer limit.
        String sql = "SELECT s.wpm, s.accuracy, s.time_taken, s.played_at, u.username FROM scores s LEFT JOIN users u ON s.user_id = u.id ORDER BY s.wpm DESC LIMIT " + limit;
        List<LeaderboardRow> rows = new ArrayList<>();
        try (Connection con = DBConnection.get_connection(); Statement stmt = con.createStatement()) {
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                LeaderboardRow r = new LeaderboardRow();
                String uname = rs.getString("username");
                r.username = (uname == null || uname.isEmpty()) ? "(anonymous)" : uname;
                r.wpm = rs.getDouble("wpm");
                r.accuracy = rs.getDouble("accuracy");
                r.timeTaken = rs.getDouble("time_taken");
                r.playedAt = rs.getTimestamp("played_at");
                rows.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rows;
    }

    public static class LeaderboardRow {
        public String username;
        public double wpm;
        public double accuracy;
        public double timeTaken;
        public Timestamp playedAt;
    }
}
