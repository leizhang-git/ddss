package com.ddss.framework.web.filter;

import com.ddss.common.core.domain.R;
import com.ddss.common.utils.StringUtils;
import org.slf4j.MDC;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * 链路追踪过滤器：一次请求一个 traceId，从 HTTP 入口贯穿到日志、响应体、异步线程
 * <p>
 * 1. 上游服务带 X-Trace-Id 请求头则续链（跨服务链路串联），否则生成 8 位短 ID；
 * 2. 写入 MDC，本请求内所有日志自动携带（logback pattern %X{traceId}）；
 * 3. 响应头回传 X-Trace-Id，前端报错凭它检索后端全链路日志；
 * 4. finally 清理 MDC（Servlet 容器线程池复用，防止串号）。
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class TraceIdFilter implements Filter {

    public static final String TRACE_HEADER = "X-Trace-Id";
    private static final Pattern SAFE_TRACE_ID = Pattern.compile("[A-Za-z0-9._-]{1,64}");

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String traceId = req.getHeader(TRACE_HEADER);
        if (StringUtils.isEmpty(traceId) || !SAFE_TRACE_ID.matcher(traceId).matches()) {
            traceId = newTraceId();
        }
        MDC.put(R.TRACE_ID, traceId);
        resp.setHeader(TRACE_HEADER, traceId);
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.remove(R.TRACE_ID);
        }
    }

    /**
     * 8 位短 ID：日志可读、冲突率足够低（与 vtrace 同风格）
     */
    private String newTraceId() {
        return UUID.randomUUID().toString().substring(0, 8);
    }
}
