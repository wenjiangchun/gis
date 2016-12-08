<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<header>
    <h1><img src="${ctx}/resources/style/images/logo.png"></h1>
</header>
<nav>
    <div>
        <ul>
            <a href="${ctx}" name="INDEX"><li>首页</li></a>
            <a href="${ctx}/show/SSW" name="SSW"><li>海面风</li></a>
            <a href="${ctx}/show/TID" name="TID"><li>天文潮</li></a>
            <a href="${ctx}/show/WAV" name="WAV"><li>海浪</li></a>
        </ul>
    </div>
</nav>
<script type="text/javascript">
    var type = "${type}";
    $("a[name='" + type +"']").find("li").addClass("navSelected");
</script>