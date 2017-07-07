<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %> 
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
<title>渔业安全预警报系统</title>
	<c:if test="${type eq 'TID'}">
		<link rel="stylesheet" href="${ctx}/resources/tablecloth/tablecloth.css" />
	</c:if>
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
				<div class="start"></div>
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
	    if (type != "TID") {
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
		} else {
            $.get(remoteUrl + "?" + "getData" + "&date=" + date + "&factor=TID", function(data) {
				$(".right").empty();
				//生成折线图和表格
				var ds = data[0].datas;
				var $chart = $("<div>");
				$chart.css({"width":700,height:300});
                $chart.attr("id", "chart_div");
                $chart.appendTo($(".right"));
                var myChart = echarts.init(document.getElementById('chart_div'));
                // 指定图表的配置项和数据
                // 使用刚指定的配置项和数据显示图表。
				var legend = [];
				var series = [];
				for (var i = 0; i < ds.length; i++) {
                    var d = ds[i];
                    d.zhandianName = convertCityName(d.zhandianName);
                    if (d.zhandianName === "芷锚湾") {
                        continue;
					}
                    legend.push(d.zhandianName);
                    var serie = {
                        name:d.zhandianName,
                        type:'line',
                        data:[d.zeroh, d.oneh, d.twoh, d.threeh, d.fourh, d.fiveh, d.sixh, d.sevenh, d.eighth, d.nineh, d.tenh, d.elevenh, d.twelveh, d.thirteenh, d.fourteenh, d.fifteenh, d.sixteenh, d.seventeenh, d.eighteenh, d.nineteenh, d.twentyh, d.twentyOneh, d.twentyTwoh, d.twentyThreeh],
					};
                    series.push(serie);
				}
                option = {
                    title: {
                        text: '24小时天文潮预报'
                    },
                    tooltip: {
                        trigger: 'axis'
                    },
                    legend: {data:legend, top:25},

                    xAxis:  {
                        type: 'category',
                        boundaryGap: false,
                        data: ['0时','1时','2时','3时','4时','5时','6时','7时','8时','9时','10时','11时','12时','13时','14时','15时','16时','17时','18时','19时','20时','21时','22时','23时']
                    },
                    yAxis: {
                        type: 'value',
                        axisLabel: {
                            formatter: '{value} CM'
                        }
                    },
                    series: series
                };
                myChart.setOption(option);

                //创建表格
				var $table = $("<table class='table'>");
				var html = "<thead><tr><th rowspan='2'>城市</th><th colspan='2'>第一次高潮</th><th colspan='2'>第二次高潮</th><th colspan='2'>第一次低潮</th><th colspan='2'>第二次低潮</th></tr>";
				html += "<tr><th>潮时</th><th>潮高(CM)</th><th>潮时</th><th>潮高(CM)</th><th>潮时</th><th>潮高(CM)</th><th>潮时</th><th>潮高(CM)</th></thead>";
                html += "<tbody>";
				for (var i = 0; i < ds.length; i++) {
                    var d = ds[i];
                    d.zhandianName = convertCityName(d.zhandianName);
                    if (d.zhandianName === "芷锚湾") {
                        continue;
                    }
                    html += "<tr><td>" + (d.zhandianName) + "</td>";
                    var firstMax = "";
                    var secondMax = "";
                    var firstMin = "";
                    var secondMin = "";
                    var firstGaochao = d.firstGaochao;
                    var secondGaochao = d.secondGaochao;
                    //判断第一次和第二次哪个大小
					if (parseInt(firstGaochao) > parseInt(secondGaochao)) {
                        firstMax += "<td>" +  formatTime(d.firstGaochaoTime) + "</td><td>" + d.firstGaochao + "</td>";
                        firstMin = "<td>" +  formatTime(d.secondGaochaoTime) + "</td><td>" + d.secondGaochao + "</td>";
                    } else {
                        firstMin += "<td>" +  formatTime(d.firstGaochaoTime) + "</td><td>" + d.firstGaochao + "</td>";
                        firstMax = "<td>" +  formatTime(d.secondGaochaoTime) + "</td><td>" + d.secondGaochao + "</td>";
                    }

                    var threeGaochao = d.threeGaochao;
                    var fourGaochaoTime = d.fourGaochao;
                    if (parseInt( threeGaochao) > parseInt(fourGaochaoTime)) {
                        secondMax += "<td>" +  formatTime(d.threeGaochaoTime) + "</td><td>" + d.threeGaochao + "</td>";
                        secondMin = "<td>" +  formatTime(d.fourGaochaoTime) + "</td><td>" + d.fourGaochao + "</td>";
                    } else {
                        secondMin += "<td>" +  formatTime(d.threeGaochaoTime) + "</td><td>" + d.threeGaochao + "</td>";
                        secondMax = "<td>" +  formatTime(d.fourGaochaoTime) + "</td><td>" + d.fourGaochao + "</td>";
                    }
                    html += firstMax;
                    html += secondMax;
                    html += firstMin;
                    html += secondMin;
                }
                html += "</tbody>";
				$table.append(html)
                $table.appendTo($(".right"));
                var $tbody = $table.find("tbody")
					$tbody.find("td").each(function(index,e) {
                    if ($(this).html() === "" || $(this).html() === " ") {
                        $(this).html("/");
					}
				});
            } );
		}
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
        if (type != "TID") {
            initTable();
		}
        $("li[class=biaodan]").click(function() {
            $("li").each(function() {
               if($(this).hasClass("biaodanclick")) {
                   $(this).removeClass("biaodanclick");
               }
            });
            $(this).addClass("biaodanclick");
            getData($(this).attr("value"));
            $(".A").find("div").removeClass("stop").addClass("start");
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
            $(".A").find("div").removeClass("stop").addClass("start");
        });
    }

    var clearIntervalId = null;
    function showDynamicImg() {
        $(".td01").css("background","");
        if (clearIntervalId != null) {
            $(".A").find("div").removeClass("stop").addClass("start");
            clearInterval(clearIntervalId);
            clearIntervalId = null;
        } else {
            $(".A").find("div").removeClass("start").addClass("stop");
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

    function formatTime(time) {
        if (time == null) {
            return "";
		}
		var str = "";
		if (time.length == 4) {
            str += time.substr(0, 2);
            str += "时";
            str += time.substr(2, 4);
            str += "分";
		}
		return str;
	}
</script>
</body>
</html>