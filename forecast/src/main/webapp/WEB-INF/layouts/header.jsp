<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<div class="menu_box">
    <div class="menu">
        <a href="${ctx}"><span class="menu_cur" style="border:none;"><img src="${ctx}/resources/style/images/menu_icon1.png">首页</span></a>
        <a href="${ctx}/show/SSW"><span name="SSW"><img src="${ctx}/resources/style/images/menu_icon2.png">海面风力预报</span></a>
        <a href="${ctx}/show/WAV"><span name="WAV"><img src="${ctx}/resources/style/images/menu_icon3.png">海浪预报</span></a>
        <a href="${ctx}/show/CUR"><span name="CUR"><img src="${ctx}/resources/style/images/menu_icon4.png">海流预报</span></a>
        <a href="${ctx}/show/ICE"><span name="ICE"><img src="${ctx}/resources/style/images/menu_icon5.png">海冰预报</span></a>
        <a href="${ctx}/showCityRegion"><span><img src="${ctx}/resources/style/images/menu_icon7.png">重点城市</span></a>
        <a href="${ctx}/showRegion"><span><img src="${ctx}/resources/style/images/menu_icon6.png">重点保障区</span></a>
    </div>
</div>