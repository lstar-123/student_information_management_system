<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.lingxing.bean.Student" %>
<%@ page import="com.lingxing.util.DBUtil" %>
<%!
    private String formatScoreWithGrade(Object scoreObj) {
        if (scoreObj == null) return "-";
        double score = ((Number) scoreObj).doubleValue();
        String grade;
        if (score >= 90) {
            grade = "优";
        } else if (score >= 80) {
            grade = "良";
        } else if (score >= 70) {
            grade = "中";
        } else if (score >= 60) {
            grade = "及格";
        } else {
            grade = "不及格";
        }
        if (Math.floor(score) == score) {
            return String.format(Locale.US, "%.0f (%s)", score, grade);
        }
        return String.format(Locale.US, "%.1f (%s)", score, grade);
    }
%>
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
    int stuId = stuObj.getStuId();
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = DBUtil.getConnection();
        Statement courseStmt = conn.createStatement();
        ResultSet courseRs = courseStmt.executeQuery("SELECT course_id, course_name FROM tb_course ORDER BY course_id");
        List<Integer> courseIds = new ArrayList<>();
        List<String> courseNames = new ArrayList<>();
        while (courseRs.next()) {
            courseIds.add(courseRs.getInt("course_id"));
            courseNames.add(courseRs.getString("course_name"));
        }
        courseRs.close();
        courseStmt.close();
        if (courseIds.isEmpty()) {
%>
            <div class="text-muted">暂无课程信息。</div>
<%
        } else {
%>
            <table class="table table-hover align-middle mb-0">
                <thead class="table-primary">
                <tr>
                    <th>科目名称</th>
                    <th>期中成绩</th>
                    <th>期末成绩</th>
                </tr>
                </thead>
                <tbody>
<%
                for (int i = 0; i < courseIds.size(); i++) {
                    int courseId = courseIds.get(i);
                    String courseName = courseNames.get(i);

                    // 查询期中成绩
                    String sqlMid = "SELECT score FROM tb_score WHERE stu_id = ? AND course_id = ? AND exam_type = '期中'";
                    ps = conn.prepareStatement(sqlMid);
                    ps.setInt(1, stuId);
                    ps.setInt(2, courseId);
                    rs = ps.executeQuery();
                    Object midScore = rs.next() ? rs.getObject("score") : null;
                    rs.close();
                    ps.close();

                    // 查询期末成绩
                    String sqlFinal = "SELECT score FROM tb_score WHERE stu_id = ? AND course_id = ? AND exam_type = '期末'";
                    ps = conn.prepareStatement(sqlFinal);
                    ps.setInt(1, stuId);
                    ps.setInt(2, courseId);
                    rs = ps.executeQuery();
                    Object finalScore = rs.next() ? rs.getObject("score") : null;
                    rs.close();
                    ps.close();
%>
                <tr>
                    <td><%=courseName%></td>
                    <td><%= formatScoreWithGrade(midScore) %></td>
                    <td><%= formatScoreWithGrade(finalScore) %></td>
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
    <div class="alert alert-danger">加载成绩失败：<%=e.getMessage()%></div>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>

