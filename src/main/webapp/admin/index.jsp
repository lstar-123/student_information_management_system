<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.lingxing.bean.Teacher" %>
<%@ page import="com.lingxing.bean.Student" %>
<%@ page import="com.lingxing.dao.TeacherMapper" %>
<%@ page import="com.lingxing.dao.StudentMapper" %>
<%@ page import="com.lingxing.dao.CourseMapper" %>
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
    List<CourseMapper.CourseItem> courses;
    try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
        TeacherMapper teacherMapper = sqlSession.getMapper(TeacherMapper.class);
        StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
        CourseMapper courseMapper = sqlSession.getMapper(CourseMapper.class);
        teachers = teacherMapper.findAll();
        students = studentMapper.findAll();
        courses = courseMapper.findAll();
    }
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>管理员后台 - 学生成绩管理系统</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        /* ================= 全局字体与背景（来自 index.jsp） ================= */
        html, body {
            height: 100%;
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Microsoft YaHei", sans-serif;
        }

        body {
            background:
                    radial-gradient(circle at 20% 20%, rgba(99,102,241,0.25), transparent 40%),
                    radial-gradient(circle at 80% 80%, rgba(14,165,233,0.18), transparent 40%),
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
            rgba(99,102,241,0.18),
            rgba(59,130,246,0.12),
            transparent 60%);
            transform: translate(-50%, -50%);
            z-index: 1;
        }

        .background-grid {
            position: fixed;
            inset: 0;
            z-index: 2;
            background-image:
                    linear-gradient(rgba(255,255,255,0.035) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(255,255,255,0.035) 1px, transparent 1px);
            background-size: 60px 60px;
            mask-image: radial-gradient(circle at center, black 60%, transparent 100%);
            pointer-events: none;
        }

        /* ================= 内容层 ================= */
        .main-wrapper {
            position: relative;
            z-index: 3;
        }

        /* ================= admin 原有样式的“视觉覆盖” ================= */
        .navbar {
            background: rgba(2,6,23,.85) !important;
            backdrop-filter: blur(14px);
            border-bottom: 1px solid rgba(148,163,184,.15);
        }

        .card {
            background: rgba(15,23,42,.75);
            backdrop-filter: blur(18px);
            border-radius: 24px;
            box-shadow: 0 30px 80px rgba(0,0,0,.6);
            border: none;
            color: #e5e7eb;
        }

        .card-header {
            background: transparent;
            border-bottom: 1px solid rgba(148,163,184,.15);
            font-weight: 600;
        }

        .form-control,
        .form-select {
            background: rgba(2,6,23,.65);
            border: 1px solid rgba(148,163,184,.25);
            color: #e5e7eb;
        }

        .form-control:focus,
        .form-select:focus {
            border-color: #6366f1;
            box-shadow: none;
        }

        .table {
            --bs-table-color: #e5e7eb;
            --bs-table-bg: transparent;
            color: #e5e7eb;
        }

        .table thead {
            background: rgba(30,41,59,.7);
            color: #e5e7eb !important;
        }

        .table-hover tbody tr:hover {
            background: rgba(99,102,241,.12);
        }

        /* ===== 成绩列表 hover 渐变文字 ===== */
        .table tbody tr:hover td {
            background: linear-gradient(135deg, #6366f1, #3b82f6);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent !important;
            transition: all .25s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg,#6366f1,#3b82f6);
            border: none;
        }

        .btn-success {
            background: linear-gradient(135deg,#22c55e,#16a34a);
            border: none;
        }

        .text-muted, .small {
            color: #94a3b8 !important;
        }


        /* 学号 / 工号 / 密码 */
        #teachers tbody td:nth-child(1),
        #teachers tbody td:nth-child(3),
        #students tbody td:nth-child(1),
        #students tbody td:nth-child(3) {
            color: #e5e7eb;
            font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
            letter-spacing: .4px;
        }
    </style>
</head>

<body>

    <!-- ===== 背景层（只新增，不影响业务） ===== -->
    <canvas id="star-canvas"></canvas>
    <div id="cursor-glow"></div>
    <div class="background-grid"></div>

    <div class="main-wrapper">

        <!-- ====================== ↓↓↓ 以下内容：原 admin.jsp 业务代码，一行未改 ↓↓↓ ====================== -->

        <nav class="navbar navbar-dark bg-primary mb-3">
            <div class="container-fluid">
                <span class="navbar-brand">管理员后台</span>
                <div class="d-flex align-items-center gap-3">
                    <span class="navbar-text text-white d-none d-sm-inline">固定账号：admin / 1234</span>
                    <a href="<%=request.getContextPath()%>/logout.jsp"
                       class="btn btn-outline-light btn-sm px-3">
                        退出登录
                    </a>
                </div>
            </div>
        </nav>

        <div class="container">
            <ul class="nav nav-tabs mb-3" id="adminTabs" role="tablist">
                <li class="nav-item">
                    <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#teachers">教师管理</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#students">学生管理</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#courses">课程管理</button>
                </li>
            </ul>

            <div class="tab-content">

                <!-- 教师管理 -->
                <div class="tab-pane fade show active" id="teachers">
                    <div class="card mb-3">
                        <div class="card-header">添加教师</div>
                        <div class="card-body">
                            <form class="row g-2" method="post" action="<%=request.getContextPath()%>/admin/teacher">
                                <input type="hidden" name="action" value="add">
                                <div class="col-sm-6 col-md-3">
                                    <label class="form-label">教师姓名</label>
                                    <input type="text" name="teacherName" class="form-control" required>
                                </div>
                                <div class="col-sm-6 col-md-3">
                                    <label class="form-label">所教班级</label>
                                    <input type="text" name="teacherClass" class="form-control" placeholder="例如：2024级1班,2024级2班">
                                </div>
                                <div class="col-sm-6 col-md-3">
                                    <label class="form-label">所教学科</label>
                                    <input type="text" name="teacherSubject" class="form-control" placeholder="例如：数学,英语">
                                </div>
                                <div class="col-sm-12 col-md-3 align-self-end">
                                    <button class="btn btn-primary">添加</button>
                                </div>
                                <div class="col-12 text-muted small">默认密码：12345678，工号自动生成。</div>
                            </form>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <span>教师列表</span>
                            <div class="input-group" style="width: 360px;">
                                <input type="text" id="teacherSearch" class="form-control" placeholder="搜索工号或姓名..." style="background: rgba(2,6,23,.65); border: 1px solid rgba(148,163,184,.25); color: #e5e7eb;">
                                <button class="btn btn-outline-info" type="button" onclick="filterTeachers('exact')">查询</button>
                                <button class="btn btn-outline-secondary" type="button" onclick="clearTeacherSearch()">清空</button>
                            </div>
                        </div>
                        <div class="card-body table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                <tr>
                                    <th>工号</th><th>姓名</th><th>所教班级</th><th>所教学科</th><th>密码</th><th style="width:220px;">操作</th>
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
                                            <div class="col-md-12 mb-2">
                                                <input type="text" name="teacherName" class="form-control form-control-sm" value="<%=t.getTeacherName()%>">
                                            </div>
                                            <div class="col-md-12 mb-2">
                                                <input type="text" name="teacherClass" class="form-control form-control-sm" value="<%=t.getTeacherClass() != null ? t.getTeacherClass() : ""%>" placeholder="所教班级">
                                            </div>
                                            <div class="col-md-12 mb-2">
                                                <input type="text" name="teacherSubject" class="form-control form-control-sm" value="<%=t.getTeacherSubject() != null ? t.getTeacherSubject() : ""%>" placeholder="所教学科">
                                            </div>
                                            <div class="col-md-12 mb-2">
                                                <input type="text" name="password" class="form-control form-control-sm" value="<%=t.getPassword()%>">
                                            </div>
                                            <div class="col-md-12">
                                                <button class="btn btn-sm btn-success">保存</button>
                                            </div>
                                        </form>
                                    </td>
                                    <td><%=t.getTeacherClass() != null ? t.getTeacherClass() : "-" %></td>
                                    <td><%=t.getTeacherSubject() != null ? t.getTeacherSubject() : "-" %></td>
                                    <td><%=t.getPassword()%></td>
                                    <td>
                                        <form method="post" action="<%=request.getContextPath()%>/admin/teacher">
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
                <div class="tab-pane fade" id="students">
                    <div class="card mb-3">
                        <div class="card-header">添加学生</div>
                        <div class="card-body">
                            <form class="row g-2" method="post" action="<%=request.getContextPath()%>/admin/student">
                                <input type="hidden" name="action" value="add">
                                <div class="col-sm-4 col-md-3">
                                    <label class="form-label">姓名</label>
                                    <input type="text" name="stuName" class="form-control">
                                </div>
                                <div class="col-sm-4 col-md-3">
                                    <label class="form-label">年份</label>
                                    <select name="year" class="form-select">
                                        <option>2025</option><option>2024</option><option>2023</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 col-md-3">
                                    <label class="form-label">班级</label>
                                    <select name="classNum" class="form-select">
                                        <% for(int i=1;i<=12;i++){ %><option><%=i%></option><% } %>
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
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <span>学生列表</span>
                            <div class="input-group" style="width: 360px;">
                                <input type="text" id="studentSearch" class="form-control" placeholder="搜索学号或姓名..." style="background: rgba(2,6,23,.65); border: 1px solid rgba(148,163,184,.25); color: #e5e7eb;">
                                <button class="btn btn-outline-info" type="button" onclick="filterStudents('exact')">查询</button>
                                <button class="btn btn-outline-secondary" type="button" onclick="clearStudentSearch()">清空</button>
                            </div>
                        </div>
                        <div class="card-body table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                <tr>
                                    <th>学号</th><th>姓名</th><th>班级</th><th>密码</th><th style="width:260px;">操作</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% for (Student s : students) { %>
                                <tr>
                                    <td><%=s.getStuNumber()%></td>
                                    <td colspan="2">
                                        <form class="row g-2" method="post" action="<%=request.getContextPath()%>/admin/student">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="stuId" value="<%=s.getStuId()%>">
                                            <div class="col-lg-3">
                                                <input type="text" name="stuName" class="form-control form-control-sm" value="<%=s.getStuName()%>">
                                            </div>
                                            <div class="col-lg-3">
                                                <select name="year" class="form-select form-select-sm">
                                                    <%
                                                    // 从学生班级信息中提取年份
                                                    String stuClass = s.getStuClass();
                                                    String currentYear = "2025"; // 默认值
                                                    if (stuClass != null && stuClass.contains("级")) {
                                                        int gradeIndex = stuClass.indexOf("级");
                                                        if (gradeIndex >= 4) { // 确保有足够的字符
                                                            currentYear = stuClass.substring(0, gradeIndex);
                                                        }
                                                    }
                                                    %>
                                                    <option <%= "2025".equals(currentYear) ? "selected" : "" %>>2025</option>
                                                    <option <%= "2024".equals(currentYear) ? "selected" : "" %>>2024</option>
                                                    <option <%= "2023".equals(currentYear) ? "selected" : "" %>>2023</option>
                                                </select>
                                            </div>
                                            <div class="col-lg-2">
                                                <select name="classNum" class="form-select form-select-sm">
                                                    <%
                                                    // 从学生班级信息中提取班级号（重用之前声明的stuClass变量）
                                                    String currentClassNum = "1"; // 默认值
                                                    if (stuClass != null && stuClass.contains("级") && stuClass.contains("班")) {
                                                        int gradeIndex = stuClass.indexOf("级");
                                                        int classIndex = stuClass.indexOf("班");
                                                        if (gradeIndex >= 0 && classIndex > gradeIndex) {
                                                            String classPart = stuClass.substring(gradeIndex + 1, classIndex);
                                                            // 移除可能的非数字字符
                                                            currentClassNum = classPart.replaceAll("[^0-9]", "");
                                                            if (currentClassNum.isEmpty()) {
                                                                currentClassNum = "1";
                                                            }
                                                        }
                                                    }
                                                    for(int i=1;i<=12;i++){
                                                    %>
                                                    <option <%= String.valueOf(i).equals(currentClassNum) ? "selected" : "" %>><%=i%></option>
                                                    <% } %>
                                                </select>
                                            </div>
                                            <div class="col-lg-2">
                                                <input type="text" name="password" class="form-control form-control-sm" value="<%=s.getPassword()%>">
                                            </div>
                                            <div class="col-lg-2">
                                                <button class="btn btn-sm btn-success">保存</button>
                                            </div>
                                        </form>
                                    </td>
                                    <td><%=s.getPassword()%></td>
                                    <td>
                                        <form method="post" action="<%=request.getContextPath()%>/admin/student">
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
                <div class="tab-pane fade" id="courses">
                    <div class="card mb-3">
                        <div class="card-header">添加课程</div>
                        <div class="card-body">
                            <form class="row g-2" method="post" action="<%=request.getContextPath()%>/admin/course">
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
                                <thead>
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
                                        <form class="row g-2" method="post" action="<%=request.getContextPath()%>/admin/course">
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
                                        <form method="post" action="<%=request.getContextPath()%>/admin/course" onsubmit="return confirm('删除该课程及其成绩？');">
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
            </div>
        </div>
    </div>

        <!-- ====================== ↑↑↑ 业务代码原样结束 ↑↑↑ ====================== -->



    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        /* ===== 搜索功能 ===== */
        function filterTeachers(mode) {
            const searchText = document.getElementById('teacherSearch').value.toLowerCase().trim();
            const tableRows = document.querySelectorAll('#teachers table tbody tr');

            tableRows.forEach(row => {
                const teacherNumber = row.cells[0].textContent.toLowerCase();
                // 从表单输入框中获取教师姓名
                const teacherNameInput = row.cells[1].querySelector('input[name="teacherName"]');
                const teacherName = teacherNameInput ? teacherNameInput.value.toLowerCase() : '';
                let isVisible = true;
                if (searchText) {
                    if (mode === 'exact') {
                        isVisible = (teacherNumber === searchText) || (teacherName === searchText);
                    } else {
                        isVisible = teacherNumber.includes(searchText) || teacherName.includes(searchText);
                    }
                }
                row.style.display = isVisible ? '' : 'none';
            });
        }

        function filterStudents(mode) {
            const searchText = document.getElementById('studentSearch').value.toLowerCase().trim();
            const tableRows = document.querySelectorAll('#students table tbody tr');

            tableRows.forEach(row => {
                const studentNumber = row.cells[0].textContent.toLowerCase();
                // 从表单输入框中获取学生姓名
                const studentNameInput = row.cells[1].querySelector('input[name="stuName"]');
                const studentName = studentNameInput ? studentNameInput.value.toLowerCase() : '';
                let isVisible = true;
                if (searchText) {
                    if (mode === 'exact') {
                        isVisible = (studentNumber === searchText) || (studentName === searchText);
                    } else {
                        isVisible = studentNumber.includes(searchText) || studentName.includes(searchText);
                    }
                }
                row.style.display = isVisible ? '' : 'none';
            });
        }

        function clearTeacherSearch() {
            document.getElementById('teacherSearch').value = '';
            filterTeachers();
        }

        function clearStudentSearch() {
            document.getElementById('studentSearch').value = '';
            filterStudents();
        }

        // 绑定搜索事件
        document.getElementById('teacherSearch').addEventListener('input', function () {
            filterTeachers('fuzzy');
        });
        document.getElementById('studentSearch').addEventListener('input', function () {
            filterStudents('fuzzy');
        });

        /* ===== 星空动画（仅视觉） ===== */
        const canvas = document.getElementById('star-canvas');
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
            ctx.clearRect(0,0,canvas.width,canvas.height);
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

        /* 光晕 */
        const glow = document.getElementById('cursor-glow');
        document.addEventListener('mousemove', e => {
            glow.style.left = e.clientX + 'px';
            glow.style.top = e.clientY + 'px';
        });
    </script>

</body>
</html>
