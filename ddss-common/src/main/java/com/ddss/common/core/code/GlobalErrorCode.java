package com.ddss.common.core.code;

/**
 * 全局通用错误码
 * <p>业务域专属错误码各自建枚举实现 {@link ErrorCode}，不往这里堆
 */
public enum GlobalErrorCode implements ErrorCode {

    SUCCESS(200, "操作成功"),

    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "认证失败，无法访问系统资源"),
    FORBIDDEN(403, "没有访问权限"),
    NOT_FOUND(404, "资源不存在"),
    METHOD_NOT_ALLOWED(405, "请求方式不支持"),
    MESSAGE_NOT_READABLE(400, "请求报文格式错误，请检查提交的数据"),

    SYSTEM_ERROR(500, "系统繁忙，请稍后再试"),
    DEMO_MODE(403, "演示模式，不允许操作");

    private final int code;
    private final String message;

    GlobalErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    @Override
    public int getCode() {
        return code;
    }

    @Override
    public String getMessage() {
        return message;
    }
}
