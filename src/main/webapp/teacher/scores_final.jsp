<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.lingxing.util.DBUtil" %>
<style>
    .table{
        --bs-table-bg:transparent;
        color:#e5e7eb;
    }
    .table thead{
        background:rgba(30,41,59,.7);
    }
    .table tbody tr{
        --bs-table-color: #e5e7eb;
        --bs-table-bg: transparent;
        color: #e5e7eb;
    }
    .table-hover tbody tr:hover{
        background:rgba(99,102,241,.12);
    }

    /* ===== 成绩列表 hover 渐变文字 ===== */
    .table tbody tr:hover td {
        background: linear-gradient(135deg, #6366f1, #3b82f6);
        -webkit-background-clip: text;
        background-clip: text;
        color: transparent;
        transition: all .25s ease;
    }
</style>

<%
    Student stuObj = (Student) session.getAttribute("currentUser");
    if (stuObj == null) {
        return;
    }
    Teacher teacher = (Teacher) session.getAttribute("currentUser");
    if (teacher == null) {
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = DBUtil.getConnection();

        // 获取教师负责的班级和科目
        String teacherClass = teacher.getTeacherClass();
        String teacherSubject = teacher.getTeacherSubject();

        if (teacherClass == null || teacherClass.trim().isEmpty()) {
%>
        <div class="alert alert-warning">您尚未设置负责班级，请联系管理员设置。</div>
<%
            return;
        }
        if (teacherSubject == null || teacherSubject.trim().isEmpty()) {
%>
        <div class="alert alert-warning">您尚未设置负责科目，请联系管理员设置。</div>
<%
            return;
        }

        // 解析负责的班级和科目
        java.util.List<String> allowedClasses = new java.util.ArrayList<>();
        java.util.List<String> allowedSubjects = new java.util.ArrayList<>();

        String[] classArray = teacherClass.split(",");
        for (String cls : classArray) {
            allowedClasses.add(cls.trim());
        }

        String[] subjectArray = teacherSubject.split(",");
        for (String subj : subjectArray) {
            allowedSubjects.add(subj.trim());
        }

        // 构建IN条件
        StringBuilder classCondition = new StringBuilder();
        for (int i = 0; i < allowedClasses.size(); i++) {
            if (i > 0) classCondition.append(",");
            classCondition.append("'").append(allowedClasses.get(i)).append("'");
        }

        StringBuilder subjectCondition = new StringBuilder();
        for (int i = 0; i < allowedSubjects.size(); i++) {
            if (i > 0) subjectCondition.append(",");
            subjectCondition.append("'").append(allowedSubjects.get(i)).append("'");
        }

        // 查询符合条件的课程
        Statement courseStmt = conn.createStatement();
        String courseQuery = "SELECT course_id, course_name FROM tb_course WHERE course_name IN (" + subjectCondition.toString() + ") ORDER BY course_id";
        ResultSet courseRs = courseStmt.executeQuery(courseQuery);
        java.util.List<Integer> courseIds = new java.util.ArrayList<>();
        java.util.List<String> courseNames = new java.util.ArrayList<>();
        while (courseRs.next()) {
            courseIds.add(courseRs.getInt("course_id"));
            courseNames.add(courseRs.getString("course_name"));
        }
        if (courseIds.isEmpty()) {
        %>
        <div class="text-muted">暂无课程信息。</div>
        <%
        } else {
            StringBuilder sql = new StringBuilder("SELECT st.stu_name");
            for (int i = 0; i < courseIds.size(); i++) {
                sql.append(", MAX(CASE WHEN s.course_id = ").append(courseIds.get(i))
                        .append(" THEN s.score END) AS `").append(courseNames.get(i)).append("`");
            }
            sql.append("FROM tb_score s ");
            sql.append("JOIN tb_student st ON s.stu_id = st.stu_id ");
            sql.append("WHERE s.exam_type = ? AND st.stu_class IN (").append(classCondition.toString()).append(") ");
            sql.append("GROUP BY st.stu_id, st.stu_name");
            ps = conn.prepareStatement(sql.toString());
            ps.setString(1, "期末");
            rs = ps.executeQuery();
        %>
        <table class="table table-hover align-middle mb-0">
            <thead class="table-primary">
            <tr>
                <th>学生姓名</th>
                <%
                for (String name : courseNames) {
                %>
                <th><%=name%></th>
                <%
                }
                %>
            </tr>
            </thead>
            <tbody>
            <%
            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
                %>
            <tr>
                <td><%=rs.getString("stu_name")%></td>
                <%
                for (String name : courseNames) {
                    Object v = rs.getObject(name);
                %>
                <td><%= v == null ? "-" : v %></td>
                <%
                }
            </tr>
            <%
            }
            if (!hasData) {
            %>
            <tr>
                <td colspan="<%= courseNames.size() + 1 %>" class="text-center text-muted">暂无期末成绩。</td>
            </tr>
            <%
            }
            %>
            </tbody>
        </table>
        <%
        }
    } catch (Exception e) {
    %>
    <div class="alert alert-danger">加载期末成绩失败：<%=e.getMessage()%></div>
    <%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>


