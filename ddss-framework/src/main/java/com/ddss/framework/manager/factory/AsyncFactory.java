package com.ddss.framework.manager.factory;

import java.util.TimerTask;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.ddss.common.constant.SystemConstants;
import com.ddss.common.utils.LogUtils;
import com.ddss.common.utils.ServletUtils;
import com.ddss.common.utils.StringUtils;
import com.ddss.common.utils.ip.AddressUtils;
import com.ddss.common.utils.ip.IpUtils;
import com.ddss.common.utils.spring.SpringUtils;
import com.ddss.system.domain.SysLogininfor;
import com.ddss.system.domain.SysOperLog;
import com.ddss.system.service.ISysLogininforService;
import com.ddss.system.service.ISysOperLogService;
import eu.bitwalker.useragentutils.UserAgent;

import javax.servlet.http.HttpServletRequest;

/**
 * 异步工厂（产生任务用）
 *
 * @author ruoyi
 */
public class AsyncFactory {

    private static final Logger sys_user_logger = LoggerFactory.getLogger(AsyncFactory.class);

    /**
     * 记录登录信息
     *
     * @param username 用户名
     * @param status   状态
     * @param message  消息
     * @param args     列表
     * @return 任务task
     */
    public static TimerTask recordLogininfor(final String username, final String status, final String message,
                                             final Object... args) {
        HttpServletRequest request = ServletUtils.getRequest();
        final String ip = IpUtils.getIpAddr(request);
        final UserAgent userAgent = UserAgent.parseUserAgentString(request.getHeader("User-Agent"));

        return new TimerTask() {
            @Override
            public void run() {
                try {
                    String address = AddressUtils.getRealAddressByIP(ip);

                    // 构建日志块
                    String logBlock = LogUtils.getBlock(ip) +
                            address +
                            LogUtils.getBlock(username) +
                            LogUtils.getBlock(status) +
                            LogUtils.getBlock(message);

                    // 打印信息到日志
                    sys_user_logger.info(logBlock, args);

                    // 安全地获取操作系统和浏览器信息
                    String os = getOperatingSystemName(userAgent);
                    String browser = getBrowserName(userAgent);

                    // 封装对象
                    SysLogininfor logininfor = new SysLogininfor();
                    logininfor.setUserName(username);
                    logininfor.setIpaddr(ip);
                    logininfor.setLoginLocation(address);
                    logininfor.setBrowser(browser);
                    logininfor.setOs(os);
                    logininfor.setMsg(message);

                    // 设置状态字段
                    if (StringUtils.equalsAny(status, SystemConstants.LOGIN_SUCCESS, SystemConstants.LOGOUT, SystemConstants.REGISTER)) {
                        logininfor.setStatus(SystemConstants.SUCCESS);
                    } else if (SystemConstants.LOGIN_FAIL.equals(status)) {
                        logininfor.setStatus(SystemConstants.FAIL);
                    }

                    // 异步插入数据（假设支持）
                    SpringUtils.getBean(ISysLogininforService.class).insertLogininfor(logininfor);
                } catch (Exception e) {
                    sys_user_logger.error("Failed to record login info for user: {}", username, e);
                }
            }
        };
    }

    // 提取浏览器名称，避免空指针
    private static String getBrowserName(UserAgent userAgent) {
        if (userAgent == null || userAgent.getBrowser() == null) {
            return "Unknown";
        }
        return userAgent.getBrowser().getName();
    }

    // 提取操作系统名称，避免空指针
    private static String getOperatingSystemName(UserAgent userAgent) {
        if (userAgent == null || userAgent.getOperatingSystem() == null) {
            return "Unknown";
        }
        return userAgent.getOperatingSystem().getName();
    }


    /**
     * 操作日志记录
     *
     * @param operLog 操作日志信息
     * @return 任务task
     */
    public static TimerTask recordOper(final SysOperLog operLog) {
        return new TimerTask() {
            @Override
            public void run() {
                // 远程查询操作地点
                operLog.setOperLocation(AddressUtils.getRealAddressByIP(operLog.getOperIp()));
                SpringUtils.getBean(ISysOperLogService.class).insertOperlog(operLog);
            }
        };
    }
}
