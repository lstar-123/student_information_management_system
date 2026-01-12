<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.lingxing.bean.Teacher" %>
<%@ page import="com.lingxing.bean.Student" %>
<%@ page import="com.lingxing.dao.TeacherMapper" %>
<%@ page import="com.lingxing.dao.StudentMapper" %>
<%@ page import="com.lingxing.util.MyBatisUtil" %>
<%@ page import="org.apache.ibatis.session.SqlSession" %>
<%
    Object user = session.getAttribute("currentUser");
    String role = (String) session.getAttribute("role");
    if (user == null || !"admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
        return;
    }
    List<Teacher> teachers;
    List<Student> students;
    try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
        TeacherMapper teacherMapper = sqlSession.getMapper(TeacherMapper.class);
        StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
        teachers = teacherMapper.findAll();
        students = studentMapper.findAll();
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>管理员后台 - 学生成绩管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-primary mb-3">
    <div class="container-fluid">
        <span class="navbar-brand">管理员后台</span>
        <span class="navbar-text text-white">固定账号：admin / 1234</span>
    </div>
</nav>
<div class="container">
    <ul class="nav nav-tabs mb-3" id="adminTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="teachers-tab" data-bs-toggle="tab" data-bs-target="#teachers" type="button">教师管理</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="students-tab" data-bs-toggle="tab" data-bs-target="#students" type="button">学生管理</button>
        </li>
    </ul>
    <div class="tab-content">
        <!-- 教师管理 -->
        <div class="tab-pane fade show active" id="teachers" role="tabpanel">
            <div class="card mb-3">
                <div class="card-header">添加教师</div>
                <div class="card-body">
                    <form class="row g-2" method="post" action="<%=request.getContextPath()%>/admin/teacher">
                        <input type="hidden" name="action" value="add">
                        <div class="col-sm-6 col-md-4">
                            <label class="form-label">教师姓名</label>
                            <input type="text" name="teacherName" class="form-control" required>
                        </div>
                        <div class="col-sm-12 col-md-4 align-self-end">
                            <button class="btn btn-primary">添加</button>
                        </div>
                        <div class="col-12 text-muted small">默认密码：12345678，工号自动生成。</div>
                    </form>
                </div>
            </div>
            <div class="card">
                <div class="card-header">教师列表</div>
                <div class="card-body table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-primary">
                        <tr>
                            <th>工号</th>
                            <th>姓名</th>
                            <th>密码</th>
                            <th style="width:220px;">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Teacher t : teachers) { %>
                        <tr>
                            <td><%=t.getTeacherNumber()%></td>
                            <td>
                                <form class="row g-2" method="post" action="<%=request.getContextPath()%>/admin/teacher">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="teacherId" value="<%=t.getTeacherId()%>">
                                    <div class="col-md-5">
                                        <input type="text" name="teacherName" class="form-control form-control-sm" value="<%=t.getTeacherName()%>" required>
                                    </div>
                                    <div class="col-md-4">
                                        <input type="text" name="password" class="form-control form-control-sm" value="<%=t.getPassword()%>" required>
                                    </div>
                                    <div class="col-md-3 d-flex gap-1">
                                        <button class="btn btn-sm btn-success">保存</button>
                                    </div>
                                </form>
                            </td>
                            <td><%=t.getPassword()%></td>
                            <td>
                                <form method="post" action="<%=request.getContextPath()%>/admin/teacher" onsubmit="return confirm('删除该教师？');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="teacherId" value="<%=t.getTeacherId()%>">
                                    <button class="btn btn-sm btn-outline-danger">删除</button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- 学生管理 -->
        <div class="tab-pane fade" id="students" role="tabpanel">
            <div class="card mb-3">
                <div class="card-header">添加学生</div>
                <div class="card-body">
                    <form class="row g-2" method="post" action="<%=request.getContextPath()%>/admin/student">
                        <input type="hidden" name="action" value="add">
                        <div class="col-sm-4 col-md-3">
                            <label class="form-label">姓名</label>
                            <input type="text" name="stuName" class="form-control" required>
                        </div>
                        <div class="col-sm-4 col-md-3">
                            <label class="form-label">年份</label>
                            <select name="year" class="form-select" required>
                                <option>2024</option>
                                <option>2023</option>
                                <option>2022</option>
                            </select>
                        </div>
                        <div class="col-sm-4 col-md-3">
                            <label class="form-label">班级</label>
                            <select name="classNum" class="form-select" required>
                                <% for (int i=1;i<=12;i++){ %>
                                <option value="<%=i%>"><%=i%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-sm-12 col-md-3 align-self-end">
                            <button class="btn btn-primary">添加</button>
                        </div>
                        <div class="col-12 text-muted small">默认密码：12345678，学号自动生成。</div>
                    </form>
                </div>
            </div>
            <div class="card">
                <div class="card-header">学生列表</div>
                <div class="card-body table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-primary">
                        <tr>
                            <th>学号</th>
                            <th>姓名</th>
                            <th>班级</th>
                            <th>密码</th>
                            <th style="width:260px;">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Student s : students) { %>
                        <tr>
                            <td><%=s.getStuNumber()%></td>
                            <td colspan="2">
                                <form class="row g-2 align-items-center" method="post" action="<%=request.getContextPath()%>/admin/student">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="stuId" value="<%=s.getStuId()%>">
                                    <div class="col-lg-3">
                                        <input type="text" name="stuName" class="form-control form-control-sm" value="<%=s.getStuName()%>" required>
                                    </div>
                                    <div class="col-lg-3">
                                        <select name="year" class="form-select form-select-sm">
                                            <option <%=s.getStuClass().startsWith("2024")?"selected":""%>>2024</option>
                                            <option <%=s.getStuClass().startsWith("2023")?"selected":""%>>2023</option>
                                            <option <%=s.getStuClass().startsWith("2022")?"selected":""%>>2022</option>
                                        </select>
                                    </div>
                                    <div class="col-lg-2">
                                        <select name="classNum" class="form-select form-select-sm">
                                            <% for (int i=1;i<=12;i++){ %>
                                            <option value="<%=i%>" <%=s.getStuClass().contains("级"+i+"班")?"selected":""%>><%=i%></option>
                                            <% } %>
                                        </select>
                                    </div>
                                    <div class="col-lg-2">
                                        <input type="text" name="password" class="form-control form-control-sm" value="<%=s.getPassword()%>">
                                    </div>
                                    <div class="col-lg-2 d-flex gap-1">
                                        <div class="form-check form-check-sm">
                                            <input class="form-check-input" type="checkbox" name="resetPassword" id="reset<%=s.getStuId()%>">
                                            <label class="form-check-label small" for="reset<%=s.getStuId()%>">重置</label>
                                        </div>
                                        <button class="btn btn-sm btn-success">保存</button>
                                    </div>
                                </form>
                            </td>
                            <td><%=s.getPassword()%></td>
                            <td>
                                <form method="post" action="<%=request.getContextPath()%>/admin/student" onsubmit="return confirm('删除该学生及其成绩？');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="stuId" value="<%=s.getStuId()%>">
                                    <button class="btn btn-sm btn-outline-danger">删除</button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

