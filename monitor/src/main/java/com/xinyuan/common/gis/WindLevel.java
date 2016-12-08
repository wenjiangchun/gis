package com.xinyuan.common.gis;

/**
 * 风速等级定义
 * Created by sofar on 16-12-4.
 */
public enum  WindLevel {

    ZERO(0, 0, 0.2, "无风"),

    ONE(1, 0.3, 1.5, "软风"),

    TWO(2, 0.6, 3.3, "清风"),

    THREE(3, 3.4, 5.4, "微风"),

    FOUR(4, 5.5, 7.9, "和风"),

    FIVE(5, 8.0, 10.7, "清劲风"),

    SIX(6, 10.8, 13.8, "强风"),

    SEVEN(7, 13.9, 17.1, "疾风"),

    EIGHT(8, 17.2, 20.7, "大风"),

    NINE(9, 20.8, 24.4, "烈风"),

    TEN(10, 24.5, 28.4, "狂风"),

    ELEVEN(11, 28.5, 32.6, "暴风"),

    TWELVE(12, 32.7, Integer.MAX_VALUE, "飓风");

    public final int level;

    public final double min;

    public final double max;

    public final String title;

    WindLevel(int level, double min, double max, String title) {
        this.level = level;
        this.min = min;
        this.max = max;
        this.title = title;
    }

    public static WindLevel getLevel(double value) {
        if (value < 0) {
            throw new IllegalArgumentException("参数错误，value应大于等于0");
        }
        for (WindLevel windLevel : WindLevel.values()) {
            if (value <= windLevel.max) {
                return windLevel;
            }
        }
        return ZERO;
    }
}
