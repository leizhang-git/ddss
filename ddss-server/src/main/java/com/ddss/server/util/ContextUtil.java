package com.ddss.server.util;


import com.ddss.server.context.IContextInfoProxy;

import java.util.Objects;

/**
 * @Describe
 * @Author zhanglei
 * @Date 2023/6/26 10:12
 */
public class ContextUtil {

    public static String getLogin() {
        Object login = IContextInfoProxy.getInstance().getContextAttribute("login");
        if(Objects.nonNull(login)) {
            return (String) login;
        }
        return null;
    }

    public static String getName() {
        Object name = IContextInfoProxy.getInstance().getContextAttribute("name");
        if(Objects.nonNull(name)) {
            return (String) name;
        }
        return null;
    }
}
