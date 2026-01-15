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
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = DBUtil.getConnection();
        Statement courseStmt = conn.createStatement();
        ResultSet courseRs = courseStmt.executeQuery("SELECT course_id, course_name FROM tb_course ORDER BY course_id");
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
            sql.append(", SUM(s.score) AS `总分` ");
            sql.append("FROM tb_score s ");
            sql.append("JOIN tb_student st ON s.stu_id = st.stu_id ");
            sql.append("WHERE s.exam_type = ? ");
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
                <th>总分</th>
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
                Object total = rs.getObject("总分");
                %>
                <td><%= total == null ? "-" : total %></td>
            </tr>
            <%
            }
            if (!hasData) {
            %>
            <tr>
                <td colspan="<%= courseNames.size() + 2 %>" class="text-center text-muted">暂无期末成绩。</td>
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


