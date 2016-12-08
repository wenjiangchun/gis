package com.xinyuan.common.gis;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import java.util.List;
import java.util.Map;

@JsonSerialize
public class GisDataWrapper {

    private List<Map<String, Object>> datas;

    private String result;

    private int totalData;

    public List<Map<String, Object>> getDatas() {
        return datas;
    }

    public void setDatas(List<Map<String, Object>> datas) {
        this.datas = datas;
    }

    public String isResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public int getTotalData() {
        return totalData;
    }

    public void setTotalData(int totalData) {
        this.totalData = totalData;
    }
}
