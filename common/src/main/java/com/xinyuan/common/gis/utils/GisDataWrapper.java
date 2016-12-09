package com.xinyuan.common.gis.utils;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import java.util.List;
import java.util.Map;

/**
 * 远程调用返回数据格式包装类
 */
@JsonSerialize
public class GisDataWrapper {

    /*具体返回数据*/
    private List<Map<String, Object>> datas;

    /*返回结果*/
    private String result;

    /*数据总条数*/
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

    @Override
    public String toString() {
        return "GisDataWrapper{" +
                "datas=" + datas +
                ", result='" + result + '\'' +
                ", totalData=" + totalData +
                '}';
    }
}
