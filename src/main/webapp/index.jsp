<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>学生成绩管理系统 - 身份选择</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/vue@3.4.21/dist/vue.global.prod.js"></script>
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
        .identity-card {
            border-radius: 16px;
            border: 1px solid #e0e0e0;
            transition: all .2s ease;
            cursor: pointer;
        }
        .identity-card:hover {
            background-color: #e6f0ff;
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.12);
        }
        .identity-card.active {
            background-color: #cfe0ff;
            border-color: #3F72AF;
        }
    </style>
</head>
<body>
<div id="app" class="container">
    <div class="card card-radius p-4 bg-white" style="max-width: 420px; margin: 0 auto;">
        <div class="text-center mb-3">
            <h3 class="fw-bold text-primary mb-1">学生成绩管理系统</h3>
            <div class="text-muted small">请选择身份后点击“进入登录”</div>
        </div>
        <div class="v-stack gap-2 mb-3">
            <div class="identity-card p-3 d-flex align-items-center"
                 :class="{active: role === 'student'}"
                 @click="role = 'student'">
                <div class="flex-grow-1">
                    <div class="fw-semibold">学生</div>
                    <div class="text-muted small">查看个人期中 / 期末成绩</div>
                </div>
            </div>
            <div class="identity-card p-3 d-flex align-items-center"
                 :class="{active: role === 'teacher'}"
                 @click="role = 'teacher'">
                <div class="flex-grow-1">
                    <div class="fw-semibold">教师</div>
                    <div class="text-muted small">维护学生信息、课程与成绩</div>
                </div>
            </div>
            <div class="identity-card p-3 d-flex align-items-center"
                 :class="{active: role === 'admin'}"
                 @click="role = 'admin'">
                <div class="flex-grow-1">
                    <div class="fw-semibold">管理员</div>
                    <div class="text-muted small">管理教师与学生账号</div>
                </div>
            </div>
        </div>
        <form method="get" action="login.jsp" class="d-grid gap-2">
            <input type="hidden" name="role" :value="role">
            <button type="submit" class="btn btn-primary btn-lg" :disabled="!role">
                进入登录
            </button>
        </form>
    </div>
</div>
<script>
    const {createApp} = Vue;
    createApp({
        data() {
            return {
                role: 'student'
            };
        }
    }).mount('#app');
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
