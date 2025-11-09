package com.typinggame.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection
{
    private static final String URL = "jdbc:postgresql://localhost:5432/typinggame";
    private static final String USER = "postgres";
    private static final String PASSWORD = "yash7105";

    public static Connection get_connection() throws SQLException
    {
        try
        {
            Class.forName("org.postgresql.Driver");
        }
        catch (ClassNotFoundException e)
        {
            throw new SQLException("PostgreSQL Driver not found");
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
