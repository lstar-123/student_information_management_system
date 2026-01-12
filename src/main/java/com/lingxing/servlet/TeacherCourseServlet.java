package com.lingxing.servlet;

import com.lingxing.dao.CourseMapper;
import com.lingxing.dao.ScoreMapper;
import com.lingxing.util.MyBatisUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;

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

    private void handleAdd(HttpServletRequest req) throws Exception {
        String courseName = req.getParameter("courseName");
        if (courseName == null || courseName.trim().isEmpty()) {
            throw new Exception("课程名称不能为空");
        }
        
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            CourseMapper mapper = sqlSession.getMapper(CourseMapper.class);
            if (mapper.existsName(courseName.trim(), null)) {
                throw new Exception("课程名称已存在");
            }
            mapper.insert(courseName.trim());
        }
    }

    private void handleEdit(HttpServletRequest req) throws Exception {
        String idStr = req.getParameter("courseId");
        if (idStr == null) throw new Exception("缺少课程ID");
        int courseId = Integer.parseInt(idStr);
        String courseName = req.getParameter("courseName");
        if (courseName == null || courseName.trim().isEmpty()) {
            throw new Exception("课程名称不能为空");
        }
        
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            CourseMapper mapper = sqlSession.getMapper(CourseMapper.class);
            if (mapper.existsName(courseName.trim(), courseId)) {
                throw new Exception("课程名称已存在");
            }
            mapper.update(courseId, courseName.trim());
        }
    }

    private void handleDelete(HttpServletRequest req) throws Exception {
        String idStr = req.getParameter("courseId");
        if (idStr == null) throw new Exception("缺少课程ID");
        int courseId = Integer.parseInt(idStr);
        
        // 使用事务处理级联删除
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession(false)) {
            try {
                CourseMapper courseMapper = sqlSession.getMapper(CourseMapper.class);
                ScoreMapper scoreMapper = sqlSession.getMapper(ScoreMapper.class);
                // 先删除成绩
                scoreMapper.deleteByCourseId(courseId);
                // 再删除课程
                courseMapper.deleteById(courseId);
                sqlSession.commit();
            } catch (Exception e) {
                sqlSession.rollback();
                throw e;
            }
        }
    }
}
