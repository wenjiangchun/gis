package com.xinyuan.common.gis.utils;

import java.util.ArrayList;
import java.util.List;


public class BMapCoordConvertResult {

    private int status;

    private List<Point> result = new ArrayList<>();

    private String message;

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public List<Point> getResult() {
        return result;
    }

    public void setResult(List<Point> result) {
        this.result = result;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

}
