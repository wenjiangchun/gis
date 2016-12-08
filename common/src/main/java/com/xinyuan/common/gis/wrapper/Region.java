package com.xinyuan.common.gis.wrapper;

import com.xinyuan.common.gis.wrapper.Point;

import java.util.ArrayList;
import java.util.List;

/**
 * 区域信息 主要封装类路径下的"region.json"中区域信息
 */
public class Region {

    /**
     * 区域对应坐标集合 如果为点区域则只有一个坐标，如果为线则有2个坐标,大于2个坐标集合则为面区域
     */
    private List<Point> pointList = new ArrayList<>();

    /*区域名称*/
    private String name;

    /*区域对应代码*/
    private String code;

    /*区域等级*/
    private int level;

    public List<Point> getPointList() {
        return pointList;
    }

    public void setPointList(List<Point> pointList) {
        this.pointList = pointList;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public RegionType getRegionType() {
        int pointSize = pointList.size();
        switch (pointSize) {
            case 0 :
                throw new IllegalArgumentException("未找到对应点坐标信息，请检查区域数据设置");
            case 1 :
                return RegionType.POINT;
            case 2:
                return RegionType.LINE;
            default:
               return RegionType.POLYGON;
        }
    }

    public enum RegionType {
        POINT, LINE, POLYGON;
    }

    public enum RegionLevel {

        /*省*/
        PROVINCE(1),

        /*市*/
        CITY(2),

        /*地区*/
        AREA(3);

        public final int level;

        RegionLevel(int level) {
            this.level = level;
        }
    }
}
