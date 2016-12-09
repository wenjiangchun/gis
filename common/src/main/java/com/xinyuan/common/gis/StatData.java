package com.xinyuan.common.gis;

import java.util.ArrayList;
import java.util.List;

/**
 * 统计数据信息 主要用于前台统计图
 * Created by Sofar on 2016/12/7.
 */
public class StatData {

    private String name;

    private String title;

    private List<?> data = new ArrayList<>();

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<?> getData() {
        return data;
    }

    public void setData(List<?> data) {
        this.data = data;
    }

    public StatData(String name, String title, List<?> data) {
        this.name = name;
        this.title = title;
        this.data = data;
    }

    public StatData() {
    }
}
