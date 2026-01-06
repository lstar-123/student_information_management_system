<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String role = request.getParameter("role");
    if (role == null) {
        role = "student";
    }
    String title;
    if ("admin".equals(role)) {
        title = "管理员登录";
    } else if ("teacher".equals(role)) {
        title = "教师登录";
    } else {
        title = "学生登录";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= title %> - 学生成绩管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(180deg, #3F72AF 0%, #203264 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Microsoft YaHei", sans-serif;
        }
        .card-radius {
            border-radius: 20px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.25);
        }
    </style>
</head>
<body>
<div class="container">
    <div class="card card-radius p-4 bg-white" style="max-width: 420px; margin: 0 auto;">
        <div class="text-center mb-3">
            <h3 class="fw-bold text-primary mb-1"><%= title %></h3>
            <div class="text-muted small">
                <% if ("admin".equals(role)) { %>
                账号：admin&nbsp;&nbsp;密码：1234
                <% } else if ("teacher".equals(role)) { %>
                请输入教师工号和密码
                <% } else { %>
                请输入学号和密码
                <% } %>
            </div>
        </div>
        <% String error = (String) request.getAttribute("error");
           if (error != null) { %>
            <div class="alert alert-danger py-2"><%= error %></div>
        <% } %>
        <form method="post" action="<%=request.getContextPath()%>/login">
            <input type="hidden" name="role" value="<%= role %>">
            <div class="mb-3">
                <label class="form-label">
                    <% if ("admin".equals(role)) { %>账号<% } else if ("teacher".equals(role)) { %>工号<% } else { %>学号<% } %>
                </label>
                <input type="text" name="username" class="form-control" required>
            </div>
            <div class="mb-3">
                <label class="form-label">密码</label>
                <input type="password" name="password" class="form-control" required minlength="4">
            </div>
            <div class="d-grid gap-2 mb-2">
                <button type="submit" class="btn btn-primary btn-lg">登录</button>
            </div>
            <% if (!"admin".equals(role)) { %>
            <div class="d-flex justify-content-between small">
                <a href="register_<%= role %>.jsp">注册账号</a>
                <span class="text-muted">忘记密码请联系管理员</span>
            </div>
            <% } %>
            <div class="text-center mt-3">
                <a href="index.jsp" class="small">返回身份选择</a>
            </div>
        </form>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>


