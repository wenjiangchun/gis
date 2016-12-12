<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %> 
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
<title>${title}预报</title>
</head>
<body>
<div class="container" style="background:#fff;">
	<div class="container_left">
			<c:forEach items="${days}" var="day">
				<h3 class="date_title">${day.key}年</h3>
				<c:forEach items="${day.value}" var="d">
					<span class="biaodan" value="<fmt:formatDate value="${d}" pattern="yyyy-MM-dd"/>"><fmt:formatDate value="${d}" pattern="MM月dd日"/></span>
				</c:forEach>
			</c:forEach>
		    <p class="date_more hide" id="more" onclick="showMore()">更多日期</p>
	</div>
	<div class="container_right">
        <div class="hours_box">
            <input class="animate_btn"  style="font-weight: bold" value="动图" type="button" onclick="showDynamicImg()">
            <div class="hours">
            </div>
            <div class="clearfix"></div>
		</div>
        <div style="padding: 5px; text-align: right; font-weight: bold;color: #de240f;font-size: 14px">起报时间：20时</div>
        <div class="seaImg_box">
            <img src="" width="700px"/>
        </div>
	</div>
    <div class="clearfix"></div>
</div>
<script type="text/javascript">
	var type = "${type}";
	$(".menu").find("span").removeClass("menu_cur");
	$(".menu").find("span[name="+type+"]").addClass("menu_cur");
	var remoteUrl = "${config.remoteUrl}";
	var method = "${config.pictureMethod}";
    var pictures = [];
	function getData(date) {
	    $.get(remoteUrl + "?" + method + "&date=" + date + "&factor=" + type + "&region=LNS", function(data) {
            if (clearIntervalId != null) {
                clearInterval(clearIntervalId);
                clearIntervalId = null;
            }
	        pictures = [];
	        var datas = data[0].datas;
	        for (var i = 0; i < datas.length; i++) {
	            pictures.push(datas[i].pictureUrl);
            }
            getPicture(0);
        } );
    }

    function getPicture(hour) {
	    var pictureUrl = pictures[hour];
	    if (pictureUrl == undefined) {
            $("div[class=seaImg_box]").find("img").attr("src", "${ctx}/resources/style/images/nodata.jpg");
            $("div[class=seaImg_box]").find("img").css("height", 200);
        } else {
            $("div[class=seaImg_box]").find("img").attr("src", pictureUrl);
            $("div[class=seaImg_box]").find("img").css("height", 500);
        }
    }

    $(document).ready(function() {
        initTable();
        $("span[class=biaodan]").click(function() {
            $("span").each(function() {
               if($(this).hasClass("date_cur")) {
                   $(this).removeClass("date_cur");
               }
            });
            $(this).addClass("date_cur");
            getData($(this).attr("value"));
            $(".animate_btn").attr("value", "动图");
        });
        //点击第一个
        $("span[class=biaodan]").eq(0).click();

        //处理更多操作
        var size = $("span[class=biaodan]").size();
        if (size > 10) {
            $("span[class=biaodan]:gt(13)").css("display","none");
        }
    });

	function showMore() {
        $("span[class=biaodan]").css("display","");
        $("#more").hide();
    }
	function initTable() {
        //初始化表格内容
        $h = $(".hours");
        var span
        for (i = 0; i <=72; i++) {
            if (i % 3 == 0) {
                var $span = $("<span>");
                $span.html(i + "小时").attr("hour", i);
                $h.append($span);
                $span.click(function() {
                    if (clearIntervalId != null) {
                        clearInterval(clearIntervalId);
                        clearIntervalId = null;
                    }
                    var $this = $(this);
                    var hour = $this.attr("hour");
                    getPicture(hour);
                    $h.find("span").removeClass("hours_cur");
                    $(this).addClass("hours_cur");
                    $(".animate_btn").attr("value", "动图");
                });
            }
        }
    }

    var clearIntervalId = null;
    function showDynamicImg() {
        $(".hours").find("span").removeClass("hours_cur");
        if (clearIntervalId != null) {
            clearInterval(clearIntervalId);
            $(".animate_btn").attr("value", "动图");
            clearIntervalId = null;
        } else {
            if (pictures.length > 0) {
                $(".animate_btn").attr("value", "停止");
                $("div[class=seaImg_box]").find("img").attr("src", pictures[0]);
                var i = 0;
                clearIntervalId = setInterval(function() {
                    getPicture(i);
                    $(".hours").find("span").removeClass("hours_cur");
                    $(".hours").find("span").each(function(index, ele) {
                        if (i == $(this).attr("hour")) {
                            $(this).addClass("hours_cur");
						}
					});
                    i ++;
                    if(i > 72) {
                        i = 0;
                    }

                }, 2000)
            }
        }
    }

</script>
</body>
</html>