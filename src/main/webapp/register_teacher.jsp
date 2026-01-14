<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>教师注册说明 · 学生成绩管理系统</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        /* 与学生页完全一致，保持统一风格 */
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
            overflow: hidden;
        }

        #star-canvas { position: fixed; inset: 0; z-index: 0; }
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

        .main-wrapper { position: relative; z-index: 2; }

        .portal-card {
            background: rgba(15,23,42,0.75);
            backdrop-filter: blur(18px);
            border-radius: 24px;
            box-shadow: 0 30px 80px rgba(0,0,0,0.6);
            padding: 48px;
            max-width: 480px;
            width: 100%;
        }

        .portal-title {
            font-size: 1.7rem;
            font-weight: 600;
        }
        .portal-subtitle {
            color: #94a3b8;
            font-size: 0.95rem;
            margin-top: 8px;
            line-height: 1.6;
        }

        .btn-primary {
            border-radius: 14px;
            background: linear-gradient(135deg, #6366f1, #3b82f6);
            border: none;
            padding: 14px;
        }
    </style>
</head>

<body>

<canvas id="star-canvas"></canvas>
<div id="cursor-glow"></div>

<div class="container h-100 d-flex align-items-center justify-content-center main-wrapper">
    <div class="portal-card text-center">

        <div class="mb-3" style="font-size: 2rem;">📘</div>

        <div class="portal-title">教师账号注册说明</div>

        <div class="portal-subtitle mt-3">
            教师账号需由<strong>系统管理员</strong>统一创建。<br>
            注册完成后，方可进行课程管理与成绩录入操作。<br><br>
            若你尚未获得账号，请联系系统管理员协助处理。
        </div>

        <div class="mt-4">
            <a class="btn btn-primary w-100" href="<%= request.getContextPath() %>/index.jsp">
                返回登录入口
            </a>
        </div>

    </div>
</div>

<script>
    /* 与学生页相同的星空与光晕逻辑 */
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
            r: Math.random() * 1.2 + 0.3,
            s: Math.random() * 0.4 + 0.1
        });
    }

    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = 'rgba(255,255,255,0.8)';
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

    const glow = document.getElementById('cursor-glow');
    document.addEventListener('mousemove', e => {
        glow.style.left = e.clientX + 'px';
        glow.style.top = e.clientY + 'px';
    });
</script>

</body>
</html>
