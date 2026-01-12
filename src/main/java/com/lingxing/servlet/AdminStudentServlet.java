package com.lingxing.servlet;

import com.lingxing.dao.StudentMapper;
import com.lingxing.bean.Student;
import com.lingxing.util.MyBatisUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;

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

    private void handleAdd(HttpServletRequest req) throws Exception {
        String name = req.getParameter("stuName");
        String year = req.getParameter("year");
        String classNum = req.getParameter("classNum");
        if (name == null || name.trim().isEmpty() || year == null || classNum == null) {
            throw new Exception("姓名、年份、班级不能为空");
        }
        String classNumTwo = String.format("%02d", Integer.parseInt(classNum));
        String stuNumber = generateStudentNumber(year, classNumTwo);
        String stuClass = year + "级" + classNum + "班";
        
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            StudentMapper mapper = sqlSession.getMapper(StudentMapper.class);
            Student student = new Student();
            student.setStuNumber(stuNumber);
            student.setStuName(name.trim());
            student.setStuClass(stuClass);
            student.setPassword("12345678");
            mapper.insert(student);
        }
    }

    private void handleEdit(HttpServletRequest req) throws Exception {
        String idStr = req.getParameter("stuId");
        if (idStr == null) throw new Exception("缺少学生ID");
        int stuId = Integer.parseInt(idStr);
        String name = req.getParameter("stuName");
        String year = req.getParameter("year");
        String classNum = req.getParameter("classNum");
        String password = req.getParameter("password");
        boolean reset = "on".equals(req.getParameter("resetPassword"));

        if (name == null || name.trim().isEmpty() || year == null || classNum == null) {
            throw new Exception("姓名、年份、班级不能为空");
        }
        
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            StudentMapper mapper = sqlSession.getMapper(StudentMapper.class);
            Student current = mapper.findById(stuId);
            if (current == null) throw new Exception("学生不存在");
            
            String currentStuClass = current.getStuClass();
            String currentYear = currentStuClass.substring(0, 4);
            String currentClass = currentStuClass.substring(5, currentStuClass.length() - 1);

            boolean classChanged = !currentYear.equals(year) || !currentClass.equals(classNum);
            String classNumTwo = String.format("%02d", Integer.parseInt(classNum));
            String stuNumber = current.getStuNumber();
            if (classChanged) {
                stuNumber = generateStudentNumber(year, classNumTwo);
            }
            String stuClass = year + "级" + classNum + "班";
            String finalPassword = reset ? "12345678" : (password == null || password.trim().isEmpty() ? current.getPassword() : password);
            
            Student student = new Student();
            student.setStuId(stuId);
            student.setStuNumber(stuNumber);
            student.setStuName(name.trim());
            student.setStuClass(stuClass);
            student.setPassword(finalPassword);
            mapper.update(student);
        }
    }

    private void handleDelete(HttpServletRequest req) throws Exception {
        String idStr = req.getParameter("stuId");
        if (idStr == null) throw new Exception("缺少学生ID");
        int stuId = Integer.parseInt(idStr);
        
        // 使用事务处理级联删除
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession(false)) {
            try {
                StudentMapper mapper = sqlSession.getMapper(StudentMapper.class);
                // 先删除成绩
                mapper.deleteScoresByStudentId(stuId);
                // 再删除学生
                mapper.deleteById(stuId);
                sqlSession.commit();
            } catch (Exception e) {
                sqlSession.rollback();
                throw e;
            }
        }
    }

    private String generateStudentNumber(String year, String classNumTwo) throws Exception {
        String prefix = year + classNumTwo + "%";
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            StudentMapper mapper = sqlSession.getMapper(StudentMapper.class);
            Integer maxSeq = mapper.getMaxSequenceByPrefix(prefix);
            int seq = (maxSeq == null) ? 1 : maxSeq + 1;
            return year + classNumTwo + String.format("%02d", seq);
        }
    }
}
