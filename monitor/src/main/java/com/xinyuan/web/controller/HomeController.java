package com.xinyuan.web.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xinyuan.common.utils.HazeDateUtils;
import com.xinyuan.common.gis.config.ConfigLoader;
import com.xinyuan.common.gis.Factor;
import com.xinyuan.common.gis.utils.GisDataUtils;
import com.xinyuan.common.gis.utils.GisDataWrapper;
import com.xinyuan.common.gis.StatResult;
import com.xinyuan.common.gis.WaveLevel;
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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 系统 Home Controller
 */
@Controller
public class HomeController {

    private static final Logger LOGGER = LoggerFactory.getLogger(HomeController.class);

    @Autowired
    private ConfigLoader config;

    @RequestMapping(value = "/")
    public String index(Model model) {
        model.addAttribute("config", config);
        Date date = new Date();
        model.addAttribute("one", HazeDateUtils.format(date, "M月d日"));
        model.addAttribute("two", HazeDateUtils.format(HazeDateUtils.addDays(date, 1), "M月d日"));
        model.addAttribute("three", HazeDateUtils.format(HazeDateUtils.addDays(date, 2), "M月d日"));
        model.addAttribute("type", "INDEX");
        return "index";
    }


    @RequestMapping(value = "/show/{type}")
    public String seaWind(Model model, @PathVariable String type) {
        //计算当天日期 然后算出近一个月内数据
        Map<String, List<Date>> map = new LinkedHashMap<>();
        int totalDay = 20;
        Date date = new Date();
        getDays(map, date);
        for (int i = 1; i < totalDay; i++) {
            Date d = HazeDateUtils.addDays(date, -i);
            getDays(map, d);
        }
        model.addAttribute("days", map);
        model.addAttribute("factor", type);
        model.addAttribute("config", config);
        return "picture";
    }

    private void getDays(Map<String, List<Date>> map, Date date) {
        if (map.containsKey(String.valueOf(HazeDateUtils.getYear(date)))) {
            map.get(String.valueOf(HazeDateUtils.getYear(date))).add(date);
        } else {
            List<Date> days = new ArrayList<>();
            days.add(date);
            map.put(String.valueOf(HazeDateUtils.getYear(date)), days);
        }
    }

    private List<GisDataWrapper> getRemoteData(Factor factor, String region) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        String s = getData(factor, region);
        return mapper.readValue(s, new TypeReference<List<GisDataWrapper>>() {
        });
    }


    private String getData(Factor factor, String region) throws Exception {
        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {
            String url = config.getRemoteUrl();
            url += "?" + config.getDataMethod();
            url += "&factor=" + factor.name();
            //url += "&date=2016-12-01";
            url += "&date=" + HazeDateUtils.format(new Date(), "yyyy-MM-dd");
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
            return result;
        } finally {
            try {
                httpclient.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }


    private List<StatResult> getWAVData(String region) throws Exception {
        List<GisDataWrapper> list = getRemoteData(Factor.WAV, region);
        //处理海浪数据
        GisDataWrapper gisDataWrapper = list.get(0);
        //获取数据
        List<Map<String, Object>> gisDataList = gisDataWrapper.getDatas();
        List<StatResult> results = new ArrayList<>();
        if (!gisDataList.isEmpty()) {
            //获取第一天数据
            StatResult waveHeightResult1 = GisDataUtils.getStatResult(gisDataList.subList(0, 23), "waveHeight", Factor.WAV);
            waveHeightResult1.getResult().put("level", String.valueOf(WaveLevel.getLevel(Double.valueOf(waveHeightResult1.getResult().get("waveHeightMax").toString())).level));
            StatResult waveDirectionResult1 = GisDataUtils.getStatResult(gisDataList.subList(0, 23), "waveDirection", Factor.WAV);
            waveHeightResult1.getResult().put("waveDirectionMax", waveDirectionResult1.getResult().get("waveDirectionMax"));
            //获取第二天数据
            StatResult waveHeightResult2 = GisDataUtils.getStatResult(gisDataList.subList(24, 47), "waveHeight", Factor.WAV);
            waveHeightResult2.getResult().put("level", String.valueOf(WaveLevel.getLevel(Double.valueOf(waveHeightResult2.getResult().get("waveHeightMax").toString())).level));
            StatResult waveDirectionResult2 = GisDataUtils.getStatResult(gisDataList.subList(24, 47), "waveDirection", Factor.WAV);
            waveHeightResult2.getResult().put("waveDirectionMax", waveDirectionResult2.getResult().get("waveDirectionMax"));
            //获取第三天数据
            StatResult waveHeightResult3 = GisDataUtils.getStatResult(gisDataList.subList(48, 71), "waveHeight", Factor.WAV);
            waveHeightResult3.getResult().put("level", String.valueOf(WaveLevel.getLevel(Double.valueOf(waveHeightResult3.getResult().get("waveHeightMax").toString())).level));
            StatResult waveDirectionResult3 = GisDataUtils.getStatResult(gisDataList.subList(48, 71), "waveDirection", Factor.WAV);
            waveHeightResult3.getResult().put("waveDirectionMax", waveDirectionResult3.getResult().get("waveDirectionMax"));
            results.add(waveHeightResult1);
            results.add(waveHeightResult2);
            results.add(waveHeightResult3);
        }
        return results;
    }

    private List<StatResult> getTIDData(String region) throws IOException {
        List<StatResult> results = new ArrayList<>();
        //TODO  获取潮汐数据
        return results;
    }

    /**
     * 获取风速数据 主要包括风速 风向和等级
     *
     * @param region 区域代码
     * @return
     * @throws IOException
     */
    private List<StatResult> getSSWData(String region) throws Exception {
        List<GisDataWrapper> list = getRemoteData(Factor.SSW, region);
        //处理海风数据
        GisDataWrapper gisDataWrapper = list.get(0);
        //获取数据
        List<Map<String, Object>> gisDataList = gisDataWrapper.getDatas();
        List<StatResult> results = new ArrayList<>();
        if (!gisDataList.isEmpty()) {
            //获取第一天数据
            StatResult waveHeightResult1 = GisDataUtils.getWindStatResult(gisDataList.subList(0, 23), Factor.SSW);
            StatResult waveHeightResult2 = GisDataUtils.getWindStatResult(gisDataList.subList(24, 47), Factor.SSW);
            StatResult waveHeightResult3 = GisDataUtils.getWindStatResult(gisDataList.subList(48, 71),  Factor.SSW);

            results.add(waveHeightResult1);
            results.add(waveHeightResult2);
            results.add(waveHeightResult3);
        }
        return results;
    }

    /**
     * 获取当天统计数据信息
     *
     * @param region 区域代码
     * @return 以要素为key的3天数据信息
     * @throws Exception
     */
    @RequestMapping(value = "/getRemoteStatData")
    @ResponseBody
    public Map<String, List<StatResult>> getRemoteStatData(String region) throws Exception {
        List<StatResult> wavResult = getWAVData(region);
        List<StatResult> tidResult = getTIDData(region);
        List<StatResult> sswResult = getSSWData(region);
        Map<String, List<StatResult>> result = new LinkedHashMap<>(3);
        result.put(Factor.WAV.name(), wavResult);
        result.put(Factor.TID.name(), tidResult);
        result.put(Factor.SSW.name(), sswResult);
        return result;
    }
}
