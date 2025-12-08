package com.ddss.config.i18n;

import cn.hutool.core.util.StrUtil;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Component;

import java.util.Locale;

@Component
public class MessageUtils implements ApplicationContextAware {

    private static MessageSource messageSource;

    public static String getMessage(String code) {
        return getMessage(code, null, String.valueOf(code), getLocale());
    }

    public static String getMessage(String code, Object[] args) {
        return getMessage(code, args, code, getLocale());
    }

    public static String getMessage(String cpde, Object[] args, String defaultMessage, Locale locale) {
        if(messageSource == null) {
            return defaultMessage;
        } else {
            if(locale == null) {
                locale = getLocale();
            }
            String message = messageSource.getMessage(cpde, args, defaultMessage, locale);
            if(StrUtil.isEmpty(message)) {
                message = defaultMessage;
            }
            return message;
        }
    }

    private static Locale getLocale() {
        String locale = "";
        if(StrUtil.isEmpty(locale)) {
            return new Locale(Locale.SIMPLIFIED_CHINESE.getLanguage(), Locale.SIMPLIFIED_CHINESE.getCountry());
        } else {
            return new Locale(locale, locale);
        }
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        messageSource = applicationContext.getBean(MessageSource.class);
    }
}
