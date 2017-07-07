<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>渔业安全预警报系统</title>
    <script type="text/javascript" src="${config.bMapUrl}"></script>
    <style type="text/css">
        .B3{
            width: 940px;
            border: #52b0ff solid 1px;
            top:100px;
        }
    </style>
</head>
<body>
<div class="main">
    <div class="map2" id="map"></div>
    <div class="under">
        <table class="B2" cellspacing="0" cellpadding="0">
            <caption
                    style="background: #47A6F6;color: #f1f1f1; font-size: 16px;font-weight: bold;padding: 10px; text-align:left"></caption>
            <tr style="height: 30px; font-weight: bold">
                <td class="td02" style="background-color:#e8f4ff;">时间</td>
                <td class="td02" style="background-color:#e8f4ff">${one}</td>
                <td class="td02" style="background-color:#e8f4ff">${two}
                </td>
                <td class="td02" style="background-color:#e8f4ff">${three}</td>
            </tr>
            <tr style="height: 20px;">
                <td class="td02" style="background-color:#e8f4ff">浪高（米<br>(浪高/浪级)</td>
                <td class="td02">-/-</td>
                <td class="td02">-/-</td>
                <td class="td02">-/-</td>
            </tr>
            <tr style="height: 20px;">
                <td class="td02" style="background-color:#e8f4ff">风速（米/秒<br>(风速/风级)</td>
                <td class="td02">-/-</td>
                <td class="td02">-/-</td>
                <td class="td02">-/-</td>
            </tr>
        </table>
        <table class="B3" cellspacing="0" cellpadding="0" style="left: 10px" style="display:none">
            <caption
                    style="background: #47A6F6;color: #f1f1f1; font-size: 16px;font-weight: bold;padding: 10px; text-align:left"></caption>
            <thead>
            <tr style="height: 30px; font-weight: bold">
                <td class="td02" style="background-color:#e8f4ff;" rowspan="2">日期</td>
                <td class="td02" style="background-color:#e8f4ff" colspan="2">第一次高潮</td>
                <td class="td02" style="background-color:#e8f4ff" colspan="2">第二次高潮
                </td>
                <td class="td02" style="background-color:#e8f4ff" colspan="2">第一次低潮</td>
                <td class="td02" style="background-color:#e8f4ff" colspan="2">第二次低潮
                </td>
            </tr>
            <tr style="height: 30px; font-weight: bold">
                <td class="td02" style="background-color:#e8f4ff">潮时</td>
                <td class="td02" style="background-color:#e8f4ff">潮高(CM)
                </td>
                <td class="td02" style="background-color:#e8f4ff">潮时</td>
                <td class="td02" style="background-color:#e8f4ff">潮高(CM)
                </td>
                <td class="td02" style="background-color:#e8f4ff">潮时</td>
                <td class="td02" style="background-color:#e8f4ff">潮高(CM)
                </td>
                <td class="td02" style="background-color:#e8f4ff">潮时</td>
                <td class="td02" style="background-color:#e8f4ff">潮高
                </td>
            </tr>
            </thead>
            <tbody>
            <tr style="height: 30px; font-weight: bold">
            </tr>
            <tr style="height: 30px; font-weight: bold">
            </tr>
            <tr style="height: 30px; font-weight: bold">
            </tr>
            </tbody>
        </table>
    </div>
</div>
<script type="text/javascript">
    var dataPoint = [], dataPloygon = [];
    var cityPoints = [];
    var map = new BMap.Map("map", {mapType: BMAP_HYBRID_MAP});
    map.addControl(new BMap.NavigationControl());
    map.addControl(new BMap.ScaleControl());
    map.addControl(new BMap.OverviewMapControl());
    //map.enableScrollWheelZoom();
    map.setMinZoom(7);
    map.setMaxZoom(10);
    map.centerAndZoom(new BMap.Point(120, 40), 9);
    $.getJSON("${ctx}/getRegions", function (data) {
        for (var i = 0; i < data.length; i++) {
            if (data[i].pointList.length == 1) {
                if (data[i].level == 2) {
                    cityPoints.push(data[i]);
                } else {
                    dataPoint.push(data[i]);
                }

            } else {
                dataPloygon.push(data[i]);
            }
        }
        showPloygon();
    });


    function ZoomControl() {
        // 默认停靠位置和偏移量
        this.defaultAnchor = BMAP_ANCHOR_TOP_RIGHT;
        this.defaultOffset = new BMap.Size(50, 11);
    }
    ZoomControl.prototype = new BMap.Control();
    ZoomControl.prototype.initialize = function (map) {
        // 创建一个DOM元素
        var div = document.createElement("div");
        // 添加文字说明
        var yunchang = document.createElement("input");
        var yugang = document.createElement("input");
        var city = document.createElement("input");
        yunchang.value = "渔场";
        yunchang.style.border = "1px";
        yunchang.style.padding = "3px";
        yunchang.style.fontSize = "12px";
        yunchang.style.cursor = "pointer";
        yunchang.type = "button";
        yugang.value = "渔港";
        yugang.style.padding = "3px";
        yugang.style.fontSize = "12px";
        yugang.style.border = "1px";
        yugang.style.cursor = "pointer";
        yugang.type = "button";
        yunchang.style.background = "#8ea8e0";
        yunchang.style.color = "#fff";
        yugang.style.color = "#000";
        yugang.style.background = "#fff";


        city.value = "城市";
        city.style.padding = "3px";
        city.style.fontSize = "12px";
        city.style.border = "1px";
        city.style.cursor = "pointer";
        city.type = "button";
        city.style.background = "#8ea8e0";
        city.style.color = "#fff";
        city.style.color = "#000";
        city.style.background = "#fff";

        div.appendChild(yunchang);
        div.appendChild(yugang);
        div.appendChild(city);
        // 设置样式
        div.style.cursor = "pointer";
        div.style.backgroundColor = "white";
        yunchang.onclick = function (e) {
            yunchang.style.background = "#8ea8e0";
            yunchang.style.color = "#fff";
            yugang.style.color = "#000";
            yugang.style.background = "#fff";
            city.style.color = "#000"
            city.style.background = "#fff";
            showPloygon();
        }
        yugang.onclick = function (e) {
            yunchang.style.background = "#fff";
            yunchang.style.color = "#000";
            yugang.style.color = "#fff"
            yugang.style.background = "#8ea8e0";
            city.style.color = "#000"
            city.style.background = "#fff";
            showPonit();
        }
        city.onclick = function (e) {
            yunchang.style.background = "#fff";
            yunchang.style.color = "#000";
            yugang.style.color = "#000"
            yugang.style.background = "#fff";
            city.style.color = "#fff"
            city.style.background = "#8ea8e0";
            showCity();
        }
        map.getContainer().appendChild(div);
        //yunchang.click();
        return div;
    }
    // 创建控件
    var myZoomCtrl = new ZoomControl();
    // 添加到地图当中
    map.addControl(myZoomCtrl);


    function showPloygon() {
        $(".B2").show();
        $(".B3").hide();
        map.clearOverlays();
        var center = null;
        for (var i = 0; i < dataPloygon.length; i++) {
            var points = dataPloygon[i].pointList;
            var mapPoints = new Array();
            for (var j = 0; j < points.length; j++) {
                mapPoints.push(new BMap.Point(points[j].x, points[j].y));
            }
            var polygon = new BMap.Polygon(mapPoints, {
                strokeColor: "#FAF1D2",
                strokeWeight: 2,
                strokeOpacity: 0.5,
                fillColor: "#c6b076"
            });  //创建多边形
            polygon.name = dataPloygon[i].name;
            if (i == 0) {
                center = polygon.getBounds().getCenter();
            }
            var label = new BMap.Label(dataPloygon[i].name, {position: polygon.getBounds().getCenter()});
            label.setStyle({
                fontSize: "12px",
                color: "#FAF1D2",
                fontWeight:"bold",
                borderColor: "transparent",
                backgroundColor:"transparent"
                //opacity: 0.9
            });
            label.setOffset(new BMap.Size(-30, -10));
            polygon.code = dataPloygon[i].code;
            polygon.type = "polygon";
            polygon.addEventListener("click", function (type, target, point, pixel) {
                getDate(this.code, this.name);
            });
            label.addEventListener("click", function (type, target, point, pixel) {
                getDate(this.polygon.code, this.polygon.name);
            });
            polygon.label = label;
            label.polygon = polygon;
            map.addOverlay(label);
            map.addOverlay(polygon);
            if (i == 0) {
                getDate(polygon.code, polygon.name);
                polygon.setFillColor("#fff");
                polygon.label.setStyle({
                    color: "#636363"
                    //opacity: 0.9
                });
            }

        }
        map.centerAndZoom(center, 7);
    }

    function showPonit() {
        $(".B2").show();
        $(".B3").hide();
        map.clearOverlays();
        var center = null;
        for (var i = 0; i < dataPoint.length; i++) {
            var region = dataPoint[i];
            var point = dataPoint[i].pointList[0];
            // var myIcon = new BMap.Icon("${ctx}/resources/style/images/foo.png", new BMap.Size(200,200));
            var marker = new BMap.Marker(new BMap.Point(point.x, point.y));
            var label = new BMap.Label(region.name, {position: new BMap.Point(point.x, point.y)});
            label.setStyle({
                color: "#f86f06",
                fontSize: "12px",
                height: "20px",
                lineHeight: "20px",
                fontFamily: "微软雅黑",
                fontWeight: "bold",
                //borderStyle: "none",
                borderColor: "#f8a01d",
                //backgroundColor:"transparent"
            });
            label.setOffset(new BMap.Size(-30, -50));
            marker.code = region.code;
            marker.type = "point";
            marker.name = region.name;
            marker.addEventListener("click", function (type, target, point, pixel) {
                getDate(this.code, this.name);
            });
            map.addOverlay(marker);
            map.addOverlay(label);
            if (i == 4) {
                //center = new BMap.Point(point.x, point.y);
                //map.centerAndZoom(center, 9);
            }
            if (i == 0) {
                getDate(marker.code, marker.name);
                marker.setAnimation(BMAP_ANIMATION_BOUNCE);
                //获取中间点
                map.centerAndZoom(marker.getPosition(), 9);
            }
        }

    }

    function getDate(region, name) {
        var overlays = map.getOverlays();
        for (var i = 0; i < overlays.length; i++) {
            var overlay = overlays[i];
            if (overlay.type != undefined) {
                if (overlay.type == "polygon") {
                    overlay.setFillColor("#c6b076");
                    overlay.label.setStyle({
                        color: "#FAF1D2"
                        //opacity: 0.9
                    });
                    if (overlay.code == region) {
                        overlay.setFillColor("#fff");
                        overlay.label.setStyle({
                            color: "#636363"
                            //opacity: 0.9
                        });
                    }
                } else {
                    overlay.setAnimation(null);
                    if (overlay.code == region) {
                        overlay.setAnimation(BMAP_ANIMATION_BOUNCE);
                        map.panTo(overlay.getPosition());
                    }
                }
            }
        }
        $(".B2 caption").html(name);
        getRemoteData(region);
    }

    /**
     * 获取远程数据 主要有海浪 潮汐和风速信息
     * @param region 区域代码 如果为空默认查询所有
     */
    function getRemoteData(region) {
        $.post("${ctx}/getRemoteStatData", {region: region}, function (data) {
            //处理返回的数据
            var $table = $(".B2");
            //$table.find("tr").find("td").not(":eq>0").html("-/-/-");
            if (data != null) {
                var wavDatas = data.WAV;
                var sswDatas = data.SSW;
                var tidDatas = data.TID;
                for (var i = 0; i < wavDatas.length; i++) {
                    var wavData = wavDatas[i];
                    var wavHeightMax = wavData.result.waveHeightMax;
                    var level = wavData.result.level;
                    var wavDirectionMax = wavData.result.waveDirectionMax;
                    var index = 3 - i;
                   // $table.find("tr").eq(1).find("td").eq(index).html(wavHeightMax + "/" + level + "/" + wavDirectionMax);
                    $table.find("tr").eq(1).find("td").eq(index).html(wavHeightMax + "/" + level + "(级)");
                }
                for (var i = 0; i < sswDatas.length; i++) {
                    var sswData = sswDatas[i];
                    var rapidMax = sswData.result.rapidMax;
                    var level = sswData.result.level;
                    var directionMax = sswData.result.directionMax;
                    var index = 3 - i;
                    //$table.find("tr").eq(2).find("td").eq(index).html(rapidMax + "/" + level + "/" + directionMax);
                    $table.find("tr").eq(2).find("td").eq(index).html(rapidMax + "/" + level + "/" + directionMax);
                }
            }
        });
    }


    /**
     * 加载城市位置信息
     */
    var regionCode = "";
    function showCity() {
        $(".B3").show();
        $(".B2").hide();
        map.clearOverlays();
        var data = cityPoints;
            if (data != null && data.length > 0) {
                var bdary = new BMap.Boundary();
                for (var index = 0; index < data.length; index++) {
                    var region = data[index];
                    var name = region.name;
                    if (regionCode == "") {
                        if (index == 0) {
                            regionCode = region.code;
                        }
                    }
                    (function(index){ //闭包用法
                        bdary.get(data[index].name, function(rs){
                            var count = rs.boundaries.length; //行政区域的点有多少个
                            if (count === 0) {
                                alert('未能获取当前输入行政区域');
                                return ;
                            }
                            var pointArray = [];
                            for (var i = 0; i < count; i++) {
                                var ply = new BMap.Polygon(rs.boundaries[i], {strokeWeight: 2, strokeColor: "#2f23ff"}); //建立多边形覆盖物
                                var opts = {
                                    position : ply.getBounds().getCenter(),    // 指定文本标注所在的地理位置
                                    offset   : new BMap.Size(-10, -20)    //设置文本偏移量
                                }
                                var label = new BMap.Label(data[index].name, opts);  // 创建文本标注对象
                                label.setStyle({
                                    color: "#f86f06",
                                    fontSize: "14px",
                                    height: "20px",
                                    lineHeight: "20px",
                                    fontFamily: "微软雅黑",
                                    fontWeight: "bold",
                                    //borderStyle: "none",
                                    borderColor: "#f8a01d",
                                    //backgroundColor:"transparent"
                                });
                                //设置覆盖物关联label对象
                                ply.label = label;
                                ply.code = data[index].code;
                                ply.name = data[index].name;
                                //label.polygon = ply;
                                map.addOverlay(ply);  //添加覆盖物
                                map.addOverlay(label);
                                pointArray = pointArray.concat(ply.getPath());
                                //注册鼠标滑动事件
                                ply.addEventListener("mousemove", function (type, target, point, pixel) {
                                    //this.setStrokeColor("red");
                                    //获取区域当前时间点数据
                                    //registerInfoWindow(this);
                                    //registerInfoWindow(this);
                                });
                                ply.addEventListener("mouseout", function (type, target, point, pixel) {
                                    //this.setStrokeColor("#2f23ff");
                                });
                                ply.addEventListener("click", function (type, target, point, pixel) {
                                  /*  //首先重置所有面
                                    if (currentRegionOverlayer != null) {
                                        currentRegionOverlayer.setFillColor("#fff");
                                    }
                                    currentRegionOverlayer = this;
                                    this.setFillColor("#f8b992");*/
                                    getCityTID(this);
                                });
                                label.polygon = ply;
                                label.addEventListener("click", function (type, target, point, pixel) {
                                   /* //首先重置所有面
                                    if (currentRegionOverlayer != null) {
                                        currentRegionOverlayer.setFillColor("#fff");
                                    }
                                    currentRegionOverlayer = this.polygon;
                                    this.polygon.setFillColor("#f8b992");*/
                                    getCityTID(this.polygon);
                                });
                                if (index == 4) {
                                    ply.dispatchEvent("click");
                                }
                            }
                        });
                    })(index);
                }
            }
    }

    var remoteUrl = "${config.remoteUrl}";

    function formatM(month) {
        if (month < 10) {
            return "0" + month;
        } else {
            return month;
        }
    }
    function getCityTID(polygon) {
        var overlays = map.getOverlays();
        for (var i = 0; i < overlays.length; i++) {
            var overlay = overlays[i];
            if (overlay.code != undefined ) {
                if (overlay.code == polygon.code) {
                    overlay.setFillColor("#f8b992");
                } else {
                    overlay.setFillColor("#fff");
                }
            }
            }

        map.centerAndZoom( polygon.getBounds().getCenter(), 8);
        var siteName = convertSiteName(polygon.code);
        //获取最近3天数据
        var d = new Date();
        $(".B3 caption").html(polygon.name + "72小时高低潮汐预报");
        var curDay = d.getFullYear() + "-" + formatM((d.getMonth() + 1))+ "-";
        if (d.getDate() < 10) {
            curDay += "0"
        }
        curDay += d.getDate();
        //获取当前日期数据
        $.get(remoteUrl + "?" + "getData" + "&date=" + curDay + "&factor=TID", function(data) {
           //获取该市数据
            var datas = data[0].datas;
            processDS(datas, siteName, curDay,0);
        });
        d.setDate(d.getDate() + 1);
        var tomDay = d.getFullYear() + "-" + formatM((d.getMonth() + 1))+ "-";
        if (d.getDate() < 10) {
            tomDay += "0"
        }
        tomDay += d.getDate();
        $.get(remoteUrl + "?" + "getData" + "&date=" + tomDay + "&factor=TID", function(data) {
            var datas = data[0].datas;
            processDS(datas, siteName, tomDay,1);
        });
        d.setDate(d.getDate() + 1);
        var aftDay = d.getFullYear() + "-" + formatM((d.getMonth() + 1)) + "-";
        if (d.getDate() < 10) {
            aftDay += "0"
        }
        aftDay += d.getDate();
        $.get(remoteUrl + "?" + "getData" + "&date=" + aftDay + "&factor=TID", function(data) {
            var datas = data[0].datas;
            processDS(datas, siteName, aftDay,2);
        });
    }

    function processDS(ds, siteName, day, index) {
        var $table = $(".B3");
        var html = "";
        for (var i = 0; i < ds.length; i++) {
            var d = ds[i];
            if (d.zhandianName === siteName) {
                html += "<td class='td02' style='background-color:#e8f4ff;'>" + day + "</td>";
                var firstMax = "";
                var secondMax = "";
                var firstMin = "";
                var secondMin = "";
                var firstGaochao = d.firstGaochao;
                var secondGaochao = d.secondGaochao;
                //判断第一次和第二次哪个大小
                if (parseInt(firstGaochao) > parseInt(secondGaochao)) {
                    firstMax += "<td class='td02' style='background-color:#e8f4ff;'>" +  formatTime(d.firstGaochaoTime) + "</td><td class='td02' style='background-color:#e8f4ff;'>" + d.firstGaochao + "</td>";
                    firstMin = "<td class='td02' style='background-color:#e8f4ff;'>" +  formatTime(d.secondGaochaoTime) + "</td><td class='td02' style='background-color:#e8f4ff;'>" + d.secondGaochao + "</td>";
                } else {
                    firstMin += "<td class='td02' style='background-color:#e8f4ff;'>" +  formatTime(d.firstGaochaoTime) + "</td><td class='td02' style='background-color:#e8f4ff;'>" + d.firstGaochao + "</td>";
                    firstMax = "<td class='td02' style='background-color:#e8f4ff;'>" +  formatTime(d.secondGaochaoTime) + "</td><td class='td02' style='background-color:#e8f4ff;'>" + d.secondGaochao + "</td>";
                }

                var threeGaochao = d.threeGaochao;
                var fourGaochaoTime = d.fourGaochao;
                if (parseInt( threeGaochao) > parseInt(fourGaochaoTime)) {
                    secondMax += "<td class='td02' style='background-color:#e8f4ff;'>" +  formatTime(d.threeGaochaoTime) + "</td><td class='td02' style='background-color:#e8f4ff;'>" + d.threeGaochao + "</td>";
                    secondMin = "<td class='td02' style='background-color:#e8f4ff;'>" +  formatTime(d.fourGaochaoTime) + "</td><td class='td02' style='background-color:#e8f4ff;'>" + d.fourGaochao + "</td>";
                } else {
                    secondMin += "<td class='td02' style='background-color:#e8f4ff;'>" +  formatTime(d.threeGaochaoTime) + "</td><td class='td02' style='background-color:#e8f4ff;'>" + d.threeGaochao + "</td>";
                    secondMax = "<td class='td02' style='background-color:#e8f4ff;'>" +  formatTime(d.fourGaochaoTime) + "</td><td class='td02' style='background-color:#e8f4ff;'>" + d.fourGaochao + "</td>";
                }
                html += firstMax;
                html += secondMax;
                html += firstMin;
                html += secondMin;
            }
        }
        var $tr = $table.find("tbody").find("tr").eq(index);
        $tr.empty();
        $tr.append(html);
        var $tbody = $table.find("tbody");
        $tbody.find("td").each(function(index,e) {
            if ($(this).html() === "" || $(this).html() === " ") {
                $(this).html("/");
            }
        });
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