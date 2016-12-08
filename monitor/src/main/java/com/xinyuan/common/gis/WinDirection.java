package com.xinyuan.common.gis;


public enum WinDirection {

    NORTH(-22.5, 22.5, "正北"),

    NORTH_EAST(22.5, 67.5, "东北"),

    EAST(67.5, 112.5, "正东"),

    SOUTH_EAST(112.5, 157.5, "东南"),

    SOUTH(157.5, -157.5, "正南"),

    SOUTH_WEST(-157.5, -112.5, "西南"),

    WEST(-112.5, -67.5, "正西"),

    NORTH_WEST(-67.5, -22.5, "西北");


    private double x;

    private double y;

    private String directionTitle;

    WinDirection(double x, double y, String directionTitle) {
        this.x = x;
        this.y = y;
        this.directionTitle = directionTitle;
    }
}
