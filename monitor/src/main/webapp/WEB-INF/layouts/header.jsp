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


    //获取城市对比
    function convertCityName(name) {
        if (name === "鲅鱼圈") {
           return "营口市";
        } else if (name === "丹东新港") {
            return "丹东市";
        } else if (name === "大连(老虎滩)") {
            return "大连市";
        } else if (name === "老北河口") {
            return "盘锦市";
        } else if (name === "锦州港") {
            return "锦州市";
        } else if (name === "菊花岛") {
            return "葫芦岛市";
        } else {
            return name;
        }
    }

    //获取城市对比
    function convertSiteName(name) {
        if (name === "LNYKS") {
            return "鲅鱼圈";
        } else if (name === "LNDDS") {
            return "丹东新港";
        } else if (name === "LNDLS") {
            return "大连(老虎滩)";
        } else if (name === "LNPJS") {
            return "老北河口";
        } else if (name === "LNJZS") {
            return "锦州港";
        } else if (name === "LNHLDS") {
            return "菊花岛";
        } else {
            return name;
        }
    }
</script>