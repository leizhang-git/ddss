package com.ddss.framework.strategy;

import com.ddss.common.strategy.CaptchaResult;
import com.ddss.common.strategy.CaptchaStrategy;
import com.google.code.kaptcha.Producer;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

@Component("mathCaptchaStrategy")
public class MathCaptchaStrategy implements CaptchaStrategy {

    @Resource(name = "captchaProducerMath")
    private Producer captchaProducerMath;

    @Override
    public CaptchaResult generate() {
        String capText = captchaProducerMath.createText();
        int splitIndex = capText.lastIndexOf("@");
        String displayText = capText.substring(0, splitIndex);
        String verifyCode = capText.substring(splitIndex + 1);
        return new CaptchaResult(verifyCode, displayText, captchaProducerMath.createImage(displayText));
    }
}
