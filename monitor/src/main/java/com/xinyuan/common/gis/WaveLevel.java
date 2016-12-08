package com.xinyuan.common.gis;

/**
 * 海浪等级
 * Created by sofar on 16-12-4.
 */
public enum WaveLevel {

    ZERO(0, 0, 0, "无浪"),

    ONE(1, 0, 0.1, "微浪"),

    TWO(2, 0.1, 0.5, "小浪"),

    THREE(3, 0.5, 1.25, "轻浪"),

    FOUR(4, 1.25, 2.50, "中浪"),

    FIVE(5, 2.50, 4, "大浪"),

    SIX(6, 4, 6, "巨浪"),

    SEVEN(7, 6, 9, "狂浪"),

    EIGHT(8, 9, 14, "狂涛"),

    NINE(9, 14, Integer.MAX_VALUE, "怒涛");

    public final int level;

    public final double min;

    public final double max;

    public final String title;

    WaveLevel(int level, double min, double max, String title) {
        this.level = level;
        this.min = min;
        this.max = max;
        this.title = title;
    }

    public static WaveLevel getLevel(double value) {
        if (value < 0) {
            throw new IllegalArgumentException("参数错误，value应大于等于0");
        }
        for (WaveLevel waveLevel : WaveLevel.values()) {
            if (value <= waveLevel.max) {
                return waveLevel;
            }
        }
        return ZERO;
    }
}
