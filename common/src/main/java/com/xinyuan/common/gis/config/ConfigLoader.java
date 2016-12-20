package com.xinyuan.common.gis.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xinyuan.common.gis.utils.BMapCoordConvertResult;
import com.xinyuan.common.gis.utils.Point;
import com.xinyuan.common.gis.utils.Region;
import com.xinyuan.common.utils.HazeHttpUtils;
import com.xinyuan.common.utils.HazeStringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.support.PropertiesLoaderUtils;
import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

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

    @Value("${bmap.url}")
    private String bMapUrl;

    @Value("${region.province.code}")
    private String provinceCode;

    public String getbMapUrl() {
        return bMapUrl;
    }

    public void setbMapUrl(String bMapUrl) {
        this.bMapUrl = bMapUrl;
    }

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

    public String getProvinceCode() {
        return provinceCode;
    }

    public void setProvinceCode(String provinceCode) {
        this.provinceCode = provinceCode;
    }

    public static final List<Region> REGIONS;

    private static final Properties defaultStrategies;

    static {
        ClassPathResource resource = new ClassPathResource(REGION_JSON);
        try(InputStream in = resource.getInputStream(); ByteArrayOutputStream out = new ByteArrayOutputStream(); ) {
            LOGGER.debug("加载区域设置信息,区域文件=【{}】", resource.getURL().getPath());
            byte[] buffer = new byte[1024];
            int len = -1;
            while ((len = in.read(buffer)) != -1) {
                out.write(buffer, 0, len);
            }
            String json = new String(out.toByteArray(), "UTF-8");
            ObjectMapper mapper = new ObjectMapper();
            REGIONS =  mapper.readValue(json, new TypeReference<List<Region>>() {});
            LOGGER.debug("加载区域设置信息完毕,共【{}】条数据", REGIONS.size());
        } catch (IOException e) {
            LOGGER.error("加载区域设置信息出错", e);
            throw new IllegalStateException("无法加载区域配置文件 '" + REGION_JSON +"': " + e.getMessage());
        }
        try {
            ClassPathResource applicationResources = new ClassPathResource("application.properties");
            LOGGER.debug("加载系统配置信息,配置文件=【{}】", applicationResources.getURL().getPath());
            defaultStrategies = PropertiesLoaderUtils.loadProperties(applicationResources);
            LOGGER.debug("加载系统配置信息完毕,配置文件内容=【{}】", defaultStrategies);
            //判断是否需要坐标转换
            String isConvert = defaultStrategies.getProperty("bmap.point.isConvert");
            if (isConvert != null && "1".equals(isConvert)) {
                //获取百度地图坐标转换URL
                String bMapConvertUrl = defaultStrategies.getProperty("bmap.convert.url");
                if (!REGIONS.isEmpty()) {
                    //批量执行坐标转换
                    LOGGER.debug("开始执行百度地图坐标转换...");
                    for (Region region : REGIONS) {
                        LOGGER.debug("区域【{}】, 原坐标信息=【{}】", region.getName(), region.getPointList());
                        if (!region.getPointList().isEmpty()) {
                            String params = "coords=";
                            for (Point point : region.getPointList()) {
                                params += point.getX() + "," + point.getY()+";";
                            }
                            //执行转换
                            try {
                                BMapCoordConvertResult result =  HazeHttpUtils.get(bMapConvertUrl + "&" + HazeStringUtils.removeEnd(params,";"),new TypeReference<BMapCoordConvertResult>(){});
                                if (result.getStatus() == 0) {
                                    region.setPointList(result.getResult());
                                }
                                LOGGER.debug("区域【{}】坐标转换成功，转换完坐标信息=【{}】", region.getName(), region.getPointList());
                            } catch (IOException e) {
                                LOGGER.warn("百度坐标转换错误，将使用未转换的数据坐标", e);
                            }

                        }
                    }
                    LOGGER.debug("百度地图坐标转换完毕");
                }
            }
        } catch (IOException e) {
            throw new IllegalStateException("无法加载配置文件 'application.properties': " + e.getMessage());
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
