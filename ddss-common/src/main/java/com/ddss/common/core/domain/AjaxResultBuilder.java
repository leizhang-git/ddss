package com.ddss.common.core.domain;

import com.ddss.common.constant.HttpStatus;

public class AjaxResultBuilder {
    private int code;
    private String msg;
    private Object data;

    private AjaxResultBuilder() {
    }

    public static AjaxResultBuilder success() {
        AjaxResultBuilder builder = new AjaxResultBuilder();
        builder.code = HttpStatus.SUCCESS;
        builder.msg = "操作成功";
        return builder;
    }

    public static AjaxResultBuilder error() {
        AjaxResultBuilder builder = new AjaxResultBuilder();
        builder.code = HttpStatus.ERROR;
        builder.msg = "操作失败";
        return builder;
    }

    public static AjaxResultBuilder warn() {
        AjaxResultBuilder builder = new AjaxResultBuilder();
        builder.code = HttpStatus.WARN;
        return builder;
    }

    public AjaxResultBuilder code(int code) {
        this.code = code;
        return this;
    }

    public AjaxResultBuilder msg(String msg) {
        this.msg = msg;
        return this;
    }

    public AjaxResultBuilder data(Object data) {
        this.data = data;
        return this;
    }

    public AjaxResultBuilder put(String key, Object value) {
        if (this.data == null) {
            this.data = new java.util.HashMap<String, Object>();
        }
        if (this.data instanceof java.util.Map) {
            @SuppressWarnings("unchecked")
            java.util.Map<String, Object> map = (java.util.Map<String, Object>) this.data;
            map.put(key, value);
        }
        return this;
    }

    public AjaxResult build() {
        return new AjaxResult(code, msg, data);
    }
}
