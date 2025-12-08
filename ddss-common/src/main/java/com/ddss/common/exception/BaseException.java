package com.ddss.common.exception;

/**
 * @Auth zhanglei
 * @Date 2023/2/18 21:31
 */
public class BaseException extends RuntimeException{

    private static final long serialVersionUID = 1L;

    /**
     * 错误信息
     */
    private String message;

    /**
     * 错误编码
     */
    private String errCode;

    /**
     * 时间戳
     */
    private String createTime;

    /**
     * 请求Id
     */
    private String traceId;


    private Throwable cause;

    public BaseException(String message, String errCode, String createTime, String traceId, Throwable cause) {
        this.message = message;
        this.errCode = errCode;
        this.createTime = createTime;
        this.traceId = traceId;
        this.cause = cause;
    }

    @Override
    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getErrCode() {
        return errCode;
    }

    public void setErrCode(String errCode) {
        this.errCode = errCode;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getTraceId() {
        return traceId;
    }

    public void setTraceId(String traceId) {
        this.traceId = traceId;
    }

    @Override
    public Throwable getCause() {
        return cause;
    }

    public void setCause(Throwable cause) {
        this.cause = cause;
    }

    @Override
    public String toString() {
        return "BaseException{" +
                "message='" + message + '\'' +
                ", errCode='" + errCode + '\'' +
                ", createTime='" + createTime + '\'' +
                ", traceId='" + traceId + '\'' +
                ", cause=" + cause +
                '}';
    }
}
