package com.lingxing.util;

import org.apache.ibatis.mapping.Environment;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.apache.ibatis.transaction.TransactionFactory;
import org.apache.ibatis.transaction.jdbc.JdbcTransactionFactory;

import javax.sql.DataSource;

/**
 * MyBatis工具类
 * <p>
 * 负责初始化和管理MyBatis的SqlSessionFactory实例。
 * 使用单例模式确保全局唯一的SqlSessionFactory。
 * 数据源使用Druid连接池，Mapper接口位于com.lingxing.dao包下。
 * </p>
 *
 * @author lingxing
 * @since 1.0
 */
public final class MyBatisUtil {

    /**
     * Mapper接口所在包路径
     */
    private static final String MAPPER_PACKAGE = "com.lingxing.dao";

    /**
     * SqlSessionFactory实例（使用volatile确保可见性）
     */
    private static volatile SqlSessionFactory sqlSessionFactory;

    /**
     * 私有构造函数，防止实例化
     */
    private MyBatisUtil() {
        throw new UnsupportedOperationException("工具类不允许实例化");
    }

    /**
     * 初始化SqlSessionFactory（使用双重检查锁定模式确保线程安全）
     */
    private static void initSqlSessionFactory() {
        if (sqlSessionFactory == null) {
            synchronized (MyBatisUtil.class) {
                if (sqlSessionFactory == null) {
                    try {
                        // 获取Druid数据源
                        DataSource dataSource = DruidUtil.getDataSource();
                        if (dataSource == null) {
                            throw new IllegalStateException("数据源未初始化");
                        }

                        // 创建事务工厂
                        TransactionFactory transactionFactory = new JdbcTransactionFactory();

                        // 创建环境
                        Environment environment = new Environment("development",
                                transactionFactory, dataSource);

                        // 创建配置
                        Configuration configuration = new Configuration(environment);

                        // 开启驼峰命名转换（数据库字段名自动转换为Java属性名）
                        configuration.setMapUnderscoreToCamelCase(true);

                        // 添加Mapper接口扫描
                        configuration.addMappers(MAPPER_PACKAGE);

                        // 创建SqlSessionFactory
                        sqlSessionFactory = new SqlSessionFactoryBuilder()
                                .build(configuration);

                        // 验证SqlSessionFactory是否创建成功
                        if (sqlSessionFactory == null) {
                            throw new IllegalStateException(
                                    "SqlSessionFactory初始化失败");
                        }
                    } catch (Exception e) {
                        throw new IllegalStateException(
                                "初始化MyBatis失败", e);
                    }
                }
            }
        }
    }

    /**
     * 获取SqlSessionFactory实例
     * <p>
     * 如果SqlSessionFactory尚未初始化，则进行懒加载初始化。
     * </p>
     *
     * @return SqlSessionFactory实例，不会为null
     * @throws IllegalStateException 如果SqlSessionFactory初始化失败
     */
    public static SqlSessionFactory getSqlSessionFactory() {
        if (sqlSessionFactory == null) {
            initSqlSessionFactory();
        }
        return sqlSessionFactory;
    }

    /**
     * 获取SqlSession（自动提交事务）
     * <p>
     * 每次调用都会创建一个新的SqlSession实例。
     * 使用完毕后必须调用SqlSession.close()方法关闭。
     * 建议使用try-with-resources语句自动关闭。
     * </p>
     *
     * @return SqlSession实例
     * @throws IllegalStateException 如果SqlSessionFactory未初始化
     */
    public static SqlSession getSqlSession() {
        return getSqlSessionFactory().openSession(true);
    }

    /**
     * 获取SqlSession（可指定是否自动提交事务）
     * <p>
     * 每次调用都会创建一个新的SqlSession实例。
     * 使用完毕后必须调用SqlSession.close()方法关闭。
     * 建议使用try-with-resources语句自动关闭。
     * </p>
     *
     * @param autoCommit true表示自动提交事务，false表示手动提交事务
     * @return SqlSession实例
     * @throws IllegalStateException 如果SqlSessionFactory未初始化
     */
    public static SqlSession getSqlSession(boolean autoCommit) {
        return getSqlSessionFactory().openSession(autoCommit);
    }
}
