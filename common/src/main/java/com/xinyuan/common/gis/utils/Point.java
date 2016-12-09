package com.xinyuan.common.gis.utils;

/**
 * 坐标点
 *
 * Created by Sofar on 2016/12/6.
 */
public class Point {

    private String x;

    private String y;

    public String getX() {
        return x;
    }

    public void setX(String x) {
        this.x = x;
    }

    public String getY() {
        return y;
    }

    public void setY(String y) {
        this.y = y;
    }

    @Override
    public String toString() {
        return "Point{" +
                "x='" + x + '\'' +
                ", y='" + y + '\'' +
                '}';
    }
}

