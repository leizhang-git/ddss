package com.ddss.common.core.domain;

import com.ddss.common.constant.HttpStatus;
import com.ddss.common.core.code.ErrorCode;
import com.ddss.common.core.code.GlobalErrorCode;
import org.slf4j.MDC;

import java.io.Serializable;

/**
 * 统一响应契约（新代码一律用这个，取代 {@link AjaxResult}）
 * <p>
 * 字段名 code/msg/data 与 AjaxResult 序列化结构完全对齐，前端零改动；
 * 额外携带 traceId（取自 MDC，由 TraceIdFilter 生成），成功/失败响应皆可凭它检索全链路日志。
 *
 * @param <T> 业务数据类型
 */
public class R<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /** MDC 中的链路 ID key（TraceIdFilter 生产，这里消费） */
    public static final String TRACE_ID = "traceId";

    private int code;
    private String msg;
    private T data;
    private String traceId;

    public R() {
    }

    private R(int code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
        this.traceId = MDC.get(TRACE_ID);
    }

    public static <T> R<T> ok() {
        return ok(null);
    }

    public static <T> R<T> ok(T data) {
        return new R<>(HttpStatus.SUCCESS, "操作成功", data);
    }

    public static <T> R<T> ok(String msg, T data) {
        return new R<>(HttpStatus.SUCCESS, msg, data);
    }

    public static <T> R<T> fail(ErrorCode errorCode) {
        return new R<>(errorCode.getCode(), errorCode.getMessage(), null);
    }

    public static <T> R<T> fail(int code, String msg) {
        return new R<>(code, msg, null);
    }

    public static <T> R<T> fail(String msg) {
        return new R<>(GlobalErrorCode.SYSTEM_ERROR.getCode(), msg, null);
    }

    public boolean isSuccess() {
        return this.code == HttpStatus.SUCCESS;
    }

    public int getCode() {
        return code;
    }

    public String getMsg() {
        return msg;
    }

    public T getData() {
        return data;
    }

    public String getTraceId() {
        return traceId;
    }
}
