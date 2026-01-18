<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.DayOfWeek" %>
<%
    // 读取课程表 JSON 文件
    String jsonPath = application.getRealPath("/WEB-INF/classes/courses/all_weeks_courses.json");
    JsonObject allWeeksCourses = null;
    String errorMsg = null;

    try {
        File jsonFile = new File(jsonPath);
        if (jsonFile.exists()) {
            BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(jsonFile), StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            reader.close();
            allWeeksCourses = JsonParser.parseString(sb.toString()).getAsJsonObject();
        } else {
            errorMsg = "课程表数据文件不存在：" + jsonPath;
        }
    } catch (Exception e) {
        errorMsg = "读取课程表数据失败：" + e.getMessage();
    }

    // 获取当前选择的周数
    String selectedWeek = request.getParameter("week");
    int weekNum = 1;
    if (selectedWeek == null || selectedWeek.isEmpty()) {
        // 根据当前日期计算周数（假设第一周从 2025-09-15 开始）
        ZoneId chinaZone = ZoneId.of("Asia/Shanghai");
        LocalDate today = LocalDate.now(chinaZone);
        LocalDate semesterStart = LocalDate.of(2025, 9, 15);
        long daysSinceStart = ChronoUnit.DAYS.between(semesterStart, today);
        weekNum = (int) (daysSinceStart / 7) + 1;
        if (weekNum < 1) weekNum = 1;
        if (weekNum > 21) weekNum = 21;
        selectedWeek = String.format("%02d", weekNum);
    } else {
        weekNum = Integer.parseInt(selectedWeek);
    }

    // 计算本周的日期范围（周一到周日）
    LocalDate semesterStart = LocalDate.of(2025, 9, 15);
    LocalDate weekStart = semesterStart.plusWeeks(weekNum - 1).with(DayOfWeek.MONDAY);
    Map<String, LocalDate> weekDates = new LinkedHashMap<>();
    Map<String, Boolean> isTodayMap = new LinkedHashMap<>();

    ZoneId chinaZone = ZoneId.of("Asia/Shanghai");
    LocalDate today = LocalDate.now(chinaZone);

    // 星期映射
    Map<String, String> weekdayMap = new LinkedHashMap<>();
    weekdayMap.put("Monday", "周一");
    weekdayMap.put("Tuesday", "周二");
    weekdayMap.put("Wednesday", "周三");
    weekdayMap.put("Thursday", "周四");
    weekdayMap.put("Friday", "周五");
    weekdayMap.put("Saturday", "周六");
    weekdayMap.put("Sunday", "周日");

    // 计算每一天的日期
    for (String engDay : weekdayMap.keySet()) {
        DayOfWeek dayOfWeek = DayOfWeek.valueOf(engDay.toUpperCase());
        LocalDate date = weekStart.with(dayOfWeek);
        weekDates.put(engDay, date);
        isTodayMap.put(engDay, date.equals(today));
    }

    // 日期格式化器
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MM/dd");
    DateTimeFormatter fullDateFormatter = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
    
    // 节次
    String[] sections = {
        "第一大节 (01,02小节) 08:20-09:55",
        "第二大节 (03,04小节) 10:15-11:50",
        "第三大节 (05,06小节) 14:00-15:35",
        "第四大节 (07,08小节) 15:55-17:30",
        "第五大节 (09,10小节) 19:00-20:40",
        "第六大节 (11,12小节) 20:45-22:20"
    };
    
    String[] sectionShort = {"第一大节", "第二大节", "第三大节", "第四大节", "第五大节", "第六大节"};
    String[] sectionTime = {"08:20-09:55", "10:15-11:50", "14:00-15:35", "15:55-17:30", "19:00-20:40", "20:45-22:20"};
%>

<style>
    /* ===== 课程表样式 ===== */
    .schedule-container {
        padding: 0;
    }
    
    .week-selector {
        display: flex;
        align-items: center;
        gap: 15px;
        margin-bottom: 20px;
        flex-wrap: wrap;
    }
    
    .week-selector label {
        font-size: 16px;
        color: #c7d2fe;
    }
    
    .week-selector select {
        padding: 10px 20px;
        border-radius: 12px;
        border: 1px solid rgba(148,163,184,.3);
        background: rgba(15,23,42,.8);
        color: #e5e7eb;
        font-size: 15px;
        cursor: pointer;
        transition: all 0.3s;
    }
    
    .week-selector select:hover,
    .week-selector select:focus {
        border-color: #6366f1;
        outline: none;
        box-shadow: 0 0 0 3px rgba(99,102,241,.2);
    }
    
    .week-nav-btns {
        display: flex;
        gap: 8px;
    }
    
    .week-nav-btn {
        padding: 8px 16px;
        border-radius: 10px;
        border: 1px solid rgba(148,163,184,.25);
        background: rgba(15,23,42,.6);
        color: #c7d2fe;
        cursor: pointer;
        transition: all 0.3s;
        font-size: 14px;
    }
    
    .week-nav-btn:hover {
        background: rgba(99,102,241,.2);
        border-color: rgba(99,102,241,.4);
    }
    
    .week-nav-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
    
    /* 课程表格 */
    .schedule-table-wrapper {
        overflow-x: auto;
        border-radius: 16px;
        background: rgba(15,23,42,.5);
        border: 1px solid rgba(148,163,184,.15);
    }
    
    .schedule-table {
        width: 100%;
        min-width: 900px;
        border-collapse: collapse;
    }
    
    .schedule-table th,
    .schedule-table td {
        padding: 12px 8px;
        text-align: center;
        border: 1px solid rgba(148,163,184,.12);
        vertical-align: top;
    }
    
    .schedule-table thead th {
        background: rgba(99,102,241,.15);
        color: #e5e7eb;
        font-weight: 600;
        font-size: 14px;
        position: sticky;
        top: 0;
    }
    
    .schedule-table thead th.time-col {
        width: 100px;
        background: rgba(30,41,59,.8);
    }

    /* 今日课程表头样式：科技感/未来感 */
    .schedule-table thead th.today-header {
        position: relative;
        background:
            radial-gradient(120px 60px at 50% 10%, rgba(56, 189, 248, 0.35), transparent 70%),
            linear-gradient(135deg, rgba(15, 23, 42, 0.9), rgba(30, 64, 175, 0.65));
        border: 1px solid rgba(56, 189, 248, 0.6);
        box-shadow:
            0 0 0 1px rgba(56, 189, 248, 0.35) inset,
            0 8px 22px rgba(56, 189, 248, 0.28);
        overflow: hidden;
        animation: todayNeonPulse 2.2s ease-in-out infinite;
    }

    .schedule-table thead th.today-header::before {
        content: "";
        position: absolute;
        inset: -2px;
        background: conic-gradient(from 0deg, rgba(56, 189, 248, 0.0), rgba(56, 189, 248, 0.6), rgba(56, 189, 248, 0.0));
        animation: todaySweep 3.6s linear infinite;
        opacity: 0.6;
        pointer-events: none;
    }

    .schedule-table thead th.today-header::after {
        content: "";
        position: absolute;
        left: -120%;
        top: 0;
        width: 120%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(56, 189, 248, 0.18), transparent);
        animation: todayScan 2.8s ease-in-out infinite;
        pointer-events: none;
    }

    @keyframes todayNeonPulse {
        0% {
            box-shadow:
                0 0 0 1px rgba(56, 189, 248, 0.35) inset,
                0 8px 18px rgba(56, 189, 248, 0.22);
        }
        100% {
            box-shadow:
                0 0 0 1px rgba(56, 189, 248, 0.6) inset,
                0 10px 26px rgba(56, 189, 248, 0.45);
        }
    }

    @keyframes todaySweep {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    @keyframes todayScan {
        0% { left: -120%; }
        100% { left: 120%; }
    }

    .schedule-table thead th.today-header .day-name,
    .schedule-table thead th.today-header .day-date {
        color: #e0f2fe;
        text-shadow: 0 0 10px rgba(56, 189, 248, 0.5);
        position: relative;
        z-index: 1;
    }
    
    .schedule-table tbody td.time-cell {
        background: rgba(30,41,59,.5);
        font-size: 12px;
        color: #94a3b8;
        white-space: nowrap;
    }
    
    .schedule-table tbody td.time-cell .section-name {
        font-weight: 600;
        color: #c7d2fe;
        display: block;
        margin-bottom: 4px;
    }
    
    /* 课程卡片 */
    .course-cell {
        min-height: 80px;
    }
    
    .course-card {
        background: linear-gradient(135deg, rgba(99,102,241,.2), rgba(59,130,246,.15));
        border-radius: 10px;
        padding: 10px;
        margin: 4px;
        border-left: 3px solid #6366f1;
        text-align: left;
        transition: all 0.3s;
    }
    
    .course-card:hover {
        transform: scale(1.02);
        box-shadow: 0 4px 15px rgba(99,102,241,.3);
    }
    
    .course-card .course-name {
        font-weight: 600;
        color: #e5e7eb;
        font-size: 13px;
        margin-bottom: 6px;
        line-height: 1.3;
    }
    
    .course-card .course-classroom {
        font-size: 11px;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    
    .course-card .course-classroom::before {
        content: "📍";
        font-size: 10px;
    }
    
    /* 空单元格 */
    .empty-cell {
        color: rgba(148,163,184,.3);
        font-size: 12px;
    }
    
    /* 课程颜色变体 */
    .course-card.color-1 { border-left-color: #6366f1; background: linear-gradient(135deg, rgba(99,102,241,.2), rgba(99,102,241,.1)); }
    .course-card.color-2 { border-left-color: #3b82f6; background: linear-gradient(135deg, rgba(59,130,246,.2), rgba(59,130,246,.1)); }
    .course-card.color-3 { border-left-color: #14b8a6; background: linear-gradient(135deg, rgba(20,184,166,.2), rgba(20,184,166,.1)); }
    .course-card.color-4 { border-left-color: #f59e0b; background: linear-gradient(135deg, rgba(245,158,11,.2), rgba(245,158,11,.1)); }
    .course-card.color-5 { border-left-color: #ef4444; background: linear-gradient(135deg, rgba(239,68,68,.2), rgba(239,68,68,.1)); }
    .course-card.color-6 { border-left-color: #8b5cf6; background: linear-gradient(135deg, rgba(139,92,246,.2), rgba(139,92,246,.1)); }
    .course-card.color-7 { border-left-color: #ec4899; background: linear-gradient(135deg, rgba(236,72,153,.2), rgba(236,72,153,.1)); }
    .course-card.color-8 { border-left-color: #10b981; background: linear-gradient(135deg, rgba(16,185,129,.2), rgba(16,185,129,.1)); }
    
    /* 无课程提示 */
    .no-course-msg {
        text-align: center;
        padding: 60px 20px;
        color: #94a3b8;
    }
    
    .no-course-msg .icon {
        font-size: 48px;
        margin-bottom: 15px;
    }
    
    /* 当前周提示 */
    .current-week-badge {
        background: linear-gradient(135deg, #6366f1, #3b82f6);
        color: white;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        margin-left: 10px;
    }
</style>

<div class="schedule-container">
    <% if (errorMsg != null) { %>
        <div class="card">
            <div class="card-body">
                <div class="alert alert-danger mb-0">
                    <%= errorMsg %>
                </div>
            </div>
        </div>
    <% } else { %>
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                <span>📅 课程表</span>
                <div class="week-selector">
                    <div class="week-nav-btns">
                        <button class="week-nav-btn" onclick="changeWeek(-1)" id="prevWeekBtn">◀ 上一周</button>
                    </div>
                    <select id="weekSelect" onchange="goToWeek(this.value)">
                        <% for (int i = 1; i <= 21; i++) {
                            String weekKey = String.format("%02d", i);
                            boolean isSelected = weekKey.equals(selectedWeek);
                        %>
                        <option value="<%= weekKey %>" <%= isSelected ? "selected" : "" %>>
                            第 <%= i %> 周
                        </option>
                        <% } %>
                    </select>
                    <div class="week-nav-btns">
                        <button class="week-nav-btn" onclick="changeWeek(1)" id="nextWeekBtn">下一周 ▶</button>
                    </div>
                </div>
            </div>
            
            <div class="card-body p-2">
                <%
                    JsonArray weekCourses = null;
                    if (allWeeksCourses != null && allWeeksCourses.has(selectedWeek)) {
                        weekCourses = allWeeksCourses.getAsJsonArray(selectedWeek);
                    }
                    
                    if (weekCourses == null || weekCourses.size() == 0) {
                %>
                    <div class="no-course-msg">
                        <div class="icon">🎉</div>
                        <h5>本周没有课程安排</h5>
                        <p class="mb-0">好好休息，或者利用这段时间自主学习吧！</p>
                    </div>
                <% } else {
                    // 构建课程表数据结构：Map<星期, Map<节次, List<课程>>>
                    Map<String, Map<String, List<JsonObject>>> scheduleMap = new LinkedHashMap<>();
                    for (String day : weekdayMap.keySet()) {
                        scheduleMap.put(day, new LinkedHashMap<>());
                        for (String sec : sections) {
                            scheduleMap.get(day).put(sec, new ArrayList<>());
                        }
                    }
                    
                    // 课程名称到颜色的映射
                    Map<String, Integer> courseColorMap = new HashMap<>();
                    int colorIndex = 1;
                    
                    // 填充数据
                    for (JsonElement elem : weekCourses) {
                        JsonObject course = elem.getAsJsonObject();
                        String weekday = course.get("weekday").getAsString();
                        String section = course.get("section").getAsString();
                        String courseName = course.get("name").getAsString();
                        
                        // 为课程分配颜色
                        if (!courseColorMap.containsKey(courseName)) {
                            courseColorMap.put(courseName, (colorIndex % 8) + 1);
                            colorIndex++;
                        }
                        
                        if (scheduleMap.containsKey(weekday)) {
                            Map<String, List<JsonObject>> dayCourses = scheduleMap.get(weekday);
                            if (dayCourses.containsKey(section)) {
                                dayCourses.get(section).add(course);
                            }
                        }
                    }
                %>
                    <div class="schedule-table-wrapper">
                        <table class="schedule-table">
                            <thead>
                                <tr>
                                    <th class="time-col">时间</th>
                                    <% for (String day : weekdayMap.keySet()) {
                                        LocalDate date = weekDates.get(day);
                                        boolean isToday = isTodayMap.get(day);
                                    %>
                                        <th class="<%= isToday ? "today-header" : "" %>">
                                            <div class="day-name"><%= weekdayMap.get(day) %></div>
                                            <div class="day-date"><%= date.format(dateFormatter) %></div>
                                        </th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int s = 0; s < sections.length; s++) {
                                    String sec = sections[s];
                                %>
                                <tr>
                                    <td class="time-cell">
                                        <span class="section-name"><%= sectionShort[s] %></span>
                                        <%= sectionTime[s] %>
                                    </td>
                                    <% for (String day : weekdayMap.keySet()) {
                                        List<JsonObject> courses = scheduleMap.get(day).get(sec);
                                    %>
                                    <td class="course-cell">
                                        <% if (courses.isEmpty()) { %>
                                            <span class="empty-cell">-</span>
                                        <% } else {
                                            for (JsonObject course : courses) {
                                                String name = course.get("name").getAsString();
                                                String classroom = course.get("classroom").getAsString();
                                                int colorNum = courseColorMap.get(name);
                                        %>
                                            <div class="course-card color-<%= colorNum %>">
                                                <div class="course-name"><%= name %></div>
                                                <div class="course-classroom"><%= classroom %></div>
                                            </div>
                                        <% }
                                        } %>
                                    </td>
                                    <% } %>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>
    <% } %>
</div>

<script>
    function goToWeek(week) {
        window.location.href = '?tab=schedule&week=' + week;
    }
    
    function changeWeek(delta) {
        const select = document.getElementById('weekSelect');
        const currentIndex = select.selectedIndex;
        const newIndex = currentIndex + delta;
        
        if (newIndex >= 0 && newIndex < select.options.length) {
            select.selectedIndex = newIndex;
            goToWeek(select.value);
        }
    }
    
    // 更新导航按钮状态
    (function() {
        const select = document.getElementById('weekSelect');
        if (!select) return;
        
        const prevBtn = document.getElementById('prevWeekBtn');
        const nextBtn = document.getElementById('nextWeekBtn');
        
        if (select.selectedIndex === 0) {
            prevBtn.disabled = true;
        }
        if (select.selectedIndex === select.options.length - 1) {
            nextBtn.disabled = true;
        }
    })();
</script>
