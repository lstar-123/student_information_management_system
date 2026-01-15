<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
  String role = request.getParameter("role");
  if (role == null || role.isEmpty()) role = "student";

  String title, subtitle, emoji;
  if ("admin".equals(role)) {
    title = "System Overview";
    subtitle = "系统运行状态与全局掌控";
    emoji = "🛠️";
  } else if ("teacher".equals(role)) {
    title = "Teaching Overview";
    subtitle = "你所引导的学习正在发生";
    emoji = "📘";
  } else {
    title = "Your Learning Journey";
    subtitle = "这是你一段学习轨迹的开始";
    emoji = "🎓";
  }

  String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title><%= title %> · 学生成绩管理系统</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    html, body {
      height: 100%;
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Microsoft YaHei", sans-serif;
    }

    /* ===== 主背景 ===== */
    body {
      background:
              radial-gradient(circle at 20% 20%, rgba(99,102,241,0.25), transparent 40%),
              radial-gradient(circle at 80% 80%, rgba(14,165,233,0.18), transparent 40%),
              linear-gradient(180deg, #020617, #020617);
      color: #e5e7eb;
      overflow: hidden;
    }

    /* ===== 星空 Canvas ===== */
    #star-canvas {
      position: fixed;
      inset: 0;
      z-index: 0;
    }

    /* ===== 鼠标光晕 ===== */
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
      transition: opacity 0.2s ease;
    }

    /* ===== 网格 ===== */
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

    /* ===== 内容区 ===== */
    .main-wrapper {
      position: relative;
      z-index: 3;
    }

    /* ===== 卡片 ===== */
    .portal-card {
      background: rgba(15,23,42,0.75);
      backdrop-filter: blur(18px);
      border-radius: 24px;
      box-shadow: 0 30px 80px rgba(0,0,0,0.6);
      padding: 48px;
      max-width: 460px;
      width: 100%;
    }

    .portal-title {
      font-size: 1.9rem;
      font-weight: 600;
    }
    .portal-subtitle {
      color: #94a3b8;
      font-size: 0.95rem;
      margin-top: 6px;
    }

    .form-control {
      background: rgba(2,6,23,0.65);
      border: 1px solid rgba(148,163,184,0.25);
      color: #e5e7eb;
      border-radius: 14px;
      padding: 14px;
    }

    .form-control::placeholder {
      color: #94a3b8;
    }

    .form-control:focus {
      color: #e5e7eb;
      border-color: #6366f1;
      box-shadow: none;
      background: rgba(2,6,23,0.85);
    }

    .btn-primary {
      border-radius: 14px;
      background: linear-gradient(135deg, #6366f1, #3b82f6);
      border: none;
      padding: 14px;
    }

    a { color: #a5b4fc; }


    .text-muted, .small {
      color: #94a3b8 !important;
    }
  </style>
</head>

<body>

<canvas id="star-canvas"></canvas>
<div id="cursor-glow"></div>
<div class="background-grid"></div>

<div class="container h-100 d-flex align-items-center justify-content-center main-wrapper">
  <div class="portal-card">

    <div class="mb-4">
      <div class="portal-title"><%= emoji %> <%= title %></div>
      <div class="portal-subtitle"><%= subtitle %></div>
    </div>

    <% if (error != null) { %>
    <div class="alert alert-danger py-2 small"><%= error %></div>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/login">
      <input type="hidden" name="role" value="<%= role %>">

      <div class="mb-3">
        <input class="form-control" name="username" required
               placeholder="<%= "admin".equals(role) ? "账号" : ("teacher".equals(role) ? "工号" : "学号") %>">
      </div>

      <div class="mb-4">
        <input type="password" class="form-control" name="password" required minlength="4" placeholder="密码">
      </div>

      <button class="btn btn-primary w-100">进入系统</button>
    </form>

    <div class="d-flex justify-content-between mt-4 small">
      <% if (!"admin".equals(role)) { %>
      <a href="register_<%= role %>.jsp">创建新账号</a>
      <% } else { %>
      <span class="text-muted">管理员入口</span>
      <% } %>

      <div class="dropdown">
        <a class="dropdown-toggle" data-bs-toggle="dropdown">切换身份</a>
        <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end">
          <li><a class="dropdown-item" href="index.jsp?role=student">🎓 学生</a></li>
          <li><a class="dropdown-item" href="index.jsp?role=teacher">📘 教师</a></li>
          <li><a class="dropdown-item" href="index.jsp?role=admin">🛠️ 管理员</a></li>
        </ul>
      </div>
    </div>

  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
  /* ===== 星空背景 ===== */
  const canvas = document.getElementById('star-canvas');
  const ctx = canvas.getContext('2d');
  let stars = [];

  function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  resize();
  window.addEventListener('resize', resize);

  function createStars(count = 120) {
    stars = [];
    for (let i = 0; i < count; i++) {
      stars.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * 1.2 + 0.3,
        s: Math.random() * 0.4 + 0.1
      });
    }
  }
  createStars();

  function animateStars() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = 'rgba(255,255,255,0.8)';
    stars.forEach(star => {
      star.y += star.s;
      if (star.y > canvas.height) star.y = 0;
      ctx.beginPath();
      ctx.arc(star.x, star.y, star.r, 0, Math.PI * 2);
      ctx.fill();
    });
    requestAnimationFrame(animateStars);
  }
  animateStars();

  /* ===== 鼠标跟随光晕 ===== */
  const glow = document.getElementById('cursor-glow');
  document.addEventListener('mousemove', e => {
    glow.style.left = e.clientX + 'px';
    glow.style.top = e.clientY + 'px';
  });

  /* 移动设备不显示光晕 */
  if ('ontouchstart' in window) {
    document.getElementById('cursor-glow').style.display = 'none';
  }

</script>

</body>
</html>