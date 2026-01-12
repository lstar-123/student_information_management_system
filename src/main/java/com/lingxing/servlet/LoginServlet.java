package com.lingxing.servlet;

import com.lingxing.bean.Admin;
import com.lingxing.bean.Student;
import com.lingxing.bean.Teacher;
import com.lingxing.dao.AdminDao;
import com.lingxing.dao.StudentMapper;
import com.lingxing.dao.TeacherMapper;
import com.lingxing.util.MyBatisUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;

/**
 * 登录 Servlet，对应桌面版本的 AdminLoginSystem / StudentLoginSystem / TeacherLoginSystem。
 * 通过 role 参数区分三种身份：admin / teacher / student。
 */
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String role = request.getParameter("role");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (role == null || username == null || password == null
                || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "请输入账号和密码");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            switch (role) {
                case "admin": {
                    AdminDao adminDao = new AdminDao();
                    Admin admin = adminDao.login(username.trim(), password.trim());
                    if (admin != null) {
                        session.setAttribute("currentUser", admin);
                        session.setAttribute("role", "admin");
                        response.sendRedirect(request.getContextPath() + "/admin/index.jsp");
                    } else {
                        request.setAttribute("error", "管理员账号或密码错误");
                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                    }
                    break;
                }
                case "teacher": {
                    TeacherMapper teacherMapper = sqlSession.getMapper(TeacherMapper.class);
                    Teacher teacher = teacherMapper.findByNumberAndPassword(username.trim(), password.trim());
                    if (teacher != null) {
                        session.setAttribute("currentUser", teacher);
                        session.setAttribute("role", "teacher");
                        response.sendRedirect(request.getContextPath() + "/teacher/index.jsp");
                    } else {
                        request.setAttribute("error", "教师账号或密码错误");
                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                    }
                    break;
                }
                case "student": {
                    StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
                    Student student = studentMapper.findByNumberAndPassword(username.trim(), password.trim());
                    if (student != null) {
                        session.setAttribute("currentUser", student);
                        session.setAttribute("role", "student");
                        response.sendRedirect(request.getContextPath() + "/student/index.jsp");
                    } else {
                        request.setAttribute("error", "学号或密码错误");
                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                    }
                    break;
                }
                default: {
                    request.setAttribute("error", "未知身份类型");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            throw new ServletException("登录时数据库错误", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }
}


