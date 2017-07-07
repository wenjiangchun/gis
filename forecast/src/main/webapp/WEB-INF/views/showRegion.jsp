<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>重点保障区</title>
    <script type="text/javascript" src="${config.bMapUrl}"></script>
    <link rel="stylesheet" href="${ctx}/resources/tablecloth/tablecloth.css" />
    <script type="text/javascript" src="${ctx}/resources/tablecloth/tablecloth.js"></script>
    <script type="text/javascript" src="${ctx}/resources/js/map.js"></script>
    <script type="text/javascript" src="${ctx}/resources/js/region.js"></script>
</head>
<body>
<div class="container" style="background:#fff;padding-bottom:16px; height: 1000px">
    <div class="map_box"  >
        <div id="map" style="height: 400px;margin: 5px; margin-top: 0px">
        </div>
    </div>
    <div class="focus_left">
        <c:forEach items="${factors}" var="factor">
            <span onclick="getRegionPicture('${factor}')" name="${factor}">${factor.title}</span>
        </c:forEach>
    </div>
    <div class="focus_right">
        <div class="focus_title">
            <span class="focusTitle_cur" name="picture" style="display: none"><i class="fa fa-picture-o" aria-hidden="true"></i>
场图</span>
            <span class="focusTitle_cur" name="table"><i class="fa fa-line-chart" aria-hidden="true"></i>
数值</span>
        </div>
        <div class="focus_img" style="height: 530px">
        </div>
    </div>
    <div class="clearfix"></div>
</div>
<script type="text/javascript">
    $.ajaxSetup ({
        cache: false
    });
    $(".menu").find("span").removeClass("menu_cur");
    $(".menu").find("span").eq(6).addClass("menu_cur");
    var regionCode = "${regionCode}";
    var map = new BMap.Map("map", {mapType: BMAP_HYBRID_MAP});
    map.addControl(new BMap.NavigationControl());
    map.addControl(new BMap.ScaleControl());
    map.addControl(new BMap.OverviewMapControl());
    //map.addControl(new BMap.MapTypeControl({mapTypes: [BMAP_HYBRID_MAP]}));
    map.enableScrollWheelZoom();
    map.setMinZoom(9);
    map.setMaxZoom(12);
    map.centerAndZoom(new BMap.Point(120, 40), 9);
    $(function() {
        //加载区域位置信息
        getRegion();
        //获取第一个要素场图信息
    });
    /**
     * 加载区域位置信息
     */
    function getRegion() {
        $.get("${ctx}/getRegions", {level:3}, function(data){
            if (data != null && data.length > 0) {
                for (var i = 0; i < data.length; i++) {
                    var region = data[i];
                    var name = region.name;
                    if (regionCode == "") {
                        if (i == 0) {
                            regionCode = region.code;
                        }
                    }
                    var pointList = region.pointList;
                    //根据pointList判断是点 线还是面
                    if (pointList != null && pointList.length > 0) {
                        var pointCount = pointList.length;
                        switch (pointCount) {
                            case 1 :
                                //加载点
                                var point = pointList[0];
                                //var myIcon = new BMap.Icon("${ctx}/resources/style/images/mapicon.png", new BMap.Size(400,260));
                                var marker = new BMap.Marker(new BMap.Point(point.x, point.y));
                                var label = new BMap.Label(name, {position: new BMap.Point(point.x, point.y)});
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
                                label.setOffset(new BMap.Size(-30, -50));
                                map.addOverlay(marker);
                                map.addOverlay(label);
                                marker.code = region.code;
                                marker.name = region.name;
                                marker.type = "marker";
                                marker.addEventListener("click", function (type, target, point, pixel) {
                                    getData(this, this.getPosition());
                                });
                                    if (regionCode == marker.code) {
                                        getData(marker, marker.getPosition());
                                    }
                                break;
                            case 2:
                                //加载线 将线转换为园
                                var points = [];
                                points.push(new BMap.Point(pointList[0].x, pointList[0].y));
                                points.push(new BMap.Point(pointList[1].x, pointList[1].y));
                                var polyline = new BMap.Polyline(points, {strokeColor:"red", strokeWeight:4, strokeOpacity:0.8, strokeStyle:"dashed"});
                                var center = polyline.getBounds().getCenter();
                                polyline = new BMap.Circle(center, 5000,{strokeColor:"red", strokeWeight:4, strokeOpacity:0.5});
                                map.addOverlay(polyline);
                                var center = polyline.getBounds().getCenter();
                                var label = new BMap.Label(name, {position: center});
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
                                label.setOffset(new BMap.Size(-30, -20));
                                map.addOverlay(label);
                                polyline.code = region.code;
                                polyline.name = region.name;
                                polyline.type = "polyline";
                                polyline.addEventListener("click", function (type, target, point, pixel) {
                                    getData(this, this.getBounds().getCenter());
                                });
                                if (regionCode == polyline.code) {
                                    getData(polyline, polyline.getBounds().getCenter());
                                }
                                break;
                            default:
                                //加载面
                                break;
                        }
                    }
                }
            }
            //init();
        });
    }

    function init() {
        var overLayers = map.getOverlays();
        for (var i = 0; i < overLayers.length; i++) {
            if (regionCode == overLayers[i].code) {
                BMapLib.EventWrapper.trigger(overLayers[i], 'onclick');
            }
        }
    }
    function getData(overlayer, point) {
        map.panTo(point);
        regionCode = overlayer.code;
        var factor = $(".focus_left").find("span").eq(0).attr("name");
        $(".focus_left").find("span").removeClass("focusLeft_cur");
        $(".focus_left").find("span").eq(0).addClass("focusLeft_cur");
        clear();
        //getRegionPicture(factor, regionCode);
        getRegionData();
        var overlays = map.getOverlays();
        for (var i = 0; i < overlays.length; i++) {
            if (overlays[i].type == "marker") {
                overlays[i].setAnimation(null);
            }
           //
        }
        if (overlayer.type == "marker") {
            overlayer.setAnimation(BMAP_ANIMATION_BOUNCE);
        }
    }

</script>
</body>
</html>