package com.ddss.framework.web.exception;

import com.ddss.common.constant.HttpStatus;
import com.ddss.common.core.code.GlobalErrorCode;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.domain.R;
import com.ddss.common.core.text.Convert;
import com.ddss.common.exception.DemoModeException;
import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.common.utils.html.EscapeUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.BindException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingPathVariableException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import javax.servlet.http.HttpServletRequest;
import javax.validation.ConstraintViolationException;
import java.util.ArrayList;
import java.util.List;

/**
 * 全局异常处理器
 *
 * <p>三个设计点：
 * <ol>
 * <li><b>traceId 全链路</b>——vtrace 即 TraceIdFilter 写入 MDC 的 traceId，
 * 一次请求从入口到异常一个 ID 串到底，前端凭响应体 vtrace / 响应头 X-Trace-Id 检索全链路日志；</li>
 * <li><b>异常链摘要</b>——cause 链前 5 层摘要入日志，防止 cause 被截断吞掉（iuap 思路）；</li>
 * <li><b>安全兜底</b>——未知异常不把 e.getMessage() 回传前端（可能含 SQL/内部路径），
 * 统一返回"系统繁忙"，细节只进日志。</li>
 * </ol>
 */
@RestControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * cause 链摘要的最大层数
     */
    private static final int CAUSE_DETAIL_MAX_DEPTH = 5;

    /**
     * AjaxResult 中携带链路 ID 的 key（值 = MDC traceId，与 X-Trace-Id 响应头一致）
     */
    public static final String VTRACE_KEY = "vtrace";

    /**
     * 权限校验异常
     */
    @ExceptionHandler(AccessDeniedException.class)
    public AjaxResult handleAccessDeniedException(AccessDeniedException e, HttpServletRequest request) {
        log.error("请求地址'{}',权限校验失败", request.getRequestURI());
        return fail(GlobalErrorCode.FORBIDDEN, request);
    }

    /**
     * 请求方式不支持
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public AjaxResult handleHttpRequestMethodNotSupported(HttpRequestMethodNotSupportedException e,
                                                          HttpServletRequest request) {
        log.error("请求地址'{}',不支持'{}'请求", request.getRequestURI(), e.getMethod());
        return fail(GlobalErrorCode.METHOD_NOT_ALLOWED, request);
    }

    /**
     * 报文不可读（json 解析失败/参数体格式错）
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public AjaxResult handleHttpMessageNotReadable(HttpMessageNotReadableException e, HttpServletRequest request) {
        log.error("请求地址'{}',JSON报文解析失败.", request.getRequestURI(), e);
        return fail(GlobalErrorCode.MESSAGE_NOT_READABLE, request);
    }

    /**
     * 单参数校验异常（@Validated + @RequestParam/@PathVariable 上的约束注解）
     */
    @ExceptionHandler(ConstraintViolationException.class)
    public AjaxResult handleConstraintViolationException(ConstraintViolationException e, HttpServletRequest request) {
        log.error("请求地址'{}',参数校验失败'{}'", request.getRequestURI(), e.getMessage());
        AjaxResult result = AjaxResult.error(StringUtils.format("请求参数校验失败:[{}]", e.getMessage()));
        return decorate(result);
    }

    /**
     * 业务异常（ServiceException 可携带 ErrorCode，见 ServiceException(ErrorCode)）
     */
    @ExceptionHandler(ServiceException.class)
    public AjaxResult handleServiceException(ServiceException e, HttpServletRequest request) {
        log.error("请求地址'{}',业务异常: {}", request.getRequestURI(), e.getMessage(), e);
        Integer code = e.getCode();
        AjaxResult result = StringUtils.isNotNull(code)
                ? AjaxResult.error(code, e.getMessage())
                : AjaxResult.error(e.getMessage());
        return decorate(result);
    }

    /**
     * 请求路径中缺少必需的路径变量
     */
    @ExceptionHandler(MissingPathVariableException.class)
    public AjaxResult handleMissingPathVariableException(MissingPathVariableException e, HttpServletRequest request) {
        log.error("请求路径中缺少必需的路径变量'{}',发生系统异常.", request.getRequestURI(), e);
        AjaxResult result = AjaxResult.error(String.format("请求路径中缺少必需的路径变量[%s]", e.getVariableName()));
        return decorate(result);
    }

    /**
     * 请求参数类型不匹配
     */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public AjaxResult handleMethodArgumentTypeMismatchException(MethodArgumentTypeMismatchException e, HttpServletRequest request) {
        String value = Convert.toStr(e.getValue());
        if (StringUtils.isNotEmpty(value)) {
            value = EscapeUtil.clean(value);
        }
        log.error("请求地址'{}',请求参数类型不匹配.", request.getRequestURI());
        AjaxResult result = AjaxResult.error(String.format("请求参数类型不匹配，参数[%s]要求类型为：'%s'，但输入值为：'%s'",
                e.getName(), e.getRequiredType().getName(), value));
        return decorate(result);
    }

    /**
     * 拦截未知的运行时异常——细节只进日志，前端只拿统一提示 + traceId
     */
    @ExceptionHandler(RuntimeException.class)
    public AjaxResult handleRuntimeException(RuntimeException e, HttpServletRequest request) {
        log.error("请求地址'{}',发生未知异常.", request.getRequestURI(), e);
        return fail(GlobalErrorCode.SYSTEM_ERROR, request, e);
    }

    /**
     * 系统异常——细节只进日志，前端只拿统一提示 + traceId
     */
    @ExceptionHandler(Exception.class)
    public AjaxResult handleException(Exception e, HttpServletRequest request) {
        log.error("请求地址'{}',发生系统异常.", request.getRequestURI(), e);
        return fail(GlobalErrorCode.SYSTEM_ERROR, request, e);
    }

    /**
     * 表单绑定校验异常
     */
    @ExceptionHandler(BindException.class)
    public AjaxResult handleBindException(BindException e) {
        log.error("参数绑定校验失败: {}", e.getMessage(), e);
        String message = !e.getAllErrors().isEmpty() ? e.getAllErrors().get(0).getDefaultMessage() : e.getMessage();
        AjaxResult result = AjaxResult.error(message);
        return decorate(result);
    }

    /**
     * @RequestBody 校验异常
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Object handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        log.error("请求体校验失败: {}", e.getMessage(), e);
        String message = e.getBindingResult().getFieldErrors().stream()
                .findFirst().map(fe -> fe.getDefaultMessage()).orElse(e.getMessage());
        AjaxResult result = AjaxResult.error(message);
        return decorate(result);
    }

    /**
     * 演示模式异常
     */
    @ExceptionHandler(DemoModeException.class)
    public AjaxResult handleDemoModeException(DemoModeException e) {
        return fail(GlobalErrorCode.DEMO_MODE, null);
    }

    /**
     * 错误码响应（不带异常链日志）
     */
    private AjaxResult fail(GlobalErrorCode errorCode, HttpServletRequest request) {
        AjaxResult result = AjaxResult.error(errorCode.getCode(), errorCode.getMessage());
        return decorate(result);
    }

    /**
     * 错误码响应 + cause 链摘要入日志（兜底异常用，方便按 traceId 追因）
     */
    private AjaxResult fail(GlobalErrorCode errorCode, HttpServletRequest request, Exception e) {
        log.error("vtrace={} 异常链摘要: {}", vtrace(),
                StringUtils.join(exCauseMsgChain(e, CAUSE_DETAIL_MAX_DEPTH), " -> "));
        AjaxResult result = AjaxResult.error(errorCode.getCode(), errorCode.getMessage());
        return decorate(result);
    }

    /**
     * 回填链路 ID（与响应头 X-Trace-Id、R.traceId 同源）
     */
    private AjaxResult decorate(AjaxResult result) {
        return result.put(VTRACE_KEY, vtrace());
    }

    private String vtrace() {
        String traceId = MDC.get(R.TRACE_ID);
        return StringUtils.isNotEmpty(traceId) ? traceId : "n/a";
    }

    /**
     * cause 链摘要（取前 maxDepth 层消息，相邻重复去重，避免自引用刷屏）
     */
    private List<String> exCauseMsgChain(Throwable t, int maxDepth) {
        List<String> msgs = new ArrayList<>();
        if (t.getMessage() != null) {
            msgs.add(t.getMessage());
        }
        Throwable cause = t.getCause();
        int depth = 1;
        while (cause != null && depth < maxDepth) {
            String msg = cause.getMessage();
            if (msg != null && (msgs.isEmpty() || !StringUtils.equals(msg, msgs.get(msgs.size() - 1)))) {
                msgs.add(msg);
            }
            cause = cause.getCause();
            depth++;
        }
        return msgs;
    }
}
