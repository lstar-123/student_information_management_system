package com.lingxing.servlet;

import com.lingxing.dao.CourseDao;
import com.lingxing.dao.ScoreDao;
import com.lingxing.dao.StudentDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class TeacherScoreServlet extends HttpServlet {

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
        resp.sendRedirect(req.getContextPath() + "/teacher/index.jsp#scores");
    }

    private void handleAdd(HttpServletRequest req) throws SQLException {
        String stuName = req.getParameter("stuName");
        String courseName = req.getParameter("courseName");
        String scoreStr = req.getParameter("score");
        String examType = req.getParameter("examType");
        if (stuName == null || courseName == null || scoreStr == null || examType == null) {
            throw new SQLException("参数不完整");
        }
        double score = Double.parseDouble(scoreStr);
        if (score < 0 || score > 100) throw new SQLException("成绩需在0-100之间");
        StudentDao studentDao = new StudentDao();
        CourseDao courseDao = new CourseDao();
        ScoreDao scoreDao = new ScoreDao();
        int stuId = studentDao.getIdByName(stuName.trim());
        int courseId = courseDao.getIdByName(courseName.trim());
        if (stuId == -1 || courseId == -1) throw new SQLException("学生或课程不存在");
        if (scoreDao.exists(stuId, courseId, examType)) {
            throw new SQLException("该学生该课程的成绩已存在");
        }
        scoreDao.addScore(stuId, courseId, score, examType);
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        String stuName = req.getParameter("stuName");
        String courseName = req.getParameter("courseName");
        String scoreStr = req.getParameter("score");
        String examType = req.getParameter("examType");
        if (stuName == null || courseName == null || scoreStr == null || examType == null) {
            throw new SQLException("参数不完整");
        }
        double score = Double.parseDouble(scoreStr);
        if (score < 0 || score > 100) throw new SQLException("成绩需在0-100之间");
        StudentDao studentDao = new StudentDao();
        CourseDao courseDao = new CourseDao();
        ScoreDao scoreDao = new ScoreDao();
        int stuId = studentDao.getIdByName(stuName.trim());
        int courseId = courseDao.getIdByName(courseName.trim());
        if (stuId == -1 || courseId == -1) throw new SQLException("学生或课程不存在");
        if (!scoreDao.exists(stuId, courseId, examType)) {
            throw new SQLException("成绩记录不存在");
        }
        scoreDao.updateScore(stuId, courseId, score, examType);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        String stuName = req.getParameter("stuName");
        String courseName = req.getParameter("courseName");
        String examType = req.getParameter("examType");
        if (stuName == null || courseName == null || examType == null) {
            throw new SQLException("参数不完整");
        }
        StudentDao studentDao = new StudentDao();
        CourseDao courseDao = new CourseDao();
        ScoreDao scoreDao = new ScoreDao();
        int stuId = studentDao.getIdByName(stuName.trim());
        int courseId = courseDao.getIdByName(courseName.trim());
        if (stuId == -1 || courseId == -1) throw new SQLException("学生或课程不存在");
        if (!scoreDao.exists(stuId, courseId, examType)) {
            throw new SQLException("成绩记录不存在");
        }
        scoreDao.deleteScore(stuId, courseId, examType);
    }
}


