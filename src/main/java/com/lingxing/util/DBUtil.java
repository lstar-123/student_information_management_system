package com.lingxing.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * 简单的 JDBC 工具类，复用桌面项目中的数据库配置。
 * 不依赖任何框架，仅使用原生 JDBC。
 */
public class DBUtil {

    private static final String URL = "jdbc:mysql://localhost:3306/score_management?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "Rcq123803";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("加载数据库驱动失败", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}


