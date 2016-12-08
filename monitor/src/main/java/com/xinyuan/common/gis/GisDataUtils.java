package com.xinyuan.common.gis;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

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
}
