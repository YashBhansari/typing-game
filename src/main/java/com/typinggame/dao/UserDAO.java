package com.typinggame.dao;

import com.typinggame.util.DBConnection;
import java.sql.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class UserDAO {

    private static String hash_password(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash_bytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hash_bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password");
        }
    }

    public static boolean register_user(String username, String email, String password) {
        String sql = "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.get_connection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, hash_password(password));
            ps.executeUpdate();
            System.out.println("✅ User registered: " + email);
            return true;
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) {
                System.out.println("❌ Email or username already registered.");
            } else {
                System.out.println("❌ SQL Error during registration:");
                e.printStackTrace();
            }
            return false;
        }
    }

    public static boolean validate_user(String email, String password) {
        String sql = "SELECT password_hash FROM users WHERE email = ?";
        try (Connection con = DBConnection.get_connection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String stored_hash = rs.getString("password_hash");
                String given_hash = hash_password(password);
                return stored_hash.equals(given_hash);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static String get_username_by_email(String email) {
        String username = null;
        try (Connection conn = DBConnection.get_connection();
             PreparedStatement ps = conn.prepareStatement("SELECT username FROM users WHERE email = ?")) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                username = rs.getString("username");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return username;
    }

    public static Integer get_user_id_by_email(String email) {
        try (Connection conn = DBConnection.get_connection();
             PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}