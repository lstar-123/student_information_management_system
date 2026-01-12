package com.lingxing.servlet;

import com.lingxing.dao.TeacherMapper;
import com.lingxing.bean.Teacher;
import com.lingxing.util.MyBatisUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;
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

    private void handleAdd(HttpServletRequest req) throws Exception {
        String name = req.getParameter("teacherName");
        if (name == null || name.trim().isEmpty()) {
            throw new Exception("教师姓名不能为空");
        }
        String number = generateUniqueTeacherNumber();
        
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            TeacherMapper mapper = sqlSession.getMapper(TeacherMapper.class);
            Teacher teacher = new Teacher();
            teacher.setTeacherNumber(number);
            teacher.setTeacherName(name.trim());
            teacher.setPassword("12345678");
            mapper.insert(teacher);
        }
    }

    private void handleEdit(HttpServletRequest req) throws Exception {
        String idStr = req.getParameter("teacherId");
        if (idStr == null) throw new Exception("缺少教师ID");
        int teacherId = Integer.parseInt(idStr);
        String name = req.getParameter("teacherName");
        String password = req.getParameter("password");
        if (name == null || name.trim().isEmpty()) {
            throw new Exception("教师姓名不能为空");
        }
        String pwd = (password == null || password.trim().isEmpty()) ? "12345678" : password;
        
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            TeacherMapper mapper = sqlSession.getMapper(TeacherMapper.class);
            Teacher teacher = new Teacher();
            teacher.setTeacherId(teacherId);
            teacher.setTeacherName(name.trim());
            teacher.setPassword(pwd);
            mapper.update(teacher);
        }
    }

    private void handleDelete(HttpServletRequest req) throws Exception {
        String idStr = req.getParameter("teacherId");
        if (idStr == null) throw new Exception("缺少教师ID");
        int teacherId = Integer.parseInt(idStr);
        
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            TeacherMapper mapper = sqlSession.getMapper(TeacherMapper.class);
            mapper.deleteById(teacherId);
        }
    }

    private String generateUniqueTeacherNumber() throws Exception {
        Random random = new Random();
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            TeacherMapper mapper = sqlSession.getMapper(TeacherMapper.class);
            for (int i = 0; i < 20; i++) {
                int number = 100000 + random.nextInt(900000);
                String teacherNumber = String.valueOf(number);
                if (mapper.findByNumber(teacherNumber) == null) {
                    return teacherNumber;
                }
            }
        }
        throw new Exception("生成教师工号失败，请重试");
    }
}
