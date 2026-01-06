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
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>我的成绩 - 学生成绩管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-primary mb-3">
    <div class="container-fluid">
        <span class="navbar-brand">学生端 - 成绩查询</span>
        <div class="navbar-text text-white">
            学号：<%=stu.getStuNumber()%>　姓名：<%=stu.getStuName()%>　班级：<%=stu.getStuClass()%>
        </div>
    </div>
</nav>
<div class="container">
    <div class="row g-3">
        <div class="col-12">
            <div class="card">
                <div class="card-header bg-white">
                    <ul class="nav nav-tabs card-header-tabs" id="scoreTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="mid-tab" data-bs-toggle="tab"
                                    data-bs-target="#mid" type="button" role="tab">
                                期中成绩
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="final-tab" data-bs-toggle="tab"
                                    data-bs-target="#final" type="button" role="tab">
                                期末成绩
                            </button>
                        </li>
                    </ul>
                </div>
                <div class="card-body tab-content">
                    <div class="tab-pane fade show active" id="mid" role="tabpanel">
                        <jsp:include page="scores_mid.jsp"/>
                    </div>
                    <div class="tab-pane fade" id="final" role="tabpanel">
                        <jsp:include page="scores_final.jsp"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>


