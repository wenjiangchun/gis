<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>渔业安全预警报系统</title>
    <script type="text/javascript" src="${config.bMapUrl}"></script>
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
            <tr style="height: 20px;">
                <td class="td02" style="background-color:#e8f4ff">潮高（米）</td>
                <td class="td02">-/-</td>
                <td class="td02">-/-</td>
                <td class="td02">-/-</td>
            </tr>
        </table>
    </div>
</div>
<script type="text/javascript">
    var dataPoint = [], dataPloygon = [];
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
                dataPoint.push(data[i]);
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
        div.appendChild(yunchang);
        div.appendChild(yugang);
        // 设置样式
        div.style.cursor = "pointer";
        div.style.backgroundColor = "white";
        yunchang.onclick = function (e) {
            yunchang.style.background = "#8ea8e0";
            yunchang.style.color = "#fff";
            yugang.style.color = "#000";
            yugang.style.background = "#fff";
            showPloygon();
        }
        yugang.onclick = function (e) {
            yunchang.style.background = "#fff";
            yunchang.style.color = "#000";
            yugang.style.color = "#fff"
            yugang.style.background = "#8ea8e0";
            showPonit();
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
        $("caption").html(name);
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
</script>
</body>
</html>