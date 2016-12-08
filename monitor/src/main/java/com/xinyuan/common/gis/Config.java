package com.xinyuan.common.gis;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class Config {

    @Value("${remote.data.url}")
    private String remoteUrl;

    @Value("${remote.picture.method}")
    private String pictureMethod;

    @Value("${remote.data.method}")
    private String dataMethod;

    public String getRemoteUrl() {
        return remoteUrl;
    }

    public void setRemoteUrl(String remoteUrl) {
        this.remoteUrl = remoteUrl;
    }

    public String getPictureMethod() {
        return pictureMethod;
    }

    public void setPictureMethod(String pictureMethod) {
        this.pictureMethod = pictureMethod;
    }

    public String getDataMethod() {
        return dataMethod;
    }

    public void setDataMethod(String dataMethod) {
        this.dataMethod = dataMethod;
    }
}
