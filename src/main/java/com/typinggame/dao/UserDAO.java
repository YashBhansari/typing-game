package com.typinggame.dao;

import com.typinggame.util.DBConnection;
import java.sql.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class UserDAO {

    private static String hash_password(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash_bytes = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash_bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password");
        } catch (java.io.UnsupportedEncodingException e) {
            throw new RuntimeException("UTF-8 not supported");
        }
    }

    public static boolean register_user(String username, String email, String password) {
        if (username == null || username.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.isEmpty()) {
            return false;
        }
        String sql = "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.get_connection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, hash_password(password));
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) {
                System.out.println("Email or username already registered.");
            } else {
                e.printStackTrace();
            }
            return false;
        }
    }

    public static boolean validate_user(String email, String password) {
        if (email == null || password == null) return false;
        String sql = "SELECT password_hash FROM users WHERE email = ?";
        try (Connection con = DBConnection.get_connection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("password_hash").equals(hash_password(password));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static String get_username_by_email(String email) {
        try (Connection conn = DBConnection.get_connection();
             PreparedStatement ps = conn.prepareStatement("SELECT username FROM users WHERE email = ?")) {
            ps.setString(1, email.trim().toLowerCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("username");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static Integer get_user_id_by_email(String email) {
        try (Connection conn = DBConnection.get_connection();
             PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
            ps.setString(1, email.trim().toLowerCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
