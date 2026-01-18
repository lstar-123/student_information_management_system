<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.lingxing.bean.Teacher" %>
<%@ page import="com.lingxing.bean.Student" %>
<%@ page import="com.lingxing.dao.CourseMapper" %>
<%@ page import="com.lingxing.dao.StudentMapper" %>
<%@ page import="com.lingxing.util.MyBatisUtil" %>
<%@ page import="com.lingxing.util.DBUtil" %>
<%@ page import="org.apache.ibatis.session.SqlSession" %>
<%
    Object user = session.getAttribute("currentUser");
    String role = (String) session.getAttribute("role");
    if (user == null || !"teacher".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=teacher");
        return;
    }
    Teacher teacher = (Teacher) user;
    List<Student> allStudents;
    List<CourseMapper.CourseItem> allCourses;
    List<Student> allowedStudents = new ArrayList<>();
    List<CourseMapper.CourseItem> allowedCourses = new ArrayList<>();
    Set<String> allowedClassSet = new HashSet<>();

    try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
        StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
        CourseMapper courseMapper = sqlSession.getMapper(CourseMapper.class);
        allStudents = studentMapper.findAll();
        allCourses = courseMapper.findAll();

        // 根据教师权限过滤学生和课程
        String teacherClass = teacher.getTeacherClass();
        String teacherSubject = teacher.getTeacherSubject();

        if (teacherClass != null && !teacherClass.trim().isEmpty()) {
            String[] classTokens = teacherClass.split(",");
            for (String token : classTokens) {
                String trimmed = token.trim();
                if (trimmed.contains("~") && trimmed.contains("级") && trimmed.contains("班")) {
                    int gradeIndex = trimmed.indexOf("级");
                    String yearPart = trimmed.substring(0, gradeIndex);
                    String classPart = trimmed.substring(gradeIndex + 1, trimmed.length() - 1);
                    String[] yearRange = yearPart.split("~");
                    String[] classRange = classPart.split("~");
                    if (yearRange.length == 2 && classRange.length == 2) {
                        int startYear = Integer.parseInt(yearRange[0]);
                        int endYear = Integer.parseInt(yearRange[1]);
                        int startClass = Integer.parseInt(classRange[0]);
                        int endClass = Integer.parseInt(classRange[1]);
                        for (int y = startYear; y <= endYear; y++) {
                            for (int c = startClass; c <= endClass; c++) {
                                allowedClassSet.add(y + "级" + c + "班");
                            }
                        }
                    } else {
                        allowedClassSet.add(trimmed);
                    }
                } else if (!trimmed.isEmpty()) {
                    allowedClassSet.add(trimmed);
                }
            }

            for (Student student : allStudents) {
                if (allowedClassSet.contains(student.getStuClass())) {
                    allowedStudents.add(student);
                }
            }
        }

        if (teacherSubject != null && !teacherSubject.trim().isEmpty()) {
            String[] allowedSubjects = teacherSubject.split(",");
            for (CourseMapper.CourseItem course : allCourses) {
                for (String allowedSubject : allowedSubjects) {
                    if (allowedSubject.trim().equals(course.getName())) {
                        allowedCourses.add(course);
                        break;
                    }
                }
            }
        }
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

        /* ===== 成绩列表 hover 渐变文字 ===== */
        #scores table tbody tr:hover td {
            background: linear-gradient(135deg, #6366f1, #3b82f6);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            transition: all .25s ease;
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
            <!-- 权限信息提示 -->
            <% if (teacher.getTeacherClass() == null || teacher.getTeacherClass().trim().isEmpty() ||
                   teacher.getTeacherSubject() == null || teacher.getTeacherSubject().trim().isEmpty()) { %>
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <strong>权限设置提醒：</strong>您的账号尚未设置负责班级或科目，请联系管理员进行设置。
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <ul class="nav nav-tabs mb-3" id="teacherTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="scores-tab" data-bs-toggle="tab" data-bs-target="#scores" type="button">成绩管理</button>
                </li>
            </ul>
    <div class="tab-content">
        <!-- 成绩管理 -->
        <div class="tab-pane fade show active" id="scores" role="tabpanel">
            <div class="card mb-3">
                <div class="card-header">添加成绩</div>
                <div class="card-body">
                    <form class="row g-2" method="post" action="<%=request.getContextPath()%>/teacher/score">
                        <input type="hidden" name="action" value="add">
                        <div class="col-md-3">
                            <label class="form-label">学生姓名</label>
                            <select name="stuName" class="form-select" required>
                                <% if (allowedStudents.isEmpty()) { %>
                                <option disabled>暂无权限管理的学生</option>
                                <% } else { %>
                                <% for (Student s : allowedStudents) { %>
                                <option><%=s.getStuName()%></option>
                                <% } %>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">课程</label>
                            <select name="courseName" class="form-select" required>
                                <% if (allowedCourses.isEmpty()) { %>
                                <option disabled>暂无权限管理的课程</option>
                                <% } else { %>
                                <% for (CourseMapper.CourseItem c : allowedCourses) { %>
                                <option><%=c.getName()%></option>
                                <% } %>
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
                                <% if (allowedStudents.isEmpty()) { %>
                                <option disabled>暂无权限管理的学生</option>
                                <% } else { %>
                                <% for (Student s : allowedStudents) { %>
                                <option><%=s.getStuName()%></option>
                                <% } %>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">课程</label>
                            <select name="courseName" class="form-select" required>
                                <% if (allowedCourses.isEmpty()) { %>
                                <option disabled>暂无权限管理的课程</option>
                                <% } else { %>
                                <% for (CourseMapper.CourseItem c : allowedCourses) { %>
                                <option><%=c.getName()%></option>
                                <% } %>
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
                                <% if (allowedStudents.isEmpty()) { %>
                                <option disabled>暂无权限管理的学生</option>
                                <% } else { %>
                                <% for (Student s : allowedStudents) { %>
                                <option><%=s.getStuName()%></option>
                                <% } %>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select name="courseName" class="form-select" required>
                                <% if (allowedCourses.isEmpty()) { %>
                                <option disabled>暂无权限管理的课程</option>
                                <% } else { %>
                                <% for (CourseMapper.CourseItem c : allowedCourses) { %>
                                <option><%=c.getName()%></option>
                                <% } %>
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

            <!-- 成绩列表 -->
            <div class="card mb-3">
                <div class="card-header">成绩列表</div>
                <div class="card-body">
                    <%
                    if (allowedClassSet.isEmpty()) {
                    %>
                    <div class="alert alert-warning">您尚未设置负责班级，请联系管理员设置。</div>
                    <%
                    } else if (allowedCourses.isEmpty()) {
                    %>
                    <div class="alert alert-warning">您尚未设置负责科目，请联系管理员设置。</div>
                    <%
                    } else {
                        // 查询教师负责班级的学生成绩
                        try {
                            Connection conn = DBUtil.getConnection();

                            // 构建班级条件
                            StringBuilder classCondition = new StringBuilder();
                            int classIndex = 0;
                            for (String cls : allowedClassSet) {
                                if (classIndex++ > 0) classCondition.append(",");
                                classCondition.append("'").append(cls).append("'");
                            }

                            // 构建动态列：每个课程对应期中/期末两列
                            StringBuilder sql = new StringBuilder("SELECT st.stu_number, st.stu_name, st.stu_class");
                            for (CourseMapper.CourseItem course : allowedCourses) {
                                sql.append(", MAX(CASE WHEN s.course_id = ").append(course.getId())
                                   .append(" AND s.exam_type = '期中' THEN s.score END) AS `")
                                   .append(course.getName()).append("_期中`");
                                sql.append(", MAX(CASE WHEN s.course_id = ").append(course.getId())
                                   .append(" AND s.exam_type = '期末' THEN s.score END) AS `")
                                   .append(course.getName()).append("_期末`");
                            }
                            sql.append(" FROM tb_student st ");
                            sql.append(" LEFT JOIN tb_score s ON st.stu_id = s.stu_id ");
                            sql.append(" WHERE st.stu_class IN (").append(classCondition.toString()).append(") ");
                            sql.append(" GROUP BY st.stu_id, st.stu_number, st.stu_name, st.stu_class ");
                            sql.append(" ORDER BY st.stu_class, st.stu_name");

                            PreparedStatement ps = conn.prepareStatement(sql.toString());
                            ResultSet rs = ps.executeQuery();

                            boolean hasData = false;
                    %>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-primary">
                                <tr>
                                    <th>学号</th>
                                    <th>姓名</th>
                                    <th>班级</th>
                                    <% for (CourseMapper.CourseItem course : allowedCourses) { %>
                                    <th><%=course.getName()%>-期中</th>
                                    <th><%=course.getName()%>-期末</th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                            while (rs.next()) {
                                hasData = true;
                            %>
                                <tr>
                                    <td><%=rs.getString("stu_number")%></td>
                                    <td><%=rs.getString("stu_name")%></td>
                                    <td><%=rs.getString("stu_class")%></td>
                                    <% for (CourseMapper.CourseItem course : allowedCourses) { %>
                                    <td><%=rs.getObject(course.getName() + "_期中") == null ? "-" : rs.getObject(course.getName() + "_期中")%></td>
                                    <td><%=rs.getObject(course.getName() + "_期末") == null ? "-" : rs.getObject(course.getName() + "_期末")%></td>
                                    <% } %>
                                </tr>
                            <%
                            }
                            if (!hasData) {
                            %>
                                <tr>
                                    <td colspan="<%= 3 + (allowedCourses.size() * 2) %>" class="text-center text-muted">暂无成绩记录</td>
                                </tr>
                            <%
                            }
                            %>
                            </tbody>
                        </table>
                    </div>
                    <%
                            rs.close();
                            ps.close();
                            conn.close();
                        } catch (Exception e) {
                    %>
                    <div class="alert alert-danger">加载成绩列表失败：<%=e.getMessage()%></div>
                    <%
                        }
                    }
                    %>
                </div>
            </div>

        </div>
    </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
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

    /* 光晕 */
    (function () {
        const glow = document.getElementById('cursor-glow');
        if (!glow) return;
        document.addEventListener('mousemove', e => {
            glow.style.left = e.clientX + 'px';
            glow.style.top = e.clientY + 'px';
        });
    })();
</script>

</body>
</html>

