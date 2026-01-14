<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.lingxing.bean.Teacher" %>
<%@ page import="com.lingxing.bean.Student" %>
<%@ page import="com.lingxing.dao.StudentMapper" %>
<%@ page import="com.lingxing.dao.CourseMapper" %>
<%@ page import="com.lingxing.util.MyBatisUtil" %>
<%@ page import="org.apache.ibatis.session.SqlSession" %>
<%
    Object user = session.getAttribute("currentUser");
    String role = (String) session.getAttribute("role");
    if (user == null || !"teacher".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=teacher");
        return;
    }
    Teacher teacher = (Teacher) user;
    List<Student> students;
    List<CourseMapper.CourseItem> courses;
    try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
        StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
        CourseMapper courseMapper = sqlSession.getMapper(CourseMapper.class);
        students = studentMapper.findAll();
        courses = courseMapper.findAll();
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>教师后台 - 学生成绩管理系统</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        /* ================= 基础 ================= */
        html, body {
            height: 100%;
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Microsoft YaHei", sans-serif;
        }
        body {
            background:
                    radial-gradient(circle at 20% 20%, rgba(99,102,241,.25), transparent 40%),
                    radial-gradient(circle at 80% 80%, rgba(14,165,233,.18), transparent 40%),
                    linear-gradient(180deg, #020617, #020617);
            color: #e5e7eb;
            overflow-x: hidden;
        }

        /* ================= 背景层 ================= */
        #star-canvas {
            position: fixed;
            inset: 0;
            z-index: 0;
        }
        #cursor-glow {
            position: fixed;
            width: 420px;
            height: 420px;
            pointer-events: none;
            background: radial-gradient(circle,
            rgba(99,102,241,.18),
            transparent 60%);
            transform: translate(-50%, -50%);
            z-index: 1;
        }
        .background-grid {
            position: fixed;
            inset: 0;
            z-index: 2;
            background-image:
                    linear-gradient(rgba(255,255,255,.035) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(255,255,255,.035) 1px, transparent 1px);
            background-size: 60px 60px;
            pointer-events: none;
        }

        /* ================= 内容层 ================= */
        .main-wrapper {
            position: relative;
            z-index: 3;
        }

        /* ================= 组件样式 ================= */
        .navbar {
            background: rgba(2,6,23,.85) !important;
            backdrop-filter: blur(14px);
            border-bottom: 1px solid rgba(148,163,184,.15);
        }

        .navbar-brand {
            color: #e5e7eb;
        }

        .card {
            background: rgba(15,23,42,.75);
            backdrop-filter: blur(18px);
            border-radius: 22px;
            border: none;
            color: #e5e7eb;
            box-shadow: 0 30px 80px rgba(0,0,0,.6);
        }

        .card-header {
            background: transparent;
            border-bottom: 1px solid rgba(148,163,184,.15);
        }

        .nav-tabs .nav-link,
        .nav-pills .nav-link {
            color: #c7d2fe;
        }
        .nav-tabs .nav-link.active,
        .nav-pills .nav-link.active {
            background: transparent;
            border-color: #6366f1;
            color: #ffffff;
        }

        .btn-primary {
            background: linear-gradient(135deg, #6366f1, #3b82f6);
            border: none;
        }

        .text-muted {
            color: #94a3b8 !important;
        }

        .table {
            --bs-table-bg: transparent;
            color: #e5e7eb;
        }
        .table thead {
            background: rgba(30,41,59,.7);
        }
        .table tbody tr {
            --bs-table-color: #e5e7eb;
            --bs-table-bg: transparent;
            color: #e5e7eb;
        }
        .table-hover tbody tr:hover {
            background: rgba(99,102,241,.12);
        }
    </style>
</head>

<body>

<!-- ===== 背景 ===== -->
<canvas id="star-canvas"></canvas>
<div id="cursor-glow"></div>
<div class="background-grid"></div>

<div class="main-wrapper">

<nav class="navbar navbar-expand-lg mb-3">
    <div class="container-fluid">
        <span class="navbar-brand">教师后台</span>
        <div class="d-flex align-items-center gap-3">
            <div class="navbar-text text-white d-none d-sm-block">
                工号：<%=teacher.getTeacherNumber()%>　
                姓名：<%=teacher.getTeacherName()%>
            </div>
            <a href="<%=request.getContextPath()%>/logout.jsp"
               class="btn btn-outline-light btn-sm px-3">
                退出登录
            </a>
        </div>
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
                        <% for (CourseMapper.CourseItem c : courses) { %>
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
                                <% for (CourseMapper.CourseItem c : courses) { %>
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
                                <% for (CourseMapper.CourseItem c : courses) { %>
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
                                <% for (CourseMapper.CourseItem c : courses) { %>
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
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    /* ===== 光晕 ===== */
    (function () {
        const glow = document.getElementById('cursor-glow');
        if (!glow) return;
        document.addEventListener('mousemove', e => {
            glow.style.left = e.clientX + 'px';
            glow.style.top = e.clientY + 'px';
        });
    })();

    /* ===== 星空 ===== */
    (function () {
        const canvas = document.getElementById('star-canvas');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        let stars = [];

        function resize() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }
        resize();
        window.addEventListener('resize', resize);

        for (let i = 0; i < 120; i++) {
            stars.push({
                x: Math.random() * canvas.width,
                y: Math.random() * canvas.height,
                r: Math.random() * 1.2 + .3,
                s: Math.random() * .4 + .1
            });
        }

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = 'rgba(255,255,255,.8)';
            stars.forEach(star => {
                star.y += star.s;
                if (star.y > canvas.height) star.y = 0;
                ctx.beginPath();
                ctx.arc(star.x, star.y, star.r, 0, Math.PI * 2);
                ctx.fill();
            });
            requestAnimationFrame(animate);
        }
        animate();
    })();
</script>

</body>
</html>

