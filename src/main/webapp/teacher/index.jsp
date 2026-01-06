<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.lingxing.bean.Teacher" %>
<%@ page import="com.lingxing.bean.Student" %>
<%@ page import="com.lingxing.dao.StudentDao" %>
<%@ page import="com.lingxing.dao.CourseDao" %>
<%
    Object user = session.getAttribute("currentUser");
    String role = (String) session.getAttribute("role");
    if (user == null || !"teacher".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=teacher");
        return;
    }
    Teacher teacher = (Teacher) user;
    StudentDao studentDao = new StudentDao();
    CourseDao courseDao = new CourseDao();
    List<Student> students = studentDao.findAll();
    List<CourseDao.CourseItem> courses = courseDao.findAll();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>教师后台 - 学生成绩管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-primary mb-3">
    <div class="container-fluid">
        <span class="navbar-brand">教师后台</span>
        <span class="navbar-text text-white">工号：<%=teacher.getTeacherNumber()%>　姓名：<%=teacher.getTeacherName()%></span>
    </div>
</nav>
<div class="container">
    <ul class="nav nav-tabs mb-3" id="teacherTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="students-tab" data-bs-toggle="tab" data-bs-target="#students" type="button">学生管理</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="courses-tab" data-bs-toggle="tab" data-bs-target="#courses" type="button">课程管理</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="scores-tab" data-bs-toggle="tab" data-bs-target="#scores" type="button">成绩管理</button>
        </li>
    </ul>
    <div class="tab-content">
        <!-- 学生管理 -->
        <div class="tab-pane fade show active" id="students" role="tabpanel">
            <div class="card mb-3">
                <div class="card-header">添加学生</div>
                <div class="card-body">
                    <form class="row g-2" method="post" action="<%=request.getContextPath()%>/teacher/student">
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
                            <th>姓名/班级/密码</th>
                            <th style="width:180px;">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Student s : students) { %>
                        <tr>
                            <td><%=s.getStuNumber()%></td>
                            <td>
                                <form class="row g-2 align-items-center" method="post" action="<%=request.getContextPath()%>/teacher/student">
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
                                            <input class="form-check-input" type="checkbox" name="resetPassword" id="treset<%=s.getStuId()%>">
                                            <label class="form-check-label small" for="treset<%=s.getStuId()%>">重置</label>
                                        </div>
                                        <button class="btn btn-sm btn-success">保存</button>
                                    </div>
                                </form>
                            </td>
                            <td>
                                <form method="post" action="<%=request.getContextPath()%>/teacher/student" onsubmit="return confirm('删除该学生及其成绩？');">
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

        <!-- 课程管理 -->
        <div class="tab-pane fade" id="courses" role="tabpanel">
            <div class="card mb-3">
                <div class="card-header">添加课程</div>
                <div class="card-body">
                    <form class="row g-2" method="post" action="<%=request.getContextPath()%>/teacher/course">
                        <input type="hidden" name="action" value="add">
                        <div class="col-sm-6 col-md-4">
                            <label class="form-label">课程名称</label>
                            <input type="text" name="courseName" class="form-control" required>
                        </div>
                        <div class="col-sm-12 col-md-3 align-self-end">
                            <button class="btn btn-primary">添加</button>
                        </div>
                    </form>
                </div>
            </div>
            <div class="card">
                <div class="card-header">课程列表</div>
                <div class="card-body table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-primary">
                        <tr>
                            <th>ID</th>
                            <th>课程名称</th>
                            <th style="width:180px;">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (CourseDao.CourseItem c : courses) { %>
                        <tr>
                            <td><%=c.getId()%></td>
                            <td>
                                <form class="row g-2" method="post" action="<%=request.getContextPath()%>/teacher/course">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="courseId" value="<%=c.getId()%>">
                                    <div class="col-md-7">
                                        <input type="text" name="courseName" class="form-control form-control-sm" value="<%=c.getName()%>" required>
                                    </div>
                                    <div class="col-md-5 d-flex gap-1">
                                        <button class="btn btn-sm btn-success">保存</button>
                                    </div>
                                </form>
                            </td>
                            <td>
                                <form method="post" action="<%=request.getContextPath()%>/teacher/course" onsubmit="return confirm('删除该课程及其成绩？');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="courseId" value="<%=c.getId()%>">
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

        <!-- 成绩管理 -->
        <div class="tab-pane fade" id="scores" role="tabpanel">
            <div class="card mb-3">
                <div class="card-header">添加成绩</div>
                <div class="card-body">
                    <form class="row g-2" method="post" action="<%=request.getContextPath()%>/teacher/score">
                        <input type="hidden" name="action" value="add">
                        <div class="col-md-3">
                            <label class="form-label">学生姓名</label>
                            <select name="stuName" class="form-select" required>
                                <% for (Student s : students) { %>
                                <option><%=s.getStuName()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">课程</label>
                            <select name="courseName" class="form-select" required>
                                <% for (CourseDao.CourseItem c : courses) { %>
                                <option><%=c.getName()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">成绩</label>
                            <input type="number" step="0.1" min="0" max="100" name="score" class="form-control" required>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">考试</label>
                            <select name="examType" class="form-select" required>
                                <option value="期中">期中</option>
                                <option value="期末">期末</option>
                            </select>
                        </div>
                        <div class="col-md-2 align-self-end">
                            <button class="btn btn-primary">添加</button>
                        </div>
                    </form>
                </div>
            </div>
            <div class="card mb-3">
                <div class="card-header">编辑 / 删除成绩</div>
                <div class="card-body">
                    <form class="row g-2" method="post" action="<%=request.getContextPath()%>/teacher/score">
                        <input type="hidden" name="action" value="edit">
                        <div class="col-md-3">
                            <label class="form-label">学生姓名</label>
                            <select name="stuName" class="form-select" required>
                                <% for (Student s : students) { %>
                                <option><%=s.getStuName()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">课程</label>
                            <select name="courseName" class="form-select" required>
                                <% for (CourseDao.CourseItem c : courses) { %>
                                <option><%=c.getName()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">新的成绩</label>
                            <input type="number" step="0.1" min="0" max="100" name="score" class="form-control" required>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">考试</label>
                            <select name="examType" class="form-select" required>
                                <option value="期中">期中</option>
                                <option value="期末">期末</option>
                            </select>
                        </div>
                        <div class="col-md-2 align-self-end d-flex gap-2">
                            <button class="btn btn-success">保存</button>
                        </div>
                    </form>
                    <form class="row g-2 mt-2" method="post" action="<%=request.getContextPath()%>/teacher/score" onsubmit="return confirm('删除该成绩记录？');">
                        <input type="hidden" name="action" value="delete">
                        <div class="col-md-3">
                            <select name="stuName" class="form-select" required>
                                <% for (Student s : students) { %>
                                <option><%=s.getStuName()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select name="courseName" class="form-select" required>
                                <% for (CourseDao.CourseItem c : courses) { %>
                                <option><%=c.getName()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <select name="examType" class="form-select" required>
                                <option value="期中">期中</option>
                                <option value="期末">期末</option>
                            </select>
                        </div>
                        <div class="col-md-2 align-self-end">
                            <button class="btn btn-outline-danger">删除成绩</button>
                        </div>
                    </form>
                </div>
            </div>
            <div class="card">
                <div class="card-header">
                    成绩总览
                </div>
                <div class="card-body">
                    <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="pills-mid-tab" data-bs-toggle="pill" data-bs-target="#pills-mid" type="button">期中</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="pills-final-tab" data-bs-toggle="pill" data-bs-target="#pills-final" type="button">期末</button>
                        </li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane fade show active" id="pills-mid" role="tabpanel">
                            <jsp:include page="scores_mid.jsp"/>
                        </div>
                        <div class="tab-pane fade" id="pills-final" role="tabpanel">
                            <jsp:include page="scores_final.jsp"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

