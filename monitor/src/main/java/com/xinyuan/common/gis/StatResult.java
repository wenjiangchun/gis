package com.xinyuan.common.gis;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 统计结果封装类
 */
public class StatResult {

    /*对应要素*/
    private Factor factor;

    /*时间段描述*/
    private String dateSection;

    private Map<String, Object> result = new LinkedHashMap<>();

    public Factor getFactor() {
        return factor;
    }

    public void setFactor(Factor factor) {
        this.factor = factor;
    }

    public String getDateSection() {
        return dateSection;
    }

    public void setDateSection(String dateSection) {
        this.dateSection = dateSection;
    }

    public Map<String, Object> getResult() {
        return result;
    }

    public void setResult(Map<String, Object> result) {
        this.result = result;
    }
}
