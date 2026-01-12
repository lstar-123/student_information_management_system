package com.lingxing.util;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * 数据库连接工具类
 * <p>
 * 提供获取数据库连接的便捷方法，底层使用Druid连接池。
 * 主要为了兼容JSP页面中直接使用JDBC的场景。
 * </p>
 * <p>
 * <strong>注意：</strong> 在Java代码中应优先使用MyBatis的SqlSession，
 * 而不是直接使用JDBC连接。此类主要用于JSP页面中的JDBC操作。
 * </p>
 *
 * @author lingxing
 * @since 1.0
 */
public final class DBUtil {

    /**
     * 私有构造函数，防止实例化
     */
    private DBUtil() {
        throw new UnsupportedOperationException("工具类不允许实例化");
    }

    /**
     * 从Druid连接池获取数据库连接
     * <p>
     * 每次调用都会从连接池中获取一个新的连接。
     * 使用完毕后必须调用Connection.close()方法将连接归还到连接池。
     * 建议使用try-with-resources语句自动关闭。
     * </p>
     *
     * @return 数据库连接对象
     * @throws SQLException 如果获取连接失败
     * @throws IllegalStateException 如果数据源未初始化
     */
    public static Connection getConnection() throws SQLException {
        DataSource dataSource = DruidUtil.getDataSource();
        if (dataSource == null) {
            throw new IllegalStateException("数据源未初始化");
        }
        return dataSource.getConnection();
    }
}
