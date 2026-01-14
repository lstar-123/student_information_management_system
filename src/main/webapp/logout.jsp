<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 读取当前角色后再销毁会话
    String role = (String) session.getAttribute("role");
    session.invalidate();

    String target;
    if ("admin".equals(role)) {
        target = "/index.jsp?role=admin";
    } else if ("teacher".equals(role)) {
        target = "/index.jsp?role=teacher";
    } else if ("student".equals(role)) {
        target = "/index.jsp?role=student";
    } else {
        // 未知或未登录角色，回到角色选择入口
        target = "/index.jsp";
    }

    response.sendRedirect(request.getContextPath() + target);
%>


