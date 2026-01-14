<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.lingxing.bean.Student" %>
<%@ page import="com.lingxing.util.DBUtil" %>
<%@ page import="java.util.*" %>
<%
    Student stuObj = (Student) session.getAttribute("currentUser");
    if (stuObj == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=student");
        return;
    }
    int stuId = stuObj.getStuId();

    // 课程Emoji映射（根据课程名称）
    Map<String, String> courseEmojiMap = new HashMap<>();
    courseEmojiMap.put("数据结构", "📚");
    courseEmojiMap.put("算法", "🧮");
    courseEmojiMap.put("数据库", "💾");
    courseEmojiMap.put("操作系统", "⚙️");
    courseEmojiMap.put("计算机网络", "🌐");
    courseEmojiMap.put("软件工程", "🔧");
    courseEmojiMap.put("编译原理", "⚡");
    courseEmojiMap.put("计算机组成原理", "🖥️");
    courseEmojiMap.put("数学", "📐");
    courseEmojiMap.put("英语", "🌍");

    // 默认Emoji
    String defaultEmoji = "📖";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    List<Map<String, Object>> courses = new ArrayList<>();

    try {
        conn = DBUtil.getConnection();

        // 查询所有课程
        Statement courseStmt = conn.createStatement();
        ResultSet courseRs = courseStmt.executeQuery("SELECT course_id, course_name FROM tb_course ORDER BY course_id");

        while (courseRs.next()) {
            int courseId = courseRs.getInt("course_id");
            String courseName = courseRs.getString("course_name");

            // 查询该课程的期中、期末成绩
            String scoreSql = "SELECT exam_type, score FROM tb_score WHERE stu_id = ? AND course_id = ?";
            ps = conn.prepareStatement(scoreSql);
            ps.setInt(1, stuId);
            ps.setInt(2, courseId);
            rs = ps.executeQuery();

            Double midScore = null;
            Double finalScore = null;

            while (rs.next()) {
                String examType = rs.getString("exam_type");
                Double score = rs.getDouble("score");
                if ("期中".equals(examType)) {
                    midScore = score;
                } else if ("期末".equals(examType)) {
                    finalScore = score;
                }
            }
            rs.close();
            ps.close();

            // 生成评价（内联实现）
            String comment;
            if (midScore == null && finalScore == null) {
                comment = "你在这门课中开始了新的探索。";
            } else {
                Double avgScore = null;
                if (midScore != null && finalScore != null) {
                    avgScore = (midScore + finalScore) / 2;
                } else if (midScore != null) {
                    avgScore = midScore;
                } else if (finalScore != null) {
                    avgScore = finalScore;
                }

                if (avgScore == null) {
                    comment = "你在这门课中开始了新的探索。";
                } else if (avgScore >= 90) {
                    comment = "你在这门课中建立了坚实的基础，展现了出色的理解力。";
                } else if (avgScore >= 80) {
                    comment = "这门课显示出你在抽象思维上的成长，你的努力在这里变得可见。";
                } else if (avgScore >= 70) {
                    comment = "这是你学习轨迹的一部分，每一步都值得记录。";
                } else if (avgScore >= 60) {
                    comment = "你在这门课中遇到了挑战，但坚持本身就是一种成长。";
                } else {
                    comment = "学习路上总有起伏，重要的是你从未停下脚步。";
                }
            }

            Map<String, Object> course = new HashMap<>();
            course.put("courseId", courseId);
            course.put("courseName", courseName);
            course.put("emoji", courseEmojiMap.getOrDefault(courseName, defaultEmoji));
            course.put("midScore", midScore);
            course.put("finalScore", finalScore);
            course.put("comment", comment);

            courses.add(course);
        }
        courseRs.close();
        courseStmt.close();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }

    // 构建JSON数据（手动构建，避免添加新依赖）
    StringBuilder jsonBuilder = new StringBuilder();
    jsonBuilder.append("{");
    jsonBuilder.append("\"student\":{");
    jsonBuilder.append("\"id\":").append(stuObj.getStuId()).append(",");
    String stuName = stuObj.getStuName() != null ? stuObj.getStuName().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t") : "";
    jsonBuilder.append("\"name\":\"").append(stuName).append("\",");
    String stuNumber = stuObj.getStuNumber() != null ? stuObj.getStuNumber().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t") : "";
    jsonBuilder.append("\"number\":\"").append(stuNumber).append("\",");
    String stuClass = stuObj.getStuClass() != null ? stuObj.getStuClass().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t") : "";
    jsonBuilder.append("\"class\":\"").append(stuClass).append("\"");
    jsonBuilder.append("},");
    jsonBuilder.append("\"courses\":[");

    for (int i = 0; i < courses.size(); i++) {
        Map<String, Object> course = courses.get(i);
        jsonBuilder.append("{");
        jsonBuilder.append("\"courseId\":").append(course.get("courseId")).append(",");
        String courseName = (String)course.get("courseName");
        if (courseName != null) {
            courseName = courseName.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
        }
        jsonBuilder.append("\"courseName\":\"").append(courseName != null ? courseName : "").append("\",");
        String emoji = (String)course.get("emoji");
        if (emoji != null) {
            emoji = emoji.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
        }
        jsonBuilder.append("\"emoji\":\"").append(emoji != null ? emoji : "").append("\",");
        jsonBuilder.append("\"midScore\":").append(course.get("midScore") != null ? course.get("midScore") : "null").append(",");
        jsonBuilder.append("\"finalScore\":").append(course.get("finalScore") != null ? course.get("finalScore") : "null").append(",");
        String comment = (String)course.get("comment");
        if (comment != null) {
            comment = comment.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
        }
        jsonBuilder.append("\"comment\":\"").append(comment != null ? comment : "").append("\"");
        jsonBuilder.append("}");
        if (i < courses.size() - 1) {
            jsonBuilder.append(",");
        }
    }

    jsonBuilder.append("]");
    jsonBuilder.append("}");

    String jsonData = jsonBuilder.toString();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>你的本学期学习回顾</title>

    <!-- 保留原有 Tailwind + React + Babel 引入（业务端依赖） -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script crossorigin src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>

    <!-- 统一视觉样式（仅影响外观，不触及业务逻辑） -->
    <style>
        /* 主体背景（与 index/admin/student 统一） */
        html, body {
            height: 100%;
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Microsoft YaHei", sans-serif;
            color: #e5e7eb;
        }
        body {
            background:
                    radial-gradient(circle at 20% 20%, rgba(99,102,241,0.18), transparent 40%),
                    radial-gradient(circle at 80% 80%, rgba(14,165,233,0.12), transparent 40%),
                    linear-gradient(180deg, #020617, #020617);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* 星空 Canvas、光晕、网格（同 index） */
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
            transition: opacity .2s ease;
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

        /* 内容层 */
        .main-wrapper {
            position: relative;
            z-index: 3;
            padding: 2.5rem 1rem;
        }

        /* 保留并微调原始视觉样式（不改逻辑）*/
        .card-hover {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .card-hover:hover {
            transform: translateY(-6px) scale(1.02);
        }
        .modal-backdrop {
            backdrop-filter: blur(4px);
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: scale(0.9) translateY(20px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }
        .modal-content {
            animation: fadeIn 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* React 卡片与模态默认色调整（更贴合系统配色） */
        .bg-slate-800\/50 { background-color: rgba(30,41,59,0.45); }
        .bg-slate-900\/50 { background-color: rgba(15,23,42,0.5); }
        .text-slate-100 { color: #e6edf3; }
        .text-slate-200 { color: #cfd8e3; }
        .text-slate-300 { color: #9fb0c8; }
        .text-slate-400 { color: #94a3b8; }
        .text-slate-500 { color: #6b7280; }
        .text-slate-600 { color: #4b5563; }

        /* 网格、卡片间距微调 */
        .grid-gap-6 { gap: 1.5rem; }
    </style>
</head>
<body>
<!-- 统一的视觉背景层（只影响外观） -->
<canvas id="star-canvas"></canvas>
<div id="cursor-glow"></div>
<div class="background-grid"></div>

<div class="main-wrapper">
    <div id="root"></div>

    <!-- 输出JSON数据（业务代码生成） -->
    <script type="application/json" id="score-data">
            <%= jsonData %>
        </script>

    <!-- 保留原有调试 console 代码（不变） -->
    <script>
        (function() {
            const dataEl = document.getElementById('score-data');
            if (dataEl) {
                console.log('JSON数据长度:', dataEl.textContent.length);
                const preview = dataEl.textContent.length > 100
                    ? dataEl.textContent.substring(0, 100) + "..."
                    : dataEl.textContent;
                console.log('JSON数据预览:', preview);
            }
        })();
    </script>

    <!-- 原有 React 应用 -->
    <script type="text/babel">


        const { useState, useEffect } = React;
        const baseUrl = '<%=request.getContextPath()%>';

        // 从JSP获取数据
        let initialData;
        try {
            const dataElement = document.getElementById('score-data');
            if (!dataElement) {
                console.error('找不到数据元素');
                initialData = { student: {}, courses: [] };
            } else {
                initialData = JSON.parse(dataElement.textContent);
                console.log('加载的数据:', initialData);
            }
        } catch (e) {
            console.error('解析JSON数据失败:', e);
            initialData = { student: {}, courses: [] };
        }

        // 确保courses数组存在
        if (!initialData.courses) {
            console.warn('courses数组不存在，初始化为空数组');
            initialData.courses = [];
        }

        console.log('课程数量:', initialData.courses.length);
        if (initialData.courses.length === 0) {
            console.warn('没有课程数据，请检查数据库查询');
        }

        // 课程卡片组件
        function CourseScoreCard({ course, onCardClick, index }) {
            const [isHovered, setIsHovered] = useState(false);
            const [isVisible, setIsVisible] = useState(true); // 默认可见，避免初始隐藏

            useEffect(() => {
                // 延迟显示动画（从隐藏到显示）
                setIsVisible(false);
                const timer = setTimeout(() => {
                    setIsVisible(true);
                }, index * 100);
                return () => clearTimeout(timer);
            }, [index]);

            // 如果课程数据无效，不渲染
            if (!course || !course.courseName) {
                console.warn('CourseScoreCard: 无效的课程数据', course);
                return null;
            }

            return (
                <div
                    className="bg-slate-800/50 backdrop-blur-sm rounded-2xl p-6 cursor-pointer border border-slate-700/50 card-hover"
                    style={{
                        opacity: isVisible ? 1 : 0,
                        transform: isVisible ? 'translateY(0)' : 'translateY(20px)',
                        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                        boxShadow: isHovered
                            ? '0 20px 25px -5px rgba(0, 0, 0, 0.3), 0 10px 10px -5px rgba(0, 0, 0, 0.2)'
                            : '0 4px 6px -1px rgba(0, 0, 0, 0.2)'
                    }}
                    onMouseEnter={() => setIsHovered(true)}
                    onMouseLeave={() => setIsHovered(false)}
                    onClick={() => onCardClick(course)}
                >
                    <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-3">
                            <span className="text-4xl">{course.emoji}</span>
                            <h3 className="text-xl font-semibold text-slate-100">
                                {course.courseName}
                            </h3>
                        </div>
                    </div>

                    <div className="space-y-3">
                        {course.midScore !== null && course.midScore !== undefined && (
                            <div className="flex justify-between items-center">
                                <span className="text-slate-400 text-sm">期中</span>
                                <span className="text-slate-200 font-medium">{Number(course.midScore).toFixed(1)}</span>
                            </div>
                        )}
                        {course.finalScore !== null && course.finalScore !== undefined && (
                            <div className="flex justify-between items-center">
                                <span className="text-slate-400 text-sm">期末</span>
                                <span className="text-slate-200 font-medium">{Number(course.finalScore).toFixed(1)}</span>
                            </div>
                        )}
                        {(course.midScore === null || course.midScore === undefined) &&
                            (course.finalScore === null || course.finalScore === undefined) && (
                                <div className="text-slate-500 text-sm">暂无成绩</div>
                            )}
                    </div>

                    <p className="mt-4 text-slate-400 text-sm leading-relaxed">
                        {course.comment}
                    </p>
                </div>
            );
        }

        // 聚焦模态框组件
        function FocusModal({ course, isOpen, onClose }) {
            const [isVisible, setIsVisible] = useState(false);

            useEffect(() => {
                if (isOpen) {
                    setIsVisible(true);
                    document.body.style.overflow = 'hidden';
                } else {
                    setIsVisible(false);
                    document.body.style.overflow = '';
                }
                return () => {
                    document.body.style.overflow = '';
                };
            }, [isOpen]);

            if (!isOpen || !course) return null;

            const mid = course.midScore !== null && course.midScore !== undefined ? Number(course.midScore) : null;
            const final = course.finalScore !== null && course.finalScore !== undefined ? Number(course.finalScore) : null;
            const avgScore = mid !== null && final !== null
                ? ((mid + final) / 2).toFixed(1)
                : mid !== null
                    ? mid.toFixed(1)
                    : final !== null
                        ? final.toFixed(1)
                        : null;

            return (
                <div
                    className="fixed inset-0 z-50 flex items-center justify-center p-4"
                    style={{
                        opacity: isVisible ? 1 : 0,
                        transition: 'opacity 0.3s ease'
                    }}
                    onClick={onClose}
                >
                    {/* 背景遮罩 */}
                    <div
                        className="absolute inset-0 bg-black/70 modal-backdrop"
                        style={{
                            opacity: isVisible ? 1 : 0,
                            transition: 'opacity 0.3s ease'
                        }}
                    />

                    {/* 卡片内容 */}
                    <div
                        className="relative bg-slate-800 rounded-3xl p-8 max-w-2xl w-full border border-slate-700/50 modal-content"
                        style={{
                            boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)'
                        }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <button
                            onClick={onClose}
                            className="absolute top-4 right-4 text-slate-400 hover:text-slate-200 text-2xl w-8 h-8 flex items-center justify-center transition-colors"
                        >
                            ×
                        </button>

                        <div className="flex items-center gap-4 mb-6">
                            <span className="text-5xl">{course.emoji}</span>
                            <h2 className="text-3xl font-semibold text-slate-100">
                                {course.courseName}
                            </h2>
                        </div>

                        <div className="space-y-4 mb-6">
                            {course.midScore !== null && course.midScore !== undefined && (
                                <div className="flex justify-between items-center py-3 border-b border-slate-700/50">
                                    <span className="text-slate-400">期中成绩</span>
                                    <span className="text-slate-100 text-xl font-medium">{Number(course.midScore).toFixed(1)}</span>
                                </div>
                            )}
                            {course.finalScore !== null && course.finalScore !== undefined && (
                                <div className="flex justify-between items-center py-3 border-b border-slate-700/50">
                                    <span className="text-slate-400">期末成绩</span>
                                    <span className="text-slate-100 text-xl font-medium">{Number(course.finalScore).toFixed(1)}</span>
                                </div>
                            )}
                            {avgScore !== null && (
                                <div className="flex justify-between items-center py-3 border-b border-slate-700/50">
                                    <span className="text-slate-300 font-medium">平均成绩</span>
                                    <span className="text-slate-100 text-2xl font-semibold">{avgScore}</span>
                                </div>
                            )}
                        </div>

                        <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-700/30">
                            <p className="text-slate-300 leading-relaxed">
                                {course.comment}
                            </p>
                        </div>

                        <div className="mt-6 pt-6 border-t border-slate-700/50">
                            <p className="text-slate-500 text-sm">
                                这是你学习轨迹的一部分，每一步都值得记录。
                            </p>
                        </div>
                    </div>
                </div>
            );
        }

        // 主组件
        function SemesterOverview() {
            const [selectedCourse, setSelectedCourse] = useState(null);
            const [isModalOpen, setIsModalOpen] = useState(false);

            const handleCardClick = (course) => {
                setSelectedCourse(course);
                setIsModalOpen(true);
            };

            const handleCloseModal = () => {
                setIsModalOpen(false);
                setTimeout(() => setSelectedCourse(null), 300);
            };

            return (
                <div className="min-h-screen py-12 px-4 sm:px-6 lg:px-8">
                    <div className="max-w-7xl mx-auto">
                        {/* 标题区域 + 返回 */}
                        <div
                            className="mb-10 flex flex-col md:flex-row md:items-center md:justify-between gap-4"
                            style={{ animation: 'fadeIn 0.6s ease' }}
                        >
                            <div className="text-left">
                                <h1 className="text-5xl font-semibold text-slate-100 mb-4">
                                    你的本学期学习回顾
                                </h1>
                                <p className="text-slate-400 text-lg">
                                    你的努力在这里变得可见
                                </p>
                            </div>
                            <button
                                type="button"
                                onClick={() => window.location.href = baseUrl + '/student/index.jsp'}
                                className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-slate-600/60 text-slate-300 text-sm hover:border-slate-300 hover:text-slate-50 hover:bg-slate-800/60 transition-colors"
                            >
                                <span>←</span>
                                <span>返回成绩主页</span>
                            </button>
                        </div>

                        {/* 卡片网格 */}
                        {initialData.courses && initialData.courses.length > 0 ? (
                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                {initialData.courses.map((course, index) => {
                                    if (!course || !course.courseName) {
                                        console.warn('无效的课程数据:', course);
                                        return null;
                                    }
                                    return (
                                        <CourseScoreCard
                                            key={course.courseId || index}
                                            course={course}
                                            onCardClick={handleCardClick}
                                            index={index}
                                        />
                                    );
                                })}
                            </div>
                        ) : (
                            <div className="text-center py-12">
                                <p className="text-slate-400 text-lg">
                                    暂无课程数据
                                </p>
                                <p className="text-slate-500 text-sm mt-2">
                                    请检查数据库连接或联系管理员
                                </p>
                                <p className="text-slate-600 text-xs mt-4">
                                    调试信息：courses数组长度 = {initialData.courses ? initialData.courses.length : 'undefined'}
                                </p>
                            </div>
                        )}

                        {/* 聚焦模态框 */}
                        <FocusModal
                            course={selectedCourse}
                            isOpen={isModalOpen}
                            onClose={handleCloseModal}
                        />
                    </div>
                </div>
            );
        }

        // 渲染应用 - 等待DOM加载完成
        function renderApp() {
            const rootElement = document.getElementById('root');
            if (!rootElement) {
                console.error('找不到root元素');
                return;
            }

            try {
                // 使用React 18的createRoot，如果不支持则使用render
                if (ReactDOM.createRoot) {
                    const root = ReactDOM.createRoot(rootElement);
                    root.render(<SemesterOverview />);
                } else if (ReactDOM.render) {
                    // 降级到React 17的render方法
                    ReactDOM.render(<SemesterOverview />, rootElement);
                } else {
                    console.error('ReactDOM不可用');
                    rootElement.innerHTML = '<div style="color: white; padding: 20px;">React加载失败</div>';
                }
            } catch (e) {
                console.error('渲染React组件失败:', e);
                rootElement.innerHTML = '<div style="color: white; padding: 20px;">加载失败: ' + e.message + '</div>';
            }
        }

        // 确保DOM加载完成后再渲染
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', renderApp);
        } else {
            renderApp();
        }
    </script>

</div> <!-- main-wrapper end -->

<!-- 视觉 JS：星空 & 光晕（安全、与业务无关） -->
<script>
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
                x: Math.random() * window.innerWidth,
                y: Math.random() * window.innerHeight,
                r: Math.random() * 1.2 + .3,
                s: Math.random() * .4 + .1
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
    })();

    (function () {
        const glow = document.getElementById('cursor-glow');
        if (!glow) return;
        document.addEventListener('mousemove', e => {
            glow.style.left = e.clientX + 'px';
            glow.style.top = e.clientY + 'px';
        });

        if ('ontouchstart' in window) {
            glow.style.display = 'none';
        }
    })();
</script>
</body>
</html>
