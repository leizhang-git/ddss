package com.ddss.common.core.code;

/**
 * 错误码契约：业务错误码只需实现此接口，即可被全局异常处理器统一消费
 */
public interface ErrorCode {

    /**
     * 数字状态码（与 HTTP 语义对齐，前端按 code 分支）
     */
    int getCode();

    /**
     * 默认提示信息
     */
    String getMessage();
}
