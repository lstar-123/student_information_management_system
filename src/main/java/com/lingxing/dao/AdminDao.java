package com.lingxing.dao;

import com.lingxing.bean.Admin;

/**
 * 桌面版管理员登录是写死账号 admin/1234，这里保持相同逻辑。
 * 如需改为数据库表，只要在此类中改实现即可。
 */
public class AdminDao {

    public Admin login(String username, String password) {
        if ("admin".equals(username) && "1234".equals(password)) {
            Admin admin = new Admin();
            admin.setAdminId(1);
            admin.setUsername(username);
            admin.setPassword(password);
            return admin;
        }
        return null;
    }
}


