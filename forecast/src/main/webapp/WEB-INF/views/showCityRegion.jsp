<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix='fmt' uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>重点城市</title>
    <script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=D1rLgwbOSvfBfyTUyR0fGSE0lSv66lHm"></script>
    <link rel="stylesheet" href="${ctx}/resources/tablecloth/tablecloth.css" />
    <script type="text/javascript" src="${ctx}/resources/tablecloth/tablecloth.js"></script>
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
            <span class="focusTitle_cur" name="picture">场图</span>
            <span name="table">数值</span>
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
    var map = new BMap.Map("map", {mapType: BMAP_HYBRID_MAP});
    map.addControl(new BMap.NavigationControl());
    map.addControl(new BMap.ScaleControl());
    map.addControl(new BMap.OverviewMapControl());
    map.addControl(new BMap.MapTypeControl({mapTypes: [BMAP_HYBRID_MAP]}));
    //map.enableScrollWheelZoom();
    //map.setMinZoom(8);
    //map.setMaxZoom(10);
    map.centerAndZoom(new BMap.Point(122.1, 40.3), 8);
    $(function() {
        //加载区域位置信息
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
                content += "<tr><td>暂无数据</td></tr>";
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
    /**
     * 获取场图信息
     * @param factor
     */
    var clearIntervalId = null;
    function getRegionPicture(factor) {
        $(".focus_title span").removeClass();
        $(".focus_title span").eq(0).addClass("focusTitle_cur");
        clear();
        regionCode = null;
        $.get("${ctx}/getRegionPicture", {regionCode:regionCode, factor:factor}, function(data) {
            var pictures = data.picture;
            if (pictures.length > 0) {
                var i = 0;
                var $img = $("<img>");
                $(".focus_img").append($img);
                clearIntervalId = setInterval(function() {
                    $(".focus_img").find("img").attr("src", pictures[i]).css({width:700,height:470});
                    i ++;
                    if(i > 72) {
                        i = 0;
                    }
                }, 2000);
            }
        });
    }

    function clear() {
        if (clearIntervalId != null) {
            clearInterval(clearIntervalId);
        }
        $(".focus_img").html("");
    }
    $(".focus_title span").click(
            function(){
                $(".focus_title span").removeClass();
                $(this).addClass("focusTitle_cur");
                var name = $(this).attr("name");
                if (name == "picture") {
                   //获取选中的要素
                    var factor = $(".focusLeft_cur").attr("name");
                    //获取数据场图
                    getRegionPicture(factor);
                } else {
                    //获取统计图和表格信息
                    getRegionData();
                }
            }
    )

    function getRegionData() {
        $(".focus_title span").removeClass();
        $(".focus_title span").eq(1).addClass("focusTitle_cur");
        clear();
        var factor = $(".focusLeft_cur").attr("name");
        regionCode = null;
        $.get("${ctx}/getRegionData1", {regionCode:regionCode, factor:factor}, function(data) {
            var $div = $("<div>").css({ height:300}).attr("id", "statDiv");
            var $tbDiv = $("<div>").css({ height:300}).attr("id", "tbDiv");
            var $parent = $(".focus_img");
            $parent.append($div);
            $parent.append($tbDiv);
            showTbDiv(data);
            showK(data);

        });
    }
    $(".focus_left span").click(
            function(){
                $(".focus_left span").removeClass()
                $(this).addClass("focusLeft_cur")
            }
    )

    //计算K线统计图
    function showK(rawData) {
        var myChart = echarts.init(document.getElementById('statDiv'));
        var data = splitData(rawData.data);
        myChart.setOption(option = {
            //backgroundColor: '#eee',
            animation: true,
            legend: {
                left: 'center',
                data: rawData.legend
            },
            title: {
                text: rawData.factor[0],
                left: 0
            },
            tooltip: {
                trigger: 'axis',
                axisPointer: {
                    type: 'line'
                }
            },
            toolbox: {
                feature: {
                    dataZoom: {
                        yAxisIndex: false
                    },
                    brush: {
                        type: ['lineX', 'clear']
                    }
                }
            },
            brush: {
                xAxisIndex: 'all',
                brushLink: 'all',
                outOfBrush: {
                    colorAlpha: 0.1
                }
            },
            grid: [
                {
                    left: '10%',
                    right: '8%',
                    height: '50%'
                },
                {
                    left: '10%',
                    right: '8%',
                    top: '63%',
                    height: '16%'
                }
            ],
            xAxis: [
                {
                    type: 'category',
                    data: data.categoryData,
                    scale: true,
                    boundaryGap : false,
                    axisLine: {onZero: false},
                    splitLine: {show: false},
                    splitNumber: 20,
                    min: 'dataMin',
                    max: 'dataMax'
                },
                {
                    type: 'value',
                    gridIndex: 1,
                    data: data.categoryData,
                    scale: true,
                    boundaryGap : false,
                    axisLine: {onZero: false},
                    axisTick: {show: false},
                    splitLine: {show: false},
                    axisLabel: {show: false},
                    splitNumber: 24,
                    min: 'dataMin',
                    max: 'dataMax'
                }
            ],
            yAxis: [
                {
                    scale: true,
                    splitArea: {
                        show: true
                    }
                },
                {
                    scale: true,
                    gridIndex: 1,
                    splitNumber: 2,
                    axisLabel: {show: false},
                    axisLine: {show: false},
                    axisTick: {show: false},
                    splitLine: {show: false}
                }
            ],
            dataZoom: [
                {
                    type: 'inside',
                    xAxisIndex: [0, 1],
                    start: 0,
                    end: 2
                },
                {
                    show: true,
                    xAxisIndex: [0, 1],
                    type: 'slider',
                    top: '85%',
                    start: 0,
                    end: 2
                }
            ],
            series: [
                {
                    type: 'line',
                    data: data.values,
                    itemStyle: {
                        normal: {
                            color: '#FD1050',
                            color0: '#0CF49B',
                            borderColor: '#FD1050',
                            borderColor0: '#0CF49B'
                        }
                    }
                },
                {
                    name: rawData.legend[0],
                    type: 'line',
                    data: calculateMA(0, data),
                    smooth: true,
                    lineStyle: {
                        normal: {opacity: 0.5},
                        color: '#FD1050'
                    }
                }
            ]
        }, true);

        myChart.dispatchAction({
            type: 'brush',
            areas: [
                {
                    brushType: 'lineX',
                    coordRange: ['', ''],
                    xAxisIndex: 0
                }
            ]
        });
    }

    function calculateMA(dayCount, data) {
        var result = [];
        for (var i = 0, len = data.values.length; i < len; i++) {
            var sum = data.values[i][dayCount];
            result.push(sum);
        }
        return result;
    }

    function splitData(rawData) {
        var categoryData = [];
        var values = [];
        //var volumns = [];
        for (var i = 0; i < rawData.length; i++) {
            categoryData.push(rawData[i].splice(0, 1)[0]);
            values.push(rawData[i]);
            //volumns.push(rawData[i][2]);
        }
        return {
            categoryData: categoryData,
            values: values
            //volumns: volumns
        };
    }

    function showTbDiv(rawData) {
        var data = rawData.data;
        var $tbDiv = $("#tbDiv");
        $tbDiv.append("<button onclick='showData(12, 18, this)' style='float: right; margin-bottom: 3px' class='myButton'>48-72小时</button>");
        $tbDiv.append("<button onclick='showData(6, 12, this)' style='float: right; margin-bottom: 3px' class='myButton'>24-48小时</button>");
        $tbDiv.append("<button onclick='showData(0, 6, this)' style='float: right; margin-bottom: 3px' class='myButton1'>0-24小时</button>");
        var $table = $("<table>").css({cellspacing:"0", cellpadding:"0"});
        var rowCount = 73 / 8;
        for (var i = 0; i < rowCount; i++) {
            var $tr1 = $("<tr>");
            var $tr2 = $("<tr>");
            $table.append($tr1);
            $table.append($tr2);
        }
        $tbDiv.append($table);
        for (var i = 0; i < data.length; i++) {
            //创建一个TR
            if (i > 71) {
                break;
            }
            var rowNum = parseInt((i / 8)) * 2;
            var $tr1 = $table.find("tr").eq(rowNum);
            var $tr2 = $table.find("tr").eq(rowNum + 1);
            if (i % 8 == 0) {
                $tr1.append("<th>" + "时间" + "</th>");
                $tr2.append("<th>" + rawData.legend[0] + "</th>");
            }
            $tr1.append("<th>" + data[i][0] + "</th>");
            $tr2.append("<td>" + data[i][1] + "</td>");
        }
        showData(0,6, null);
    }

    function showData(start, end, obj) {
        $("#tbDiv").find("tr").each(function(index, e) {
            if (index < start || index >= end) {
                $(this).css("display", "none");
            } else {
                $(this).css("display", "");
            }
        });
        if (obj != null) {
            $("#tbDiv").find(".myButton1").removeClass("myButton1").addClass("myButton");
            $(obj).removeClass("myButton").addClass("myButton1");
        }
    }
</script>
</body>
</html>