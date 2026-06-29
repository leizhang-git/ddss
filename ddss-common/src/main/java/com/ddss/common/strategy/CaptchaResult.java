package com.ddss.common.strategy;

import java.awt.image.BufferedImage;

public class CaptchaResult {

    private final String verifyCode;
    private final String displayText;
    private final BufferedImage image;

    public CaptchaResult(String verifyCode, String displayText, BufferedImage image) {
        this.verifyCode = verifyCode;
        this.displayText = displayText;
        this.image = image;
    }

    public String getVerifyCode() {
        return verifyCode;
    }

    public String getDisplayText() {
        return displayText;
    }

    public BufferedImage getImage() {
        return image;
    }
}
