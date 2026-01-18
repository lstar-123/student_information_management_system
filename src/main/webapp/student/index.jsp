<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="com.lingxing.bean.Student" %>
<%
    Object obj = session.getAttribute("currentUser");
    String role = (String) session.getAttribute("role");
    if (obj == null || !"student".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=student");
        return;
    }
    Student stu = (Student) obj;
    
    // 获取当前选中的功能，默认为成绩查询
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.isEmpty()) {
        activeTab = "scores";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= "scores".equals(activeTab) ? "我的成绩" : "课程表" %> - 学生成绩管理系统</title>

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
            --bs-table-color: #e5e7eb;
            --bs-table-bg: transparent;
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

        /* ================= 功能切换导航 ================= */
        .function-nav {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
        }
        
        .function-nav .nav-btn {
            padding: 14px 28px;
            border-radius: 16px;
            border: 1px solid rgba(148,163,184,.25);
            background: rgba(15,23,42,.6);
            color: #c7d2fe;
            text-decoration: none;
            font-size: 16px;
            font-weight: 500;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .function-nav .nav-btn:hover {
            background: rgba(99,102,241,.15);
            border-color: rgba(99,102,241,.4);
            transform: translateY(-2px);
        }
        
        .function-nav .nav-btn.active {
            background: linear-gradient(135deg, #6366f1, #3b82f6);
            border-color: transparent;
            color: #ffffff;
            box-shadow: 0 8px 25px rgba(99,102,241,.35);
        }
        
        .function-nav .nav-btn .icon {
            font-size: 20px;
        }

        .nav-tabs .nav-link {
            color: #c7d2fe;
        }
        .nav-tabs .nav-link.active {
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
    </style>
</head>

<body>

<!-- ===== 背景 ===== -->
<canvas id="star-canvas"></canvas>
<div id="cursor-glow"></div>
<div class="background-grid"></div>

<div class="main-wrapper">

    <!-- ===== 导航栏 ===== -->
    <nav class="navbar navbar-expand-lg mb-3">
        <div class="container-fluid">
            <span class="navbar-brand">学生端 - <%= "scores".equals(activeTab) ? "成绩查询" : "课程表" %></span>

            <div class="d-flex align-items-center gap-3">
                <a href="<%=request.getContextPath()%>/student/semester_review.jsp"
                   class="btn btn-light btn-sm">
                    📊 学期回顾
                </a>
                <div class="navbar-text text-white d-none d-sm-block">
                    学号：<%=stu.getStuNumber()%>　
                    姓名：<%=stu.getStuName()%>　
                    班级：<%=stu.getStuClass()%>
                </div>
                <a href="<%=request.getContextPath()%>/logout.jsp"
                   class="btn btn-outline-light btn-sm px-3">
                    退出登录
                </a>
            </div>
        </div>
    </nav>

    <!-- ===== 主体 ===== -->
    <div class="container">

        <!-- 功能切换导航 -->
        <div class="function-nav">
            <a href="?tab=scores" class="nav-btn <%= "scores".equals(activeTab) ? "active" : "" %>">
                <span class="icon">📝</span>
                <span>成绩查询</span>
            </a>
            <a href="?tab=schedule" class="nav-btn <%= "schedule".equals(activeTab) ? "active" : "" %>">
                <span class="icon">📅</span>
                <span>课程表</span>
            </a>
        </div>

        <% if ("scores".equals(activeTab)) { %>
        <!-- 学期回顾卡片 -->
        <div class="row g-3 mb-3">
            <div class="col-12">
                <div class="card">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="mb-1">📚 本学期学习回顾</h5>
                            <p class="text-muted small mb-0">
                                以全新的方式回顾你的学习轨迹
                            </p>
                        </div>
                        <a href="<%=request.getContextPath()%>/student/semester_review.jsp"
                           class="btn btn-primary btn-lg px-4">
                            ✨ 进入回顾
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 成绩 Tab -->
        <div class="row g-3">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">成绩总览</div>

                    <div class="card-body">
                        <jsp:include page="scores_all.jsp"/>
                    </div>
                </div>
            </div>
        </div>
        <% } else { %>
        <!-- 课程表 -->
        <jsp:include page="course_schedule.jsp"/>
        <% } %>

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
