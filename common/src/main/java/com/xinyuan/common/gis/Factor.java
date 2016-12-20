package com.xinyuan.common.gis;

/**
 * 要素枚举类
 */
public enum Factor {


    SSW("海风"),
    WAV("海浪"),

    //TID("潮汐"),

    CUR("海流"),

    ICE("海冰");

    public final String title;

    Factor(String title) {
        this.title = title;
    }

    public String getTitle() {
        return title;
    }
}
