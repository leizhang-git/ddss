package com.ddss.common.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.lang.NonNull;

/**
 * 统一异常基类
 * @Auth zhanglei
 * @Date 2023/2/18 21:09
 */
public class SystemException extends MiddlewareException{

    private static final long serialVersionUID = 1L;

    private static final Logger log = LoggerFactory.getLogger(SystemException.class);

    private final ErrCode errCode;

    /**
     * @param errCode 错误编码
     */
    public SystemException(@NonNull ErrCode errCode) {
        super(errCode.getErrCode(), null, null);
        this.errCode = errCode;
    }

    /**
     * @param errCode    错误编码
     * @param errMessage 错误信息
     */
    public SystemException(@NonNull ErrCode errCode, @NonNull String errMessage) {
        super(errCode.getErrCode(), errMessage, null);
        this.errCode = errCode;
    }

    public SystemException(@NonNull ErrCode errCode, @NonNull String errMessage, @NonNull Throwable cause) {
        super(errCode.getErrCode(), errMessage, cause);
        this.errCode = errCode;
    }

    public SystemException(@NonNull ErrCode errCode, @NonNull Throwable cause) {
        super(errCode.getErrCode(), null, cause);
        this.errCode = errCode;
    }
}
