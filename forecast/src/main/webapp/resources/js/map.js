var map;
$(function() {
    map = new BMap.Map("map", {mapType: BMAP_HYBRID_MAP});
    map.addControl(new BMap.NavigationControl());
    map.addControl(new BMap.ScaleControl());
    map.addControl(new BMap.OverviewMapControl());
    //map.addControl(new BMap.MapTypeControl({mapTypes: [BMAP_HYBRID_MAP]}));
    //map.enableScrollWheelZoom();
    map.setMinZoom(8);
    map.setMaxZoom(10);
    map.centerAndZoom(new BMap.Point(120, 40), 9);
});


