package com.lingxing.servlet;

import com.lingxing.dao.StudentDao;
import com.lingxing.bean.Student;
import com.lingxing.util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AdminStudentServlet extends HttpServlet {

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
        String name = req.getParameter("stuName");
        String year = req.getParameter("year");
        String classNum = req.getParameter("classNum");
        if (name == null || name.trim().isEmpty() || year == null || classNum == null) {
            throw new SQLException("姓名、年份、班级不能为空");
        }
        String classNumTwo = String.format("%02d", Integer.parseInt(classNum));
        String stuNumber = generateStudentNumber(year, classNumTwo);
        String stuClass = year + "级" + classNum + "班";
        StudentDao dao = new StudentDao();
        dao.addStudent(stuNumber, name.trim(), stuClass, "12345678");
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        String idStr = req.getParameter("stuId");
        if (idStr == null) throw new SQLException("缺少学生ID");
        int stuId = Integer.parseInt(idStr);
        String name = req.getParameter("stuName");
        String year = req.getParameter("year");
        String classNum = req.getParameter("classNum");
        String password = req.getParameter("password");
        boolean reset = "on".equals(req.getParameter("resetPassword"));

        if (name == null || name.trim().isEmpty() || year == null || classNum == null) {
            throw new SQLException("姓名、年份、班级不能为空");
        }
        StudentDao dao = new StudentDao();
        String classNumTwo = String.format("%02d", Integer.parseInt(classNum));

        // 当前信息用于判断班级是否变化
        int currentId = stuId;
        Student current = dao.findById(currentId);
        if (current == null) throw new SQLException("学生不存在");
        String currentStuClass = current.getStuClass();
        String currentYear = currentStuClass.substring(0, 4);
        String currentClass = currentStuClass.substring(5, currentStuClass.length() - 1);

        boolean classChanged = !currentYear.equals(year) || !currentClass.equals(classNum);
        String stuNumber = current.getStuNumber();
        if (classChanged) {
            stuNumber = generateStudentNumber(year, classNumTwo);
        }
        String stuClass = year + "级" + classNum + "班";
        String finalPassword = reset ? "12345678" : (password == null || password.trim().isEmpty() ? current.getPassword() : password);
        dao.updateStudent(stuId, stuNumber, name.trim(), stuClass, finalPassword);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        String idStr = req.getParameter("stuId");
        if (idStr == null) throw new SQLException("缺少学生ID");
        int stuId = Integer.parseInt(idStr);
        StudentDao dao = new StudentDao();
        dao.deleteStudent(stuId);
    }

    private String generateStudentNumber(String year, String classNumTwo) throws SQLException {
        String prefix = year + classNumTwo;
        String sql = "SELECT MAX(CAST(SUBSTRING(stu_number, 7, 2) AS UNSIGNED)) AS max_sequence " +
                "FROM tb_student WHERE stu_number LIKE ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                int seq = 1;
                if (rs.next() && rs.getObject("max_sequence") != null) {
                    seq = rs.getInt("max_sequence") + 1;
                }
                return prefix + String.format("%02d", seq);
            }
        }
    }
}


