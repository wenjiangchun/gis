<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %> 
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
<title>渔业安全预警报系统</title>
</head>
<body>
<div class="main">
	<div class="left">
		<ul>
			<c:forEach items="${days}" var="day">
				<li class="biaotou">${day.key}年</li>
				<c:forEach items="${day.value}" var="d">
					<li class="biaodan" value="<fmt:formatDate value="${d}" pattern="yyyy-MM-dd"/>"><fmt:formatDate value="${d}" pattern="MM月dd日"/></li>
				</c:forEach>
			</c:forEach>
			<li class="biaodan hide" id="more" onclick="showMore()"><a>更多</a></li>
		</ul>
	</div>
	<div class="right">
		<div class="nav">
			<div class="A" onclick="showDynamicImg()" style="cursor: pointer">
				<div ></div>
			</div>
			<div class="B">
				<table cellspacing="5" class="B1 table">
					<tr>
					</tr>
					<tr>
					</tr>
				</table>
			</div>
		</div>
        <div style="padding: 5px; text-align: right; font-weight: bold;color: #de240f;font-size: 14px">起报时间：20时</div>
		<diV class="map1">
            <img src="" width="700px"/>
        </diV>
	</div>
</div>
<script type="text/javascript">
	var type = "${type}";
	var remoteUrl = "${config.remoteUrl}";
	var method = "${config.pictureMethod}";
    var pictures = [];
	function getData(date) {
	    $.get(remoteUrl + "?" + method + "&date=" + date + "&factor=" + type, function(data) {
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
            $("div[class=map1]").find("img").attr("src", "${ctx}/resources/style/images/nodata.jpg");
        } else {
            $("div[class=map1]").find("img").attr("src", pictureUrl);
        }
    }

    $(document).ready(function() {
        initTable();
        $("li[class=biaodan]").click(function() {
            $("li").each(function() {
               if($(this).hasClass("biaodanclick")) {
                   $(this).removeClass("biaodanclick");
               }
            });
            $(this).addClass("biaodanclick");
            getData($(this).attr("value"));
        });
        //点击第一个
        $("li[class=biaodan]").eq(0).click();

        //处理更多操作
        var size = $("li[class=biaodan]").size() ;
        if (size > 10) {
            $("li[class=biaodan]:gt(10)").css("display","none");
        }
    });

	function showMore() {
        $("li[class=biaodan]").css("display","");
        $("#more").hide();
    }
	function initTable() {
        //初始化表格内容
        var $table = $("table");
        var $tr1 = $table.find("tr").eq(0);
        var $tr2 = $table.find("tr").eq(1);
        for (i = 0; i <=72; i++) {
            if (i % 3 == 0) {
                var $td = $("<td>").addClass("td01").text(i + "小时").attr("hour", i);
                if (i < 36) {
                    $tr1.append($td);
                } else {
                    $tr2.append($td);
                }
            }
        }
        //绑定点击事件
        $table.find("td").click(function() {
            if (clearIntervalId != null) {
                clearInterval(clearIntervalId);
                clearIntervalId = null;
            }
            var $this = $(this);
            var hour = $this.attr("hour");
            getPicture(hour);
            $(".td01").css("background","");
            $(this).css("background","#3b454b");
        });
    }

    var clearIntervalId = null;
    function showDynamicImg() {
        $(".td01").css("background","");
        if (clearIntervalId != null) {
            clearInterval(clearIntervalId);
            clearIntervalId = null;
        } else {
            var i = 0;
            clearIntervalId = setInterval(function() {
                getPicture(i);
                i ++;
                if(i > 72) {
                    i = 0;
                }
            }, 2000)
        }
    }

</script>
</body>
</html>