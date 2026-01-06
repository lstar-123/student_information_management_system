package com.lingxing.servlet;

import com.lingxing.dao.CourseDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class TeacherCourseServlet extends HttpServlet {

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
        resp.sendRedirect(req.getContextPath() + "/teacher/index.jsp#courses");
    }

    private void handleAdd(HttpServletRequest req) throws SQLException {
        String courseName = req.getParameter("courseName");
        if (courseName == null || courseName.trim().isEmpty()) {
            throw new SQLException("课程名称不能为空");
        }
        CourseDao dao = new CourseDao();
        if (dao.existsName(courseName.trim(), null)) {
            throw new SQLException("课程名称已存在");
        }
        dao.addCourse(courseName.trim());
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        String idStr = req.getParameter("courseId");
        if (idStr == null) throw new SQLException("缺少课程ID");
        int courseId = Integer.parseInt(idStr);
        String courseName = req.getParameter("courseName");
        if (courseName == null || courseName.trim().isEmpty()) {
            throw new SQLException("课程名称不能为空");
        }
        CourseDao dao = new CourseDao();
        if (dao.existsName(courseName.trim(), courseId)) {
            throw new SQLException("课程名称已存在");
        }
        dao.updateCourse(courseId, courseName.trim());
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        String idStr = req.getParameter("courseId");
        if (idStr == null) throw new SQLException("缺少课程ID");
        int courseId = Integer.parseInt(idStr);
        CourseDao dao = new CourseDao();
        dao.deleteCourse(courseId);
    }
}


