<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>辽宁省海洋环境预报与防灾减灾中心精细化预报系统</title>
</head>
<body>
<div class="container">
    <div class="report_box">
        <div class="column_title">
            <span class="column_name">海域报告</span>
        </div>
        <div class="report_menu">
            <c:forEach items="${factors}" var="factor">
                <span name="${factor}">${factor.title}</span>
            </c:forEach>
        </div>
        <div class="report_img">
            <img src="${ctx}/resources/style/images/nodata.jpg">
            <div class="clearfix"></div>
        </div>
    </div>
    <div class="focus_box">
        <div class="column_title">
            <span class="column_name">重点保障区</span>
        </div>
        <div class="focus_map">
            <c:forEach items="${regions}" var="region" varStatus="idx">
                <div
                <c:if test="${idx.index == 0}">
                    style="margin-left:27px;"
                </c:if>
                        class="map_each">
                    <a href="${ctx}/showRegion?regionCode=${region.code}">
                        <div><img src="${ctx}/resources/style/images/focus_img1.png"></div>
                        <span>${region.name}</span></a>
                </div>
            </c:forEach>
        </div>
    </div>
</div>
<script type="text/javascript">
    $(function () {
        $(".report_menu span").click(function () {
                    $(".report_menu span").removeClass();
                    $(this).addClass("report_cur");
                    var factor = $(this).attr("name");
                    getPicture(factor);
                }
        );
        $(".report_menu span").eq(0).click();
    });

    var clearIntervalId = null;

    function getPicture(factor) {
        $.get("${ctx}/getRegionPicture", {factor: factor,regionCode:"${config.provinceCode}"}, function(data) {
            if (clearIntervalId != null) {
                clearInterval(clearIntervalId);
            }
            if (data.picture.length == 0) {
                $(".report_img").find("img").attr("src", "${ctx}/resources/style/images/nodata.jpg").css({width:534, height:189});
            } else {
                $(".report_img").find("img").attr("src", data.picture[0]).css({width:800, height:400});
                var i = 0;
                clearIntervalId = setInterval(function() {
                    i ++;
                    if(i >= data.picture.length) {
                        i = 0;
                    }
                    $(".report_img").find("img").attr("src", data.picture[i]).css({width:800, height:400});
                }, 2000)
            }
        });
    }

</script>
</body>
</html>