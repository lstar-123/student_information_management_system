package com.lingxing.util;

import com.alibaba.druid.pool.DruidDataSourceFactory;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Druid数据源工具类
 * <p>
 * 负责初始化和管理Druid数据库连接池。使用单例模式确保全局唯一的数据源实例。
 * 数据源配置从classpath下的druid.properties文件中读取。
 * </p>
 *
 * @author lingxing
 * @since 1.0
 */
public final class DruidUtil {

    /**
     * Druid数据源实例
     */
    private static volatile DataSource dataSource;

    /**
     * 配置文件路径
     */
    private static final String CONFIG_FILE = "druid.properties";

    /**
     * 私有构造函数，防止实例化
     */
    private DruidUtil() {
        throw new UnsupportedOperationException("工具类不允许实例化");
    }

    /**
     * 初始化数据源（使用双重检查锁定模式确保线程安全）
     */
    private static void initDataSource() {
        if (dataSource == null) {
            synchronized (DruidUtil.class) {
                if (dataSource == null) {
                    try (InputStream is = DruidUtil.class.getClassLoader()
                            .getResourceAsStream(CONFIG_FILE)) {
                        if (is == null) {
                            throw new IllegalStateException(
                                    "无法找到配置文件: " + CONFIG_FILE);
                        }
                        Properties properties = new Properties();
                        properties.load(is);
                        dataSource = DruidDataSourceFactory.createDataSource(properties);
                    } catch (IOException e) {
                        throw new IllegalStateException(
                                "读取配置文件失败: " + CONFIG_FILE, e);
                    } catch (Exception e) {
                        throw new IllegalStateException(
                                "初始化Druid连接池失败", e);
                    }
                }
            }
        }
    }

    /**
     * 获取Druid数据源实例
     * <p>
     * 如果数据源尚未初始化，则进行懒加载初始化。
     * 使用双重检查锁定模式确保线程安全。
     * </p>
     *
     * @return DataSource 数据源实例，不会为null
     * @throws IllegalStateException 如果数据源初始化失败
     */
    public static DataSource getDataSource() {
        if (dataSource == null) {
            initDataSource();
        }
        return dataSource;
    }
}
