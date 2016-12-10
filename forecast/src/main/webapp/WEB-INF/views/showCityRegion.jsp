<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>重点城市</title>
    <script type="text/javascript" src="${config.bMapUrl}"></script>
    <link rel="stylesheet" href="${ctx}/resources/tablecloth/tablecloth.css" />
    <script type="text/javascript" src="${ctx}/resources/tablecloth/tablecloth.js"></script>
    <script type="text/javascript" src="${ctx}/resources/js/map.js"></script>
    <script type="text/javascript" src="${ctx}/resources/js/region.js"></script>
</head>
<body>
<div class="container" style="background:#fff;padding-bottom:16px; height: 1100px">
    <div class="map_box"  >
        <div id="map" style="height: 500px;margin: 5px; margin-top: 0px">
        </div>
    </div>
    <div class="focus_left hide">
        <c:forEach items="${factors}" var="factor">
            <span onclick="getRegionPicture('${factor}')" name="${factor}">${factor.title}</span>
        </c:forEach>
    </div>
    <div class="focus_right hide">
        <div class="focus_title">
           <span class="focusTitle_cur" name="picture"><i class="fa fa-picture-o" aria-hidden="true"></i>
场图</span>
            <span name="table"><i class="fa fa-line-chart" aria-hidden="true"></i>
数值</span>
        </div>
        <div class="focus_img" style="height: 530px">
        </div>
    </div>
    <div class="clearfix"></div>
</div>
<script type="text/javascript">
    $(".menu").find("span").removeClass("menu_cur");
    $(".menu").find("span").eq(5).addClass("menu_cur");
    var regionCode = "";
    var currentRegionOverlayer;

    //map.enableScrollWheelZoom();
    //map.setMinZoom(8);
    //map.setMaxZoom(10);

    $(function() {
        //加载区域位置信息
        map.centerAndZoom(new BMap.Point(122.1, 40.3), 8);
        getRegion();
        //获取第一个要素场图信息
    });
    /**
     * 加载城市位置信息
     */
    function getRegion() {
        $.get("${ctx}/getRegions", {level:2}, function(data){
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
                                    registerInfoWindow(this);
                                });
                                ply.addEventListener("mouseout", function (type, target, point, pixel) {
                                    //this.setStrokeColor("#2f23ff");
                                });
                                ply.addEventListener("click", function (type, target, point, pixel) {
                                    //首先重置所有面
                                    if (currentRegionOverlayer != null) {
                                        //currentRegionOverlayer.setStrokeColor("#2f23ff");
                                        currentRegionOverlayer.setFillColor("#fff");
                                    }
                                    currentRegionOverlayer = this;
                                    //this.setStrokeColor("red");
                                    this.setFillColor("#f8b992");
                                    registerInfoWindow(this);
                                    getData(this,null);
                                });
                            }
                            // map.setViewport(pointArray);    //调整视野
                            //addlabel();
                        });
                    })(index);
                }
            }
            //init();
        });
    }

    var opts = {
        width : 250,     // 信息窗口宽度
        enableMessage:true//设置允许信息窗发送短息
    };
    function registerInfoWindow(overlayer) {
        var infoWindow = new BMap.InfoWindow("数据加载中...",opts);  // 创建信息窗口对象
        var d = new Date();
        var date = d.getFullYear() + "年" + (d.getMonth()+ 1) + "月" + d.getDate() + "日 <label style='font-weight: bold;color:red;font-size: 13px'>" + d.getHours() + "</label>时";
        var title = "<span style='font-weight: bold;font-size: 14px'>" + overlayer.name + "  【" + date + "】</span>";
        infoWindow.setTitle(title);
        map.openInfoWindow(infoWindow,overlayer.getBounds().getCenter());
        $.get("${ctx}/getRegionCurrentData", {regionCode: overlayer.code}, function(data) {
            //添加信息窗口
            var content = "<table>";
            if (data.length > 0) {
                for (var i = 0; i < data.length; i++) {
                    content += "<tr>";
                    var dataArr = data[i].split(":");
                    content += "<tr><th width='60px'>" + dataArr[0] + "</th><td>" + dataArr[1] + "</td></tr>";
                }
            } else {
                content += "<tr><td><span><i class=\"fa fa-exclamation-triangle\" aria-hidden=\"true\"></i>暂无数据</span></td></tr>";
            }
            content += "</table>";
            infoWindow.setContent(content);
            infoWindow.enableCloseOnClick();
        });
    }
    function init() {
        var overLayers = map.getOverlays();
        for (var i = 0; i < overLayers.length; i++) {
            if (regionCode == overLayers[i].code) {
            }
        }
    }
    function getData(overlayer, point) {
        //map.panTo(point);
        regionCode = overlayer.code;
        var factor = $(".focus_left").find("span").eq(0).attr("name");
        $(".focus_left").find("span").removeClass("focusLeft_cur");
        $(".focus_left").find("span").eq(0).addClass("focusLeft_cur");
        clear();
        getRegionPicture(factor, regionCode);
    }
</script>
</body>
</html>