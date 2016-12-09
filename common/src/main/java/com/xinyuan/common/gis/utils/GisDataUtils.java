package com.xinyuan.common.gis.utils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xinyuan.common.gis.Factor;
import com.xinyuan.common.gis.StatData;
import com.xinyuan.common.gis.StatResult;
import com.xinyuan.common.gis.WindLevel;
import com.xinyuan.common.gis.config.ConfigLoader;
import com.xinyuan.common.utils.HazeDateUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public final class GisDataUtils {

    /**
     * 获取统计列表中某个属性最大值,最小值和平均值
     * @param gisDataList 待统计的数据列表
     * @param property 数据列表中需要统计的字段
     * @param factor 统计对应要素 如海浪 海风等
     * @return 返回列表中字段最大 最小和平均值
     */
    public static StatResult getStatResult(List<Map<String, Object>> gisDataList, String property, Factor factor) {
        List<Double> resultList = new ArrayList<>(gisDataList.size());
        for (Map<String, Object> gisData : gisDataList) {
            BigDecimal bigDecimal = new BigDecimal(gisData.get(property).toString());
            resultList.add(bigDecimal.setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue());
        }

        //Collections.sort(resultList);
        StatResult result = new StatResult();
        //result.getResult().put(property + "Min", Collections.min(resultList).toString());
        result.getResult().put(property + "Max", Collections.max(resultList).toString());
        result.setFactor(factor);
        //计算平均值
       /* BigDecimal total = new BigDecimal(0);
        total.setScale(2);
        for (Double aDouble : resultList) {
            total = total.add(new BigDecimal(aDouble.toString()));
        }
        double avg = total.divide(new BigDecimal(resultList.size()), 2, BigDecimal.ROUND_HALF_UP).doubleValue();
        result.getResult().put(property + "Avg", String.valueOf(avg));*/
        return result;
    }

    /**
     * 获取统计列表中某个属性最大值,最小值和平均值
     * @param gisDataList 待统计的数据列表
     * @param factor 统计对应要素 如海浪 海风等
     * @return 返回列表中字段最大 最小和平均值
     */
    public static StatResult getWindStatResult(List<Map<String, Object>> gisDataList,  Factor factor) {
        //存放风速值
        List<BigDecimal> rapidList = new ArrayList<>(gisDataList.size());
        for (Map<String, Object> gisData : gisDataList) {
            //获取U10和V10
            double u10 = 0;
            double v10 = 0;
            if (gisData.get("u10") != null) {
                u10 = Double.valueOf(gisData.get("u10").toString());
            }
            if (gisData.get("v10") != null) {
                u10 = Double.valueOf(gisData.get("v10").toString());
            }
            //计算风向
            //double value = (Math.atan2(v10, u10)/Math.PI) * 180;
            //计算风速
            double rapid = Math.sqrt(u10 * u10 + v10 * v10);
            rapidList.add(new BigDecimal(rapid));
        }
        StatResult result = new StatResult();
        BigDecimal rapidMax = Collections.max(rapidList);
        result.getResult().put("rapidMax", rapidMax.setScale(2, BigDecimal.ROUND_HALF_UP));
        //风速等级
        result.getResult().put("level", WindLevel.getLevel(rapidMax.doubleValue()).level);
        //获取风速最大值所在的索引
        int index = rapidList.indexOf(rapidMax);
        Map<String, Object> gisDataMax = gisDataList.get(index);
        //计算风向
        double u10 = 0d;
        double v10 = 0d;
        if (gisDataMax.get("u10") != null) {
            u10 = Double.valueOf(gisDataMax.get("u10").toString());
        }
        if (gisDataMax.get("v10") != null) {
            v10 = Double.valueOf(gisDataMax.get("v10").toString());
        }
        //计算风向
        double value = (Math.atan2(v10, u10)/Math.PI) * 180;
        result.getResult().put("directionMax", new BigDecimal(value).setScale(2, BigDecimal.ROUND_HALF_UP));
        result.setFactor(factor);
        return result;
    }

    public static List<StatData> getFactorData(Factor factor, List<GisDataWrapper> gisDataWrapperList) {
        List<StatData> dataList = new ArrayList<>();
        if (gisDataWrapperList != null && !gisDataWrapperList.isEmpty()) {
            GisDataWrapper gisDataWrapper = gisDataWrapperList.get(0);
            if (gisDataWrapper.getTotalData() > 0) {
                switch (factor) {
                    case WAV:
                        //处理海浪数据 获取波高 波向
                        List<String> waveHeightList = new ArrayList<>(gisDataWrapper.getDatas().size());
                        //List<String> waveDirectionList = new ArrayList<>(gisDataWrapper.getDatas().size());
                        for (Map<String, Object> gisData : gisDataWrapper.getDatas()) {
                            waveHeightList.add(formatData(gisData.get("waveHeight").toString()));
                            //waveDirectionList.add(gisData.get("waveDirection").toString());
                        }
                        dataList.add(new StatData("波高","波高(m)",waveHeightList));
                        //dataList.add(new StatData("波向","波向",waveDirectionList));
                        break;
                    case CUR:
                        //处理海流 获取海流速海面高度
                        List<String> curRapidList = new ArrayList<>(gisDataWrapper.getDatas().size());
                        List<String> curHeightList = new ArrayList<>(gisDataWrapper.getDatas().size());
                        for (Map<String, Object> gisData : gisDataWrapper.getDatas()) {
                            //获取U10和V10
                            double u10 = 0;
                            double v10 = 0;
                            if (gisData.get("u") != null) {
                                u10 = Double.valueOf(gisData.get("u").toString());
                            }
                            if (gisData.get("v") != null) {
                                u10 = Double.valueOf(gisData.get("v").toString());
                            }
                            //计算海流速
                            double rapid = new BigDecimal(Math.sqrt(u10 * u10 + v10 * v10)).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
                            double waterSurfaceHeight = new BigDecimal(gisData.get("waterSurfaceHeight").toString()).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
                            curHeightList.add(String.valueOf(waterSurfaceHeight));
                            curRapidList.add(String.valueOf(rapid));
                        }
                        dataList.add(new StatData("海流速度","海流速度(m/s)",curRapidList));
                        dataList.add(new StatData("海面高度","海面高度(m)",curHeightList));
                        break;
                    case ICE:
                        //处理海冰 获取海冰厚度
                        List<String> iceThickList = new ArrayList<>(gisDataWrapper.getDatas().size());
                        for (Map<String, Object> gisData : gisDataWrapper.getDatas()) {
                            iceThickList.add(formatData(gisData.get("iceThick").toString()));
                        }
                        dataList.add(new StatData("海冰厚度","海冰厚度(m)",iceThickList));break;
                    case SSW:
                        //处理海风 获取风速风级
                        List<String> rapidList = new ArrayList<>(gisDataWrapper.getDatas().size());
                        List<String> levelList = new ArrayList<>(gisDataWrapper.getDatas().size());
                        for (Map<String, Object> gisData : gisDataWrapper.getDatas()) {
                            //获取U10和V10
                            double u10 = 0;
                            double v10 = 0;
                            if (gisData.get("u10") != null) {
                                u10 = Double.valueOf(gisData.get("u10").toString());
                            }
                            if (gisData.get("v10") != null) {
                                u10 = Double.valueOf(gisData.get("v10").toString());
                            }
                            //计算风速
                            double rapid = new BigDecimal(Math.sqrt(u10 * u10 + v10 * v10)).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
                            levelList.add(String.valueOf(WindLevel.getLevel(rapid).level));
                            rapidList.add(String.valueOf(rapid));
                        }
                        dataList.add(new StatData("风速","风速(m/s)",rapidList));
                        //dataList.add(new StatData("风级","风级",levelList));
                }
            }
        }
        return dataList;
    }

    private static String formatData(String value) {
        double formatValue = new BigDecimal(value).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
        return String.valueOf(formatValue);
    }


    public static final Map<String, Object> DATA_CACHE = new ConcurrentHashMap<>();

    private static final Logger LOGGER = LoggerFactory.getLogger(GisDataUtils.class);

    /**
     * 获取指定区域下面的要素数据信息
     * @param configLoader 配置类
     * @param factor 要素
     * @param region 区域代码
     * @param date  数据日期
     * @return
     * @throws Exception
     */
    public static List<GisDataWrapper> getFactorData(ConfigLoader configLoader, Factor factor, String region, Date date) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        String s = getRemoteData(factor, region, configLoader.getRemoteUrl(), configLoader.getDataMethod(), date);
        return mapper.readValue(s, new TypeReference<List<GisDataWrapper>>() {
        });
    }

    /**
     * 获取指定区域下面的要素图片信息
     * @param configLoader 配置类
     * @param factor 要素
     * @param region 区域代码
     * @param date  数据日期
     * @return
     * @throws Exception
     */
    public static List<GisDataWrapper> getFactorPicture(ConfigLoader configLoader, Factor factor, String region, Date date) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        String s = getRemoteData(factor, region, configLoader.getRemoteUrl(), configLoader.getPictureMethod(), date);
        return mapper.readValue(s, new TypeReference<List<GisDataWrapper>>() {
        });
    }

    private static synchronized String getRemoteData(Factor factor, String region, String remoteUrl, String methodName, Date date) throws Exception {
        //首先从缓存中加载 缓存Key=要素,日期,区域代码(如果有) 如WAV,2016-12-07,getData/getPicture,LNDLYC
        String cacheKey = factor + "," + HazeDateUtils.format(date, "yyyy-MM-dd") + "," + methodName;
        if (region != null) {
            cacheKey += "," + region;
        }
        if (GisDataUtils.DATA_CACHE.containsKey(cacheKey)) {
            String result = (String) GisDataUtils.DATA_CACHE.get(cacheKey);
            LOGGER.debug("命中缓存,从缓存中加载数据key=【{}】, value=【{}】", cacheKey, result);
            return result;
        }
        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {
            String url = remoteUrl;
            url += "?" + methodName;
            url += "&factor=" + factor.name();
            if (date != null) {
                url += "&date=" + HazeDateUtils.format(date, "yyyy-MM-dd");
            }
            if (StringUtils.isNoneBlank(region)) {
                url += "&region=" + region;
            }
            HttpGet httpget = new HttpGet(url);
            for (Header header : httpget.getAllHeaders()) {
                System.out.println(header.getName() + "," + header.getValue());
            }
            LOGGER.debug("Request URL= " + httpget.getRequestLine());
            ResponseHandler<String> responseHandler = new ResponseHandler<String>() {
                @Override
                public String handleResponse(
                        final HttpResponse response) throws IOException {
                    int status = response.getStatusLine().getStatusCode();
                    if (status >= 200 && status < 300) {
                        HttpEntity entity = response.getEntity();
                        return entity != null ? EntityUtils.toString(entity) : null;
                    } else {
                        throw new ClientProtocolException("Unexpected response status: " + status);
                    }
                }
            };
            String result = httpclient.execute(httpget, responseHandler);
            LOGGER.debug("Response=" + result);
            GisDataUtils.DATA_CACHE.put(cacheKey, result);
            return result;
        } finally {
            try {
                httpclient.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }

    /**
     * 清空所有数据缓存
     */
    public static void clearAllCache() {
        LOGGER.debug("清空全部缓存数据...");
        DATA_CACHE.clear();
        LOGGER.debug("缓存数据清空完毕");
    }
}
