package com.ddss.framework.strategy;

import com.ddss.common.strategy.CaptchaResult;
import com.ddss.common.strategy.CaptchaStrategy;
import com.google.code.kaptcha.Producer;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

@Component("charCaptchaStrategy")
public class CharCaptchaStrategy implements CaptchaStrategy {

    @Resource(name = "captchaProducer")
    private Producer captchaProducer;

    @Override
    public CaptchaResult generate() {
        String capText = captchaProducer.createText();
        return new CaptchaResult(capText, capText, captchaProducer.createImage(capText));
    }
}
