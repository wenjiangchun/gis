package com.xinyuan.common.gis.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xinyuan.common.gis.wrapper.Region;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * 加载类路径下配置信息  同时获取区域配置信息
 */
@Component
public class ConfigLoader {

    private static final String REGION_JSON = "region.json";

    private static final Logger LOGGER = LoggerFactory.getLogger(ConfigLoader.class);

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

    public static List<Region> REGIONS = new ArrayList<>();

    static {
        ClassPathResource resource = new ClassPathResource(REGION_JSON);
        try(InputStream in = resource.getInputStream(); ByteArrayOutputStream out = new ByteArrayOutputStream(); ) {
            LOGGER.debug("读取区域设置信息,区域文件=【{}】", resource.getURL().getPath());
            byte[] buffer = new byte[1024];
            int len = -1;
            while ((len = in.read(buffer)) != -1) {
                out.write(buffer, 0, len);
            }
            String json = new String(out.toByteArray());
            ObjectMapper mapper = new ObjectMapper();
            REGIONS =  mapper.readValue(json, new TypeReference<List<Region>>() {});
            LOGGER.debug("读取区域设置信息完毕,共【{}】条数据", REGIONS.size());
        } catch (Exception e) {
            LOGGER.error("读取区域设置信息出错", e);
            e.printStackTrace();
        }
    }

    /**
     * 根据区域代码获取区域信息
     * @param code 区域代码
     * @return
     */
    public static Region getRegion(String code) {
        for (Region region : REGIONS) {
            if (region.getCode().equals(code)) {
                return region;
            }
        }
        throw new IllegalArgumentException("未找到对应区域代码信息,区域代码=" + code);
    }

    /**
     * 根据区域代码获取区域信息
     * @param level 区域等级
     * @return 该等级下区域列表信息
     */
    public static List<Region> getRegionByLevel(int level) {
        List<Region> regions = new ArrayList<>();
        for (Region region : REGIONS) {
            if (region.getLevel() == level) {
                regions.add(region);
            }
        }
        return regions;
    }
}
