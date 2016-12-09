package com.xinyuan.web.controller;

import com.xinyuan.common.gis.Factor;
import com.xinyuan.common.gis.StatData;
import com.xinyuan.common.gis.config.ConfigLoader;
import com.xinyuan.common.gis.utils.GisDataUtils;
import com.xinyuan.common.gis.utils.GisDataWrapper;
import com.xinyuan.common.gis.utils.Region;
import com.xinyuan.common.utils.HazeDateUtils;
import com.xinyuan.common.utils.HazeStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 系统 Home Controller
 */
@Controller
public class HomeController {

    @Autowired
    private ConfigLoader configLoader;

    @RequestMapping(value = "/")
    public String index(Model model) {
        model.addAttribute("config", configLoader);
        model.addAttribute("factors", Factor.values());
        model.addAttribute("regions", ConfigLoader.getRegionByLevel(Region.RegionLevel.AREA.level));
        GisDataUtils.clearAllCache();
        return "index";
    }


    @RequestMapping(value = "/show/{type}")
    public String showFactor(Model model, @PathVariable String type) {
        //计算当天日期 然后算出近20天内数据
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
        model.addAttribute("title", Factor.valueOf(type).getTitle());
        model.addAttribute("config", configLoader);
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


    /**
     * 显示所有重点保障区
     *
     * @param model
     * @return
     */
    @RequestMapping("/showAreaRegion")
    public String showAreaRegion(Model model) {
        //加载所有区域信息
        model.addAttribute("regions", ConfigLoader.getRegionByLevel(Region.RegionLevel.AREA.level));
        model.addAttribute("level", Region.RegionLevel.AREA.level);
        model.addAttribute("config", configLoader);
        return "areaRegions";
    }

    /**
     * 显示所有城市信息
     *
     * @param model
     * @return
     */
    @RequestMapping("/showCityRegion")
    public String showCityRegion(Model model) {
        //加载所有城市信息
        model.addAttribute("regions", ConfigLoader.getRegionByLevel(Region.RegionLevel.CITY.level));
        model.addAttribute("level", Region.RegionLevel.CITY.level);
        model.addAttribute("regionCode", "");
        model.addAttribute("factors", Factor.values());
        model.addAttribute("config", configLoader);
        return "showCityRegion";
    }

    @RequestMapping("/showRegion")
    public String showRegion(String regionCode, Model model) {
        model.addAttribute("regionCode", regionCode);
        model.addAttribute("factors", Factor.values());
        model.addAttribute("config", configLoader);
        return "showRegion";
    }


    /**
     * 获取区域信息
     * @param regionCode
     * @param model
     * @return
     */
    @RequestMapping("/getRegion")
    @ResponseBody
    public Region getRegion(String regionCode, Model model) {
        return ConfigLoader.getRegion(regionCode);
    }

    @RequestMapping("/getRegions")
    @ResponseBody
    public List<Region> getRegions(int level, Model model) {
        return ConfigLoader.getRegionByLevel(level);
    }

    /**
     * 根据要素和区域信息获取各要素数据信息
     *
     * @param regionCode 区域信息 可以为空
     * @param factor     要素 不能为空
     * @return
     */
    @RequestMapping("/getRegionData")
    @ResponseBody
    public List<StatData> getRegionData(String regionCode, Factor factor) throws Exception {
        //获取远程数据信息
        List<GisDataWrapper> gisDataWrapperList = GisDataUtils.getFactorData(configLoader, factor, regionCode, new Date());
        List<StatData> dataList = GisDataUtils.getFactorData(factor, gisDataWrapperList);
        return dataList;
    }

    /**
     * 根据要素和区域信息获取各要素场图信息
     *
     * @param regionCode 区域信息 可以为空
     * @param factor     要素 不能为空
     * @return
     */
    @RequestMapping("/getRegionPicture")
    @ResponseBody
    public Map<String, List<?>> getRegionPicture(String regionCode, Factor factor) throws Exception {
        Map<String, List<?>> result = new HashMap<>();
        List<String> pictureList = new ArrayList<>();
        //获取远程图片
        List<GisDataWrapper> gisPictureWrapperList = GisDataUtils.getFactorPicture(configLoader, factor, regionCode, new Date());
        //处理图片
        if (gisPictureWrapperList != null && !gisPictureWrapperList.isEmpty()) {
            GisDataWrapper pictureData = gisPictureWrapperList.get(0);
            if (pictureData.getTotalData() > 0) {
                for (Map<String, Object> stringObjectMap : pictureData.getDatas()) {
                    pictureList.add((String) stringObjectMap.get("pictureUrl"));
                }
            }
        }
        result.put("picture", pictureList);
        return result;
    }


    /**
     * 根据要素和区域信息获取各要素数据信息
     *
     * @param regionCode 区域信息 可以为空
     * @param factor     要素 不能为空
     * @return
     */
    @RequestMapping("/getRegionData1")
    @ResponseBody
    public Map<String, List<?>> getRegionData1(String regionCode, Factor factor) throws Exception {
        //获取远程数据信息
        List<GisDataWrapper> gisDataWrapperList = GisDataUtils.getFactorData(configLoader, factor, regionCode, new Date());
        List<StatData> dataList = GisDataUtils.getFactorData(factor, gisDataWrapperList);
        List<String> legend = new ArrayList<>();
        List<List<Object>> data = new ArrayList<>();
        //计算当前日期
        Date date = new Date();
        date = HazeDateUtils.setHours(date, 20);
        boolean b = false;
        for (StatData statData : dataList) {
            legend.add(statData.getTitle());
            List<?> data1 = statData.getData();
            //计算共需要多少个数组
            if (!b) {
                int length = data1.size();
                for (int i = 0; i < length; i++) {
                    List<Object> r = new ArrayList<>();
                    r.add(HazeDateUtils.format(HazeDateUtils.addHours(date, i), "MM/dd HH时"));
                    data.add(r);
                }
            }
            b = true;
        }
        for (int i = 0; i < data.size(); i++) {
            List<Object> datum = data.get(i);
            for (int j = 0; j < legend.size(); j++) {
                    datum.add(dataList.get(j).getData().get(i));
            }
        }
        Map<String, List<?>> result = new HashMap<>();
        result.put("legend", legend);
        result.put("data", data);
        List<String> factorList = new ArrayList<>();
        String title = "";
        if (HazeStringUtils.isNoneBlank(regionCode)) {
            title += "【" + ConfigLoader.getRegion(regionCode).getName() +"】";
        }
        title += factor.getTitle();
        factorList.add(title);
        result.put("factor", factorList);
        return result;
    }

    @RequestMapping("/getRegionCurrentData")
    @ResponseBody
    public List<String> getRegionCurrentData(String regionCode) throws Exception {
        //ji算当前时间点
        Date date = new Date();
        regionCode = null;
        int hour = Integer.parseInt(String.valueOf(HazeDateUtils.getFragmentInHours(date, Calendar.HOUR_OF_DAY)));
        int statHour = hour;
        if (hour < 20) {
            //取昨天时间
            date = HazeDateUtils.addDays(date, -1);
            statHour = (24 - 20) + hour;
        }
        String dateFormat = HazeDateUtils.format(date, "yyyy-MM-dd");
        List<String> result = new ArrayList<>();
        for (Factor factor : Factor.values()) {
            List<GisDataWrapper> gisDataWrapperList = GisDataUtils.getFactorData(configLoader, factor, regionCode, date);
            List<StatData> statDataList = GisDataUtils.getFactorData(factor, gisDataWrapperList);
            if (!statDataList.isEmpty()) {
                //取第一条数据
                StatData statData = statDataList.get(0);
                //循环数据
                if (!statData.getData().isEmpty() && statData.getData().size() >= (statHour - 1)) {
                    Object value = statData.getData().get(statHour - 1);
                    //存放到结果里面
                    result.add(statData.getTitle() + ":" + value);
                }
            }
        }
        return result;
    }
}
