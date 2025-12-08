package com.ddss.web.controller.common;

import com.ddss.common.config.DdssConfig;
import com.ddss.common.constant.CacheConstants;
import com.ddss.common.constant.SystemConstants;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.redis.RedisCache;
import com.ddss.common.utils.sign.Base64;
import com.ddss.common.utils.uuid.IdUtils;
import com.ddss.system.service.ISysConfigService;
import com.google.code.kaptcha.Producer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.FastByteArrayOutputStream;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletResponse;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * 验证码操作处理
 *
 * @author ruoyi
 */
@RestController
public class CaptchaController {

    private static final Logger log = LoggerFactory.getLogger(CaptchaController.class);

    @Resource(name = "captchaProducer")
    private Producer captchaProducer;

    @Resource(name = "captchaProducerMath")
    private Producer captchaProducerMath;

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private ISysConfigService configService;

    /**
     * 生成验证码
     */
    @GetMapping("/captchaImage")
    public AjaxResult getCode(HttpServletResponse response) throws IOException {
        AjaxResult ajax = AjaxResult.success();
        boolean captchaEnabled = configService.selectCaptchaEnabled();
        ajax.put("captchaEnabled", captchaEnabled);
        if (!captchaEnabled) {
            return ajax;
        }

        // 保存验证码信息
        String uuid = IdUtils.simpleUUID();
        String verifyKey = CacheConstants.CAPTCHA_CODE_KEY + uuid;

        String displayText = null;
        String verifyCode = null;
        BufferedImage image = null;

        // 生成验证码
        String captchaType = DdssConfig.getCaptchaType();
        if ("math".equals(captchaType)) {
            String capText = captchaProducerMath.createText();
            int splitIndex = capText.lastIndexOf("@");
            if (splitIndex == -1 || splitIndex >= capText.length() - 1) {
                return AjaxResult.error("验证码生成失败，请联系管理员");
            }
            displayText = capText.substring(0, splitIndex);
            verifyCode = capText.substring(splitIndex + 1);
            image = captchaProducerMath.createImage(displayText);
        } else if ("char".equals(captchaType)) {
            displayText = verifyCode = captchaProducer.createText();
            image = captchaProducer.createImage(displayText);
        } else {
            return AjaxResult.error("不支持的验证码类型：" + captchaType);
        }

        if (image == null) {
            return AjaxResult.error("验证码图片生成失败，请重试");
        }

        redisCache.setCacheObject(verifyKey, verifyCode, SystemConstants.CAPTCHA_EXPIRATION, TimeUnit.MINUTES);

        // 转换流信息写出
        try (FastByteArrayOutputStream os = new FastByteArrayOutputStream()) {
            boolean result = ImageIO.write(image, "jpg", os);
            if (!result) {
                log.warn("图像写入失败，可能由于缺少对应的 ImageWriter 支持");
                return AjaxResult.error("图像编码失败");
            }
            ajax.put("uuid", uuid);
            ajax.put("img", Base64.encode(os.toByteArray()));
        } catch (IOException e) {
            log.error("生成验证码图片异常", e);
            return AjaxResult.error(e.getMessage());
        }

        return ajax;
    }

}
