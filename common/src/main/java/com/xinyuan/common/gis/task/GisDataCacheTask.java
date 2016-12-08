package com.xinyuan.common.gis.task;

import com.xinyuan.common.gis.utils.GisDataUtils;
import com.xinyuan.common.utils.HazeDateUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Date;

/**
 * 定时管理缓存数据
 *
 * Created by sofar on 16-12-8.
 */
@Component
public class GisDataCacheTask {

    private static final Logger LOGGER = LoggerFactory.getLogger(GisDataCacheTask.class);

    @Scheduled(cron = "0 0/1 * * * ?")
    public void clearCache() {
        String preWeekDay = HazeDateUtils.format(HazeDateUtils.addDays(new Date(), -7), "yyyy-MM-dd");
        //获取一周前的时间点
        LOGGER.debug("定时任务执行,开始清理过期缓存数据,指定日期【{}】", preWeekDay);
        int count = 0;
        for (String key : GisDataUtils.DATA_CACHE.keySet()) {
            if (key.contains(preWeekDay)) {
                //GisDataUtils.DATA_CACHE.remove(key);
                count += 1;
            }
        }
        LOGGER.debug("清理过期缓存数据完毕,共清除【{}】条数据", count);
    }
}
