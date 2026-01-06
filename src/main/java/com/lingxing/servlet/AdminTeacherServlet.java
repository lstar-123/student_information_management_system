package com.lingxing.servlet;

import com.lingxing.dao.TeacherDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Random;

public class AdminTeacherServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        try {
            if ("add".equals(action)) {
                handleAdd(req);
            } else if ("edit".equals(action)) {
                handleEdit(req);
            } else if ("delete".equals(action)) {
                handleDelete(req);
            } else {
                req.setAttribute("error", "未知操作");
            }
        } catch (Exception e) {
            req.setAttribute("error", "操作失败: " + e.getMessage());
            e.printStackTrace();
        }
        resp.sendRedirect(req.getContextPath() + "/admin/index.jsp");
    }

    private void handleAdd(HttpServletRequest req) throws SQLException {
        String name = req.getParameter("teacherName");
        if (name == null || name.trim().isEmpty()) {
            throw new SQLException("教师姓名不能为空");
        }
        TeacherDao dao = new TeacherDao();
        String number = generateUniqueTeacherNumber();
        dao.addTeacher(number, name.trim(), "12345678");
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        String idStr = req.getParameter("teacherId");
        if (idStr == null) throw new SQLException("缺少教师ID");
        int teacherId = Integer.parseInt(idStr);
        String name = req.getParameter("teacherName");
        String password = req.getParameter("password");
        if (name == null || name.trim().isEmpty()) {
            throw new SQLException("教师姓名不能为空");
        }
        String pwd = (password == null || password.trim().isEmpty()) ? "12345678" : password;
        TeacherDao dao = new TeacherDao();
        dao.updateTeacher(teacherId, name.trim(), pwd);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        String idStr = req.getParameter("teacherId");
        if (idStr == null) throw new SQLException("缺少教师ID");
        int teacherId = Integer.parseInt(idStr);
        TeacherDao dao = new TeacherDao();
        dao.deleteTeacher(teacherId);
    }

    private String generateUniqueTeacherNumber() throws SQLException {
        TeacherDao dao = new TeacherDao();
        Random random = new Random();
        for (int i = 0; i < 20; i++) {
            int number = 100000 + random.nextInt(900000);
            String teacherNumber = String.valueOf(number);
            if (dao.findByNumber(teacherNumber) == null) {
                return teacherNumber;
            }
        }
        throw new SQLException("生成教师工号失败，请重试");
    }
}


