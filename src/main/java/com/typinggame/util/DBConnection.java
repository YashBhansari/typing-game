package com.typinggame.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        Properties props = new Properties();
        try (InputStream in = DBConnection.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (in != null) {
                props.load(in);
            } else {
                throw new RuntimeException(
                    "db.properties not found in classpath. " +
                    "Copy db.properties.example to db.properties and fill in your credentials.");
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to load db.properties", e);
        }

        URL      = props.getProperty("db.url",      "jdbc:postgresql://localhost:5432/typinggame");
        USER     = props.getProperty("db.user",     "postgres");
        PASSWORD = props.getProperty("db.password", "changeme");
    }

    public static Connection get_connection() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("PostgreSQL Driver not found", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
