package com.lingxing.servlet;

import com.lingxing.bean.Teacher;
import com.lingxing.dao.CourseMapper;
import com.lingxing.dao.ScoreMapper;
import com.lingxing.dao.StudentMapper;
import com.lingxing.util.MyBatisUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;

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

    private void handleAdd(HttpServletRequest req) throws Exception {
        Teacher teacher = (Teacher) req.getSession().getAttribute("currentUser");
        if (teacher == null) throw new Exception("请先登录");

        String stuName = req.getParameter("stuName");
        String courseName = req.getParameter("courseName");
        String scoreStr = req.getParameter("score");
        String examType = req.getParameter("examType");
        if (stuName == null || courseName == null || scoreStr == null || examType == null) {
            throw new Exception("参数不完整");
        }
        double score = Double.parseDouble(scoreStr);
        if (score < 0 || score > 100) throw new Exception("成绩需在0-100之间");

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
            CourseMapper courseMapper = sqlSession.getMapper(CourseMapper.class);
            ScoreMapper scoreMapper = sqlSession.getMapper(ScoreMapper.class);

            int stuId = studentMapper.getIdByName(stuName.trim());
            int courseId = courseMapper.getIdByName(courseName.trim());
            if (stuId <= 0 || courseId <= 0) throw new Exception("学生或课程不存在");

            // 检查权限：教师只能管理自己所教班级和科目的成绩
            checkTeacherPermission(sqlSession, teacher, stuId, courseId);

            if (scoreMapper.exists(stuId, courseId, examType)) {
                throw new Exception("该学生该课程的成绩已存在");
            }
            scoreMapper.insert(stuId, courseId, score, examType);
        }
    }

    private void handleEdit(HttpServletRequest req) throws Exception {
        Teacher teacher = (Teacher) req.getSession().getAttribute("currentUser");
        if (teacher == null) throw new Exception("请先登录");

        String stuName = req.getParameter("stuName");
        String courseName = req.getParameter("courseName");
        String scoreStr = req.getParameter("score");
        String examType = req.getParameter("examType");
        if (stuName == null || courseName == null || scoreStr == null || examType == null) {
            throw new Exception("参数不完整");
        }
        double score = Double.parseDouble(scoreStr);
        if (score < 0 || score > 100) throw new Exception("成绩需在0-100之间");

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
            CourseMapper courseMapper = sqlSession.getMapper(CourseMapper.class);
            ScoreMapper scoreMapper = sqlSession.getMapper(ScoreMapper.class);

            int stuId = studentMapper.getIdByName(stuName.trim());
            int courseId = courseMapper.getIdByName(courseName.trim());
            if (stuId <= 0 || courseId <= 0) throw new Exception("学生或课程不存在");

            // 检查权限：教师只能管理自己所教班级和科目的成绩
            checkTeacherPermission(sqlSession, teacher, stuId, courseId);

            if (!scoreMapper.exists(stuId, courseId, examType)) {
                throw new Exception("成绩记录不存在");
            }
            scoreMapper.update(stuId, courseId, score, examType);
        }
    }

    private void handleDelete(HttpServletRequest req) throws Exception {
        Teacher teacher = (Teacher) req.getSession().getAttribute("currentUser");
        if (teacher == null) throw new Exception("请先登录");

        String stuName = req.getParameter("stuName");
        String courseName = req.getParameter("courseName");
        String examType = req.getParameter("examType");
        if (stuName == null || courseName == null || examType == null) {
            throw new Exception("参数不完整");
        }

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
            CourseMapper courseMapper = sqlSession.getMapper(CourseMapper.class);
            ScoreMapper scoreMapper = sqlSession.getMapper(ScoreMapper.class);

            int stuId = studentMapper.getIdByName(stuName.trim());
            int courseId = courseMapper.getIdByName(courseName.trim());
            if (stuId <= 0 || courseId <= 0) throw new Exception("学生或课程不存在");

            // 检查权限：教师只能管理自己所教班级和科目的成绩
            checkTeacherPermission(sqlSession, teacher, stuId, courseId);

            if (!scoreMapper.exists(stuId, courseId, examType)) {
                throw new Exception("成绩记录不存在");
            }
            scoreMapper.delete(stuId, courseId, examType);
        }
    }

    private void checkTeacherPermission(SqlSession sqlSession, Teacher teacher, int stuId, int courseId) throws Exception {
        // 检查教师是否有权限管理该学生的成绩
        StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
        CourseMapper courseMapper = sqlSession.getMapper(CourseMapper.class);

        // 获取学生信息
        com.lingxing.bean.Student student = studentMapper.findById(stuId);
        if (student == null) throw new Exception("学生不存在");

        // 获取课程信息
        String courseName = courseMapper.getNameById(courseId);
        if (courseName == null) throw new Exception("课程不存在");

        // 检查教师是否负责该班级
        String teacherClass = teacher.getTeacherClass();
        String teacherSubject = teacher.getTeacherSubject();

        if (teacherClass == null || teacherClass.trim().isEmpty()) {
            throw new Exception("教师未设置负责班级");
        }
        if (teacherSubject == null || teacherSubject.trim().isEmpty()) {
            throw new Exception("教师未设置负责科目");
        }

        // 检查班级权限
        boolean classAllowed = false;
        String[] allowedClasses = teacherClass.split(",");
        for (String allowedClass : allowedClasses) {
            if (allowedClass.trim().equals(student.getStuClass())) {
                classAllowed = true;
                break;
            }
        }

        // 检查科目权限
        boolean subjectAllowed = false;
        String[] allowedSubjects = teacherSubject.split(",");
        for (String allowedSubject : allowedSubjects) {
            if (allowedSubject.trim().equals(courseName)) {
                subjectAllowed = true;
                break;
            }
        }

        if (!classAllowed) {
            throw new Exception("您只能管理自己所教班级的学生成绩");
        }
        if (!subjectAllowed) {
            throw new Exception("您只能管理自己所教学科的成绩");
        }
    }
}
