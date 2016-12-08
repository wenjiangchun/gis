<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>重点保障区列表</title>
</head>
<body>
<div class="main">
    <table class="table">
        <thead>
         <tr><th>保障区列表</th></tr>
        </thead>
        <tbody>
        <c:forEach items="${regions}" var="region">
            <tr><td><a href="${ctx}/showRegion/${region.code}">${region.name}</a></td></tr>
        </c:forEach>
        </tbody>
    </table>
</div>
<script type="text/javascript">
</script>
</body>
</html>