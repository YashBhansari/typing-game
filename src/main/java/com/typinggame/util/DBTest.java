package com.typinggame.util;

import java.sql.Connection;

public class DBTest {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.get_connection()) {
            if (conn != null) {
                System.out.println("✅ PostgreSQL Connected!");
            } else {
                System.out.println("❌ Connection returned null!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
