package com.ddss.web.controller.common;

import com.ddss.common.constant.CacheConstants;
import com.ddss.common.constant.SystemConstants;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.redis.RedisCache;
import com.ddss.common.strategy.CaptchaResult;
import com.ddss.common.utils.sign.Base64;
import com.ddss.common.utils.uuid.IdUtils;
import com.ddss.framework.strategy.CaptchaStrategyContext;
import com.ddss.system.service.ISysConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.FastByteArrayOutputStream;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.imageio.ImageIO;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * 验证码操作处理（使用 Strategy 模式）
 *
 * @author ddss
 */
@RestController
public class CaptchaController {

    private static final Logger log = LoggerFactory.getLogger(CaptchaController.class);

    @Resource
    private CaptchaStrategyContext captchaStrategyContext;

    @Resource
    private RedisCache redisCache;

    @Resource
    private ISysConfigService configService;

    @GetMapping("/captchaImage")
    public AjaxResult getCode() {
        AjaxResult ajax = AjaxResult.success();
        boolean captchaEnabled = configService.selectCaptchaEnabled();
        // Redis 不可用时无法存储验证码，强制关闭
        if (captchaEnabled && redisCache.redisTemplate == null) {
            captchaEnabled = false;
        }
        ajax.put("captchaEnabled", captchaEnabled);
        if (!captchaEnabled) {
            return ajax;
        }

        String uuid = IdUtils.simpleUUID();
        String verifyKey = CacheConstants.CAPTCHA_CODE_KEY + uuid;

        CaptchaResult result = captchaStrategyContext.getStrategy().generate();
        if (result == null || result.getImage() == null) {
            return AjaxResult.error("验证码生成失败，请重试");
        }

        redisCache.setCacheObject(verifyKey, result.getVerifyCode(),
                SystemConstants.CAPTCHA_EXPIRATION, TimeUnit.MINUTES);

        try (FastByteArrayOutputStream os = new FastByteArrayOutputStream()) {
            boolean writeResult = ImageIO.write(result.getImage(), "jpg", os);
            if (!writeResult) {
                log.warn("图像写入失败，可能由于缺少对应的 ImageWriter 支持");
                return AjaxResult.error("图像编码失败");
            }
            ajax.put("uuid", uuid);
            ajax.put("img", Base64.encode(os.toByteArray()));
            ajax.put("math", result.getDisplayText());
        } catch (IOException e) {
            log.error("生成验证码图片异常", e);
            return AjaxResult.error(e.getMessage());
        }

        return ajax;
    }
}
