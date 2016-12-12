$(function() {
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
    );
    $(".focus_left span").click(
        function(){
            $(".focus_left span").removeClass()
            $(this).addClass("focusLeft_cur")
        }
    );
});
/**
 * 获取场图信息
 * @param factor
 */
var clearIntervalId = null;
function getRegionPicture(factor) {
    $(".focus_title span").removeClass();
    $(".focus_title span").eq(0).addClass("focusTitle_cur");
    clear();
    var $img = $("<img>");
    $(".focus_img").append($img);
    $.get(ctx + "/getRegionPicture", {regionCode:regionCode, factor:factor}, function(data) {
        var pictures = data.picture;
        if (pictures.length > 0) {
            var i = 0;
            clearIntervalId = setInterval(function() {
                $(".focus_img").find("img").attr("src", pictures[i]).css({width:"98%",height:470});
                i ++;
                if(i > 72) {
                    i = 0;
                }
            }, 2000);
        } else {
            $(".focus_img").find("img").attr("src", ctx + "/resources/style/images/nodata.jpg").css({width:"98%", height:"60%"});
        }
    });
}

function clear() {
    if (clearIntervalId != null) {
        clearInterval(clearIntervalId);
    }
    $(".focus_img").html("");
}


function getRegionData() {
    $(".focus_title span").removeClass();
    $(".focus_title span").eq(1).addClass("focusTitle_cur");
    clear();
    var factor = $(".focusLeft_cur").attr("name");
    $.get(ctx + "/getRegionData1", {regionCode:regionCode, factor:factor}, function(data) {
        var $div = $("<div>").css({ height:300}).attr("id", "statDiv");
        var $tbDiv = $("<div>").css({ height:300}).attr("id", "tbDiv");
        var $parent = $(".focus_img");
        $parent.append($div);
        $parent.append($tbDiv);
        showTbDiv(data);
        showK(data);

    });
}


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
                saveAsImage: {},
                restore:{},
                magicType: {
                    type: ['line', 'bar']
                }
            },
            right:30
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
    var $tbDiv = $("#tbDiv").css({padding:10});
    $tbDiv.append("<button onclick='showData(12, 18, this)' style='float: right; margin-bottom: 3px' class='myButton'>48-72小时</button>");
    $tbDiv.append("<button onclick='showData(6, 12, this)' style='float: right; margin-bottom: 3px' class='myButton'>24-48小时</button>");
    $tbDiv.append("<button onclick='showData(0, 6, this)' style='float: right; margin-bottom: 3px' class='myButton1'>0-24小时</button>");
    var $table = $("<table>").css({cellspacing:"0", cellpadding:"0"});
    if (data.length > 0) {
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
    } else {
        //禁用按钮
        $("#tbDiv").find("button").css("display", "none");
    }
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